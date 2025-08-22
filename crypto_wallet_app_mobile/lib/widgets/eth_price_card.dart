// lib/widgets/eth_price_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:crypto_wallet_app_mobile/state/eth_price_state.dart'; // Assumed provider path
import 'package:crypto_wallet_app_mobile/constants/app_colors.dart'; // Assumed colors path

/// A beautiful, responsive, and minimal widget to display the current ETH price.
class EthPriceCard extends StatelessWidget {
  const EthPriceCard({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a Consumer to listen for changes in the EthPriceProvider.
    // This widget will rebuild automatically whenever the ETH price is updated.
    return Consumer<EthPriceProvider>(
      builder: (context, priceProvider, child) {
        final ethPrice = priceProvider.ethPrice;

        return Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          decoration: BoxDecoration(
            // A subtle gradient for a modern and beautiful look.
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8B5CF6), // A vibrant purple
                Color(0xFF5B21B6), // A darker purple
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(77),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5), // Adds a nice shadow effect
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Keep card height minimal
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // ETH icon. Assumes an image is at 'assets/avatar_Imgs/Ethereum.png'
                  Image.asset(
                    'assets/avatar_Imgs/Ethereum.png',
                    width: 25, // ✅ Updated for a more minimal look
                    height: 25, // ✅ Updated for a more minimal look
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Ethereum",
                    style: TextStyle(
                      fontSize: 12, // ✅ Updated for a more minimal look
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // ✅ FIXED: Wrap the price Text with Expanded and FittedBox
                  Expanded(
                    child: FittedBox(
                      child: Text(
                        ethPrice == 0.0
                            ? "Loading..."
                            : "\$${NumberFormat("#,##0.00").format(ethPrice)}",
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 16, // ✅ Updated for a more minimal look
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        // ✅ FittedBox handles scaling, so we don't need overflow and maxLines
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // A divider for visual separation
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 10),
              // Subtitle/label text
              const Text(
                "Current Market Price",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ), // ✅ Updated for a more minimal look
              ),
            ],
          ),
        );
      },
    );
  }
}
