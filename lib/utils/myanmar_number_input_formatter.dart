import 'package:donation/utils/age_utils.dart';
import 'package:flutter/services.dart';

/// Accepts ASCII or Myanmar digits and stores the normalized ASCII value.
class MyanmarNumberInputFormatter extends TextInputFormatter {
  const MyanmarNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = normalizeMyanmarDigits(newValue.text);
    if (normalized.isNotEmpty && !RegExp(r'^\d+$').hasMatch(normalized)) {
      return oldValue;
    }
    return newValue.copyWith(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
      composing: TextRange.empty,
    );
  }
}
