// lib/models/hd_wallet_model.dart

// import 'package:crypto_wallet_app_mobile/functions/api_functions.dart';
import 'package:crypto_wallet_app_mobile/models/wallet_crypto_asset_model.dart';

class HDDataKey {
  final String? seedPhrase;
  final String masterPrivateKeyXprv;
  final String masterPublicKeyXpub;
  final List<WalletCryptoAssetModel> childKeys;

  HDDataKey({
    required this.seedPhrase,
    required this.masterPrivateKeyXprv,
    required this.masterPublicKeyXpub,
    required this.childKeys,
  });

  factory HDDataKey.fromJson(Map<String, dynamic> json) {
    return HDDataKey(
      seedPhrase: json["seed_phrase"] as String?,
      masterPrivateKeyXprv: json["master_private_key_xprv"] as String,
      masterPublicKeyXpub: json["master_public_key_xpub"] as String,
      childKeys:
          (json["child_keys"] as List<dynamic>?)
              ?.map(
                (e) =>
                    WalletCryptoAssetModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "seed_phrase": seedPhrase,
      "master_private_key_xprv": masterPrivateKeyXprv,
      "master_public_key_xpub": masterPublicKeyXpub,
      "child_keys": childKeys.map((e) => e.toJson()).toList(),
    };
  }

  // NEW: Add copyWith method for HDDataKey
  HDDataKey copyWith({
    String? seedPhrase,
    String? masterPrivateKeyXprv,
    String? masterPublicKeyXpub,
    List<WalletCryptoAssetModel>? childKeys,
  }) {
    return HDDataKey(
      seedPhrase: seedPhrase ?? this.seedPhrase,
      masterPrivateKeyXprv: masterPrivateKeyXprv ?? this.masterPrivateKeyXprv,
      masterPublicKeyXpub: masterPublicKeyXpub ?? this.masterPublicKeyXpub,
      childKeys: childKeys ?? this.childKeys,
    );
  }
}

class HDWalletModel {
  final String walletName;
  final bool isActive;
  final HDDataKey dataKey;
  final bool isBackedUp;
  final DateTime createdTime;
  //final double balance;

  HDWalletModel({
    required this.walletName,
    required this.isActive,
    required this.dataKey,
    this.isBackedUp = false,
    required this.createdTime,
    //required this.balance,
  });

  factory HDWalletModel.fromJson(Map<String, dynamic> json) {
    return HDWalletModel(
      walletName: json["wallet_name"] as String,
      isActive: json["is_active"] as bool,
      dataKey: HDDataKey.fromJson(json["data_key"] as Map<String, dynamic>),
      isBackedUp: json["is_backedUp"] as bool,
      createdTime: DateTime.parse(json["created_time"] as String),
      //balance: await APIFunctions.getEthBalance(userAddress),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "wallet_name": walletName,
      "is_active": isActive,
      "data_key": dataKey.toJson(),
      "is_backedUp": isBackedUp,
      "created_time": createdTime.toIso8601String(),
    };
  }

  HDWalletModel copyWith({
    String? walletName,
    bool? isActive,
    HDDataKey? dataKey,
    bool? isBackedUp,
    DateTime? createdTime,
  }) {
    return HDWalletModel(
      walletName: walletName ?? this.walletName,
      isActive: isActive ?? this.isActive,
      dataKey: dataKey ?? this.dataKey,
      isBackedUp: isBackedUp ?? this.isBackedUp,
      createdTime: createdTime ?? this.createdTime,
    );
  }
}
