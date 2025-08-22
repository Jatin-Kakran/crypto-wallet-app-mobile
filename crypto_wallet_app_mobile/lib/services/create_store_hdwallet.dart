import 'dart:convert';
//import 'dart:ffi';
import 'dart:math';
//import 'dart:typed_data';
//import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hex/hex.dart';
//import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:crypto_wallet_app_mobile/constants/app_data_provider.dart';
//import 'package:crypto_wallet_app_mobile/functions/api_functions.dart';
import 'package:crypto_wallet_app_mobile/models/hd_wallet_model.dart';
import 'package:crypto_wallet_app_mobile/models/wallet_crypto_asset_model.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';
import 'package:web3dart/credentials.dart';

import '../functions/wallet_generate.dart';

final Random random = Random();
List<Map<String, dynamic>>? _cryptoConfigs;

Future<List<Map<String, dynamic>>> _loadCryptoConfigs() async {
  if (_cryptoConfigs != null) {
    return _cryptoConfigs!;
  }
  try {
    final String cryptoMockData = await rootBundle.loadString(
      //'assets/data/NEW_MOCK_DATA.json',
      PathsForData.forCrypto, // 'assets/data/ETH_DATA_NEW.json'
    );
    final List<dynamic> data = json.decode(cryptoMockData);
    _cryptoConfigs = data.cast<Map<String, dynamic>>();
    if (kDebugMode) {
      print('Successfully loaded crypto configs from assets.');
    }
    return _cryptoConfigs!;
  } catch (e) {
    if (kDebugMode) {
      print('Error loading crypto configs from assets: $e');
    }
    return [];
  }
}

String generateAndReturnMnemonic() {
  return bip39.generateMnemonic();
}

String returnMnemonicToUse() {
  return generateAndReturnMnemonic();
}

