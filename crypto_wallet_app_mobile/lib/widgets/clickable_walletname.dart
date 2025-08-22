import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_wallet_app_mobile/constants/app_colors.dart';
import 'package:crypto_wallet_app_mobile/constants/app_sizes.dart';
import 'package:crypto_wallet_app_mobile/functions/reusable_functions.dart';
import 'package:crypto_wallet_app_mobile/new_wallet_create.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';
import 'package:crypto_wallet_app_mobile/models/hd_wallet_model.dart';
import 'package:crypto_wallet_app_mobile/wallet_info.dart'; // Make sure this import is correct

// Dummy NavigationHelper to make the code compile if not already defined
// class NavigationHelper {
//   static void push(BuildContext context, Widget newRoute) {
//     Navigator.of(context).push(MaterialPageRoute(builder: (context) => newRoute));
//   }
// }

class ClickableWalletName extends StatelessWidget {
  final VoidCallback? onWalletSwitched;

  const ClickableWalletName({super.key, this.onWalletSwitched});

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final HDWalletModel? activeWallet = walletProvider.selectedWallet;

    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = AppSizes.textSize(context);

    final String currentWalletName = activeWallet?.walletName ?? "No Wallet";

    return InkWell(
      onTap: () async {
        final List<HDWalletModel> wallets = walletProvider.allWallets;

        if (!context.mounted) return;

        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                child: Container(
                  height: screenHeight * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800.withAlpha((0.68 * 255).toInt()),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        height: 10,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color.fromRGBO(140, 140, 139, 0.5),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "My Wallets",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: textScale * 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: wallets.isEmpty
                            ? Center(
                                child: Text(
                                  "No HD Wallets found. Create one!",
                                  style: TextStyle(
                                    color: AppColors.textColor,
                                    fontSize: AppSizes.textSize(context),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: wallets.length,
                                itemBuilder: (context, index) {
                                  final wallet = wallets[index];
                                  final isCurrentlyActive =
                                      walletProvider
                                          .selectedWallet
                                          ?.walletName ==
                                      wallet.walletName;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isCurrentlyActive
                                            ? AppColors.defaultThemePurple
                                                  .withAlpha(76)
                                            : Colors.grey.shade700.withAlpha(
                                                70,
                                              ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: isCurrentlyActive
                                            ? Border.all(
                                                color: AppColors
                                                    .defaultThemePurple,
                                                width: 1.5,
                                              )
                                            : null,
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 0,
                                            ),
                                        // leading: Icon(
                                        //   Icons.account_balance_wallet,
                                        //   color: isCurrentlyActive
                                        //       ? AppColors.defaultThemePurple
                                        //       : Colors.white70,
                                        // ),
                                        title: Text(
                                          wallet.walletName,
                                          style: TextStyle(
                                            color: isCurrentlyActive
                                                ? AppColors.titleColor
                                                : AppColors.textColor,
                                            fontSize:
                                                AppSizes.textSize(context) *
                                                1.1,
                                            fontWeight: isCurrentlyActive
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isCurrentlyActive)
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  right: 8.0,
                                                ),
                                                child: Icon(
                                                  Icons.check_circle,
                                                  color: Colors.greenAccent,
                                                  size: 20,
                                                ),
                                              ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.info_outline,
                                                color: Colors.white54,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                if (context.mounted) {
                                                  Navigator.pop(
                                                    context,
                                                  ); // Close the bottom sheet first
                                                  // NEW: Pass the specific wallet object to WalletInfoPage
                                                  NavigationHelper.push(
                                                    context,
                                                    WalletInfoPage(
                                                      wallet: wallet,
                                                    ),
                                                  );
                                                }
                                              },
                                              tooltip: 'Wallet Info',
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          if (!isCurrentlyActive) {
                                            await context
                                                .read<WalletProvider>()
                                                .selectWallet(
                                                  wallet.walletName,
                                                );
                                          }

                                          if (context.mounted) {
                                            Navigator.pop(
                                              context,
                                            ); // Close bottom sheet after selection
                                          }
                                          if (onWalletSwitched != null) {
                                            onWalletSwitched!();
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.defaultThemePurple
                                .withAlpha(200),
                            foregroundColor: Colors.white,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            minimumSize: const Size.fromHeight(56),
                          ),
                          onPressed: () async {
                            if (context.mounted)
                              Navigator.pop(context); // Close current modal
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateNewWallet(),
                              ),
                            );
                            await context
                                .read<WalletProvider>()
                                .loadAllInitialData();
                            if (onWalletSwitched != null) {
                              onWalletSwitched!();
                            }
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: Text(
                            "Generate New Wallet",
                            style: TextStyle(fontSize: textScale * 1.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              currentWalletName,
              style: TextStyle(
                color: AppColors.titleColor,
                fontSize: textScale,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: AppSizes.iconSize(context),
            ),
          ],
        ),
      ),
    );
  }
}
