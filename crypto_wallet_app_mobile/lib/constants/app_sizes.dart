import 'package:flutter/material.dart';

class AppSizes {
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double scaleFactor(BuildContext context) =>
      (screenWidth(context) + screenHeight(context));

  static const double paddingVerySmall = 2.0;
  static const double paddingSmall = 4.0;
  static const double paddingMedium = 8.0;
  static const double paddingLarge = 12.0;

  static const double cornerRadius = 12.0;
  static double iconSize(BuildContext context) => scaleFactor(context) * 0.014;
  static double textSize(BuildContext context) => scaleFactor(context) * 0.014;

  static bool isSmallScreen(BuildContext context) => screenWidth(context) < 600;

  static bool isLargeScreen(BuildContext context) =>
      screenWidth(context) > 1200;
}
