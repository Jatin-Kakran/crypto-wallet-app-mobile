import 'package:flutter/material.dart';
import 'package:crypto_wallet_app_mobile/add_existing_wallet_page.dart';
//import 'package:crypto_wallet_app_mobile/functions/reusable_functions.dart';
import 'package:crypto_wallet_app_mobile/services/create_store_hdwallet.dart';
import 'backup_screen.dart';
import 'constants/app_colors.dart'; // Ensure this is correct and not empty
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//import 'enter_seed_phrase_page.dart';

class CreateNewWallet extends StatefulWidget {
  const CreateNewWallet({super.key});

  @override
  State<CreateNewWallet> createState() => _CreateNewWalletState();
}

class _CreateNewWalletState extends State<CreateNewWallet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.iconColor),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Add wallet",
                  style: TextStyle(color: AppColors.textColor, fontSize: 15),
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(2, (index) {
                List<IconData> cardIcons = [
                  Icons.create_new_folder,
                  Icons.folder,
                ];
                List<String> cardTitle = [
                  "Create new wallet",
                  "Add existing wallet",
                ];

                return cardWidget(cardIcons[index], cardTitle[index]);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardWidget(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: InkWell(
        onTap: () async {
          // Store context in a local variable before async operations
          final currentContext = context;

          showModalBottomSheet(
            context: currentContext,
            isScrollControlled: true,
            backgroundColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => PasswordBottomSheet(
              onSuccess: () async {
                try {
                  // First close the bottom sheet
                  Navigator.pop(currentContext);

                  if (title == "Create new wallet") {
                    // Show loading indicator
                    showDialog(
                      context: currentContext,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    // Create new wallet
                    final newWallet = await createAndStoreHDWallet(
                      context: currentContext,
                      mnemonicToUse: generateAndReturnMnemonic(),
                    );

                    // Dismiss loading indicator
                    Navigator.pop(currentContext);

                    // Check if widget is still mounted
                    if (!mounted) return;

                    // Navigate to backup screen
                    Navigator.push(
                      currentContext,
                      MaterialPageRoute(
                        builder: (_) => BackupScreen(wallet: newWallet),
                      ),
                    );
                  } else {
                    // For existing wallet, just navigate to seed phrase entry
                    Navigator.push(
                      currentContext,
                      MaterialPageRoute(
                        builder: (_) => AddExistingWalletPage(),
                      ),
                    );
                  }
                } catch (e) {
                  // Dismiss loading indicator if still showing
                  if (Navigator.canPop(currentContext)) {
                    Navigator.pop(currentContext);
                  }

                  if (!mounted) return;

                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
            ),
          );
        },
        child: Card(
          elevation: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            width: double.infinity,
            height: 50,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(icon, color: AppColors.iconColor),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      title,
                      style: TextStyle(color: AppColors.textColor),
                      overflow: TextOverflow.ellipsis,
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

class PasswordBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const PasswordBottomSheet({super.key, required this.onSuccess});

  @override
  State<PasswordBottomSheet> createState() => _PasswordBottomSheetState();
}

class _PasswordBottomSheetState extends State<PasswordBottomSheet> {
  final List<String> inputs = [];
  final storage = const FlutterSecureStorage();

  void addDigit(String digit) {
    if (inputs.length < 6) {
      setState(() => inputs.add(digit));
    }
    if (inputs.length == 6) {
      verifyPassword();
    }
  }

  void deleteDigit() {
    if (inputs.isNotEmpty) {
      setState(() => inputs.removeLast());
    }
  }

  Future<void> verifyPassword() async {
    String entered = inputs.join();
    String? savedPassword = await storage.read(key: 'user_password');

    if (entered == savedPassword) {
      widget.onSuccess();
      //await createAndStoreNewWallet();
      //await createAndStoreHDWallet();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password confirmed"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text(
              "Incorrect password",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );

      setState(() => inputs.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 30,
          right: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [inputDots(), const SizedBox(height: 20), buildKeypad()],
        ),
      ),
    );
  }

  Widget inputDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        bool filled = index < inputs.length;
        return Container(
          margin: const EdgeInsets.all(8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? Colors.white : Colors.transparent,
            border: Border.all(color: Colors.white),
          ),
        );
      }),
    );
  }

  Widget buildKeypadButton(
    String value, {
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap ?? () => addDigit(value),
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
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

  Widget buildKeypad() {
    return Column(
      children: [
        Row(
          children: [
            buildKeypadButton('1'),
            buildKeypadButton('2'),
            buildKeypadButton('3'),
          ],
        ),
        Row(
          children: [
            buildKeypadButton('4'),
            buildKeypadButton('5'),
            buildKeypadButton('6'),
          ],
        ),
        Row(
          children: [
            buildKeypadButton('7'),
            buildKeypadButton('8'),
            buildKeypadButton('9'),
          ],
        ),
        Row(
          children: [
            const Spacer(),
            buildKeypadButton('0'),
            buildKeypadButton('', icon: Icons.backspace, onTap: deleteDigit),
          ],
        ),
      ],
    );
  }
}
