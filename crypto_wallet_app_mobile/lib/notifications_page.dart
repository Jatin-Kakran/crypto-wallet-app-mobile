import 'dart:ui';

import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'constants/app_sizes.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  List<String> tabNames = ["Transaction", "System"];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = AppSizes.textSize(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        centerTitle: true,
        title: InkWell(
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (BuildContext context) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      height: screenHeight * 0.95,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800.withValues(
                          alpha: (0.85 * 255),
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Drag Handle
                          Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.only(top: 12, bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          // Title & Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Text(
                                  "Create a New Wallet",
                                  style: TextStyle(
                                    fontSize: textScale * 1.8,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Securely generate a new wallet to manage your crypto assets with ease.",
                                  style: TextStyle(
                                    fontSize: textScale * 1.2,
                                    color: Colors.grey.shade400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Generate Wallet Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 30,
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.defaultThemePurple,
                                foregroundColor: Colors.white,
                                elevation: 10,
                                shadowColor: Colors.black.withAlpha(
                                  (0.4 * 255).toInt(),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                minimumSize: const Size.fromHeight(56),
                              ),
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (_) => const CreateNewWallet()),
                                // );
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 24,
                              ),
                              label: Text(
                                "Generate New Wallet",
                                style: TextStyle(
                                  fontSize: textScale * 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
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
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                //const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
                //const SizedBox(width: 8),
                Text(
                  "Notifications",
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
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: TextStyle(color: Colors.white),
          indicatorColor: AppColors.defaultThemePurple,
          tabs: [
            ...List.generate(tabNames.length, (index) {
              return Tab(text: tabNames[index]);
            }),
          ],
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            Center(
              child: Text(
                "Nothing to show",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Center(
              child: Text(
                "No system notifications",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
