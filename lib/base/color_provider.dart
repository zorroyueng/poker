import 'package:base/base.dart';
import 'package:flutter/material.dart';

class ColorProvider {
  ColorProvider._();

  /// base
  static Color itemBg([bool? dark]) => dark ?? ThemeProvider.isDark() ? const Color(0xFF171717) : Colors.grey[50]!;

  // static Color textColor() => ThemeProvider.dark() ? Colors.grey[300]! : Colors.grey[600]!;
  static Color textColor() => ThemeProvider.isDark() ? Colors.white : Colors.black;

  static Color textBorderColor() => ThemeProvider.isDark() ? Colors.black26 : Colors.white24;

  static Color btnBg() => ThemeProvider.isDark() ? Colors.grey[700]! : Colors.grey[400]!;

  static Color textBg() => ThemeProvider.isDark() ? Colors.grey.withOpacity(.3) : Colors.grey.withOpacity(.3);

  static Color menuBg() => ThemeProvider.isDark() ? Colors.grey[800]! : Colors.grey[200]!;

  /// bone studio
  // static Color animBg(bool b) =>
  //     ThemeProvider.dark() ? (b ? Colors.grey[850]! : Colors.grey[800]!) : (b ? Colors.grey[200]! : Colors.grey[300]!);

  static Color animText(Color c, bool to) => ThemeProvider.isDark()
      ? (to ? c.withOpacity(.6) : c.withOpacity(.3))
      : (to ? c.withOpacity(1) : c.withOpacity(.5));

  static Color editMask() => ThemeProvider.isDark() ? Colors.black.withOpacity(.66) : Colors.white.withOpacity(.66);

  static Color barMask() => ThemeProvider.isDark() ? Colors.black.withOpacity(.8) : Colors.white.withOpacity(.9);

  static Color headBg() => ThemeProvider.map['grey']!.withOpacity(ThemeProvider.isDark() ? 0.1 : 0.1);

  static Color durationBg() => ThemeProvider.map['lime']!.withOpacity(ThemeProvider.isDark() ? 0.1 : 0.1);

  static Color moveBg() => ThemeProvider.map['amber']!.withOpacity(ThemeProvider.isDark() ? 0.1 : 0.1);

  static Color scaleBg() => ThemeProvider.map['lightBlue']!.withOpacity(ThemeProvider.isDark() ? 0.1 : 0.1);

  static Color rotateBg() => ThemeProvider.map['teal']!.withOpacity(ThemeProvider.isDark() ? 0.1 : 0.05);

  static Color alphaBg() => ThemeProvider.map['pink']!.withOpacity(ThemeProvider.isDark() ? 0.1 : 0.1);

  static Color listItemBg(int index) {
    List<MaterialColor> colors = ThemeProvider.map.values.toList();
    return ThemeProvider.isDark()
        ? colors[index % colors.length].withOpacity(.1)
        : colors[index % colors.length].shade800.withOpacity(.1);
  }
}
