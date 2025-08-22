//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundColor = Colors.black;
  static const Color cardWidgetColored = Colors.deepPurpleAccent;
  static const Color defaultThemePurple = Colors.deepPurpleAccent;
  static const Color transparent = Colors.transparent;
  static const Color cardWidgetBlack = Color.fromRGBO(24, 24, 24, 1);
  static const Color textColor = Colors.white;
  static const Color titleColor = Colors.white;
  static const Color subtitleColor = Colors.grey;
  static const Color iconColor = Colors.white;

  // --- NEW COLOR CONSTANTS ADDED BELOW ---
  static const Color redColor = Colors.red;
  static const Color greenColor = Colors.green;
  static const Color redAccentColor = Colors.redAccent;
  static const Color borderColor = Color.fromRGBO(70, 70, 70, 1);
  static const Color cardColor = Color.fromRGBO(36, 36, 36, 1);
  // --- END OF NEW COLOR CONSTANTS ---

  static const LinearGradient gradientBackgroundColor = LinearGradient(
    colors: [
      Color.fromRGBO(113, 17, 247, 1),
      Color.fromRGBO(15, 9, 121, 1),
      Color.fromRGBO(25, 29, 31, 1),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.4, 0.73],
  );
}