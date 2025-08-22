import 'dart:ui'; // For BackdropFilter
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle and Clipboard
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart'; // NEW: Import qr_flutter
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';
import 'package:crypto_wallet_app_mobile/models/hd_wallet_model.dart';
import 'package:crypto_wallet_app_mobile/models/wallet_crypto_asset_model.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../crypto_info_page.dart';
import '../widgets/crypto_main_card.dart'; // Your reusable card

class SendReceivePage extends StatefulWidget {
  final String title;

  const SendReceivePage({super.key, required this.title});

  @override
  State<SendReceivePage> createState() => _SendReceivePage();
}

class _SendReceivePage extends State<SendReceivePage> {
  @override
  void initState() {
    super.initState();
  }

  // --- Helper methods for QR Bottom Sheet ---

  // Function to copy text to clipboard and show a snackbar
  void _copyToClipboard(String textToCopy, String cryptoSymbol) {
    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$cryptoSymbol address copied!'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.defaultThemePurple,
          ),
        );
      }
    });
  }

  // Method to show the receive QR bottom sheet
  Future<void> _showReceiveQRBottomSheet(
    BuildContext context,
    WalletCryptoAssetModel asset,
  ) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final String cryptoSymbol = asset.symbol;
    final String publicAddress = asset.publicAddress;

    // Get the crypto template for image path
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final cryptoTemplate = walletProvider.getCryptoTemplate(cryptoSymbol);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              height: screenHeight * 0.7,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade800.withAlpha((0.8 * 255).toInt()),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    "Receive $cryptoSymbol",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: publicAddress,
                      version: QrVersions.auto,
                      size: screenHeight * 0.25,
                      gapless: true,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SelectableText(
                      publicAddress,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.defaultThemePurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          _copyToClipboard(publicAddress, cryptoSymbol);
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy Address"),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.defaultThemePurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          // TODO: Implement share functionality (e.g., using share_plus package)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Share functionality not implemented yet.',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (cryptoTemplate != null)
                    Image.asset(cryptoTemplate.imgPath, height: 40, width: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Widget for displaying crypto list ---
  Widget _cryptoListWidget(List<WalletCryptoAssetModel> assets) {
    if (assets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No crypto assets found in this wallet.",
            style: TextStyle(color: AppColors.subtitleColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Determine the onTap action based on the page title
    Function(WalletCryptoAssetModel)? cardOnTap;
    if (widget.title == "Receive") {
      cardOnTap = (asset) => _showReceiveQRBottomSheet(context, asset);
    } else if (widget.title == "Send") {
      cardOnTap = (asset) {
        // Example for Send page: Navigate to a SendCryptoPage
        // Make sure CryptoInfoPage is appropriately named for sending or you create a new SendCryptoPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CryptoInfoPage(
              // Or a dedicated SendCryptoPage
              walletCryptoAsset: asset,
              // You might pass an argument indicating "send mode"
            ),
          ),
        );
        if (kDebugMode) {
          print('Tapped ${asset.symbol} for SEND action');
        }
      };
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final walletCryptoAsset = assets[index];
        return CryptoMainCard(
          walletCryptoAsset: walletCryptoAsset,
          onTap: cardOnTap, // Pass the determined onTap callback
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final HDWalletModel? activeWallet = walletProvider.selectedWallet;
    final bool isLoading = walletProvider.isLoading;

    List<WalletCryptoAssetModel> currentWalletAssets = [];
    if (activeWallet != null) {
      currentWalletAssets = activeWallet.dataKey.childKeys;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          title: Text(
            widget.title,
            style: TextStyle(
              color: AppColors.titleColor,
              fontSize: AppSizes.textSize(context),
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.iconColor,
              size: AppSizes.iconSize(context),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SearchBar(
                        hintText: "Search",
                        hintStyle: WidgetStateProperty.all(
                          const TextStyle(color: Colors.grey),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          const Color(0xFF1E1E1E),
                        ),
                        leading: Icon(Icons.search, color: AppColors.iconColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // This section now always shows assets, but onTap behavior differs
                  _cryptoListWidget(currentWalletAssets),
                ],
              ),
            ),
    );
  }
}
