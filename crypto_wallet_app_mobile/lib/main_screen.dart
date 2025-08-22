import 'package:flutter/material.dart';
import 'package:crypto_wallet_app_mobile/settings_screen.dart';
import 'package:crypto_wallet_app_mobile/swap_screen.dart';
import 'package:crypto_wallet_app_mobile/utils/bottom_nav_bar.dart';
import 'package:crypto_wallet_app_mobile/widgets/clickable_walletname.dart';
import 'constants/app_colors.dart';
import 'constants/app_sizes.dart';
import 'earn_screen.dart';
import 'explore_screen.dart';
import 'home_page.dart';
import 'market_screen.dart';
import 'notifications_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ValueNotifier<String> activeWalletNotifier = ValueNotifier<String>("");

  @override
  void dispose() {
    activeWalletNotifier.dispose();
    super.dispose();
  }

  late final List<Widget> _pages;
  final List<IconData?> _leadingIcons = [null, null, Icons.dehaze, null, null];

  @override
  void initState() {
    super.initState();
    _pages = [
      Homepage(),
      MarketScreen(),
      ExploreScreen(),
      SwapScreen(),
      EarnScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconScale = AppSizes.iconSize(context) * 1.2;
    final iconColor = AppColors.iconColor;

    final List<List<Widget>?> actionIcons = [
      [
        // IconButton(
        //   icon: Icon(
        //     Icons.notifications_outlined,
        //     color: AppColors.iconColor,
        //     size: iconScale,
        //   ),
        //   onPressed: () => Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => NotificationsPage()),
        //   ),
        // ),
        IconButton(
          icon: Icon(
            Icons.settings,
            color: AppColors.iconColor,
            size: iconScale,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          ),
        ),
      ],
      [
        IconButton(
          icon: Icon(Icons.search_outlined, color: iconColor, size: iconScale),
          onPressed: () {},
        ),
      ],
      [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.card_giftcard, color: iconColor, size: iconScale),
        ),
      ],
      [],
      [],
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            _leadingIcons[_currentIndex],
            color: AppColors.iconColor,
            size: AppSizes.iconSize(context),
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        title: ClickableWalletName(
          //activeWalletNotifier: activeWalletNotifier,
        ),
        actions: actionIcons[_currentIndex],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      // bottomNavigationBar: CustomBottomNavBar(
      //   isPortrait: true,
      //   currentIndex: _currentIndex,
      //   onTap: _onTabTapped,
      // ),
    );
  }
}
