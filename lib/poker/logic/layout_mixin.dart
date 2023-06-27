import 'dart:math' as math;
import 'dart:ui';

mixin LayoutMixin {
  static const double _paddingK = .1; // 最小边比例
  static const double _percentK = .4; // 滑动超出宽高范围，计算百分比使用
  static const double _swipeK = .2; // 滑动超出宽高范围，判断滑动阈值
  static const double _aspectRatio = .6; // 卡片宽高比
  static const _maxRotate = 10 * math.pi / 180; // 卡片横向滑动最大旋转角度
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

  bool canSwipeOut(bool x, Offset dif) {
    if (x) {
      return dif.dx.abs() >= _swipeK * _rect.width; // 左右滑动
    } else {
      return dif.dy >= _swipeK * _rect.height; // 向上滑动
    }
  }

  double percent(bool x, Offset dif) {
    if (_rect.isEmpty) {
      return 0;
    } else {
      if (x) {
        return dif.dx / (_rect.width * _percentK);
      } else {
        return dif.dy / (_rect.height * _percentK);
      }
    }
  }

  double rotate(Offset dif, bool up) => percent(true, dif) * _maxRotate * (up ? 1 : -1);
}
