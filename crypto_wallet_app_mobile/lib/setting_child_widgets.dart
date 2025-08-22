import 'dart:ui';

import 'package:flutter/material.dart';
//import 'package:crypto_wallet_app_mobile/functions/reusable_functions.dart';
import 'package:crypto_wallet_app_mobile/settings_screen.dart';
import 'package:crypto_wallet_app_mobile/widgets/simple_appbar.dart';

import 'constants/app_colors.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  void _onTap(String label) {
    debugPrint("Tapped on $label");
    // You can implement navigation or toggles here
  }

  Widget buildTile(
    String title, {
    String? trailing,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                subtitle,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            )
          : null,
      trailing: trailing != null
          ? Text(trailing, style: const TextStyle(color: Colors.grey))
          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget buildSection(List<Widget> tiles) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: tiles),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.iconColor),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
      ),
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildSection([
              buildTile(
                'Pattern Unlock',
                trailing: 'Off',
                onTap: () => _onTap('Pattern Unlock'),
              ),
              buildTile('Touch ID', onTap: () => _onTap('Touch ID')),
            ]),
            buildSection([
              buildTile(
                'Auto Signing',
                trailing: 'Off',
                subtitle:
                    'In Auto Signing mode, you can sign transactions without authentication after signing the first transaction in a specific timeframe. This mode only works on software wallets and does not work when biometric verification is enabled.',
                onTap: () => _onTap('Auto Signing'),
              ),
            ]),
            buildSection([
              buildTile(
                'Auto Lock',
                trailing: 'Off',
                subtitle:
                    'Automatically lock your wallet after your SafePal App is inactive in the background for some time.',
                onTap: () => _onTap('Auto Lock'),
              ),
            ]),
            buildSection([
              buildTile(
                'Change Security Password',
                onTap: () => _onTap('Change Security Password'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({super.key});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: SimpleAppbarWidget(appbarTitle: "Address Book"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 100),
              Center(
                child: Text(
                  "Contents will be shown here",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NodeSettingsPage extends StatefulWidget {
  const NodeSettingsPage({super.key});

  @override
  State<NodeSettingsPage> createState() => _NodeSettingsPageState();
}

class _NodeSettingsPageState extends State<NodeSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const SimpleAppbarWidget(appbarTitle: "DApp Node Settings"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Minimal Search Bar using TextField
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey.shade400),
                  hintText: 'Search Network',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Add content below
          ],
        ),
      ),
    );
  }
}

class CustomNetworkPage extends StatefulWidget {
  const CustomNetworkPage({super.key});

  @override
  State<CustomNetworkPage> createState() => _CustomNetworkPageState();
}

