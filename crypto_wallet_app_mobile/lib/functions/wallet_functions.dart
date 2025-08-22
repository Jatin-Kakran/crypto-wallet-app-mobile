import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';
import 'package:bip39/bip39.dart' as bip39; // Alias for clarity
import 'package:web3dart/credentials.dart'; // For EthPrivateKey, EthereumAddress
import 'package:hex/hex.dart'; // For hex encoding/decoding

class WalletFunctions {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> deleteAccount(BuildContext context) async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    try {
      await walletProvider.deleteAllWallets();
      if (kDebugMode) {
        print("All wallets deleted successfully!");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting wallets: ${e.toString()}')),
        );
      }
    }
  }

  static Future<void> readAllWalletsInConsole(BuildContext context) async {
    try {
      Map<String, String> readAllWalletsInConsole = await _secureStorage
          .readAll();
      if (kDebugMode) {
        print("Secure Storage value read successfully");
        print(readAllWalletsInConsole);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error to read: $e");
      }
    }
  }

  static String getPublicKeyFromMnemonic(String mnemonic) {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw ArgumentError(
        "Invalid mnemonic phrase provided for public key derivation.",
      );
    }

    try {
      // 1. Convert mnemonic to seed
      final String seedHex = bip39.mnemonicToSeedHex(mnemonic);
      final Uint8List seedBytes =
          HEX.decode(seedHex) as Uint8List; // Decode hex to bytes
      if (seedBytes.length < 32) {
        throw Exception("Seed too short to derive a 32-byte private key.");
      }
      final Uint8List privateKeyBytes = seedBytes.sublist(0, 32);

      final EthPrivateKey privateKey = EthPrivateKey(privateKeyBytes);

      // The public address is derived from the private key
      return privateKey
          .address
          .hex; // Returns the Ethereum address (e.g., "0x...")
    } catch (e) {
      if (kDebugMode) {
        print("Error deriving public key from mnemonic: $e");
      }
      rethrow;
    }
  }

  static String getPrivateKeyFromMnemonic(String mnemonic) {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw ArgumentError(
        "Invalid mnemonic phrase provided for private key derivation.",
      );
    }

    try {
      // 1. Convert mnemonic to seed
      final String seedHex = bip39.mnemonicToSeedHex(mnemonic);
      final Uint8List seedBytes =
          HEX.decode(seedHex) as Uint8List; // Decode hex to bytes

      // 2. Derive the private key from the seed (simplification for demonstration)
      if (seedBytes.length < 32) {
        throw Exception("Seed too short to derive a 32-byte private key.");
      }
      final Uint8List privateKeyBytes = seedBytes.sublist(0, 32);

      // Return the private key as a hex string
      return HEX.encode(
        privateKeyBytes,
      ); // Uint8List is already a list of bytes
    } catch (e) {
      if (kDebugMode) {
        print("Error deriving private key from mnemonic: $e");
      }
      rethrow;
    }
  }
}
