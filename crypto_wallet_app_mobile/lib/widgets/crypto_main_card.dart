// lib/widgets/crypto_main_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:crypto_wallet_app_mobile/crypto_info_page.dart'; // No longer navigated to directly by default
import 'package:crypto_wallet_app_mobile/constants/app_colors.dart';
import 'package:crypto_wallet_app_mobile/models/crypto_template_model.dart';
import 'package:crypto_wallet_app_mobile/models/wallet_crypto_asset_model.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';

import '../setting_child_widgets.dart';
import '../state/local_settings_provider.dart';

class CryptoMainCard extends StatelessWidget {
  final WalletCryptoAssetModel walletCryptoAsset;
  final Function(WalletCryptoAssetModel)? onTap;

  const CryptoMainCard({
    super.key,
    required this.walletCryptoAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final CryptoTemplateModel? cryptoTemplate = walletProvider
        .getCryptoTemplate(walletCryptoAsset.symbol);

    if (cryptoTemplate == null) {
      return const SizedBox.shrink();
    }

    final String imagePath = cryptoTemplate.imgPath;
    final String cryptoName = cryptoTemplate.cryptoName;
    //final double cryptoPrice = cryptoTemplate.cryptoPrice;
    final double balance = walletCryptoAsset.balance;
    //const double priceChange = -3.97; // Placeholder

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final scaleFactor = (width + height);
    final textScale = scaleFactor * 0.011;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final avatarRadius = isPortrait ? width * 0.06 : height * 0.04;
    double fontSize = (width + height) * 0.0135;

    final settings = Provider.of<LocalSettingsState>(context); // ✅ add this
    final symbol = settings.currency.symbol; // use selected currency symbol

    // final double convertedPrice =
    //     cryptoPrice * (fiatConversionRates[settings.currency] ?? 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: InkWell(
        onTap: () {
          onTap?.call(walletCryptoAsset);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: AppColors.cardWidgetBlack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            height: isPortrait ? height * 0.1 : height * 0.18,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.transparent,
                  radius: avatarRadius,
                  child: Image.asset(imagePath, fit: BoxFit.fill),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            cryptoName,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: AppColors.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Row(
                          children: [
                            // Flexible(
                            //   child: Text(
                            //     "$symbol${convertedPrice.toStringAsFixed(2)}",
                            //     style: TextStyle(
                            //       fontSize: textScale,
                            //       color: AppColors.textColor,
                            //     ),
                            //     overflow: TextOverflow.ellipsis,
                            //   ),
                            // ),
                            const SizedBox(width: 8),
                            // Flexible(
                            //   child: Text(
                            //     "${priceChange.toStringAsFixed(2)}%",
                            //     style: TextStyle(
                            //       fontSize: textScale,
                            //       color: priceChange < 0
                            //           ? Colors.red
                            //           : Colors.green,
                            //     ),
                            //     overflow: TextOverflow.ellipsis,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            balance.toStringAsFixed(4),
                            style: TextStyle(
                              fontSize: textScale,
                              color: AppColors.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            walletCryptoAsset.symbol,
                            style: TextStyle(
                              fontSize: textScale,
                              color: AppColors.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
