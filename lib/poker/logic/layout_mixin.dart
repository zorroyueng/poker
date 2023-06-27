import 'dart:math' as math;
import 'dart:ui';

mixin LayoutMixin {
  static const double _percentK = .4; // 滑动超出宽高范围，计算百分比使用
  static const double _swipeK = .2; // 滑动超出宽高范围，判断滑动阈值
  static const _maxRotate = 10 * math.pi / 180; // 卡片横向滑动最大旋转角度

  bool canSwipeOut(bool x, Offset dif, Rect rect) {
    if (x) {
      return dif.dx.abs() >= _swipeK * rect.width; // 左右滑动
    } else {
      return dif.dy >= _swipeK * rect.height; // 向上滑动
    }
  }

  double percent(bool x, Offset dif, Rect rect) {
    if (rect.isEmpty) {
      return 0;
    } else {
      if (x) {
        return dif.dx / (rect.width * _percentK);
      } else {
        return dif.dy / (rect.height * _percentK);
      }
    }
  }

  double rotate(Offset dif, Rect rect, bool up) => percent(true, dif, rect) * _maxRotate * (up ? 1 : -1);
}
