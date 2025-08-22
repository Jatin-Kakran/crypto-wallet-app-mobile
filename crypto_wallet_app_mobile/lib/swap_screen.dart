import 'package:flutter/material.dart';
import 'package:crypto_wallet_app_mobile/widgets/crypto_exchange_widget.dart';

import 'constants/app_colors.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  SwapScreenState createState() => SwapScreenState();
}

class SwapScreenState extends State<SwapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<String> tabTitles = ["Swap", "Bridge", "Buy/Sell", "Exchange"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  Widget buildCryptoCard(Map<String, String> crypto) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(child: Text(crypto["symbol"]![0])),
        title: Text("${crypto["name"]} (${crypto["symbol"]})"),
        subtitle: Text(crypto["price"]!),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              crypto["change"]!,
              style: TextStyle(
                color: crypto["change"]!.contains("-")
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: () {}, child: Text("Buy")),
                TextButton(onPressed: () {}, child: Text("Sell")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search coin...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Center(child: CurrencyExhangeWidget()),
                Center(child: Text("Bridge Page")),
                Center(child: Text("Buy/Sell Page")),
                Center(child: Text("Exchange Page")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
