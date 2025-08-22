import 'dart:ui';
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'package:crypto_wallet_app_mobile/pages/enter_seed_phrase_page.dart'; // NEW: Import EnterSeedPhrasePage
//import 'package:crypto_wallet_app_mobile/services/create_store_hdwallet.dart';
//import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'enter_seed_phrase_page.dart';
import 'main_screen.dart';
import 'models/hd_wallet_model.dart'; // Assuming HomeScreen is MainScreen

class BackupScreen extends StatefulWidget {
  final HDWalletModel wallet;

  const BackupScreen({super.key, required this.wallet});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _showBackupOptions = false; // Controls UI for showing backup methods

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _showBackupOptions
          ? AppBar(
              backgroundColor: AppColors.backgroundColor,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.iconColor,
                  size: 16,
                ),
                onPressed: () => setState(() => _showBackupOptions = false),
              ),
              title: Text(
                AppStrings.backupText,
                style: TextStyle(color: AppColors.titleColor, fontSize: 18),
              ),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _showBackupOptions
              ? _backupOptions(screenHeight)
              : _walletReadyUI(),
        ),
      ),
    );
  }

  Widget _walletReadyUI() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          AppStrings.appName,
          style: const TextStyle(
            color: Colors.deepPurpleAccent,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Text(
          "Your Wallet is Ready!!",
          style: TextStyle(
            color: AppColors.titleColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Text(
          "Secure your wallet by saving your mnemonic phrase. "
          "This unique set of words is your only key to access your funds. "
          "${AppStrings.appName} cannot store or recover it for you.",
          style: TextStyle(color: AppColors.subtitleColor, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        // In BackupScreen's _walletReadyUI method, modify the backup now button:
        _actionCard(
          "${AppStrings.backupText} Now",
          AppColors.cardWidgetColored,
          () async {
            // final walletProvider = Provider.of<WalletProvider>(
            //   context,
            //   listen: false,
            // );

            final HDWalletModel displayWallet = widget.wallet;

            if (displayWallet.dataKey.seedPhrase == null) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error: Wallet seed phrase not found'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EnterSeedPhrasePage(
                  mnemonic: displayWallet.dataKey.seedPhrase!,
                  walletNameForBackup:
                      displayWallet.walletName, // Pass wallet name here
                  startInVerificationMode: false,
                  walletName: displayWallet.walletName,
                ),
              ),
            );
          },
        ),
        _actionCard(
          "Skip ${AppStrings.backupText}",
          AppColors.cardWidgetBlack,
          () async {
            // If skipping backup, just generate and store the wallet directly
            // await createAndStoreHDWallet(
            //   context: context,
            //   mnemonicToUse: generateAndReturnMnemonic(),
            // ); // Generate new mnemonic and pass it
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wallet generated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _backupOptions(double screenHeight) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "${AppStrings.backupText} mnemonic phrase",
          style: TextStyle(color: AppColors.titleColor),
        ),
        const SizedBox(height: 10),
        Text(
          "The mnemonic phrase is the master key to your wallet. It can be used to recover your wallet on any compatible device.",
          style: TextStyle(color: AppColors.subtitleColor, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // These cards will now potentially navigate to a page where you *manually* input
        // a mnemonic or handle cloud backup. For now, they can remain placeholders.
        _backupMethodCard(
          Icons.cloud_outlined,
          "${AppStrings.backupText} to Google Drive",
          screenHeight,
        ),
        _backupMethodCard(
          Icons.description_outlined,
          "${AppStrings.backupText} manually",
          screenHeight,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              const Text(
                "Learn more about mnemonic phrases ",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () {},
                child: const Text(
                  "here",
                  style: TextStyle(color: Colors.deepPurpleAccent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionCard(String title, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Card(
          elevation: 4,
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(title, style: TextStyle(color: AppColors.titleColor)),
          ),
        ),
      ),
    );
  }

  Widget _backupMethodCard(IconData icon, String title, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: screenHeight * 0.6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withAlpha(217),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const Text(
                          "Backup steps go here",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Card(
          elevation: 3,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.cardWidgetBlack,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(icon, color: AppColors.iconColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: AppColors.iconColor),
                    overflow: TextOverflow.ellipsis,
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
