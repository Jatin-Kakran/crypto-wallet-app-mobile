import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_wallet_app_mobile/constants/app_colors.dart';
import 'package:crypto_wallet_app_mobile/functions/reusable_functions.dart';
import 'package:crypto_wallet_app_mobile/setting_child_widgets.dart';
import 'package:crypto_wallet_app_mobile/state/local_settings_provider.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';

import 'delete_splash_page.dart';

enum AppearanceMode { light, dark }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _onTap(String label) {
    debugPrint("Tapped on $label");
    // Handle tap actions if needed
  }

  Widget buildSection(List<Widget> tiles) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: tiles),
    );
  }

  Widget buildTile(String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      trailing:
          trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: Colors.grey,
            weight: 0.1,
          ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalSettingsState>(
      builder: (context, settings, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios, color: AppColors.iconColor),
            ),
            centerTitle: true,
            backgroundColor: AppColors.backgroundColor,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                buildSection([
                  buildTile(
                    'Security',
                    onTap: () => NavigationHelper.push(context, SecurityPage()),
                  ),
                ]),
                buildSection([
                  buildTile(
                    'Address Book',
                    onTap: () =>
                        NavigationHelper.push(context, AddressBookPage()),
                  ),
                  buildTile(
                    'Node Settings',
                    onTap: () =>
                        NavigationHelper.push(context, NodeSettingsPage()),
                  ),
                  buildTile(
                    'Custom Network',
                    onTap: () =>
                        NavigationHelper.push(context, CustomNetworkPage()),
                  ),
                  buildTile(
                    'Clear Cache',
                    onTap: () => showAlertBoxWithTimer(
                      context: context,
                      message:
                          "This will permanently delete all wallets, private keys,"
                          " and associated balances stored on this device."
                          " This action is irreversible."
                          " Make sure you have backed up all necessary information before continuing.",
                      onYes: () {
                        Provider.of<WalletProvider>(
                          context,
                          listen: false,
                        ).deleteAllWallets().then((_) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WalletDeletionSplashPage(),
                            ),
                            (route) => false,
                          );
                        });
                      },
                      countdownSeconds: 10,
                    ),
                  ),
                ]),
                buildSection([
                  buildTile(
                    'Appearance',
                    trailing: Text(
                      settings.appearance == AppearanceMode.dark
                          ? 'Dark Mode'
                          : 'Light Mode',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    onTap: () => showAppearanceSwitcherBottomSheet(
                      context: context,
                      currentMode: settings.appearance,
                      onSelect: (mode) => settings.setAppearance(mode),
                    ),
                  ),
                  buildTile(
                    'Transaction Cost',
                    trailing: Text(
                      settings.txCost.name,
                      style: TextStyle(color: Colors.grey.shade400),
                    ), // Add .toUpperCase() if needed
                    onTap: () => showTransactionCostBottomSheet(
                      context: context,
                      currentCost: settings.txCost,
                      onSelect: (cost) => settings.setTransactionCost(cost),
                    ),
                  ),
                  buildTile(
                    'Fiat Currency',
                    trailing: Text(
                      settings.currency.code,
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    onTap: () => showFiatCurrencyBottomSheet(
                      context: context,
                      currentCurrency: settings.currency,
                      onSelect: (currency) => settings.setCurrency(currency),
                    ),
                  ),
                  buildTile(
                    'Language',
                    trailing: Text(
                      settings.language.label,
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    onTap: () => showLanguageSelectorBottomSheet(
                      context: context,
                      currentLanguage: settings.language,
                      onSelect: (lang) => settings.setLanguage(lang),
                    ),
                  ),
                  buildTile(
                    'K-Line Color',
                    trailing: const SizedBox(
                      width: 30, // or any value that fits
                      child: _KLineColorIcon(),
                    ),
                    onTap: () => _onTap("K-Line Color"),
                  ),
                ]),
                buildSection([
                  buildTile('Help Center', onTap: () => _onTap("Help Center")),
                  buildTile('Support', onTap: () => _onTap("Support")),
                  buildTile('Community', onTap: () => _onTap("Community")),
                  buildTile(
                    'About',
                    trailing: Text(
                      'V1.0.0',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    onTap: () => _onTap("About"),
                  ),
                ]),
                const SizedBox(height: 150),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KLineColorIcon extends StatelessWidget {
  const _KLineColorIcon();

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<LocalSettingsState>(context);

    return Row(
      children: [
        Container(
          width: 7,
          height: 14,
          decoration: BoxDecoration(
            color: settings.kLineColorDown,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 7,
          height: 14,
          decoration: BoxDecoration(
            color: settings.kLineColorUp,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
