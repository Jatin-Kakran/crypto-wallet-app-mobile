import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SimpleAppbarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String appbarTitle;
  final List<Widget>? actionButtons;

  const SimpleAppbarWidget({
    super.key,
    required this.appbarTitle,
    this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(appbarTitle, style: TextStyle(color: AppColors.titleColor)),
      backgroundColor: AppColors.backgroundColor,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: AppColors.iconColor),
      ),
      actions: actionButtons,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
