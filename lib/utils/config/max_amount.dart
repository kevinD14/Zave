import 'package:flutter/services.dart';

class MaxAmountFormatter extends TextInputFormatter {
  static const double maxAmount = 9999.99;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if ('.'.allMatches(text).length > 1) {
      return oldValue;
    }

    final parsed = double.tryParse(text);
    if (parsed != null && parsed > maxAmount) {
      return oldValue;
    }

    return newValue;
  }
}
