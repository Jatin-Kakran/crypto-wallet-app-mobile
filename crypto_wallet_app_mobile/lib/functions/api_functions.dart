import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
//import 'package:crypto_wallet_app_mobile/models/transaction_model.dart';

class APIPortSetup {
  // static const String ipv4Address =
  //     '192.168.29.153'; // Replace with your actual laptop IP
  static const String ipv4Address =
      'crypto-wallet-api-production.up.railway.app';
  static const String port = '3000';
  static const String baseUrl = "http://$ipv4Address";
}

class APIFunctions {
  /*
  ====================================================================
  ==================== Fetching Balance endpoints ====================
  ====================================================================
  */
  static Future<double> getEthBalance(String userAddress) async {
    final url = Uri.parse(
      '${APIPortSetup.baseUrl}/api/eth/balance/$userAddress',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return double.tryParse(data['balance'].toString()) ?? 0.0;
    } else {
      throw Exception('Failed to fetch ETH balance');
    }
  }

  static Future<double> getEthPrice() async {
    final url = Uri.parse('${APIPortSetup.baseUrl}/api/eth-price');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Correct way to parse the price value from the API response
        return double.tryParse(data['price'].toString()) ?? 0.0;
      } else {
        throw Exception(
          'Failed to fetch ETH price. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Re-throw the exception with a more descriptive error message.
      throw Exception('Failed to connect to API: $e');
    }
  }

  // static Future<double> getERC20Balance({
  //   required String userAddress,
  //   required String contractAddress,
  //   required int decimals,
  // }) async {
  //   final url = Uri.parse(
  //     '${APIPortSetup.baseUrl}/balance/erc20/$contractAddress/$userAddress/$decimals',
  //   );
  //   final response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return double.tryParse(data['balance'].toString()) ?? 0.0;
  //   } else {
  //     throw Exception('Failed to fetch ERC20 balance');
  //   }
  //}

  /*
  ====================================================================
  ===================== Sending Tokens endpoints =====================
  ====================================================================
  */
  // In api_functions.dart, modify the sendEth function:
  //   static Future<Map<String, dynamic>> sendEth({
  //     required String privateKey,
  //     required String recipientAddress,
  //     required double amountEth,
  //   }) async {
  //     final url = Uri.parse('${APIPortSetup.baseUrl}/api/eth/send');

  //     // Remove "0x" prefix if present and trim whitespace
  //     final cleanedPrivateKey = privateKey
  //         .replaceFirst(RegExp(r'^0x'), '')
  //         .trim();

  //     // Validate private key length before sending to backend
  //     if (cleanedPrivateKey.length != 64) {
  //       return {
  //         'status': 'fail',
  //         'message': 'Invalid private key length',
  //         'details': 'Private key must be 64 characters long without 0x prefix',
  //       };
  //     }

  //     final body = jsonEncode({
  //       'privateKey': cleanedPrivateKey,
  //       'recipientAddress': recipientAddress,
  //       'amountEth': amountEth,
  //     });

  //     debugPrint(
  //       "Sending to API with key: ${cleanedPrivateKey.substring(0, 6)}...",
  //     );

  //     final headers = {'Content-Type': 'application/json'};

  //     try {
  //       final response = await http.post(
  //         url,
  //         headers: headers,
  //         body: body,
  //         //timeout: const Duration(seconds: 30),
  //       );

  //       final responseBody = jsonDecode(response.body);

  //       // Check for success based on different possible response formats
  //       final isSuccess =
  //           response.statusCode == 200 &&
  //           (responseBody['success'] == true ||
  //               responseBody['status'] == 'success');

  //       if (isSuccess) {
  //         debugPrint(
  //           "Transaction successful: ${responseBody['transactionHash']}",
  //         );
  //         return {
  //           'status': 'success',
  //           'transactionHash': responseBody['transactionHash'],
  //           'message': responseBody['message'] ?? 'Transaction successful',
  //           'blockNumber': responseBody['blockNumber'],
  //           'gasUsed': responseBody['gasUsed'],
  //         };
  //       } else {
  //         // Handle API-level errors
  //         final errorMessage = responseBody['error'] ?? 'Transaction failed';
  //         final errorDetails =
  //             responseBody['details'] ??
  //             responseBody['message'] ??
  //             'No details provided';

