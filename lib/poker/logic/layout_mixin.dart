import 'dart:math' as math;
import 'dart:ui';

import 'package:poker/poker/poker_config.dart';

mixin LayoutMixin {
  static const double _percentSwipeK = .3; // 滑动超出宽高范围，计算滑动百分比使用，back也使用做变换
  static const double _percentRotateK = .6; // 滑动超出宽高范围，计算旋转百分比使用
  static const double _swipeK = .5; // 滑动超出宽高范围，判断滑动阈值
  static const double _maxRotate = 10 * math.pi / 180; // 卡片横向滑动最大旋转角度
  static const double _disappearK = 2.7; // 消失边界为宽or高的倍数

  bool canSwipeOut(bool x, Offset dif, Rect rect) {
    if (x) {
      return dif.dx.abs() >= _swipeK * rect.shortestSide && dif.dx.abs() >= dif.dy.abs(); // 左右滑动
    } else {
      return -dif.dy >= _swipeK * rect.shortestSide && dif.dy.abs() >= dif.dx.abs(); // 向上滑动
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
    bool? right, // true: right, false: left, null: up
    Offset dif,
    Rect rect,
    double vX,
    double vY,
  ) {
    // 消失边界
    Rect rc = Rect.fromCenter(
      center: rect.center,
      width: rect.width * _disappearK,
      height: rect.height * _disappearK,
    );
    late Offset end;
    if (right != null) {
      if (vX != 0) {
        double x = (vX > 0 ? 1 : -1) * rc.width / 2;
        double y = dif.dy + (x - dif.dx) / vX * vY;
        end = Offset(x, y);
        // print('1 end=$end, dif=$dif');
      } else {
        end = Offset((right ? 1 : -1) * rc.width / 2, dif.dy);
        // print('2 end=$end, dif=$dif');
      }
    } else {
      if (vY != 0) {
        double y = -rc.height / 2;
        double x = dif.dx + (y - dif.dy) / vY * vX;
        end = Offset(x, y);
        // print('3 end=$end, dif=$dif');
      } else {
        end = Offset(dif.dx, -rc.height / 2);
        // print('4 end=$end, dif=$dif');
      }
    }
    return end;
  }

  double backScale(double percent) => PokerConfig.backCardScale + (1 - PokerConfig.backCardScale) * percent;

  Offset backOffset(double percent, Rect rect) => Offset(
        rect.width * PokerConfig.backCardOffset.dx * (1 - percent),
        rect.height * PokerConfig.backCardOffset.dy * (1 - percent),
      );
}
