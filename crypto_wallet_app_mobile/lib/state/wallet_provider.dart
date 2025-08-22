import 'dart:async';
import 'package:crypto_wallet_app_mobile/constants/app_data_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
//import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
//import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'dart:convert';
import 'package:collection/collection.dart'; // For firstWhereOrNull
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Still needed for type hint
import 'package:crypto_wallet_app_mobile/functions/api_functions.dart';
import 'package:crypto_wallet_app_mobile/models/crypto_template_model.dart';
import 'package:crypto_wallet_app_mobile/models/wallet_crypto_asset_model.dart';
import '../models/hd_wallet_model.dart';
import '../utils/secure_storage_helper.dart'; // Make sure this import is correct

class WalletProvider extends ChangeNotifier {
  // This already correctly gets the singleton instance of SecureStorageHelper
  final SecureStorageHelper _secureStorageHelper =
      SecureStorageHelper(); // Renamed to clarify it's the helper

  // This is correct and remains static
  static const String secureWalletPasswordKey =
      'crypto_wallet_app_mobile_password';

  // Timer to update balance automatically
  //Timer? _balanceUpdateTimer;
  IO.Socket? _socket;
  //WebSocketChannel? _channel;
  //StreamSubscription? _socketSubscription;
  bool isSocketConnected = false;
  Timer? _refreshThrottleTimer;

  FlutterSecureStorage get secureStorage => _secureStorageHelper.storage;

