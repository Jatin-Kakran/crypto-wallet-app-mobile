import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:crypto_wallet_app_mobile/constants/app_colors.dart';
import 'package:crypto_wallet_app_mobile/enter_seed_phrase_page.dart';
import 'package:crypto_wallet_app_mobile/functions/reusable_functions.dart';
//import 'package:crypto_wallet_app_mobile/functions/wallet_functions.dart';
import 'package:crypto_wallet_app_mobile/main_screen.dart';
import 'package:crypto_wallet_app_mobile/new_wallet_create.dart';
import 'package:crypto_wallet_app_mobile/widgets/simple_appbar.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';
import 'package:crypto_wallet_app_mobile/models/hd_wallet_model.dart';
import 'package:crypto_wallet_app_mobile/delete_splash_page.dart';

class WalletInfoPage extends StatefulWidget {
  final HDWalletModel wallet;

  const WalletInfoPage({super.key, required this.wallet});

  @override
  State<WalletInfoPage> createState() => _WalletInfoPageState();
}

class _WalletInfoPageState extends State<WalletInfoPage> {
  List<String> _passwordInputs = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String warningBeforeRemovingWallet =
        "Deleting this wallet is permanent and cannot be undone. "
        "If you haven't backed up your recovery phrase or private key, "
        "you will lose access to your funds forever. Proceed only if you're sure.";
    final walletProvider = Provider.of<WalletProvider>(context);

    final HDWalletModel displayWallet = walletProvider.allWallets.firstWhere(
      (w) => w.walletName == widget.wallet.walletName,
      orElse: () => widget.wallet,
    );

    final String walletName = displayWallet.walletName;
    final String suffix = walletName.length > 3
        ? walletName.substring(walletName.length - 3).toUpperCase()
        : walletName.toUpperCase();

