import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: AppColors.iconColor),
          ),
          centerTitle: true,
          title: Text(
            "SoSoValue Index (SSI)",
            style: TextStyle(
              fontSize: AppSizes.textSize(context) * 1.2,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Text(
                  "SoSoValue Index",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
