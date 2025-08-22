//import 'package:core_wallet/utils/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class NullPage extends StatelessWidget {
  const NullPage({super.key});

  @override
  Widget build(BuildContext context) {
    //final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      body: Placeholder(),
      //bottomNavigationBar: CustomBottomNavBar(isPortrait: isPortrait)
    );
  }
}
