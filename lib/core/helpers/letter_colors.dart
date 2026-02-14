import 'package:flutter/material.dart';
import '../theming/app_theme.dart';

class LetterColors {
  static final Map<String, Color> _colors = {
    'ا': const Color(0xFF2F80ED),
    'ب': const Color(0xFF27AE60),
    'ت': const Color(0xFF9B51E0),
    'ث': const Color(0xFFF2994A),
    'ج': const Color(0xFF56CCF2),
    'ح': const Color(0xFFEB5757),
    'خ': const Color(0xFF6FCF97),
    'د': const Color(0xFFBB6BD9),
    'ذ': const Color(0xFF2D9CDB),
    'ر': const Color(0xFF219653),
    'ز': const Color(0xFFF2C94C),
    'س': const Color(0xFF3F8CFF),
    'ش': const Color(0xFF00BFA6),
    'ص': const Color(0xFFFC5C65),
    'ض': const Color(0xFF8E44AD),
    'ط': const Color(0xFF2ECC71),
    'ظ': const Color(0xFF1ABC9C),
    'ع': const Color(0xFF6C5CE7),
    'غ': const Color(0xFF0984E3),
    'ف': const Color(0xFF00B894),
    'ق': const Color(0xFFE17055),
    'ك': const Color(0xFF6C5CE7),
    'ل': const Color(0xFF00CEC9),
    'م': const Color(0xFF00B894),
    'ن': const Color(0xFF00A8FF),
    'ه': const Color(0xFF9B59B6),
    'و': const Color(0xFF1ABC9C),
    'ي': const Color(0xFF3498DB),
  };

  static Color forLetter(String letter) {
    return _colors[letter] ?? AppTheme.primaryTeal;
  }
}
