import 'package:flutter/material.dart';

class WalletDeletionSplashPage extends StatefulWidget {
  const WalletDeletionSplashPage({super.key});

  @override
  State<WalletDeletionSplashPage> createState() =>
      _WalletDeletionSplashPageState();
}

class _WalletDeletionSplashPageState extends State<WalletDeletionSplashPage> {
  bool _showDeletedGif = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showDeletedGif = true;
      });

      // Delay before navigating away
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/login_page');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _showDeletedGif
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/gifs/wallet_deleted.gif', // <- make sure this path is correct
                    height: 180,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "All wallets deleted successfully!",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: Colors.redAccent),
                  SizedBox(height: 20),
                  Text(
                    "Deleting Wallets...",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
      ),
    );
  }
}
