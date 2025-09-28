import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:crypto_wallet_app_mobile/constants/app_colors.dart';
import 'package:crypto_wallet_app_mobile/enter_seed_phrase_page.dart';
import 'package:crypto_wallet_app_mobile/functions/reusable_functions.dart';
//import 'package:crypto_wallet_app_mobile/functions/wallet_functions.dart';
import 'package:crypto_wallet_app_mobile/main_screen.dart';
import 'package:crypto_wallet_app_mobile/new_wallet_create.dart';
import 'package:crypto_wallet_app_mobile/widgets/simple_appbar.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';
import 'package:crypto_wallet_app_mobile/models/hd_wallet_model.dart';
import 'package:crypto_wallet_app_mobile/delete_splash_page.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class WalletCryptoAssetModel {
  final String symbol;
  final String publicAddress;
  final String privateKey;
  final double balance;
  final String publicKey;

  WalletCryptoAssetModel({
    required this.symbol,
    required this.publicAddress,
    required this.privateKey,
    required this.balance,
    required this.publicKey,
  });

  factory WalletCryptoAssetModel.fromJson(Map<String, dynamic> json) {
    return WalletCryptoAssetModel(
      symbol: json['symbol'] as String,
      publicAddress: json['publicAddress'] as String,
      privateKey: json['privateKey'] as String,
      balance: (json['balance'] as num).toDouble(),
      publicKey: json['publicKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'publicAddress': publicAddress,
      'privateKey': privateKey,
      'balance': balance,
      'publicKey': publicKey,
    };
  }
}

class WalletInfoPage extends StatefulWidget {
  final HDWalletModel wallet;

  const WalletInfoPage({super.key, required this.wallet});

  @override
  State<WalletInfoPage> createState() => _WalletInfoPageState();
}

class _WalletInfoPageState extends State<WalletInfoPage> {
  List<String> _passwordInputs = [];
  List<WalletCryptoAssetModel> _cryptoAssets = [];