  //         debugPrint("Transaction failed: $errorMessage - $errorDetails");

  //         return {
  //           'status': 'fail',
  //           'message': errorMessage,
  //           'details': errorDetails,
  //         };
  //       }
  //     } catch (e) {
  //       debugPrint("Network error: ${e.toString()}");
  //       return {
  //         'status': 'fail',
  //         'message': 'Network error occurred',
  //         'details': e.toString(),
  //       };
  //     }
  //   }
  // }

  static Future<Map<String, dynamic>> sendEth({
    required String privateKey,
    required String recipientAddress,
    required double amountEth,
  }) async {
    final url = Uri.parse('${APIPortSetup.baseUrl}/api/eth/send');

    // Remove "0x" prefix if present and trim whitespace
    final cleanedPrivateKey = privateKey
        .replaceFirst(RegExp(r'^0x'), '')
        .trim();

    // Validate private key length before sending to backend
    if (cleanedPrivateKey.length != 64) {
      return {
        'status': 'fail',
        'message': 'Invalid private key length',
        'details': 'Private key must be 64 characters long without 0x prefix',
      };
    }

    final body = jsonEncode({
      'privateKey': cleanedPrivateKey,
      'recipientAddress': recipientAddress,
      'amountEth': amountEth,
    });

    debugPrint(
      "Sending to API with key: ${cleanedPrivateKey.substring(0, 6)}...",
    );

    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
        //timeout: const Duration(seconds: 30),
      );

      // Check if response body is empty
      if (response.body.isEmpty) {
        debugPrint(
          "EMPTY RESPONSE FROM SERVER - Status: ${response.statusCode}",
        );
        return {
          'status': 'fail',
          'message': 'Server returned empty response',
          'details':
              'Please check server logs. Status code: ${response.statusCode}',
        };
      }

      // Debug print the raw response
      debugPrint("Raw response: ${response.body}");

      final responseBody = jsonDecode(response.body);

      // Check for success based on different possible response formats
      final isSuccess =
          response.statusCode == 200 &&
          (responseBody['success'] == true ||
              responseBody['status'] == 'success');

      if (isSuccess) {
        debugPrint(
          "Transaction successful: ${responseBody['transactionHash']}",
        );
        return {
          'status': 'success',
          'transactionHash': responseBody['transactionHash'],
          'message': responseBody['message'] ?? 'Transaction successful',
          'blockNumber': responseBody['blockNumber'],
          'gasUsed': responseBody['gasUsed'],
        };
      } else {
        // Handle API-level errors
        final errorMessage = responseBody['error'] ?? 'Transaction failed';
        final errorDetails =
            responseBody['details'] ??
            responseBody['message'] ??
            'No details provided';

        debugPrint("Transaction failed: $errorMessage - $errorDetails");

        return {
          'status': 'fail',
          'message': errorMessage,
          'details': errorDetails,
        };
      }
    } on FormatException catch (e) {
      debugPrint("JSON FormatException: $e");
      return {
        'status': 'fail',
        'message': 'Invalid response from server',
        'details': 'Server returned malformed JSON. Please check server logs.',
      };
    } on http.ClientException catch (e) {
      debugPrint("Network error: $e");
      return {
        'status': 'fail',
        'message': 'Network error',
        'details': 'Failed to connect to server: ${e.message}',
      };
    } catch (e) {
      debugPrint("Unexpected error: ${e.toString()}");
      return {
        'status': 'fail',
        'message': 'Unexpected error occurred',
        'details': e.toString(),
      };
    }
  }
}

//   static Future<List<TransactionModel>> getTransaction({
//     required String userAddress,
//     required bool isErc20,
//     String? contractAddress,
// }) async {
//
//   }
