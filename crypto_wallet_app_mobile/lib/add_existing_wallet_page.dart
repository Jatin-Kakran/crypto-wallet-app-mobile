// lib/pages/add_existing_wallet_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
//import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:crypto_wallet_app_mobile/functions/api_functions.dart';
import 'package:web3dart/credentials.dart';
import '../constants/app_colors.dart';
import '../models/hd_wallet_model.dart';
import '../models/wallet_crypto_asset_model.dart';
import '../state/wallet_provider.dart';
import '../functions/wallet_generate.dart'; // Import for GenerateWalletName
import '../widgets/text_area_widget.dart';
import 'main_screen.dart';

class AddExistingWalletPage extends StatefulWidget {
  const AddExistingWalletPage({super.key});

  @override
  State<AddExistingWalletPage> createState() => _AddExistingWalletPageState();
}

class _AddExistingWalletPageState extends State<AddExistingWalletPage> {
  String _enteredMnemonic = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>>? _cryptoConfigs;

  Future<List<Map<String, dynamic>>> _loadCryptoConfigs() async {
    if (_cryptoConfigs != null) {
      return _cryptoConfigs!;
    }
    try {
      final String cryptoMockData = await rootBundle.loadString(
        'assets/data/ETH_MOCK_DATA.json',
      );
      final List<dynamic> data = json.decode(cryptoMockData);
      _cryptoConfigs = data.cast<Map<String, dynamic>>();
      return _cryptoConfigs!;
    } catch (e) {
      debugPrint('Error loading crypto configs: $e');
      return [];
    }
  }

  Future<void> _importWallet() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String trimmedMnemonic = _enteredMnemonic.trim();

      if (!bip39.validateMnemonic(trimmedMnemonic)) {
        setState(() {
          _errorMessage = 'Invalid mnemonic phrase. Please check your words.';
          _isLoading = false;
        });
        return;
      }

      final List<String> words = trimmedMnemonic.split(' ');
      if (!(words.length == 12 || words.length == 24)) {
        setState(() {
          _errorMessage = 'Mnemonic must be 12 or 24 words.';
          _isLoading = false;
        });
        return;
      }

      final List<Map<String, dynamic>> cryptoConfigs =
          await _loadCryptoConfigs();
      if (cryptoConfigs.isEmpty) {
        setState(() {
          _errorMessage =
              'Failed to load crypto configurations for derivation.';
          _isLoading = false;
        });
        return;
      }

      Uint8List seedBytes = Uint8List.fromList(
        bip39.mnemonicToSeed(trimmedMnemonic),
      );
      final bip32.BIP32 masterNode = bip32.BIP32.fromSeed(seedBytes);

      String masterPrivateKeyXprv = masterNode.toBase58();
      String masterPublicKeyXpub = masterNode.neutered().toBase58();

      List<WalletCryptoAssetModel> childWalletCryptoAssets = [];

      for (var config in cryptoConfigs) {
        final String baseDerivationPath = config["derivationPath"];
        final String fullDerivationPath = "$baseDerivationPath/0/0";
        final bip32.BIP32 childNode = masterNode.derivePath(fullDerivationPath);

        String privateKeyHex = HEX.encode(childNode.privateKey!);
        String address = '';
        String symbol = config['symbol'];
        //int coinType = config['coinType'];
        bool isErc20 = config['isErc20'] ?? false;

        if (config['coinType'] == 60) {
          final privateKeyEth = EthPrivateKey.fromHex(privateKeyHex);
          address = privateKeyEth.address.hex;
        } else if (config['coinType'] == 0) {
          address = "BTC_HOLDER";
        } else if (config['coinType'] == 3) {
          address = "DOGE_HOLDER";
        } else {
          address = 'UNSUPPORTED_ADDRESS_TYPE';
          debugPrint(
            'Warning: Unsupported coinType for address generation: ${config['coinType']} (Symbol: ${config['symbol']})',
          );
        }

        double balance = 0.0;
        try {
          if (!isErc20) {
            balance = await APIFunctions.getEthBalance(address);
          } else {
            // balance = await APIFunctions.getERC20Balance(
            //   userAddress: address,
            //   contractAddress: config['contractAddress'],
            //   decimals: config['decimals'],
            // );
          }
        } catch (e) {
          debugPrint("Failed to fetch balance for $symbol: $e");
        }

        childWalletCryptoAssets.add(
          WalletCryptoAssetModel(
            symbol: config['symbol'],
            publicAddress: address,
            privateKey: privateKeyHex,
            balance: balance,
            publicKey: '',
          ),
        );
      }

      // Get the WalletProvider instance to access existing wallets
      final walletProvider = Provider.of<WalletProvider>(
        // ignore: use_build_context_synchronously
        context,
        listen: false,
      );

      // Generate a new unique name based on existing wallet names
      final nameGenerator = GenerateWalletName();
      // Pass the names of currently loaded wallets from the provider
      await nameGenerator.generateNewWallet(
        existingWalletNames: walletProvider.allWallets
            .map((w) => w.walletName)
            .toList(),
      );
      final String importedWalletName = nameGenerator.getLastWallet()!;

      final importedWallet = HDWalletModel(
        walletName: importedWalletName,
        isActive: true,
        dataKey: HDDataKey(
          seedPhrase: trimmedMnemonic,
          masterPrivateKeyXprv: masterPrivateKeyXprv,
          masterPublicKeyXpub: masterPublicKeyXpub,
          childKeys: childWalletCryptoAssets,
        ),
        createdTime: DateTime.now(),
        isBackedUp: false,
      );

      await walletProvider.addNewWallet(importedWallet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error importing wallet: ${e.toString()}';
        debugPrint('Import wallet error: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Import Existing Wallet",
          style: TextStyle(color: AppColors.titleColor, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "Enter your 12 or 24-word mnemonic phrase to import your wallet.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.subtitleColor, fontSize: 14),
              ),
              const SizedBox(height: 30),

              TextAreaWidget(
                isEditable: true,
                onChanged: (text) {
                  setState(() {
                    _enteredMnemonic = text;
                    _errorMessage = null;
                  });
                },
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 30),

              _isLoading
                  ? const CircularProgressIndicator(
                      color: AppColors.defaultThemePurple,
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.defaultThemePurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _enteredMnemonic.trim().isEmpty
                          ? null
                          : _importWallet,
                      child: const Text("Import Wallet"),
                    ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SECURITY WARNING:",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Never share your mnemonic phrase. Anyone with this phrase can access your funds. Only import into trusted apps on secure devices.",
                      style: TextStyle(
                        color: AppColors.subtitleColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
