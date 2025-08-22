import 'package:flutter/material.dart';
// Make sure to import your other necessary files
import 'package:crypto_wallet_app_mobile/functions/reusable_functions.dart';
import 'package:crypto_wallet_app_mobile/main_screen.dart';
//import 'constants/app_colors.dart';

class TransactionStatusPage extends StatelessWidget {
  final String status; // 'waiting', 'success', 'fail'
  final Map<String, dynamic>? result;
  final VoidCallback? onRetry;

  const TransactionStatusPage({
    super.key,
    required this.status,
    this.result,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _buildStatusScaffold(context);
  }

  Widget _buildStatusScaffold(BuildContext context) {
    final String title;
    final String message;
    final Color color;
    final IconData icon;
    final Widget? details;
    final Widget? actionButton;

    switch (status) {
      case 'success':
        title = "Transaction Successful";
        message = "Your funds have been sent.";
        color = Colors.green.shade400;
        icon = Icons.check_circle_outline;
        details = _buildSuccessDetails(context, result);
        actionButton = _buildDoneButton(context);
        break;
      case 'fail':
        title = "Transaction Failed";
        message = result?['message'] ?? "An unknown error occurred.";
        color = Colors.red.shade400;
        icon = Icons.error_outline;
        details = Text(
          result?['details'] ?? 'No further details available.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
        );
        actionButton = _buildRetryButton(context);
        break;
      default: // 'waiting'
        title = "Processing Transaction";
        message =
            "Please wait while we submit your transaction to the network.";
        color = Colors.orange.shade400;
        icon = Icons.hourglass_empty_rounded;
        details = const CircularProgressIndicator(color: Colors.white);
        actionButton = null; // No button in waiting state
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide back button
      ),
      // MODIFIED: Made the layout responsive and scrollable.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // This makes the main content area scrollable if it overflows.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Added extra padding for better spacing on scroll
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.15),
                        ),
                        child: Icon(icon, size: 60, color: color),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      ...[const SizedBox(height: 32), details],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // This keeps the button fixed at the bottom.
              if (actionButton != null) ...[
                const SizedBox(height: 16),
                actionButton,
              ],
            ],
          ),
        ),
      ),
    );
  }

  // In transaction_status_page.dart, modify the details display:
  Widget _buildSuccessDetails(
    BuildContext context,
    Map<String, dynamic>? result,
  ) {
    if (result == null) return const SizedBox.shrink();

    final String txHash = result['transactionHash'] ?? 'N/A';
    final String message = result['message'] ?? 'Transaction completed';

    return Column(
      children: [
        Text(message, style: TextStyle(color: Colors.white.withOpacity(0.7))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                "Transaction Hash",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  //Clipboard.setData(ClipboardData(text: txHash));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Copied to clipboard")),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        txHash,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.copy, size: 16, color: Colors.white70),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // backgroundColor: AppColors.defaultThemePurple,
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
      child: const Text("Done", style: TextStyle(fontSize: 18)),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //     // backgroundColor: AppColors.defaultThemePurple,
        //     backgroundColor: Colors.deepPurpleAccent,
        //     foregroundColor: Colors.white,
        //     minimumSize: const Size(double.infinity, 50),
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        //   ),
        //   onPressed: onRetry,
        //   child: const Text("Retry", style: TextStyle(fontSize: 18)),
        // ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () =>
              NavigationHelper.pushAndRemoveUntil(context, HomeScreen()),
          child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
