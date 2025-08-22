import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CurrencyExhangeWidget extends StatefulWidget {
  const CurrencyExhangeWidget({super.key});

  @override
  State<CurrencyExhangeWidget> createState() => _CurrencyExhangeWidgetState();
}

class _CurrencyExhangeWidgetState extends State<CurrencyExhangeWidget> {
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
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardWidgetBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SizedBox(
                    child: Column(
                      children: [
                        rowLabel("Pay"),
                        currencyRow(payCurrency, payController),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        // Swap currencies
                        final tempCurrency = payCurrency;
                        payCurrency = receiveCurrency;
                        receiveCurrency = tempCurrency;

                        // Swap values
                        final tempText = payController.text;
                        payController.text = receiveController.text;
                        receiveController.text = tempText;
                      });
                    },

                    icon: Icon(
                      Icons.swap_vert,
                      size: 32,
                      color: AppColors.defaultThemePurple,
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    child: Column(
                      children: [
                        rowLabel("Estimated Receive"),
                        currencyRow(receiveCurrency, null, readOnly: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
