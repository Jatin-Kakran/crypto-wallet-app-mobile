import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart'; // Make sure this is imported
import 'package:crypto_wallet_app_mobile/main_screen.dart';
import 'package:crypto_wallet_app_mobile/password_setup_page.dart';
import 'package:crypto_wallet_app_mobile/state/eth_price_state.dart';
import 'package:crypto_wallet_app_mobile/state/local_settings_provider.dart';
import 'package:crypto_wallet_app_mobile/state/wallet_provider.dart'; // Make sure this is imported
import 'home_page.dart'; // Assuming this is Homepage
import 'login_page.dart';
import 'market_screen.dart';
import 'null_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //final walletProvider = WalletProvider();
  final settingsState = LocalSettingsState();
  await settingsState.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => LocalSettingsState()),
        ChangeNotifierProvider(create: (_) => EthPriceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isPasswordSaved() async {
    final storage = const FlutterSecureStorage();
    return storage.containsKey(key: 'user_password');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Core Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: FutureBuilder(
        future: _isPasswordSaved(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data == true) {
            return Consumer<WalletProvider>(
              builder: (context, walletProvider, child) {
                if (walletProvider.isLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (walletProvider.errorMessage != null) {
                  return Scaffold(
                    body: Center(
                      child: Text('Error: ${walletProvider.errorMessage}'),
                    ),
                  );
                }
                // *** CRUCIAL CHECK: Check for selectedWallet ***
                if (walletProvider.selectedWallet != null) {
                  // Wallets exist, go to HomeScreen
                  return const HomeScreen();
                } else {
                  // No wallets exist, go to LoginPage
                  return LoginPage();
                }
              },
            );
          } else {
            return LoginPage();
          }
        },
      ),
      routes: {
        // All these routes will now also have access to WalletProvider
        '/login_page': (context) => LoginPage(),
        'password_setup_page': (context) => PasswordSetupPage(),
        '/homePage': (context) => Homepage(),
        '/market_screen': (context) => MarketScreen(),
        '/nullPage': (context) => NullPage(),
      },
    );
  }
}
