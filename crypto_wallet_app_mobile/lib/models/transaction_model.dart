class TransactionModel {
  final String hash;
  final String from;
  final String to;
  final double value;
  final DateTime timeStamp;
  final String symbol;
  final bool isSender; // To easily identify if the user sent or received

  TransactionModel({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.timeStamp,
    required this.symbol,
    required this.isSender,
  });

  // A factory constructor to create a TransactionModel from a JSON map.
  // This is what your API should return for each transaction.
  factory TransactionModel.fromJson(Map<String, dynamic> json, String currentUserAddress) {
    final String fromAddress = json['from'] as String;
    final String toAddress = json['to'] as String;
    // Etherscan API returns value in the smallest unit (wei), so you need to convert it.
    // Your Node.js API should ideally do this conversion before sending it to the app.
    final double value = double.tryParse(json['value'].toString()) ?? 0.0;

    return TransactionModel(
      hash: json['hash'] as String,
      from: fromAddress,
      to: toAddress,
      value: value,
      // Etherscan provides a Unix timestamp, which needs to be converted.
      timeStamp: DateTime.fromMillisecondsSinceEpoch(
        (int.parse(json['timeStamp'].toString()) * 1000),
      ),
      symbol: json['symbol'] as String,
      // Determine if the current user was the sender
      isSender: fromAddress.toLowerCase() == currentUserAddress.toLowerCase(),
    );
  }
}