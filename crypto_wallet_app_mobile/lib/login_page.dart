// lib/pages/login_page.dart (or wherever your LoginPage resides)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crypto_wallet_app_mobile/password_setup_page.dart';
//import 'package:crypto_wallet_app_mobile/pages/add_existing_wallet_page.dart'; // Import the AddExistingWalletPage

import 'constants/app_colors.dart';
import 'constants/app_strings.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _images = ["assets/gifs/gif1.gif", "assets/gifs/gif2.gif"];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        // Use const for PreferredSize and AppBar
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: Colors.transparent),
      ),
      body: Container(
        height: screenHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.gradientBackgroundColor,
        ), // Use the gradient directly
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: AppColors.titleColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Text(
                  'Use Crypto in secure way',
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.4,

                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            _images[index],
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Changed cardWidget calls to pass specific onTap functions
              _cardWidget(
                AppColors.cardWidgetColored,
                Icons.create_new_folder,
                'Create New Wallet',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PasswordSetupPage(isImportingWallet: false),
                    ),
                  );
                },
              ),
              _cardWidget(
                AppColors.cardWidgetBlack,
                Icons.folder,
                'Add Existing Wallet',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PasswordSetupPage(isImportingWallet: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'By continuing, you agree to our',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 10,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Terms of Use',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 12,
                        ),
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

  // Modified cardWidget to accept an onTap callback
  Widget _cardWidget(
    Color inputColor,
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 20),
      child: InkWell(
        onTap: onTap, // Use the provided onTap callback
        child: Card(
          elevation: 3,
          child: Container(
            decoration: BoxDecoration(
              color: inputColor,
              borderRadius: BorderRadius.circular(10),
            ),
            width: double.infinity,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
