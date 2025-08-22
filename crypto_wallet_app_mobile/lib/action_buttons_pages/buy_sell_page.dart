import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/clickable_walletname.dart';
import '../widgets/crypto_exchange_widget.dart';

class BuySellPage extends StatefulWidget {
  const BuySellPage({super.key});

  @override
  State<BuySellPage> createState() => _BuySellPageState();
}

class _BuySellPageState extends State<BuySellPage> {
  bool isBuySelected = true;

  final TextEditingController payController = TextEditingController();
  final TextEditingController receiveController = TextEditingController();

  String estimatedReceiveValue = "0.0"; // This will be displayed
  String payCurrency = "USD";
  String receiveCurrency = "BTC";

  // String payCurrency = "";
  // String receiveCurrency = "";

  String payValue = "";
  String receiveValue = "";

  @override
  Widget build(BuildContext context) {
    //final textColor = AppColors.textColor;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        iconTheme: IconThemeData(color: AppColors.iconColor),
        title: ClickableWalletName(),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {},
            color: AppColors.iconColor,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Buy/Sell Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  toggleButton("Buy", isBuySelected),
                  SizedBox(width: 8),
                  toggleButton("Sell", !isBuySelected),
                ],
              ),
              SizedBox(height: 20),

              CurrencyExhangeWidget(),

              SizedBox(height: 16),

              // Payment Method Section
              ListTile(
                tileColor: AppColors.cardWidgetBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  "Payment Method",
                  style: TextStyle(color: AppColors.textColor),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "All",
                      style: TextStyle(color: AppColors.subtitleColor),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.subtitleColor),
                  ],
                ),
                onTap: () {},
              ),
              SizedBox(height: 16),

              // Receiving Address
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardWidgetBlack,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Receiving Address (Bitcoin)",
                      style: TextStyle(color: AppColors.subtitleColor),
                    ),
                    SizedBox(height: 8),
                    SelectableText(
                      "bc1qgutjualk33jxu3wcqdznandjvahfe0fsg5h8l7",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32), // Spacing before button
              // Buy/Sell Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.defaultThemePurple,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isBuySelected ? "Buy" : "Sell",
                    style: TextStyle(fontSize: 18, color: AppColors.textColor),
                  ),
                ),
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget toggleButton(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          isBuySelected = text == "Buy";
        }),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.defaultThemePurple
                : AppColors.cardWidgetBlack,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: AppColors.textColor),
          ),
        ),
      ),
    );
  }

  Widget rowLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(color: AppColors.subtitleColor, fontSize: 12),
      ),
    );
  }

  Widget currencyRow(
    String currency,
    TextEditingController? controller, {
    bool readOnly = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {},
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                radius: 12,
                child: Text(
                  currency[0],
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(currency, style: TextStyle(color: AppColors.textColor)),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: readOnly
              ? Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    estimatedReceiveValue,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                )
              : TextField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    hintText: "Enter value",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      final double payAmount = double.tryParse(value) ?? 0.0;
                      final double rate = 0.000025; // dummy conversion rate
                      estimatedReceiveValue = (payAmount * rate)
                          .toStringAsFixed(8);
                    });
                  },
                ),
        ),
      ],
    );
  }
}
