import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../setting_child_widgets.dart';
import '../settings_screen.dart';
//import 'enums.dart'; // if you defined enums like AppearanceMode, FiatCurrency, etc.


class LocalSettingsState extends ChangeNotifier {
  AppearanceMode _appearance = AppearanceMode.dark;
  FiatCurrency _currency = FiatCurrency.usd;
  AppLanguage _language = AppLanguage.english;
  TransactionCost _txCost = TransactionCost.middle;

  AppearanceMode get appearance => _appearance;
  FiatCurrency get currency => _currency;
  AppLanguage get language => _language;
  TransactionCost get txCost => _txCost;

  Color kLineColorUp = const Color(0xFF34C759);
  Color kLineColorDown = const Color(0xFFE54242);


  LocalSettingsState() {
    loadSettings(); // Load persisted settings on startup
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _appearance = AppearanceMode.values[prefs.getInt('appearance') ?? 1]; // dark
    _currency = FiatCurrency.values[prefs.getInt('currency') ?? 0];
    _language = AppLanguage.values[prefs.getInt('language') ?? 0];
    _txCost = TransactionCost.values[prefs.getInt('txCost') ?? 1]; // middle
    notifyListeners();
  }

  Future<void> setAppearance(AppearanceMode mode) async {
    _appearance = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('appearance', mode.index);
  }

  Future<void> setCurrency(FiatCurrency currency) async {
    _currency = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('currency', currency.index);
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('language', lang.index);
  }

  void setKLineColors({required Color up, required Color down}) {
    kLineColorUp = up;
    kLineColorDown = down;
    notifyListeners();
    persist();
  }



  Future<void> setTransactionCost(TransactionCost cost) async {
    _txCost = cost;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('txCost', cost.index);
  }

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('appearance', _appearance.index);
    prefs.setInt('currency', _currency.index);
    prefs.setInt('language', _language.index);
    prefs.setInt('txCost', _txCost.index);
    // Optionally persist K-Line colors if needed (store as ARGB or hex)
  }

}


class LocalSettingsProvider extends InheritedNotifier<LocalSettingsState> {
  const LocalSettingsProvider({
    Key? key,
    required LocalSettingsState appState,
    required Widget child,
  }) : super(key: key, notifier: appState, child: child);

  static LocalSettingsState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocalSettingsProvider>()!.notifier!;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotifier<LocalSettingsState> oldWidget) {
    return true;
  }
}
