// lib/state/eth_price_provider.dart

import 'dart:async';
//import 'dart:convert';
import 'package:flutter/foundation.dart';
//import 'package:http/http.dart' as http;

import 'package:crypto_wallet_app_mobile/functions/api_functions.dart'; // Ensure this path is correct

class EthPriceProvider with ChangeNotifier {
  late final Timer _timer;
  double _ethPrice = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  double get ethPrice => _ethPrice;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  EthPriceProvider() {
    _fetchAndSetEthPrice();
    _timer = Timer.periodic(const Duration(minutes: 6), (timer) {
      _fetchAndSetEthPrice();
    });
  }

  Future<void> _fetchAndSetEthPrice() async {
    try {
      final newPrice = await APIFunctions.getEthPrice();
      if (_ethPrice != newPrice) {
        _ethPrice = newPrice;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _ethPrice = 0.0; // Reset price on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
