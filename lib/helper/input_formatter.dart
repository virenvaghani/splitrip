import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class InputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('en_IN'); // Use 'en_IN' for Indian-style commas (e.g., 45,55,566)

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove non-numeric characters except for the decimal point
    String cleanedText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleanedText.isEmpty || cleanedText == '.') {
      return newValue.copyWith(text: '');
    }

    // Parse the number
    double? value = double.tryParse(cleanedText);
    if (value == null) {
      return oldValue;
    }

    // Format with thousand separators
    String formatted = _formatter.format(value.round()); // Round to avoid decimals
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}