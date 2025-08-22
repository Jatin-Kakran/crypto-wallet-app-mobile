//import 'package:crypto_wallet_app_mobile/functions/api_functions.dart';

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
    //required this.network,
    //required this.transactions,
  });

  factory WalletCryptoAssetModel.fromJson(Map<String, dynamic> json) {
    return WalletCryptoAssetModel(
      symbol: json['symbol'] as String,
      publicAddress: json['publicAddress'] as String,
      privateKey: json['privateKey'] as String,
      balance: (json['balance'] as num).toDouble(),
      //balance: APIFunctions.getEthBalance(widget.p),
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
