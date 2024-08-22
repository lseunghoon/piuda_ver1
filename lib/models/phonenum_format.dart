import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length <= 3) {
      return newValue;
    } else if (text.length <= 7) {
      final newText = text.substring(0, 3) + '-' + text.substring(3);
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } else if (text.length <= 11) {
      final newText = text.substring(0, 3) + '-' + text.substring(3, 7) + '-' + text.substring(7);
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } else {
      return oldValue;
    }
  }
}