  List<HDWalletModel> _allWallets = [];
  HDWalletModel? _selectedWallet;
  List<CryptoTemplateModel> _cryptoTemplates = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<HDWalletModel> get allWallets => _allWallets;
  HDWalletModel? get selectedWallet => _selectedWallet;
  List<CryptoTemplateModel> get cryptoTemplates => _cryptoTemplates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    //_balanceUpdateTimer?.cancel();
    super.dispose();
    _disconnectWebSocket();
    _refreshThrottleTimer?.cancel();
  }

  WalletProvider() {
    loadAllInitialData();
  }

  // --- Initial Data Loading ---
  Future<void> loadAllInitialData() async {
    if (kDebugMode) {
      print('--- WalletProvider: loadAllInitialData() called ---');
    }
    _setLoading(true);
    try {
      final String cryptoTemplatesJson = await rootBundle.loadString(
        PathsForData.forCrypto,
      );
      final List<dynamic> templateList = jsonDecode(cryptoTemplatesJson);
      _cryptoTemplates = templateList
          .map((e) => CryptoTemplateModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (kDebugMode) {
        print(
          'WalletProvider: Loaded ${_cryptoTemplates.length} crypto templates.',
        );
      }

      // Use _secureStorageHelper.read()
      String? walletsJson = await _secureStorageHelper.read(key: 'hd_wallets');

      if (walletsJson != null && walletsJson.isNotEmpty) {
        List<dynamic> decodedList;
        try {
          decodedList = jsonDecode(walletsJson);
        } catch (e) {
          if (kDebugMode) {
            print('WalletProvider ERROR: Failed to decode walletsJson: $e');
          }
          _errorMessage = 'Failed to parse wallet data from storage.';
          _allWallets = [];
          _selectedWallet = null;
          return;
        }

        _allWallets = decodedList
            .whereType<Map<String, dynamic>>()
            .map((walletJsonMap) {
              try {
                return HDWalletModel.fromJson(walletJsonMap);
              } catch (e) {
                if (kDebugMode) {
                  print(
                    'WalletProvider ERROR: Failed to create HDWalletModel from map: $e',
                  );
                }
                return null;
              }
            })
            .whereNotNull()
            .toList();

        if (kDebugMode) {
          print(
            'WalletProvider: Successfully mapped and filtered ${_allWallets.length} HDWalletModels.',
          );
          if (_allWallets.isNotEmpty) {
            print(
              'WalletProvider: Names of loaded wallets: ${_allWallets.map((w) => w.walletName).toList()}',
            );
          }
        }

        _selectedWallet = _allWallets.firstWhereOrNull(
          (wallet) => wallet.isActive,
        );
        if (kDebugMode) {
          print(
            'WalletProvider: Initial _selectedWallet (by isActive): ${_selectedWallet?.walletName ?? "None active"}',
          );
        }

        if (_selectedWallet == null && _allWallets.isNotEmpty) {
          _selectedWallet = _allWallets.first;
          if (kDebugMode) {
            print(
              'WalletProvider: No active wallet found, defaulting to first: ${_selectedWallet!.walletName}',
            );
          }
          await _setActiveWalletInStorage(_selectedWallet!.walletName);
        } else if (_allWallets.isEmpty) {
          _selectedWallet = null;
          if (kDebugMode) {
            print('WalletProvider: No wallets found, _selectedWallet is null.');
          }
        }
      } else {
        _allWallets = [];
        _selectedWallet = null;
        if (kDebugMode) {
          print(
            'WalletProvider: No walletsJson found or it was empty. _allWallets and _selectedWallet set to null.',
          );
        }
      }

      _errorMessage = null;

      if (_selectedWallet != null) {
        final addressToWatch =
            _selectedWallet!.dataKey.childKeys.first.publicAddress;
        _connectToWebSocket(addressToWatch);
        await refreshBalanceOfSelectedWallet();
        // Start the periodic timer for automatic updates
        // _balanceUpdateTimer = Timer.periodic(const Duration(seconds: 10), (
        //   timer,
        // ) {
        //   refreshBalanceOfSelectedWallet();
        // });
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('WalletProvider FATAL ERROR in loadAllInitialData: $e');
        print('Stack trace: $stack');
      }
      _errorMessage = 'Failed to load wallet data due to an unexpected error.';
      _allWallets = [];
      _selectedWallet = null;
    } finally {
      _setLoading(false);
      if (kDebugMode) {
        print('--- WalletProvider: loadAllInitialData() finished ---');
      }
    }
  }

  // CryptoTemplateModel? getCryptoTemplate(String symbol) {
  //   return _cryptoTemplates.firstWhereOrNull(
  //         (template) => template.symbol == symbol,
  //   );
  // }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ======================================================================
  // ======================= Wallet Selection =============================
  // ======================================================================
  Future<void> selectWallet(String walletName) async {
    if (_selectedWallet?.walletName == walletName) return;

    _setLoading(true);

    // REMOVED: The old timer cancellation is no longer needed.
    //_balanceUpdateTimer?.cancel();

    try {
      final HDWalletModel? newSelectedWallet = _allWallets.firstWhereOrNull(
        (wallet) => wallet.walletName == walletName,
      );

      if (newSelectedWallet != null) {
        _selectedWallet = newSelectedWallet;
        _allWallets = _allWallets.map((wallet) {
          return wallet.copyWith(isActive: wallet.walletName == walletName);
        }).toList();

        await _setActiveWalletInStorage(walletName);

        // ✅ NEW: Connect to WebSocket with the new wallet's address.
        final addressToWatch =
            newSelectedWallet.dataKey.childKeys.first.publicAddress;
        _connectToWebSocket(addressToWatch);

        // Perform an initial refresh. Subsequent refreshes will be triggered by WebSocket events.
        await refreshBalanceOfSelectedWallet();

        _errorMessage = null;
      } else {
        _errorMessage = 'Wallet with name $walletName not found.';
      }
    } catch (e) {
      if (kDebugMode) print('Error selecting wallet: $e');
      _errorMessage = 'Failed to select wallet: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Helper to save entire _allWallets list after deleting wallets.
  Future<void> _saveAllWalletsToStorage() async {
    final updatedWalletJson = _allWallets.map((wallet) {
      return wallet.toJson();
    }).toList();
    await _secureStorageHelper.write(
      key: "hd_wallets",
      value: jsonEncode(updatedWalletJson),
    );
    debugPrint(
      "WalletProvider: All wallets saved to storage (key: hd_wallets). Current count: ${_allWallets.length}",
    );
  }

  // Helper to persist active wallet status to secure storage
  Future<void> _setActiveWalletInStorage(String activeWalletName) async {
    // Ensure isActive status is correctly set in _allWallets before saving
    _allWallets = _allWallets.map((wallet) {
      return wallet.copyWith(isActive: wallet.walletName == activeWalletName);
    }).toList();

    // Save the entire updated list of wallets
    await _saveAllWalletsToStorage();

    // If you also have a separate key for just the 'selected_wallet_name', save it here:
    await _secureStorageHelper.write(
      key: 'selected_wallet_name',
      value: activeWalletName,
    ); // Keep this if you use it elsewhere

    if (kDebugMode) {
      print(
        'WalletProvider: Active wallet set to "$activeWalletName" and all wallets persisted.',
      );
    }
  }

  // --- Add New Wallet ---
  Future<void> addNewWallet(HDWalletModel newWallet) async {
    _setLoading(true);
    try {
      // Refactor: Use copyWith to deactivate all existing wallets
      _allWallets = _allWallets
          .map((w) => w.copyWith(isActive: false))
          .toList();

      // Add the new wallet and set it as active
      _allWallets.add(
        newWallet.copyWith(isActive: true),
      ); // Ensure new wallet is added as active
      _selectedWallet = newWallet; // Set the new wallet as selected

      await _setActiveWalletInStorage(newWallet.walletName);
      _errorMessage = null;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding new wallet: $e');
      }
      _errorMessage = 'Failed to add new wallet: $e';
    } finally {
      _setLoading(false);
      // notifyListeners() is called by _setLoading(false)
    }
  }

  /*
  ======================================================================
  ==================== Wallet Deletion Logic Starts ====================
  ======================================================================
   */

  Future<bool> deleteSpecificWallet(String walletName) async {
    try {
      // Find the index of the wallet to be deleted before modifying the list
      final int deletedWalletIndex = _allWallets.indexWhere(
        (wallet) => wallet.walletName == walletName,
      );

      // Check if we're deleting the currently selected wallet
      final bool isDeletingSelectedWallet =
          _selectedWallet?.walletName == walletName;

      // Delete from secure storage
      await _secureStorageHelper.delete(key: walletName);

      // Remove the wallet from the list
      _allWallets.removeWhere((wallet) => wallet.walletName == walletName);

      // Handle wallet selection after deletion
      if (_allWallets.isEmpty) {
        // _balanceUpdateTimer?.cancel(); // Stop the timer
        _selectedWallet = null;
        await _secureStorageHelper.delete(key: 'selected_wallet_name');
      }
      if (_allWallets.isNotEmpty) {
        if (isDeletingSelectedWallet) {
          final HDWalletModel newActiveWallet;
          if (deletedWalletIndex > 0 &&
              deletedWalletIndex <= _allWallets.length) {
            newActiveWallet = _allWallets[deletedWalletIndex - 1];
          } else {
            // Otherwise, take the last one or the first one if only one remains
            newActiveWallet = _allWallets.last; // Or _allWallets.first
          }
          await selectWallet(newActiveWallet.walletName);
        } else if (_selectedWallet != null) {
          // If a different wallet was selected, ensure its selected state is persisted
          await _setActiveWalletInStorage(_selectedWallet!.walletName);
        }
      } else {
        // No wallets left
        _selectedWallet = null;
        // Also clear from storage
        await _secureStorageHelper.delete(key: 'selected_wallet_name');
      }

      await _saveAllWalletsToStorage();
      notifyListeners();
      debugPrint('Wallet "$walletName" deleted successfully.');
      return true; // Indicate success
    } catch (e, stack) {
      debugPrint("Error deleting wallet: $e");
      debugPrint(stack.toString());
      // Do not show SnackBar here; let the UI layer handle it.
      return false; // Indicate failure
    }
  }

  Future<void> deleteAllWallets() async {
    _setLoading(true); // Indicate loading state

    try {
      _disconnectWebSocket();

      _allWallets = [];
      _selectedWallet = null;
      await _secureStorageHelper.deleteAll();
      if (kDebugMode) {
        print("All wallets deleted from storage and in-memory list cleared.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting all wallets: $e");
      }
      _errorMessage = 'Failed to delete all wallets: $e';
      rethrow;
    } finally {
      _setLoading(false);
      // notifyListeners() is called by _setLoading(false)
    }
  }

  /*
  ======================================================================
  ==================== Wallet Deletion Logic Ends ======================
  ======================================================================
   */

  // NEW METHOD: Update wallet backup status
  Future<void> updateWalletBackupStatus(
    String walletName,
    bool isBackedUp,
  ) async {
    _setLoading(true);
    try {
      final int index = _allWallets.indexWhere(
        (wallet) => wallet.walletName == walletName,
      );
      if (index != -1) {
        _allWallets[index] = _allWallets[index].copyWith(
          isBackedUp: isBackedUp,
        );
        if (_selectedWallet?.walletName == walletName) {
          _selectedWallet =
              _allWallets[index]; // Reference the updated wallet from the list
        }

        // Persist the entire updated list of wallets
        // Use _secureStorageHelper.write()
        await _secureStorageHelper.write(
          key: 'hd_wallets',
          value: jsonEncode(_allWallets.map((w) => w.toJson()).toList()),
        );
        _errorMessage = null;
        if (kDebugMode) {
          print(
            'Wallet $walletName backup status updated to $isBackedUp and persisted.',
          );
        }
      } else {
        _errorMessage =
            'Wallet $walletName not found for backup status update.';
        debugPrint(_errorMessage);
      }
    } catch (e) {
      debugPrint('Error updating wallet backup status: $e');
      _errorMessage = 'Failed to update backup status: $e';
    } finally {
      _setLoading(false);
      // notifyListeners() is called by _setLoading(false)
    }
  }

  // Helper to get CryptoTemplate for a given symbol
  CryptoTemplateModel? getCryptoTemplate(String symbol) {
    return _cryptoTemplates.firstWhereOrNull(
      (template) => template.symbol == symbol,
    );
  }

  // --- Refresh Crypto Data for Selected Wallet ---
  Future<void> refreshSelectedWalletData() async {
    if (_selectedWallet == null) return;

    _setLoading(true);
    try {
      if (_selectedWallet!.walletName == "My Main Wallet") {
        await Future.delayed(const Duration(seconds: 1));
        final updatedChildKeys = _selectedWallet!.dataKey.childKeys.map((wc) {
          if (wc.symbol == "BTC") {
            return WalletCryptoAssetModel(
              symbol: wc.symbol,
              publicAddress: wc.publicAddress,
              privateKey: wc.privateKey,
              balance: wc.balance + 0.00005,
              publicKey: '',
            );
          }
          return wc;
        }).toList();

        // Refactor: Use copyWith for deep update of dataKey and its childKeys
        _selectedWallet = _selectedWallet!.copyWith(
          dataKey: _selectedWallet!.dataKey.copyWith(
            childKeys: updatedChildKeys,
          ),
        );

        // Update the wallet in the _allWallets list as well
        final int index = _allWallets.indexWhere(
          (w) => w.walletName == _selectedWallet!.walletName,
        );
        if (index != -1) {
          _allWallets[index] = _selectedWallet!;
          await _setActiveWalletInStorage(_selectedWallet!.walletName);
        }
      }
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error refreshing wallet data: $e');
      _errorMessage = 'Failed to refresh data: $e';
    } finally {
      _setLoading(false);
      // notifyListeners() is called by _setLoading(false)
    }
  }

  /*
  ===========================================================================
  ================= Web Socket and API calling setup start ==================
  ===========================================================================
*/
  void _connectToWebSocket(String address) {
    _disconnectWebSocket();

    try {
      _socket = IO.io('http://localhost:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _socket!.onConnect((_) {
        isSocketConnected = true;
        debugPrint('Connected to socket server');
        _socket!.emit('subscribe', address);
      });

      _socket!.on('balance_update', (_) {
        debugPrint('Received balance update event');
        _refreshThrottleTimer?.cancel(); // Cancel any existing timer
        _refreshThrottleTimer = Timer(const Duration(seconds: 5), () {
          refreshBalanceOfSelectedWallet();
        });
      });

      _socket!.onDisconnect((_) {
        isSocketConnected = false;
        debugPrint('Socket disconnected');
      });

      _socket!.connect();
    } catch (e) {
      debugPrint('Socket connection failed: $e');
      isSocketConnected = false;
    }
  }

  void _disconnectWebSocket() {
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
    isSocketConnected = false;
  }

  /*
  ===========================================================================
  ================= Web Socket and API calling setup ends ===================
  ===========================================================================
*/

  /*
  ===========================================================================
  =================== Refreshing Wallet Balance starts ======================
  ===========================================================================
*/
  Future<void> refreshBalanceOfSelectedWallet() async {
    if (_selectedWallet == null) return;

    // ✅ FIX: The `Future.wait` will create the list for us.
    // We no longer need to initialize an empty list here.

    // Use the existing address from the first asset, as it's shared.
    final String userAddress =
        _selectedWallet!.dataKey.childKeys.first.publicAddress;

    // `Future.wait` will return a list of `WalletCryptoAssetModel` in the correct order.
    final List<WalletCryptoAssetModel> updatedAssets = await Future.wait(
      _selectedWallet!.dataKey.childKeys.map((asset) async {
        double newBalance = asset.balance;
        final template = getCryptoTemplate(asset.symbol);

        if (template != null && template.apiSupported) {
          try {
            if (!template.isErc20) {
              newBalance = await APIFunctions.getEthBalance(userAddress);
            } else {
              // newBalance = await APIFunctions.getERC20Balance(
              //   userAddress: userAddress,
              //   contractAddress: template.contractAddress!,
              //   decimals: template.decimals,
              // );
            }
          } catch (e) {
            // If fetching fails, we keep the old balance.
            // debugPrint("Failed to refresh balance for ${asset.symbol}: $e");
          }
        }

        // ✅ FIX: Return the new model instead of adding to a list here.
        return WalletCryptoAssetModel(
          symbol: asset.symbol,
          publicAddress: asset.publicAddress,
          privateKey: asset.privateKey,
          balance: newBalance,
          publicKey: asset.publicKey,
        );
      }),
    );

    /*
  ===========================================================================
  ==================== Refreshing Wallet Balance ends =======================
  ===========================================================================
*/

    // Now, update the wallet state with the correctly ordered list of assets.
    _selectedWallet = _selectedWallet!.copyWith(
      dataKey: _selectedWallet!.dataKey.copyWith(childKeys: updatedAssets),
    );

    final index = _allWallets.indexWhere(
      (w) => w.walletName == _selectedWallet!.walletName,
    );
    if (index != -1) {
      _allWallets[index] = _selectedWallet!;
    }

    notifyListeners();
  }
}
