// lib/crypto_info_page.dart
import 'dart:ui';

//import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:qr_flutter/qr_flutter.dart';
//import 'package:crypto_wallet_app_mobile/functions/reusable_functions.dart';
import 'package:crypto_wallet_app_mobile/models/wallet_crypto_asset_model.dart'; // Import WalletCryptoAssetModel
import 'package:crypto_wallet_app_mobile/state/eth_balance_provider.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart'; // Import WalletProvider
import 'package:crypto_wallet_app_mobile/transaction_status_page.dart';
import 'package:crypto_wallet_app_mobile/widgets/simple_appbar.dart';
import 'constants/app_colors.dart';
import 'constants/app_exchanges.dart';
//import 'constants/app_sizes.dart';
import 'functions/api_functions.dart';
import 'package:crypto_wallet_app_mobile/state/eth_price_state.dart';
import 'package:intl/intl.dart';
//import 'models/crypto_template_model.dart';

class CryptoInfoPage extends StatefulWidget {
  final WalletCryptoAssetModel walletCryptoAsset;

  const CryptoInfoPage({super.key, required this.walletCryptoAsset});

  @override
  State<CryptoInfoPage> createState() => _CryptoInfoPageState();
}

class _CryptoInfoPageState extends State<CryptoInfoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String textToCopy, String cryptoSymbol) {
    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$cryptoSymbol address copied!'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.defaultThemePurple,
          ),
        );
      }
    });
  }

  Future<void> _showReceiveQRBottomSheet(
    BuildContext context,
    WalletCryptoAssetModel asset,
  ) async {
    final String cryptoSymbol = asset.symbol;
    final String publicAddress = asset.publicAddress;
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final cryptoTemplate = walletProvider.getCryptoTemplate(cryptoSymbol);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Title
                    Text(
                      "Receive $cryptoSymbol",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // QR Code Container with neon effect
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.defaultThemePurple.withOpacity(
                              0.1,
                            ),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: publicAddress,
                        version: QrVersions.auto,
                        size: MediaQuery.of(context).size.height * 0.25,
                        gapless: true,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Address with copy button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade800,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              publicAddress,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade400),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            color: AppColors.defaultThemePurple,
                            onPressed: () =>
                                _copyToClipboard(publicAddress, cryptoSymbol),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.grey.shade900,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: AppColors.defaultThemePurple.withOpacity(
                                  0.5,
                                ),
                                width: 1,
                              ),
                            ),
                            onPressed: () {
                              _copyToClipboard(publicAddress, cryptoSymbol);
                            },
                            icon: Icon(
                              Icons.copy,
                              color: AppColors.defaultThemePurple,
                            ),
                            label: const Text("Copy"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.grey.shade900,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: AppColors.defaultThemePurple.withOpacity(
                                  0.5,
                                ),
                                width: 1,
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Share functionality coming soon!',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.share,
                              color: AppColors.defaultThemePurple,
                            ),
                            label: const Text("Share"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Retrieve the ETH price from the provider
    final ethPriceProvider = context.watch<EthPriceProvider>();
    final ethPrice = ethPriceProvider.ethPrice;

    final walletProvider = context.watch<WalletProvider>();
    final activeWallet = walletProvider.selectedWallet;
    final cryptoTemplate = walletProvider.getCryptoTemplate(
      widget.walletCryptoAsset.symbol,
    );

    final currentAsset = activeWallet?.dataKey.childKeys.firstWhere(
      (asset) => asset.symbol == widget.walletCryptoAsset.symbol,
      orElse: () => widget.walletCryptoAsset,
    );

    if (activeWallet == null ||
        cryptoTemplate == null ||
        currentAsset == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String walletName = activeWallet.walletName;
    final String walletAddress = currentAsset.publicAddress;
    final double cryptoPrice = cryptoTemplate.cryptoPrice;
    final double balance = currentAsset.balance;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.walletCryptoAsset.symbol,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          // Icon(Icons.candlestick_chart_outlined, color: Colors.white),
          // SizedBox(width: 16),
          // Icon(Icons.more_vert, color: Colors.white),
          // SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wallet Info Row
            Row(
              children: [
                Expanded(
                  child: infoBox(Icons.account_balance_wallet, walletName),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _copyToClipboard(
                      walletAddress,
                      widget.walletCryptoAsset.symbol,
                    ),
                    child: infoBox(
                      Icons.copy,
                      '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Crypto Logo, Balance, and ETH Price
            Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(cryptoTemplate.imgPath),
                  backgroundColor: AppColors.defaultThemePurple.withOpacity(
                    0.1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  balance.toStringAsFixed(
                    widget.walletCryptoAsset.symbol == 'BTC' ? 6 : 4,
                  ),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                // Text(
                //   "${FiatPriceConverter(context).symbol}${NumberFormat("#,##0.00").format(balance * cryptoPrice)}",
                //   style: const TextStyle(color: Colors.white60, fontSize: 16),
                // ),
                TotalBalanceTextWidget(),
                const SizedBox(height: 6),
                // ✅ Display the ETH price if the current asset is not ETH
                if (widget.walletCryptoAsset.symbol != 'ETH')
                  Text(
                    ethPrice == 0.0
                        ? "ETH Price: Loading..."
                        : "ETH Price: \$${NumberFormat("#,##0.00").format(ethPrice)}",
                    style: const TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                const SizedBox(height: 28),
              ],
            ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // actionButton("Swap", () => debugPrint("Clicked on swap")), // Swap button
                actionButton(
                  "Receive",
                  Icons.arrow_downward,
                  () => _showReceiveQRBottomSheet(context, currentAsset),
                ),
                const SizedBox(width: 12),
                actionButton("Send", Icons.arrow_upward, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SendPage(walletCryptoAsset: currentAsset),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 30),

            _tabBar(),
            const SizedBox(height: 12),
            SizedBox(height: 320, child: _tabBarView()),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget infoBox(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.defaultThemePurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.defaultThemePurple.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.defaultThemePurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget actionButton(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.defaultThemePurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _tabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: false,
      labelColor: AppColors.defaultThemePurple,
      unselectedLabelColor: Colors.white54,
      indicatorColor: AppColors.defaultThemePurple,
      indicatorWeight: 3,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      tabs: const [
        Tab(child: FittedBox(child: Text("Transactions"))),
        // Tab(child: FittedBox(child: Text("Services"))),
        // Tab(child: FittedBox(child: Text("News"))),
      ],
    );
  }

  Widget _tabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _EmptyTab(icon: Icons.insert_drive_file, title: "No transactions"),
        // _EmptyTab(
        //   icon: Icons.miscellaneous_services,
        //   title: "No services available",
        // ),
        // _EmptyTab(icon: Icons.article_outlined, title: "No news available"),
      ],
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String title;

  const _EmptyTab({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white30),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

/*
=================================================================
=================================================================
=================================================================
====================== SendPage starts ==========================
=================================================================
=================================================================
=================================================================
*/

class SendPage extends StatefulWidget {
  final WalletCryptoAssetModel walletCryptoAsset;
  const SendPage({super.key, required this.walletCryptoAsset});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final _formKey = GlobalKey<FormState>();
  final _toAddressController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // No listener needed here, fiat amount can be calculated on demand
  }

  @override
  void dispose() {
    _toAddressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // --- Core Transaction Logic ---
  Future<void> _sendTransaction() async {
    // This function is called from the confirmation dialog
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    // Close the confirmation dialog first
    Navigator.of(context).pop();

    // Navigate to the waiting page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TransactionStatusPage(status: 'waiting'),
        fullscreenDialog: true,
      ),
    );

    final recipient = _toAddressController.text;
    final amount = double.parse(_amountController.text);
    String privateKey = "${widget.walletCryptoAsset.privateKey}";

    // Normalize private key - remove 0x prefix and trim whitespace
    privateKey = privateKey.replaceFirst(RegExp(r'^0x'), '').trim();

    // Validate private key length before sending
    if (privateKey.length != 64) {
      setState(() => _isSending = false);
      Navigator.of(context).pop(); // Remove waiting page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TransactionStatusPage(
            status: 'fail',
            result: {
              'message': 'Invalid private key format',
              'details': 'Key must be 64 characters long without 0x prefix',
            },
          ),
        ),
      );
      return;
    }

    debugPrint(
      "Sending transaction with private key: ${privateKey.substring(0, 6)}...",
    );

    final result = await APIFunctions.sendEth(
      privateKey: privateKey,
      recipientAddress: recipient,
      amountEth: amount,
    );

    setState(() => _isSending = false);

    // Pop the waiting page and push the final status page
    Navigator.of(context).pop(); // Remove waiting page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TransactionStatusPage(
          status: result['status'],
          result: result,
          onRetry: () {
            Navigator.of(context).pop(); // Go back to SendPage on retry
          },
        ),
      ),
    );
  }

  // --- UI and Helper Methods ---

  /// ✅ KEPT: QR Code Scanning Logic
  Future<void> _scanQRCode() async {
    final String? scannedCode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        // Using your existing QR Scanner Bottom Sheet UI
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.92,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(153),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Text(
                    "Scan QR Code",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MobileScanner(
                        onDetect: (barcodeCapture) {
                          final String? code =
                              barcodeCapture.barcodes.first.rawValue;
                          if (code != null) Navigator.pop(context, code);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (scannedCode != null) {
      final cleanedCode = scannedCode.replaceFirst(
        RegExp(r'^ethereum:', caseSensitive: false),
        '',
      );
      _toAddressController.text = cleanedCode;
    }
  }

  void _pasteAddress() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _toAddressController.text = clipboardData!.text!;
    }
  }

  void _setMaxAmount(double balance) {
    _amountController.text = balance.toString();
  }

  /// ✅ UPDATED: Uses a themed AlertDialog as requested.
  void _showConfirmationDialog() {
    if (!_formKey.currentState!.validate()) return;

    final amount = _amountController.text;
    final recipient = _toAddressController.text;
    final cryptoSymbol = widget.walletCryptoAsset.symbol;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E), // Dark background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withAlpha(51)),
        ),
        title: const Text(
          "Confirm Transaction",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "You are about to send $amount $cryptoSymbol to the following address:\n\n$recipient",
          style: TextStyle(color: Colors.white.withAlpha(178)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.defaultThemePurple,
              foregroundColor: Colors.white,
            ),
            onPressed: _sendTransaction,
            child: FittedBox(child: const Text("Confirm & Send")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        final currentAsset = walletProvider.selectedWallet?.dataKey.childKeys
            .firstWhere(
              (asset) => asset.symbol == widget.walletCryptoAsset.symbol,
              orElse: () => widget.walletCryptoAsset,
            );

        if (currentAsset == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final availableBalance = currentAsset.balance;
        //final cryptoTemplate = walletProvider.getCryptoTemplate(currentAsset.symbol)!;

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: const SimpleAppbarWidget(appbarTitle: "Send"),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildInputCard(
                            label: "To Address",
                            child: TextFormField(
                              controller: _toAddressController,
                              // ✅ MODIFIED: Allow the text field to expand vertically
                              maxLines: null,
                              minLines: 1,
                              decoration: _inputDecoration(
                                hint: "0x...",
                                suffix: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.paste,
                                        color: Colors.white70,
                                      ),
                                      onPressed: _pasteAddress,
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.qr_code_scanner,
                                        color: AppColors.defaultThemePurple,
                                      ),
                                      onPressed: _scanQRCode,
                                    ),
                                  ],
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              validator: (value) {
                                if (value == null ||
                                    !value.startsWith('0x') ||
                                    value.length < 42) {
                                  return 'Please enter a valid address';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildInputCard(
                            label: "Amount",
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: _inputDecoration(
                                hint: "0.00",
                                suffix: TextButton(
                                  onPressed: () =>
                                      _setMaxAmount(availableBalance),
                                  child: const Text(
                                    "MAX",
                                    style: TextStyle(
                                      color: AppColors.defaultThemePurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter an amount';
                                final amount = double.tryParse(value);
                                if (amount == null || amount <= 0)
                                  return 'Invalid amount';
                                if (amount > availableBalance)
                                  return 'Amount exceeds available balance';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              "Available: ${availableBalance.toStringAsFixed(4)} ${currentAsset.symbol}",
                              style: TextStyle(
                                color: Colors.white.withAlpha(150),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // This pushes the button to the bottom
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.defaultThemePurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSending ? null : _showConfirmationDialog,
                      child: _isSending
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Next",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Reusable UI Helper Widgets ---
  Widget _buildInputCard({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(150)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withAlpha(175), fontSize: 16),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
      border: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      suffixIcon: suffix,
    );
  }
}
