import 'dart:ui';

mixin PokerMixin {
  static const double _paddingK = .1; // 最小边比例
  static const double _aspectRatio = .6; // 卡片宽高比

  Size _size = Size.zero;
  Rect _rect = Rect.zero;

  Rect idle(Size size) {
    if (size != _size) {
      _size = size;
      double centerX = size.width / 2;
      double centerY = size.height / 2;
      double p = size.shortestSide * _paddingK;
      double width = size.width - 2 * p;
      double height = size.height - 2 * p;
      if (width / height >= _aspectRatio) {
        width = height * _aspectRatio;
      } else {
        height = width / _aspectRatio;
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
