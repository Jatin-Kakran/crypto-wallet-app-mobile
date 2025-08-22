import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final bool isPortrait;
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.isPortrait,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Simply return an empty widget when in landscape mode
    if (!isPortrait) return const SizedBox.shrink();

    return SafeArea(bottom: true, child: _buildBottomNavBar(context));
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final List<IconData> iconList = [
      Icons.wallet,
      Icons.bar_chart,
      Icons.category,
      Icons.swap_vert,
      Icons.monetization_on,
    ];

    final List<String> labelList = [
      "Wallet",
      "Market",
      "Explore",
      "Swap",
      "Earn",
    ];

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final iconScale = (screenWidth + screenHeight) * 0.010;
    final textScale = (screenWidth + screenHeight) * 0.012;

    return BottomNavigationBar(
      backgroundColor: AppColors.backgroundColor,
      iconSize: iconScale * 2,
      selectedFontSize: textScale * 0.6,
      unselectedFontSize: textScale * 0.6,
      currentIndex: currentIndex,
      onTap: onTap,
      items: List.generate(iconList.length, (index) {
        return BottomNavigationBarItem(
          icon: Icon(iconList[index]),
          label: labelList[index],
        );
      }),
      selectedItemColor: AppColors.defaultThemePurple,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }
}
