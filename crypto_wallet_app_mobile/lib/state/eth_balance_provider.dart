import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_wallet_app_mobile/models/hd_wallet_model.dart';
import 'package:crypto_wallet_app_mobile/state/eth_price_state.dart';
//import 'package:crypto_wallet_app_mobile/state/eth_price_state.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart';

class TotalBalanceTextWidget extends StatelessWidget {
  const TotalBalanceTextWidget({super.key});

  //final bool isObscure;

  @override
  Widget build(BuildContext context) {
    // Watch for changes in both providers
    final walletProvider = context.watch<WalletProvider>();
    final ethPriceProvider = context.watch<EthPriceProvider>();
    final HDWalletModel? activeWallet = walletProvider.selectedWallet;

    // Show loading state if either provider is loading
    if (ethPriceProvider.isLoading || walletProvider.isLoading) {
      return const CircularProgressIndicator();
    }

    // Handle error state from the price provider
    if (ethPriceProvider.errorMessage != null) {
      return Text(
        ethPriceProvider.errorMessage!,
        style: const TextStyle(color: Colors.red),
      );
    }

    // Calculate total balance using the live ETH price
    double totalBalanceUSD = 0.0;
    if (activeWallet != null) {
      for (var asset in activeWallet.dataKey.childKeys) {
        if (asset.symbol == 'ETH') {
          totalBalanceUSD += asset.balance * ethPriceProvider.ethPrice;
        }
        // You would need to add similar logic for other crypto assets
        // if you were fetching their prices as well.
      }
    }

    return SelectableText(
      '\$${totalBalanceUSD.toStringAsFixed(5)}',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class TotalBalanceObscureWidget extends StatelessWidget {
  const TotalBalanceObscureWidget({super.key, required this.isObscure});

  final bool isObscure;

  @override
  Widget build(BuildContext context) {
    // Watch for changes in both providers
    final walletProvider = context.watch<WalletProvider>();
    final ethPriceProvider = context.watch<EthPriceProvider>();
    final HDWalletModel? activeWallet = walletProvider.selectedWallet;

    // Show loading state if either provider is loading
    if (ethPriceProvider.isLoading || walletProvider.isLoading) {
      return const CircularProgressIndicator();
    }

    // Handle error state from the price provider
    if (ethPriceProvider.errorMessage != null) {
      return Text(
        ethPriceProvider.errorMessage!,
        style: const TextStyle(color: Colors.red),
      );
    }

    // Calculate total balance using the live ETH price
    double totalBalanceUSD = 0.0;
    if (activeWallet != null) {
      for (var asset in activeWallet.dataKey.childKeys) {
        if (asset.symbol == 'ETH') {
          totalBalanceUSD += asset.balance * ethPriceProvider.ethPrice;
        }
        // You would need to add similar logic for other crypto assets
        // if you were fetching their prices as well.
      }
    }

    return SelectableText(
      isObscure ? '******' : '\$${totalBalanceUSD.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
