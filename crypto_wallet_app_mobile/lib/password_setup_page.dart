// lib/password_setup_page.dart (or wherever your PasswordSetupPage resides)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto_wallet_app_mobile/services/create_store_hdwallet.dart';
import 'package:crypto_wallet_app_mobile/utils/secure_storage_helper.dart';

import 'add_existing_wallet_page.dart';
import 'backup_screen.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'models/hd_wallet_model.dart';

class PasswordSetupPage extends StatefulWidget {
  final bool isImportingWallet; // <--- NEW: Add this property

  const PasswordSetupPage({
    super.key,
    this.isImportingWallet = false,
  }); // <--- NEW: Add to constructor

  @override
  State<PasswordSetupPage> createState() => _PasswordSetupPageState();
}

class _PasswordSetupPageState extends State<PasswordSetupPage> {
  List<String> inputs = [];
  List<String> originalPassword = [];
  bool isConfirming = false;

  String get _password => inputs.join();

  void addDigit(String digit) {
    if (inputs.length < 6) {
      setState(() {
        inputs.add(digit);
      });
    }

    if (inputs.length == 6) {
      Future.delayed(const Duration(milliseconds: 300), () {
        isConfirming ? _confirmPassword() : _moveToConfirmation();
      });
    }
  }

  void deleteDigit() {
    if (inputs.isNotEmpty) {
      setState(() {
        inputs.removeLast();
      });
    }
  }

  void _moveToConfirmation() {
    originalPassword = List.from(inputs);
    setState(() {
      inputs.clear();
      isConfirming = true;
    });
  }

  void _confirmPassword() async {
    final String generatedMnemonic = generateAndReturnMnemonic();
    if (listEquals(inputs, originalPassword)) {
      await _savePassword(_password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password Saved Successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // <--- NEW LOGIC HERE: Conditional navigation based on isImportingWallet
        if (widget.isImportingWallet) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExistingWalletPage(),
            ),
          );
        } else {
          final HDWalletModel newWallet = await createAndStoreHDWallet(
            context: context,
            mnemonicToUse: generatedMnemonic,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BackupScreen(wallet: newWallet),
            ),
          );
        }
        // END NEW LOGIC
      }
    } else {
      setState(() {
        inputs.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _savePassword(String password) async {
    final storage = SecureStorageHelper();
    try {
      await storage.write(key: 'user_password', value: password);
      if (kDebugMode) print('Password saved successfully');
    } catch (e) {
      if (kDebugMode) print('Error saving password: $e');
    }
  }

  Widget _buildInputCircles(double height, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        bool filled = index < inputs.length;
        return Expanded(
          child: Container(
            height: height,
            width: width,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: filled
                  ? AppColors.defaultThemePurple
                  : AppColors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.defaultThemePurple),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypadButton(
    String value, {
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap ?? () => addDigit(value),
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: Colors.white)
                : Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          children: [
            _buildKeypadButton('1'),
            _buildKeypadButton('2'),
            _buildKeypadButton('3'),
          ],
        ),
        Row(
          children: [
            _buildKeypadButton('4'),
            _buildKeypadButton('5'),
            _buildKeypadButton('6'),
          ],
        ),
        Row(
          children: [
            _buildKeypadButton('7'),
            _buildKeypadButton('8'),
            _buildKeypadButton('9'),
          ],
        ),
        Row(
          children: [
            const Spacer(),
            _buildKeypadButton('0'),
            _buildKeypadButton('', icon: Icons.backspace, onTap: deleteDigit),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: IntrinsicHeight(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.iconColor,
                  size: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isConfirming
                  ? "Confirm your ${AppStrings.passwordText}"
                  : "Create a 6-digit ${AppStrings.passwordText}",
              style: const TextStyle(
                color: AppColors.titleColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildInputCircles(
                MediaQuery.of(context).size.height * 0.07,
                MediaQuery.of(context).size.width * 0.07,
              ),
            ),
            const Spacer(),
            _buildKeypad(),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Platform.isWindows
            ? SingleChildScrollView(child: content)
            : content,
      ),
    );
  }
}