    final List<Map<String, dynamic>> walletDetails = [
      {
        "type": "info",
        "title": "Created By",
        "trailing": "Mnemonic Phrase",
        "hasInfoIcon": false,
      },
      {
        "type": "info",
        "title": "Created Time",
        "trailing": DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(displayWallet.createdTime),
        "hasInfoIcon": false,
      },
      {
        "type": "info",
        "title": "Security Suffix",
        "trailing": suffix,
        "hasInfoIcon": true,
      },
      {
        "type": "action",
        "title": "Backup",
        "badge_text": displayWallet.isBackedUp ? "Backed Up" : "No backup",
        "onTap": displayWallet.isBackedUp
            ? null
            : () async {
                bool? passwordConfirmed =
                    await _showPasswordConfirmationAndDisplayKeys(
                      context,
                      displayWallet.dataKey.seedPhrase!,
                      isPrivateKey: false,
                      walletProvider: walletProvider,
                    );

                if (passwordConfirmed == true && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => EnterSeedPhrasePage(
                        mnemonic: displayWallet.dataKey.seedPhrase!,
                        walletNameForBackup: displayWallet.walletName,
                        startInVerificationMode: false,
                        walletName: displayWallet.walletName,
                      ),
                    ),
                  );
                }
              },
      },
      {
        "type": "action",
        "title": "Export Public Key",
        "hasInfoIcon": true,
        "onTap": () => _showPasswordConfirmationAndDisplayKeys(
          context,
          displayWallet.dataKey.seedPhrase!,
          isPrivateKey: false,
          walletProvider: walletProvider,
        ),
      },
      {
        "type": "action",
        "title": "Export Private Key",
        "onTap": () => _showWarningAndDisplayPrivateKeys(
          context,
          displayWallet.dataKey.seedPhrase!,
          walletProvider: walletProvider,
        ),
      },
      {
        "type": "action",
        "title": "Create Account",
        "onTap": () =>
            debugPrint("Create Account tapped for ${displayWallet.walletName}"),
      },
      {
        "type": "action",
        "title": "Clear Cache",
        "onTap": () => showAlertBoxWithTimer(
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
          countdownSeconds: 3,
        ),
      },
      {
        "type": "coins",
        "title": "Coins",
        "trailing": "\$0",
        "onTap": () =>
            debugPrint("Coins tapped for ${displayWallet.walletName}"),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const SimpleAppbarWidget(appbarTitle: "Wallet Details"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildHeader(walletName),
              const SizedBox(height: 24),
              ..._buildGroupedListItems(walletDetails),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    // IMPORTANT: Make onPressed async
                    debugPrint(
                      "Remove Wallet button tapped for ${displayWallet.walletName}",
                    );

                    // 1. Show Password Bottom Sheet
                    bool? passwordConfirmed = await showModalBottomSheet<bool>(
                      backgroundColor: AppColors.backgroundColor,
                      context: context,
                      isScrollControlled: true,
                      builder: (sheetContext) => PasswordBottomSheet(
                        onSuccess: () {
                          Navigator.of(sheetContext).pop(true);
                        },
                      ),
                    );

                    if (passwordConfirmed != true) {
                      debugPrint(
                        "Password not confirmed or sheet dismissed. Aborting deletion.",
                      );
                      return;
                    }

                    if (!context.mounted) {
                      debugPrint(
                        "Context not mounted after password confirmation.",
                      );
                      return;
                    }

                    // 2. Show Alert Box With Timer
                    bool? confirmedToDelete = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (alertContext) => AlertBoxWithTimer(
                        message: warningBeforeRemovingWallet,
                        countdownSeconds: 5,
                        onYes: () {
                          Navigator.of(alertContext).pop(true);
                        },
                        onNo: () {
                          // Make sure your AlertBoxWithTimer accepts onNo
                          Navigator.of(alertContext).pop(false);
                        },
                      ),
                    );

                    if (confirmedToDelete != true) {
                      debugPrint(
                        "Wallet deletion not confirmed by user. Aborting.",
                      );
                      return;
                    }

                    if (!context.mounted) {
                      debugPrint(
                        "Context not mounted after deletion confirmation.",
                      );
                      return;
                    }

                    // --- FIX START ---
                    // Change `BuildContext loadingDialogContext;` to `BuildContext? loadingDialogContext;`
                    // and initialize it to null.
                    BuildContext?
                    loadingDialogContext; // Now nullable and initialized to null

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) {
                        loadingDialogContext = ctx; // Assignment happens here
                        return const Center(child: CircularProgressIndicator());
                      },
                    );
                    // --- FIX END ---

                    bool deletionSuccess = false;
                    try {
                      deletionSuccess = await walletProvider
                          .deleteSpecificWallet(displayWallet.walletName);
                    } catch (e) {
                      debugPrint("Error during wallet deletion: $e");
                    } finally {
                      // Check if loadingDialogContext is not null AND mounted before popping
                      if (loadingDialogContext != null &&
                          loadingDialogContext!.mounted) {
                        Navigator.of(
                          loadingDialogContext!,
                        ).pop(); // Use null-aware access
                      }
                    }

                    if (!context.mounted) {
                      debugPrint(
                        "Context not mounted after deletion operation.",
                      );
                      return;
                    }

                    if (deletionSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Wallet "${displayWallet.walletName}" deleted successfully!',
                          ),
                          backgroundColor: AppColors.greenColor,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to delete wallet "${displayWallet.walletName}". Please try again.',
                          ),
                          backgroundColor: AppColors.redColor,
                        ),
                      );
                    }

                    if (walletProvider.allWallets.isEmpty) {
                      NavigationHelper.pushAndRemoveUntil(
                        context,
                        const WalletDeletionSplashPage(),
                      );
                    } else {
                      NavigationHelper.pushAndRemoveUntil(
                        context,
                        const HomeScreen(),
                      );
                    }
                  },
                  child: const Text(
                    "Remove Wallet",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedListItems(
    List<Map<String, dynamic>> walletDetails,
  ) {
    List<Widget> groupedWidgets = [];
    String? currentType;
    List<Map<String, dynamic>> currentGroup = [];

    for (var item in walletDetails) {
      if (currentType == null || item['type'] != currentType) {
        if (currentGroup.isNotEmpty) {
          groupedWidgets.add(_buildSectionContainer(currentGroup));
        }
        currentType = item['type'];
        currentGroup = [item];
      } else {
        currentGroup.add(item);
      }
    }
    if (currentGroup.isNotEmpty) {
      groupedWidgets.add(_buildSectionContainer(currentGroup));
    }
    return groupedWidgets;
  }

  Widget _buildSectionContainer(List<Map<String, dynamic>> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardWidgetBlack.withAlpha(242),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                title: Row(
                  children: [
                    Text(
                      item["title"],
                      style: const TextStyle(color: AppColors.textColor),
                    ),
                    if (item["hasInfoIcon"] == true)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.help_outline,
                          size: 16,
                          color: AppColors.subtitleColor,
                        ),
                      ),
                  ],
                ),
                trailing: item["badge_text"] != null
                    ? _Badge(text: item["badge_text"])
                    : item["trailing"] != null
                    ? Text(
                        item["trailing"],
                        style: TextStyle(color: AppColors.subtitleColor),
                      )
                    : (item["onTap"] != null
                          ? Icon(
                              Icons.chevron_right,
                              color: AppColors.subtitleColor,
                            )
                          : null),
                onTap: item["onTap"] != null ? () => item["onTap"]() : null,
              ),
              if (index < items.length - 1)
                Divider(
                  color: AppColors.subtitleColor.withAlpha(76),
                  height: 1,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(String walletName) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              walletName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.titleColor,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.edit, size: 18, color: AppColors.subtitleColor),
          ],
        ),
      ],
    );
  }

  // --- Key Export Logic ---

  // --- CRUCIAL FIX: Changed return type from Future<void> to Future<bool?> ---
  Future<bool?> _showPasswordConfirmationAndDisplayKeys(
    BuildContext context,
    String mnemonic, {
    required bool isPrivateKey,
    required WalletProvider walletProvider,
  }) async {
    _passwordInputs.clear();

    bool? passwordConfirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext innerContext, StateSetter innerSetState) {
            Future<bool> _verifyPassword(
              BuildContext currentContext,
              WalletProvider walletProvider,
            ) async {
              String enteredPassword = _passwordInputs.join();
              String? storedPassword = await walletProvider.secureStorage.read(
                key: 'user_password',
              );

              if (enteredPassword == storedPassword) {
                if (currentContext.mounted) {
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(
                      content: Text("Password confirmed"),
                      backgroundColor: AppColors.greenColor,
                    ),
                  );
                }
                return true;
              } else {
                if (currentContext.mounted) {
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect password or no password set.'),
                      backgroundColor: AppColors.redColor,
                    ),
                  );
                  innerSetState(() => _passwordInputs.clear());
                }
                return false;
              }
            }

            void addDigit(String digit) async {
              if (_passwordInputs.length < 6) {
                innerSetState(() => _passwordInputs.add(digit));
              }
              if (_passwordInputs.length == 6) {
                bool isCorrect = await _verifyPassword(
                  innerContext,
                  walletProvider,
                );
                if (isCorrect) {
                  if (innerContext.mounted) {
                    Navigator.pop(innerContext, true);
                  }
                }
              }
            }

            void deleteDigit() {
              if (_passwordInputs.isNotEmpty) {
                innerSetState(() => _passwordInputs.removeLast());
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(innerContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInputDots(_passwordInputs),
                    const SizedBox(height: 20),
                    _buildKeypad(addDigit, deleteDigit),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (passwordConfirmed == true) {
      final displayWallet = widget.wallet;
      List<Map<String, String>> keysToDisplay = [];

      try {
        if (isPrivateKey) {
          // Display master private key (XPRV)
          keysToDisplay.add({
            'name': 'Master Private Key (XPRV)',
            'value': displayWallet.dataKey.masterPrivateKeyXprv,
            'chain': 'Hierarchical Deterministic Wallet',
          });
        } else {
          // Display master public key (XPUB)
          keysToDisplay.add({
            'name': 'Master Public Key (XPUB)',
            'value': displayWallet.dataKey.masterPublicKeyXpub,
            'chain': 'Hierarchical Deterministic Wallet',
          });
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deriving key: ${e.toString()}'),
              backgroundColor: AppColors.redColor,
            ),
          );
        }
        return false;
      }

      if (mounted) {
        _displayKeysBottomSheet(
          context,
          keysToDisplay,
          isPrivateKey: isPrivateKey,
        );
      }
    }
    return passwordConfirmed;
  }

  Future<void> _showWarningAndDisplayPrivateKeys(
    BuildContext context,
    String mnemonic, {
    required WalletProvider walletProvider,
  }) async {
    bool? userAgreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor,
          title: Text(
            'WARNING: Export Private Key',
            style: TextStyle(
              color: AppColors.redAccentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Private keys control direct access to your funds. Anyone with your private key can steal your assets.',
                  style: TextStyle(color: AppColors.textColor, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text(
                  'Guidelines:',
                  style: TextStyle(
                    color: AppColors.titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '1. Never share your private key.',
                  style: TextStyle(color: AppColors.textColor, fontSize: 13),
                ),
                Text(
                  '2. Do not store it digitally (e.g., screenshots, cloud, email).',
                  style: TextStyle(color: AppColors.textColor, fontSize: 13),
                ),
                Text(
                  '3. Write it down on paper and store it in a very secure, private place.',
                  style: TextStyle(color: AppColors.textColor, fontSize: 13),
                ),
                Text(
                  '4. Losing this key means losing your funds forever.',
                  style: TextStyle(color: AppColors.textColor, fontSize: 13),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.defaultThemePurple),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('I Understand & Agree'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (userAgreed == true) {
      if (mounted) {
        // Here, we don't care about the return value of _showPasswordConfirmationAndDisplayKeys,
        // so awaiting a Future<bool?> (which we changed it to) is fine.
        await _showPasswordConfirmationAndDisplayKeys(
          context,
          mnemonic,
          isPrivateKey: true,
          walletProvider: walletProvider,
        );
      }
    }
  }

  Future<void> _displayKeysBottomSheet(
    BuildContext context,
    List<Map<String, String>> keys, {
    required bool isPrivateKey,
  }) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isPrivateKey ? 'Your Private Keys' : 'Your Public Keys',
                    style: TextStyle(
                      color: AppColors.titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ...keys.map((keyData) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${keyData['name']} (${keyData['chain']})',
                          style: TextStyle(
                            color: AppColors.subtitleColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  keyData['value']!,
                                  style: TextStyle(
                                    color: AppColors.textColor,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.copy,
                                  color: AppColors.iconColor,
                                  size: 18,
                                ),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: keyData['value']!),
                                  );
                                  ScaffoldMessenger.of(
                                    sheetContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${keyData['name']} copied to clipboard!',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.defaultThemePurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputDots(List<String> inputs) {
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
            color: filled ? AppColors.textColor : AppColors.transparent,
            border: Border.all(color: AppColors.textColor),
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
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardWidgetBlack,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: AppColors.textColor)
                : Text(
                    value,
                    style: TextStyle(color: AppColors.textColor, fontSize: 22),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(
    Function(String) addDigitCallback,
    VoidCallback deleteDigitCallback,
  ) {
    return Column(
      children: [
        Row(
          children: [
            _buildKeypadButton('1', onTap: () => addDigitCallback('1')),
            _buildKeypadButton('2', onTap: () => addDigitCallback('2')),
            _buildKeypadButton('3', onTap: () => addDigitCallback('3')),
          ],
        ),
        Row(
          children: [
            _buildKeypadButton('4', onTap: () => addDigitCallback('4')),
            _buildKeypadButton('5', onTap: () => addDigitCallback('5')),
            _buildKeypadButton('6', onTap: () => addDigitCallback('6')),
          ],
        ),
        Row(
          children: [
            _buildKeypadButton('7', onTap: () => addDigitCallback('7')),
            _buildKeypadButton('8', onTap: () => addDigitCallback('8')),
            _buildKeypadButton('9', onTap: () => addDigitCallback('9')),
          ],
        ),
        Row(
          children: [
            const Spacer(),
            _buildKeypadButton('0', onTap: () => addDigitCallback('0')),
            _buildKeypadButton(
              '',
              icon: Icons.backspace,
              onTap: deleteDigitCallback,
            ),
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    Color badgeColor = text == "Backed Up"
        ? AppColors.greenColor
        : AppColors.redColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
