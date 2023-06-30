import 'dart:math' as math;
import 'dart:ui';

mixin LayoutMixin {
  static const double _percentSwipeK = .3; // 滑动超出宽高范围，计算滑动百分比使用，back也使用做变换
  static const double _percentRotateK = .6; // 滑动超出宽高范围，计算旋转百分比使用
  static const double _swipeK = .2; // 滑动超出宽高范围，判断滑动阈值
  static const double _maxRotate = 10 * math.pi / 180; // 卡片横向滑动最大旋转角度
  static const double _disappearK = 2.5; // 消失边界为宽or高的倍数

  bool canSwipeOut(bool x, Offset dif, Rect rect) {
    if (x) {
      return dif.dx.abs() >= _swipeK * rect.shortestSide; // 左右滑动
    } else {
      return -dif.dy >= _swipeK * rect.shortestSide; // 向上滑动
    }
  }

  // 滑动百分比为[0,1]
  double swipePercent(bool x, Offset dif, Rect rect, [double k = _percentSwipeK]) {
    if (rect.isEmpty) {
      return 0;
    } else {
      if (x) {
        return math.min(1, dif.dx.abs() / (rect.shortestSide * k));
      } else {
        return math.min(1, dif.dy.abs() / (rect.shortestSide * k));
      }
    }
  }

  double rotate(Offset dif, Rect rect, bool up) =>
      swipePercent(true, dif, rect, _percentRotateK) * _maxRotate * (up ? 1 : -1) * (dif.dx >= 0 ? 1 : -1);

  Offset end(
    bool x, // x方向还是y方向
    Offset dif,
    Rect rect,
    double vX,
    double vY, [
    bool right = true,
  ]) {
    // 消失边界
    Rect rc = Rect.fromCenter(
      center: rect.center,
      width: rect.width * _disappearK,
      height: rect.height * _disappearK,
    );
    late Offset end;
    if (x) {
      if (vX != 0) {
        double x = (vX > 0 ? 1 : -1) * rc.width / 2;
        double y = dif.dy + (x - dif.dx) / vX * vY;
        end = Offset(x, y);
      } else {
        end = Offset((right ? 1 : -1) * rect.width / 2, -rect.height / 4);
      }
    } else {
      if (vY != 0) {
        double y = -rc.height / 2;
        double x = dif.dx + (y - dif.dy) / vY * vX;
        end = Offset(x, y);
      } else {
        end = Offset(0, -rc.height / 2);
      }
    }
    return end;
  }
}
