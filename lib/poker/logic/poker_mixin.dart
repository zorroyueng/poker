import 'dart:ui';

import 'package:poker/poker/config.dart';

mixin PokerMixin {
  Size _size = Size.zero;
  Rect _rect = Rect.zero;

  Size size() => _size;

  Rect idle(Size size) {
    if (size != _size) {
      _size = size;
      double centerX = size.width / 2;
      double centerY = size.height / 2;
      double p = size.shortestSide * Config.paddingK;
      double width = size.width - 2 * p;
      double height = size.height - 2 * p;
      if (width / height >= Config.aspectRatio) {
        width = height * Config.aspectRatio;
      } else {
        height = width / Config.aspectRatio;
      }
      _rect = Rect.fromLTWH(
        centerX - width / 2,
        centerY - height / 2,
        width,
        height,
      );
    }
    return _rect;
  }
}