class _CustomNetworkPageState extends State<CustomNetworkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppbarWidget(appbarTitle: "Custom Network"),
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  "No Networks to add yet",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Add button at the bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardWidgetColored,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  debugPrint("Add Network button tapped");
                },
                child: const Text(
                  "Add Network",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showAppearanceSwitcherBottomSheet({
  required BuildContext context,
  required AppearanceMode currentMode,
  required ValueChanged<AppearanceMode> onSelect,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: 300, // Adjust height as needed
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color.fromARGB(125, 60, 60, 60),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Appearance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Light Mode Option
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Light Mode',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: currentMode == AppearanceMode.light
                      ? const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.greenAccent,
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(width: 24),
                  onTap: () {
                    onSelect(AppearanceMode.light);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Dark Mode Option
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: currentMode == AppearanceMode.dark
                      ? const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.greenAccent,
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(width: 24),
                  onTap: () {
                    onSelect(AppearanceMode.dark);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

enum TransactionCost { low, middle, high }

void showTransactionCostBottomSheet({
  required BuildContext context,
  required TransactionCost currentCost,
  required ValueChanged<TransactionCost> onSelect,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: 300, // You can adjust this as needed
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color.fromARGB(125, 60, 60, 60),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Transaction Cost',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Low
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Low',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: currentCost == TransactionCost.low
                      ? const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.greenAccent,
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(width: 24),
                  onTap: () {
                    onSelect(TransactionCost.low);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Middle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'Middle',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: currentCost == TransactionCost.middle
                      ? const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.greenAccent,
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(width: 24),
                  onTap: () {
                    onSelect(TransactionCost.middle);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // High
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: const Text(
                    'High',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: currentCost == TransactionCost.high
                      ? const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.greenAccent,
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(width: 24),
                  onTap: () {
                    onSelect(TransactionCost.high);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

enum FiatCurrency {
  usd,
  inr,
  jpy,
  eur;

  String get code {
    switch (this) {
      case FiatCurrency.usd:
        return "USD";
      case FiatCurrency.inr:
        return "INR";
      case FiatCurrency.jpy:
        return "JPY";
      case FiatCurrency.eur:
        return "EUR";
    }
  }

  String get symbol {
    switch (this) {
      case FiatCurrency.usd:
        return "\$";
      case FiatCurrency.inr:
        return "₹";
      case FiatCurrency.jpy:
        return "¥";
      case FiatCurrency.eur:
        return "€";
    }
  }
}

extension FiatCurrencyExtension on FiatCurrency {
  String get code => name.toUpperCase();
}

const Map<FiatCurrency, double> fiatConversionRates = {
  FiatCurrency.usd: 1.0,
  FiatCurrency.inr: 86.05,
  FiatCurrency.jpy: 145.04,
  FiatCurrency.eur: 0.86,
};

void showFiatCurrencyBottomSheet({
  required BuildContext context,
  required FiatCurrency currentCurrency,
  required ValueChanged<FiatCurrency> onSelect,
}) {
  final TextEditingController searchController = TextEditingController();
  String searchTerm = '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final filteredCurrencies = FiatCurrency.values
              .where(
                (currency) => currency.code.toLowerCase().contains(
                  searchTerm.toLowerCase(),
                ),
              )
              .toList();

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              height: 500,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(125, 60, 60, 60),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Select Fiat Currency',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Minimal Search Bar — Typing now works
                  TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      hintText: 'Search currency...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        searchTerm = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: filteredCurrencies.isEmpty
                        ? const Center(
                            child: Text(
                              "No currency found",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredCurrencies.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final currency = filteredCurrencies[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text(
                                    currency.code,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  trailing: currentCurrency == currency
                                      ? const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.greenAccent,
                                          child: Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const SizedBox(width: 24),
                                  onTap: () {
                                    onSelect(currency);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

enum AppLanguage { english, hindi, spanish, chinese, japanese, german, french }

extension AppLanguageExtension on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.english:
        return "English";
      case AppLanguage.hindi:
        return "Hindi";
      case AppLanguage.spanish:
        return "Spanish";
      case AppLanguage.chinese:
        return "Chinese";
      case AppLanguage.japanese:
        return "Japanese";
      case AppLanguage.german:
        return "German";
      case AppLanguage.french:
        return "French";
    }
  }
}

void showLanguageSelectorBottomSheet({
  required BuildContext context,
  required AppLanguage currentLanguage,
  required ValueChanged<AppLanguage> onSelect,
}) {
  final TextEditingController searchController = TextEditingController();
  String searchTerm = '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final filteredLanguages = AppLanguage.values
              .where(
                (lang) =>
                    lang.label.toLowerCase().contains(searchTerm.toLowerCase()),
              )
              .toList();

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 500,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Select Language',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔍 Minimal Search Bar
                  TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      hintText: 'Search language...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setModalState(() => searchTerm = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: filteredLanguages.isEmpty
                        ? const Center(
                            child: Text(
                              "No language found",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredLanguages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final lang = filteredLanguages[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text(
                                    lang.label,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  trailing: currentLanguage == lang
                                      ? const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.greenAccent,
                                          child: Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const SizedBox(width: 24),
                                  onTap: () {
                                    onSelect(lang);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