  @override
  void initState() {
    super.initState();
    _loadCryptoAssets();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadCryptoAssets() {
    // Mock data - replace with actual data from your provider
    final displayWallet = widget.wallet;

    setState(() {
      _cryptoAssets = [
        WalletCryptoAssetModel(
          symbol: 'BTC',
          publicAddress:
              displayWallet.dataKey.masterPublicKeyXpub ??
              'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
          privateKey: displayWallet.dataKey.masterPrivateKeyXprv ?? 'L4gB1...',
          balance: 0.125,
          publicKey: displayWallet.dataKey.masterPublicKeyXpub ?? '02a1b2...',
        ),
        WalletCryptoAssetModel(
          symbol: 'ETH',
          publicAddress: '0x742d35Cc6634C0532925a3b8Doe2345f7e4a0f3d',
          privateKey:
              '0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318',
          balance: 1.75,
          publicKey:
              '0x03a1b2c3d4e5f678901234567890123456789012345678901234567890123456789',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final String warningBeforeRemovingWallet =
        "Deleting this wallet is permanent and cannot be undone. "
        "If you haven't backed up your recovery phrase or private key, "
        "you will lose access to your funds forever. Proceed only if you're sure.";
    final walletProvider = Provider.of<WalletProvider>(context);

    final HDWalletModel displayWallet = walletProvider.allWallets.firstWhere(
      (w) => w.walletName == widget.wallet.walletName,
      orElse: () => widget.wallet,
    );

    final String walletName = displayWallet.walletName;
    final String suffix = walletName.length > 3
        ? walletName.substring(walletName.length - 3).toUpperCase()
        : walletName.toUpperCase();

    final List<Map<String, dynamic>> walletDetails = [
      {
        "type": "info",
        "title": "Created By",
        "trailing": "Mnemonic Phrase",
        "hasInfoIcon": false,
      },
      {
        "type": "info",
        "title": "Created Time",
        "trailing": DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(displayWallet.createdTime),
        "hasInfoIcon": false,
      },
      {
        "type": "info",
        "title": "Security Suffix",
        "trailing": suffix,
        "hasInfoIcon": true,
      },
      {
        "type": "action",
        "title": "Backup",
        "badge_text": displayWallet.isBackedUp ? "Backed Up" : "No backup",
        "onTap": displayWallet.isBackedUp
            ? null
            : () async {
                bool? passwordConfirmed =
                    await _showPasswordConfirmationAndDisplayKeys(
                      context,
                      displayWallet.dataKey.seedPhrase!,
                      isPrivateKey: false,
                      walletProvider: walletProvider,
                    );

                if (passwordConfirmed == true && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => EnterSeedPhrasePage(
                        mnemonic: displayWallet.dataKey.seedPhrase!,
                        walletNameForBackup: displayWallet.walletName,
                        startInVerificationMode: false,
                        walletName: displayWallet.walletName,
                      ),
                    ),
                  );
                }
              },
      },
      {
        "type": "action",
        "title": "Export Public Key",
        "hasInfoIcon": true,
        "onTap": () => _showPasswordConfirmationAndDisplayKeys(
          context,
          displayWallet.dataKey.seedPhrase!,
          isPrivateKey: false,
          walletProvider: walletProvider,
        ),
      },
      {
        "type": "action",
        "title": "Export Private Key",
        "onTap": () => _showWarningAndDisplayPrivateKeys(
          context,
          displayWallet.dataKey.seedPhrase!,
          walletProvider: walletProvider,
        ),
      },
      {
        "type": "action",
        "title": "Create Account",
        "onTap": () =>
            debugPrint("Create Account tapped for ${displayWallet.walletName}"),
      },
      {
        "type": "action",
        "title": "Clear Cache",
        "onTap": () => showAlertBoxWithTimer(
          context: context,
          message:
              "This will permanently delete all wallets, private keys, and associated balances stored on this device. This action is irreversible. Make sure you have backed up all necessary information before continuing.",
          onYes: () {
            Provider.of<WalletProvider>(
              context,
              listen: false,
            ).deleteAllWallets().then((_) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const WalletDeletionSplashPage(),
                ),
                (route) => false,
              );
            });
          },
          countdownSeconds: 3,
        ),
      },
      {
        "type": "coins",
        "title": "Crypto Assets",
        "trailing": "\$${_calculateTotalBalance()}",
        "onTap": () => _showCryptoAssets(context),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const SimpleAppbarWidget(appbarTitle: "Wallet Details"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildHeader(walletName),
              const SizedBox(height: 24),
              ..._buildGroupedListItems(walletDetails),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _handleWalletRemoval(
                    context,
                    displayWallet,
                    walletProvider,
                    warningBeforeRemovingWallet,
                  ),
                  child: const Text(
                    "Remove Wallet",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateTotalBalance() {
    double total = _cryptoAssets.fold(0.0, (sum, asset) => sum + asset.balance);
    return total.toStringAsFixed(2);
  }

  Future<void> _handleWalletRemoval(
    BuildContext context,
    HDWalletModel displayWallet,
    WalletProvider walletProvider,
    String warningMessage,
  ) async {
    debugPrint("Remove Wallet button tapped for ${displayWallet.walletName}");

    bool? passwordConfirmed = await showModalBottomSheet<bool>(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => PasswordBottomSheet(
        onSuccess: () {
          Navigator.of(sheetContext).pop(true);
        },
      ),
    );

    if (passwordConfirmed != true) {
      debugPrint(
        "Password not confirmed or sheet dismissed. Aborting deletion.",
      );
      return;
    }

    if (!context.mounted) return;

    bool? confirmedToDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (alertContext) => AlertBoxWithTimer(
        message: warningMessage,
        countdownSeconds: 5,
        onYes: () => Navigator.of(alertContext).pop(true),
        onNo: () => Navigator.of(alertContext).pop(false),
      ),
    );

    if (confirmedToDelete != true) {
      debugPrint("Wallet deletion not confirmed by user. Aborting.");
      return;
    }

    if (!context.mounted) return;

    BuildContext? loadingDialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        loadingDialogContext = ctx;
        return const Center(child: CircularProgressIndicator());
      },
    );

    bool deletionSuccess = false;
    try {
      deletionSuccess = await walletProvider.deleteSpecificWallet(
        displayWallet.walletName,
      );
    } catch (e) {
      debugPrint("Error during wallet deletion: $e");
    } finally {
      if (loadingDialogContext != null && loadingDialogContext!.mounted) {
        Navigator.of(loadingDialogContext!).pop();
      }
    }

    if (!context.mounted) return;

    _showDeletionResultSnackbar(
      context,
      displayWallet.walletName,
      deletionSuccess,
    );

    if (walletProvider.allWallets.isEmpty) {
      NavigationHelper.pushAndRemoveUntil(
        context,
        const WalletDeletionSplashPage(),
      );
    } else {
      NavigationHelper.pushAndRemoveUntil(context, const HomeScreen());
    }
  }

  void _showDeletionResultSnackbar(
    BuildContext context,
    String walletName,
    bool success,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Wallet "$walletName" deleted successfully!'
              : 'Failed to delete wallet "$walletName". Please try again.',
        ),
        backgroundColor: success ? AppColors.greenColor : AppColors.redColor,
      ),
    );
  }

  List<Widget> _buildGroupedListItems(
    List<Map<String, dynamic>> walletDetails,
  ) {
    List<Widget> groupedWidgets = [];
    String? currentType;
    List<Map<String, dynamic>> currentGroup = [];

    for (var item in walletDetails) {
      if (currentType == null || item['type'] != currentType) {
        if (currentGroup.isNotEmpty) {
          groupedWidgets.add(_buildSectionContainer(currentGroup));
        }
        currentType = item['type'];
        currentGroup = [item];
      } else {
        currentGroup.add(item);
      }
    }
    if (currentGroup.isNotEmpty) {
      groupedWidgets.add(_buildSectionContainer(currentGroup));
    }
    return groupedWidgets;
  }

  Widget _buildSectionContainer(List<Map<String, dynamic>> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardWidgetBlack.withAlpha(242),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                title: Row(
                  children: [
                    Text(
                      item["title"],
                      style: const TextStyle(color: AppColors.textColor),
                    ),
                    if (item["hasInfoIcon"] == true)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.help_outline,
                          size: 16,
                          color: AppColors.subtitleColor,
                        ),
                      ),
                  ],
                ),
                trailing: item["badge_text"] != null
                    ? _Badge(text: item["badge_text"])
                    : item["trailing"] != null
                    ? Text(
                        item["trailing"],
                        style: TextStyle(color: AppColors.subtitleColor),
                      )
                    : (item["onTap"] != null
                          ? Icon(
                              Icons.chevron_right,
                              color: AppColors.subtitleColor,
                            )
                          : null),
                onTap: item["onTap"] != null ? () => item["onTap"]() : null,
              ),
              if (index < items.length - 1)
                Divider(
                  color: AppColors.subtitleColor.withAlpha(76),
                  height: 1,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(String walletName) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              walletName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.titleColor,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.edit, size: 18, color: AppColors.subtitleColor),
          ],
        ),
      ],
    );
  }

  Future<bool?> _showPasswordConfirmationAndDisplayKeys(
    BuildContext context,
    String mnemonic, {
    required bool isPrivateKey,
    required WalletProvider walletProvider,
  }) async {
    _passwordInputs.clear();

    bool? passwordConfirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext innerContext, StateSetter innerSetState) {
            Future<bool> _verifyPassword(
              BuildContext currentContext,
              WalletProvider walletProvider,
            ) async {
              String enteredPassword = _passwordInputs.join();
              String? storedPassword = await walletProvider.secureStorage.read(
                key: 'user_password',
              );

              if (enteredPassword == storedPassword) {
                if (currentContext.mounted) {
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(
                      content: Text("Password confirmed"),
                      backgroundColor: AppColors.greenColor,
                    ),
                  );
                }
                return true;
              } else {
                if (currentContext.mounted) {
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect password or no password set.'),
                      backgroundColor: AppColors.redColor,
                    ),
                  );
                  innerSetState(() => _passwordInputs.clear());
                }
                return false;
              }
            }

            void addDigit(String digit) async {
              if (_passwordInputs.length < 6) {
                innerSetState(() => _passwordInputs.add(digit));
              }
              if (_passwordInputs.length == 6) {
                bool isCorrect = await _verifyPassword(
                  innerContext,
                  walletProvider,
                );
                if (isCorrect) {
                  if (innerContext.mounted) {
                    Navigator.pop(innerContext, true);
                  }
                }
              }
            }

            void deleteDigit() {
              if (_passwordInputs.isNotEmpty) {
                innerSetState(() => _passwordInputs.removeLast());
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(innerContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInputDots(_passwordInputs),
                    const SizedBox(height: 20),
                    _buildKeypad(addDigit, deleteDigit),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (passwordConfirmed == true) {
      final displayWallet = widget.wallet;
      List<Map<String, String>> keysToDisplay = [];

      try {
        if (isPrivateKey) {
          keysToDisplay.add({
            'name': 'Master Private Key (XPRV)',
            'value': displayWallet.dataKey.masterPrivateKeyXprv,
            'chain': 'Hierarchical Deterministic Wallet',
          });
        } else {
          keysToDisplay.add({
            'name': 'Master Public Key (XPUB)',
            'value': displayWallet.dataKey.masterPublicKeyXpub,
            'chain': 'Hierarchical Deterministic Wallet',
          });
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deriving key: ${e.toString()}'),
              backgroundColor: AppColors.redColor,
            ),
          );
        }
        return false;
      }

      if (mounted) {
        _displayKeysBottomSheet(
          context,
          keysToDisplay,
          isPrivateKey: isPrivateKey,
        );
      }
    }
    return passwordConfirmed;
  }

  Future<void> _showWarningAndDisplayPrivateKeys(
    BuildContext context,
    String mnemonic, {
    required WalletProvider walletProvider,
  }) async {
    bool? userAgreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor,
          title: Text(
            'WARNING: Export Private Key',
            style: TextStyle(
              color: AppColors.redAccentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Private keys control direct access to your funds. Anyone with your private key can steal your assets.',
                  style: TextStyle(color: AppColors.textColor, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text(
                  'Guidelines:',
                  style: TextStyle(
                    color: AppColors.titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '1. Never share your private key.',
                  style: TextStyle(color: AppColors.textColor, fontSize: 13),
                ),
                Text(
                  '2. Do not store it digitally (e.g., screenshots, cloud, email).',
                  style: TextStyle(color: AppColors.textColor, fontSize: 13),
                ),
                Text(
                  '3. Write it down on paper and store it in a very secure, private place.',
                  style: TextStyle(color: AppColors.textColor, fontSize: 13),
                ),
                Text(
                  '4. Losing this key means losing your funds forever.',
                  style: TextStyle(color: AppColors.textColor, fontSize: 13),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.defaultThemePurple),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('I Understand & Agree'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (userAgreed == true && mounted) {
      await _showPasswordConfirmationAndDisplayKeys(
        context,
        mnemonic,
        isPrivateKey: true,
        walletProvider: walletProvider,
      );
    }
  }

  Future<void> _displayKeysBottomSheet(
    BuildContext context,
    List<Map<String, String>> keys, {
    required bool isPrivateKey,
  }) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isPrivateKey ? 'Your Private Key' : 'Your Public Key',
                    style: TextStyle(
                      color: AppColors.titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ...keys.map((keyData) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${keyData['name']} (${keyData['chain']})',
                          style: TextStyle(
                            color: AppColors.subtitleColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  keyData['value']!,
                                  style: TextStyle(
                                    color: AppColors.textColor,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.copy,
                                  color: AppColors.iconColor,
                                  size: 18,
                                ),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: keyData['value']!),
                                  );
                                  ScaffoldMessenger.of(
                                    sheetContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${keyData['name']} copied to clipboard!',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.defaultThemePurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCryptoAssets(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Crypto Assets',
                    style: TextStyle(
                      color: AppColors.titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_cryptoAssets.isEmpty)
                  Center(
                    child: Text(
                      'No crypto assets found',
                      style: TextStyle(
                        color: AppColors.subtitleColor,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  ..._cryptoAssets.map((asset) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  asset.symbol,
                                  style: TextStyle(
                                    color: AppColors.titleColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Balance: ${asset.balance}',
                                  style: TextStyle(
                                    color: AppColors.textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildKeyValueRow(
                              'Public Address',
                              asset.publicAddress,
                            ),
                            const SizedBox(height: 4),
                            _buildKeyValueRow('Public Key', asset.publicKey),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  _showAssetPrivateKey(context, asset),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.redColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Show Private Key'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.defaultThemePurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeyValueRow(String key, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$key: ',
          style: TextStyle(
            color: AppColors.subtitleColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: AppColors.textColor, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(Icons.copy, color: AppColors.iconColor, size: 14),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$key copied to clipboard!')),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showAssetPrivateKey(
    BuildContext context,
    WalletCryptoAssetModel asset,
  ) async {
    bool? userAgreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor,
          title: Text(
            'WARNING: ${asset.symbol} Private Key',
            style: TextStyle(
              color: AppColors.redAccentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'This is the private key for ${asset.symbol}. Anyone with this key can access your ${asset.symbol} funds.',
                  style: TextStyle(color: AppColors.textColor, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text(
                  'Keep this secure and never share it!',
                  style: TextStyle(
                    color: AppColors.titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.defaultThemePurple),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('I Understand'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (userAgreed == true && mounted) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: AppColors.cardColor,
            title: Text(
              '${asset.symbol} Private Key',
              style: TextStyle(
                color: AppColors.titleColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      asset.privateKey,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: AppColors.iconColor,
                      size: 16,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: asset.privateKey));
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('${asset.symbol} Private Key copied!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Close',
                  style: TextStyle(color: AppColors.defaultThemePurple),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildInputDots(List<String> inputs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        bool filled = index < inputs.length;
        return Container(
          margin: const EdgeInsets.all(8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.textColor : AppColors.transparent,
            border: Border.all(color: AppColors.textColor),
          ),
        );
      }),
    );
  }

  Widget _buildKeypadButton(
    String value, {
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardWidgetBlack,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: AppColors.textColor)
                : Text(
                    value,
                    style: TextStyle(color: AppColors.textColor, fontSize: 22),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(
    Function(String) addDigitCallback,
    VoidCallback deleteDigitCallback,
  ) {
    return Column(
      children: [
        Row(
          children: [
            _buildKeypadButton('1', onTap: () => addDigitCallback('1')),
            _buildKeypadButton('2', onTap: () => addDigitCallback('2')),
            _buildKeypadButton('3', onTap: () => addDigitCallback('3')),
          ],
        ),
        Row(
          children: [
            _buildKeypadButton('4', onTap: () => addDigitCallback('4')),
            _buildKeypadButton('5', onTap: () => addDigitCallback('5')),
            _buildKeypadButton('6', onTap: () => addDigitCallback('6')),
          ],
        ),
        Row(
          children: [
            _buildKeypadButton('7', onTap: () => addDigitCallback('7')),
            _buildKeypadButton('8', onTap: () => addDigitCallback('8')),
            _buildKeypadButton('9', onTap: () => addDigitCallback('9')),
          ],
        ),
        Row(
          children: [
            const Spacer(),
            _buildKeypadButton('0', onTap: () => addDigitCallback('0')),
            _buildKeypadButton(
              '',
              icon: Icons.backspace,
              onTap: deleteDigitCallback,
            ),
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    Color badgeColor = text == "Backed Up"
        ? AppColors.greenColor
        : AppColors.redColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
