import 'package:base/base.dart';
import 'package:flutter/material.dart';

class ColorProvider {
  ColorProvider._();

  /// base
  static Color bg() => ThemeProvider.isDark() ? Colors.black : Colors.white;

  static Color itemBg([bool? dark]) => dark ?? ThemeProvider.isDark() ? const Color(0xFF171717) : Colors.grey[50]!;

  static Color base([double alpha = 1]) => Colors.white.withOpacity(alpha);

  static Color textColor() => ThemeProvider.isDark() ? Colors.white : Colors.black;

  static Color textBorderColor() => Colors.grey[900]!;

  static Color btnBg() => ThemeProvider.isDark() ? Colors.grey[700]! : Colors.grey[400]!;

  static Color textBg() => ThemeProvider.isDark() ? Colors.grey.withOpacity(.3) : Colors.grey.withOpacity(.3);

  static Color menuBg() => ThemeProvider.isDark() ? Colors.grey[800]! : Colors.grey[200]!;
}
