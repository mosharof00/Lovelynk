import '../utils/helper_utils.dart';

extension GetCurrencyExtension on num {
  String getCurrency({bool isDecimal = false}) {
    final symbol = HelperUtils.currencySymbol;

    if (isDecimal) {
      return "$symbol${toStringAsFixed(2)}"; // always 2 decimal places
    } else {
      return "$symbol${toInt()}"; // drop decimals
    }
  }
}
