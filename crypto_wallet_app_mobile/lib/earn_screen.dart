import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for Clipboard
import 'package:provider/provider.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';
import 'package:crypto_wallet_app_mobile/models/hd_wallet_model.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class EarnScreen extends StatefulWidget {
  const EarnScreen({super.key});

  @override
  State<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen>
    with SingleTickerProviderStateMixin {
  bool isClickedObscure = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void switchObscure() {
    setState(() {
      isClickedObscure = !isClickedObscure;
    });
  }

  // Modified copy function to ensure snackbar context
  void _copyToClipboard(String textToCopy) {
    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      // Ensure the widget is still mounted before showing the SnackBar
      if (mounted) {
        // Access the nearest ScaffoldMessengerState using the context
        // This context should be a descendant of the Scaffold in HomeScreen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet identifier copied!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  final List<String> _tabTitles = ["Stake", "Binance Earn", "Farm"];

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final HDWalletModel? activeWallet = walletProvider.selectedWallet;
    final bool isLoading = walletProvider.isLoading;

    final String walletIdentifier =
        activeWallet?.dataKey.masterPublicKeyXpub ?? "No Wallet Selected";

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Equity Value",
                          style: TextStyle(color: AppColors.textColor),
                        ),
                        IconButton(
                          onPressed: switchObscure,
                          icon: Icon(
                            isClickedObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: AppSizes.iconSize(context) * 1.5,
                            color: AppColors.iconColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isClickedObscure ? "\$0" : "******",
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    // Row for Wallet Identifier and Copy Icon
                    Row(
                      mainAxisSize: MainAxisSize.min, // Make row take min space
                      children: [
                        // Use SelectableText for the wallet identifier
                        Expanded(
                          // Allow text to take available space
                          child: SelectableText(
                            isClickedObscure
                                ? "Your master public key: \n $walletIdentifier"
                                : "***********",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!isClickedObscure ||
                            isClickedObscure) // Only show copy icon if not obscured
                          IconButton(
                            onPressed: () {
                              _copyToClipboard(walletIdentifier);
                            },
                            icon: const Icon(
                              Icons.copy,
                              color: Colors.white54,
                              size: 20,
                            ), // Distinct copy icon
                            tooltip:
                                'Copy wallet identifier', // Provides a hint on long press
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "All products",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TabBar(
                      labelStyle: TextStyle(
                        overflow: TextOverflow.visible,
                        fontSize: AppSizes.textSize(context),
                      ),
                      labelPadding: EdgeInsets.zero,
                      controller: _tabController,
                      indicatorColor: AppColors.defaultThemePurple,
                      tabs: List.generate(_tabTitles.length, (index) {
                        return Tab(text: _tabTitles[index]);
                      }),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          Center(
                            child: Text(
                              "Stake",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Center(
                            child: Text(
                              "Binance Earn",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Center(
                            child: Text(
                              "Farm",
                              style: TextStyle(color: Colors.white),
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
