// lib/pages/enter_seed_phrase_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';
//import 'package:crypto_wallet_app_mobile/models/hd_wallet_model.dart';
//import 'package:crypto_wallet_app_mobile/services/create_store_hdwallet.dart'; // Import your wallet creation function
import 'package:crypto_wallet_app_mobile/widgets/text_area_widget.dart';
import 'package:crypto_wallet_app_mobile/main_screen.dart'; // Assuming HomeScreen is MainScreen
import 'package:no_screenshot/no_screenshot.dart';

import '../constants/app_colors.dart';

class EnterSeedPhrasePage extends StatefulWidget {
  final String mnemonic;
  final String? walletNameForBackup; // New optional parameter for backup flow
  final bool startInVerificationMode; // New parameter to control initial mode

  const EnterSeedPhrasePage({
    super.key,
    required this.mnemonic,
    this.walletNameForBackup,
    this.startInVerificationMode =
        false, // Default to false for new wallet flow
    required String walletName,
  });

  @override
  State<EnterSeedPhrasePage> createState() => _EnterSeedPhrasePageState();
}

class _EnterSeedPhrasePageState extends State<EnterSeedPhrasePage> {
  late bool _isVerificationMode;
  String _enteredMnemonic = '';
  String? _verificationError;
  bool _isProcessing = false;

  final _noScreenshot = NoScreenshot.instance;
  bool _isScreenshotPreventionActive = true;

  @override
  void initState() {
    super.initState();
    _noScreenshot.screenshotOff();
    _isScreenshotPreventionActive = true;
    debugPrint(
      'Screenshot prevention activated by default for EnterSeedPhrasePage.',
    );

    _isVerificationMode = widget.startInVerificationMode;
  }

  @override
  void dispose() {
    _noScreenshot.screenshotOn();
    debugPrint(
      'Screenshot prevention deactivated on page dispose for EnterSeedPhrasePage.',
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isVerificationMode ? "Verify Mnemonic" : "Your Mnemonic Phrase",
          style: TextStyle(color: AppColors.titleColor, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isScreenshotPreventionActive ? Icons.lock : Icons.lock_open,
              color: AppColors.iconColor,
            ),
            tooltip: _isScreenshotPreventionActive
                ? 'Disable Screenshot Protection'
                : 'Enable Screenshot Protection',
            onPressed: () {
              setState(() {
                _isScreenshotPreventionActive = !_isScreenshotPreventionActive;
              });
              if (_isScreenshotPreventionActive) {
                _noScreenshot.screenshotOff();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Screenshot protection ON')),
                );
              } else {
                _noScreenshot.screenshotOn();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Screenshot protection OFF')),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                _isVerificationMode
                    ? "Please re-enter your mnemonic phrase to verify it word by word."
                    : "Write down these words in order and keep them in a safe place. You will need them to recover your wallet.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.subtitleColor, fontSize: 14),
              ),
              const SizedBox(height: 30),

              TextAreaWidget(
                initialText: _isVerificationMode ? null : widget.mnemonic,
                isEditable: _isVerificationMode,
                onChanged: (text) {
                  setState(() {
                    _enteredMnemonic = text;
                    _verificationError = null;
                  });
                },
              ),

              if (_verificationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _verificationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (!_isVerificationMode) // Only show NOTE for new wallet creation flow
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "NOTE:",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "1. Do NOT share your mnemonic phrase with anyone.",
                        style: TextStyle(
                          color: AppColors.subtitleColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "2. Do NOT store it digitally (e.g., screenshots, cloud storage, email).",
                        style: TextStyle(
                          color: AppColors.subtitleColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "3. Write it down on paper and store it in a secure, private location.",
                        style: TextStyle(
                          color: AppColors.subtitleColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "4. Losing this phrase means losing access to your funds.",
                        style: TextStyle(
                          color: AppColors.subtitleColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),

              _isVerificationMode
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.defaultThemePurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // In the verification button onPressed handler:
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              if (_enteredMnemonic.trim().toLowerCase() ==
                                  widget.mnemonic.trim().toLowerCase()) {
                                setState(() {
                                  _isProcessing = true;
                                });

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Mnemonic verified!'),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                }

                                final walletProvider =
                                    Provider.of<WalletProvider>(
                                      context,
                                      listen: false,
                                    );

                                try {
                                  // Only update backup status, don't create a new wallet
                                  await walletProvider.updateWalletBackupStatus(
                                    widget
                                        .walletNameForBackup!, // This should be passed from BackupScreen
                                    true, // Set to true as verification succeeded
                                  );

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Wallet backup verified successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    // Navigate to home screen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HomeScreen(),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error updating backup status: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  debugPrint(
                                    'Error during backup status update: $e',
                                  );
                                }
                              } else {
                                setState(() {
                                  _verificationError =
                                      "Mnemonic does not match. Please try again.";
                                });
                              }
                              setState(() {
                                _isProcessing = false;
                              });
                            },
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Verify Mnemonic"),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.defaultThemePurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isVerificationMode = true;
                          _verificationError = null;
                        });
                      },

                      child: const Text("I have written it down"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
