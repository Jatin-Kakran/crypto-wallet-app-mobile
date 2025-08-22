import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_colors.dart';
import 'constants/app_sizes.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? walletName = "Unnamed Wallet";
  bool isChecked = false;

  Future<void> loadWalletName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      walletName = prefs.getString("wallet_name") ?? "Unnamed Wallet";
    });
  }

  @override
  Widget build(BuildContext context) {
    // final isPortrait =
    //     MediaQuery.of(context).orientation == Orientation.portrait;
    //final iconColor = AppColors.iconColor;
    // final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;
    // final scaleFactor = (screenWidth + screenHeight);
    // final iconScale = AppSizes.iconSize(context);
    // final textScale = AppSizes.textSize(context);
    // final textColor = AppColors.textColor;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      // appBar: AppBar(
      //   centerTitle: true,
      //   backgroundColor: AppColors.backgroundColor,
      //   actions: [
      //     IconButton(
      //       onPressed: () {},
      //       icon: Icon(Icons.card_giftcard, color: iconColor),
      //     ),
      //   ],
      //   leading: IconButton(
      //     onPressed: () {},
      //     icon: Icon(Icons.dehaze, color: iconColor),
      //   ),
      //   title: ClickableWalletName(),
      // ),
      body: SafeArea(
        child: Center(
          child: Container(
            // margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(15),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "DApp Guide",
                    style: TextStyle(
                      fontSize: AppSizes.textSize(context) * 2,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "You are about to view the DApps store, "
                    "please read the following information to ensure "
                    "the safety of your assets.",
                    style: TextStyle(color: Colors.white),
                    softWrap: true,
                    overflow: TextOverflow.fade,
                  ),
                  const SizedBox(height: 20),
                  ...[
                    "What is a DApp?",
                    "How can I prevent phishing scams?",
                    "Disclaimer for using Dapps",
                  ].map(
                    (text) => Card(
                      color: const Color(0xFF2C2C2E),
                      child: ListTile(
                        title: Text(
                          text,
                          style: TextStyle(color: Colors.white),
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.iconColor,
                        ),
                        onTap: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (val) {
                          setState(() {
                            isChecked = val!;
                          });
                        },
                        side: const BorderSide(color: Colors.grey),
                        activeColor: Colors.green,
                      ),
                      const Expanded(
                        child: Text(
                          "I know how to use DApps very well, skip the guide.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isChecked ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[800],
                      foregroundColor: Colors.purple[200],
                      disabledBackgroundColor: Colors.grey[900],
                      disabledForegroundColor: Colors.grey,
                    ),
                    child: const Text(
                      "View DApp Store",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