Future<HDWalletModel> createAndStoreHDWallet({
  required BuildContext context,
  required String mnemonicToUse,
}) async {
  if (kDebugMode) {
    print("\n═══════════════════════════════════════════════════════════════");
    print("         STARTING HD WALLET CREATION PROCESS");
    print("═══════════════════════════════════════════════════════════════");
    print("Mnemonic phrase: $mnemonicToUse");
  }

  try {
    final List<Map<String, dynamic>> cryptoConfigs = await _loadCryptoConfigs();
    if (cryptoConfigs.isEmpty) {
      throw Exception(
        'Failed to load crypto configurations for derivation. List is empty.',
      );
    }
    if (kDebugMode) {
      print("Loaded ${cryptoConfigs.length} crypto configurations:");
      for (var config in cryptoConfigs) {
        if (kDebugMode) {
          print(
            "  - ${config['symbol']} (CoinType: ${config['coinType']}, isTestnet: ${config['isTestnet']})",
          );
        }
      }
    }

    Uint8List seedBytes = Uint8List.fromList(
      bip39.mnemonicToSeed(mnemonicToUse),
    );
    if (kDebugMode) {
      print("Seed bytes (hex): ${HEX.encode(seedBytes)}");
      print("Seed length: ${seedBytes.length} bytes");
    }

    final bip32.BIP32 masterNode = bip32.BIP32.fromSeed(seedBytes);
    if (kDebugMode) {
      print("MASTER NODE DETAILS:");
      print("XPRV: ${masterNode.toBase58()}");
      print("XPUB: ${masterNode.neutered().toBase58()}");
      print("Private key (hex): ${HEX.encode(masterNode.privateKey!)}");
      print("Public key (hex): ${HEX.encode(masterNode.publicKey)}");
      print("Chain code (hex): ${HEX.encode(masterNode.chainCode)}");
    }

    List<WalletCryptoAssetModel> childWalletCryptoAssets = [];

    for (var config in cryptoConfigs) {
      final String symbol = config['symbol'];
      final int coinType = config['coinType'];
      final String derivationPath = config['derivationPath'];
      final bool isTestnet = config['isTestnet'] ?? false;
      final String network = config['network'] ?? 'Unknown';

      final String fullDerivationPath = "$derivationPath/0/0";

      if (kDebugMode) {
        print(
          "═══════════════════════════════════════════════════════════════",
        );
        print("Processing: $symbol (CoinType: $coinType, Testnet: $isTestnet)");
        print("Derivation path: $fullDerivationPath");
      }

      final bip32.BIP32 childNode = masterNode.derivePath(fullDerivationPath);

      if (childNode.privateKey == null) {
        if (kDebugMode) {
          print(
            "Error: Child node private key is null for $symbol ($fullDerivationPath). Skipping asset.",
          );
        }
        continue;
      }

      String privateKeyHex = HEX.encode(childNode.privateKey!);
      String address = '';
      String derivedPublicKeyForAddress = '';

      try {
        if (coinType == 60) {
          final privateKeyEth = EthPrivateKey.fromHex(privateKeyHex);
          address = privateKeyEth.address.hex;
          final Uint8List rawPublicKeyBytes = privateKeyEth.encodedPublicKey;
          derivedPublicKeyForAddress = HEX.encode(rawPublicKeyBytes);

          if (kDebugMode) {
            print(
              "ETHEREUM/ERC20 ADDRESS GENERATION (${isTestnet ? 'Testnet' : 'Mainnet'}):",
            );
            print("Address: $address");
            print(
              "Public Key (derived from EthPrivateKey, uncompressed 64-bytes): $derivedPublicKeyForAddress",
            );
          }
        } else {
          address = 'UNSUPPORTED_COIN_TYPE';
          derivedPublicKeyForAddress = 'UNSUPPORTED_KEY_TYPE';
          if (kDebugMode) {
            print('\nUNSUPPORTED COIN TYPE: $coinType (Symbol: $symbol)');
          }
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print(
            "\nERROR GENERATING ADDRESS FOR $symbol (CoinType: $coinType):",
          );
          print("Error: $e");
          print("Stack Trace: $stackTrace");
        }
        address = 'ERROR_GENERATING_ADDRESS';
        derivedPublicKeyForAddress = 'ERROR_KEY_GENERATION';
      }

      double balance = 0.0;

      childWalletCryptoAssets.add(
        WalletCryptoAssetModel(
          symbol: symbol,
          publicAddress: address,
          privateKey: privateKeyHex,
          publicKey: derivedPublicKeyForAddress,
          balance: balance,
        ),
      );

      if (kDebugMode) {
        print("\nFINAL ASSET DETAILS FOR $symbol:");
        print("Address: $address");
        print("Public Key (for address): $derivedPublicKeyForAddress");
        print("Private key: [HIDDEN]");
        print("Network: $network");
        print(
          "═══════════════════════════════════════════════════════════════",
        );
      }
    }

    // ignore: use_build_context_synchronously
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final nameGenerator = GenerateWalletName();
    await nameGenerator.generateNewWallet(
      existingWalletNames: walletProvider.allWallets
          .map((w) => w.walletName)
          .toList(),
    );

    final String? generatedWalletName = nameGenerator.getLastWallet();
    if (generatedWalletName == null) {
      throw Exception("Failed to generate wallet name");
    }

    if (kDebugMode) {
      print("\nWALLET METADATA:");
      print("Generated wallet name: $generatedWalletName");
      print("Creation time: ${DateTime.now()}");
    }

    final newWallet = HDWalletModel(
      walletName: generatedWalletName,
      isActive: true,
      dataKey: HDDataKey(
        seedPhrase: mnemonicToUse,
        masterPrivateKeyXprv: masterNode.toBase58(),
        masterPublicKeyXpub: masterNode.neutered().toBase58(),
        childKeys: childWalletCryptoAssets,
      ),
      isBackedUp: false,
      createdTime: DateTime.now(),
    );

    await walletProvider.addNewWallet(newWallet);

    if (kDebugMode) {
      print(
        "\n═══════════════════════════════════════════════════════════════",
      );
      print("         WALLET CREATION COMPLETE - SUMMARY");
      print("═══════════════════════════════════════════════════════════════");
      print("Wallet name: ${newWallet.walletName}");
      print("Master XPRV: [HIDDEN]");
      print("Master XPUB: ${newWallet.dataKey.masterPublicKeyXpub}");
      print("Assets count: ${newWallet.dataKey.childKeys.length}");
      print(
        "Backup status: ${newWallet.isBackedUp ? 'BACKED UP' : 'NOT BACKED UP'}",
      );
      print(
        "═══════════════════════════════════════════════════════════════\n",
      );
    }

    return newWallet;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print(
        "\n═══════════════════════════════════════════════════════════════",
      );
      print("         FATAL ERROR DURING WALLET CREATION");
      print("═══════════════════════════════════════════════════════════════");
      print("Error: $e");
      print("Stack Trace:\n$stackTrace");
    }
    rethrow;
  }
}
