import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:crypto_wallet_app_mobile/action_buttons_pages/send_recieve_page.dart';
import 'package:crypto_wallet_app_mobile/state/eth_balance_provider.dart';
//import 'package:crypto_wallet_app_mobile/state/local_settings_provider.dart';
import 'package:crypto_wallet_app_mobile/widgets/crypto_main_card.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';
import 'package:crypto_wallet_app_mobile/models/hd_wallet_model.dart';
import 'package:crypto_wallet_app_mobile/models/wallet_crypto_asset_model.dart';
import 'package:crypto_wallet_app_mobile/crypto_info_page.dart'; // <--- NEW: Import CryptoInfoPage
import 'package:crypto_wallet_app_mobile/widgets/eth_price_card.dart';

//import 'action_buttons_pages/buy_sell_page.dart';
//import 'action_buttons_pages/index_page.dart';
import 'constants/app_colors.dart';
import 'constants/app_exchanges.dart';
import 'constants/app_strings.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  final ScrollController _scrollController = ScrollController();
  bool isObscure = true;

  @override
  void initState() {
    super.initState();
  }

  void isObscureChecked() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // void _deleteAccount() async {
  //   final walletProvider = Provider.of<WalletProvider>(context, listen: false);
  //   try {
  //     await walletProvider.deleteAllWallets();
  //     if (!mounted) return;
  //     Navigator.pushReplacementNamed(context, '/login_page');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('All wallets deleted successfully!')),
  //     );
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error deleting wallets: ${e.toString()}')),
  //       );
  //     }
  //   }
  // }

  void _readAllWalletsInConsole() async {
    final storage = FlutterSecureStorage();
    try {
      Map<String, String> readAllWalletsInConsole = await storage
          .readAll(); // Corrected return type to Map<String, String>
      if (kDebugMode) {
        print("Secure Storage value read successfully");
        print(readAllWalletsInConsole); // Print the content for debugging
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error to read: $e");
      }
    }
  }

  // lib/pages/homepage.dart

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final HDWalletModel? activeWallet = walletProvider.selectedWallet;
    final bool isLoading = walletProvider.isLoading;

    double totalBalanceUSD = 0.0;
    if (activeWallet != null) {
      for (WalletCryptoAssetModel asset in activeWallet.dataKey.childKeys) {
        final cryptoTemplate = walletProvider.getCryptoTemplate(asset.symbol);
        if (cryptoTemplate != null) {
          totalBalanceUSD += asset.balance * cryptoTemplate.cryptoPrice;
        }
      }
    }

    double totalBalanceBTC = 0.0;
    final btcTemplate = walletProvider.getCryptoTemplate('BTC');
    if (btcTemplate != null && btcTemplate.cryptoPrice > 0) {
      totalBalanceBTC = totalBalanceUSD / btcTemplate.cryptoPrice;
    }

    //final double balance = walletCryptoAsset.balance;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Material(
            color: Colors.black,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Balance',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          IconButton(
                            onPressed: isObscureChecked,
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // SelectableText(
                      //   isObscure
                      //       ? '******'
                      //       :
                      //       FiatPriceConverter(
                      //           context,
                      //           listen: true,
                      //         ).format(totalBalanceUSD),
                      //   style: const TextStyle(
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.white,
                      //   ),
                      // ),
                      TotalBalanceObscureWidget(isObscure: isObscure),
                      // Text(
                      //   isObscure
                      //       ? '****** BTC'
                      //       : "${totalBalanceBTC.toStringAsFixed(6)} BTC",
                      //   style: const TextStyle(color: Colors.grey),
                      // ),
                      isObscure
                          ? const SizedBox(height: 4)
                          : const SizedBox(height: 1),
                      isObscure
                          ? const Text(
                              "******",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            )
                          : const Text(""),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(Icons.arrow_upward, 'Send', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SendReceivePage(title: 'Send'),
                              ),
                            );
                          }),
                          _buildActionButton(
                            Icons.arrow_downward,
                            'Receive',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SendReceivePage(title: 'Receive'),
                                ),
                              );
                            },
                          ),
                          _buildActionButton(
                            Icons.list,
                            "Values",
                            _readAllWalletsInConsole,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ✅ NEW: Place the EthPriceCard widget here
                const EthPriceCard(),

                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      setState(() {
                        // _scrollOffset = scrollInfo.metrics.pixels;
                      });
                      return true;
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (activeWallet != null &&
                                    activeWallet.dataKey.childKeys.isNotEmpty) {
                                  final asset =
                                      activeWallet.dataKey.childKeys[index];
                                  return CryptoMainCard(
                                    walletCryptoAsset: asset,
                                    onTap: (tappedAsset) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CryptoInfoPage(
                                            walletCryptoAsset: tappedAsset,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              childCount:
                                  activeWallet?.dataKey.childKeys.length ?? 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final iconScale = (screenWidth + screenHeight) * 0.018;
    //final textScale = (screenWidth + screenHeight) * 0.015;

    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: iconScale * 1.15,
            backgroundColor: Colors.blueAccent,
            child: Center(
              child: IconButton(
                icon: Icon(icon, color: AppColors.iconColor, size: iconScale),
                onPressed: onTap,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Text(
          //   label,
          //   style: TextStyle(color: AppColors.textColor, fontSize: textScale),
          //   overflow: TextOverflow.ellipsis,
          // ),
        ],
      ),
    );
  }
}
