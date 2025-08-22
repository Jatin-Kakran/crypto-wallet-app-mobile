import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../setting_child_widgets.dart';
import '../state/local_settings_provider.dart';

class FiatPriceConverter {
  final BuildContext context;
  final bool listen;

  FiatPriceConverter(this.context, {this.listen = false});

  String get symbol {
    final settings = Provider.of<LocalSettingsState>(context, listen: listen);
    return settings.currency.symbol;
  }

  double convert(double usdPrice) {
    final settings = Provider.of<LocalSettingsState>(context, listen: listen);
    final rate = fiatConversionRates[settings.currency] ?? 1.0;
    return usdPrice * rate;
  }

  String format(double usdPrice, {int decimals = 2}) {
    return "$symbol${convert(usdPrice).toStringAsFixed(decimals)}";
  }
}
