// models/crypto_template_model.dart

class CryptoTemplateModel {
  final String symbol;
  final String cryptoName;
  final String imgPath;
  final int coinType;
  final String derivationPath;
  final bool isTestnet;
  final String network;
  final double cryptoPrice;
  final bool isErc20;
  final String? contractAddress; // Nullable for non-ERC20 tokens
  final int decimals;
  final int chainId;
  final bool apiSupported;

  CryptoTemplateModel({
    required this.symbol,
    required this.cryptoName,
    required this.imgPath,
    required this.coinType,
    required this.derivationPath,
    required this.isTestnet,
    required this.network,
    required this.cryptoPrice,
    required this.isErc20,
    this.contractAddress,
    required this.decimals,
    required this.chainId,
    required this.apiSupported,
  });

  factory CryptoTemplateModel.fromJson(Map<String, dynamic> json) {
    return CryptoTemplateModel(
      symbol: json['symbol'] as String,
      cryptoName: json['cryptoName'] as String,
      imgPath: json['imgPath'] as String,
      coinType: json['coinType'] as int,
      derivationPath: json['derivationPath'] as String,
      isTestnet: json['isTestnet'] as bool,
      network: json['network'] as String,
      cryptoPrice: (json['cryptoPrice'] as num).toDouble(),
      isErc20: json['isErc20'] as bool,
      contractAddress: json['contractAddress'] as String?,
      decimals: json['decimals'] as int,
      chainId: json['chainId'] as int,
      apiSupported: json['apiSupported'] as bool,
    );
  }
}