import 'dart:ui';
import 'dart:math' as math;
import 'package:poker/poker/config.dart';

mixin LayoutMixin {
  bool canSwipeOut(bool x, Offset dif, Rect rect) {
    if (x) {
      return dif.dx.abs() >= Config.swipeK * rect.shortestSide && dif.dx.abs() >= dif.dy.abs(); // 左右滑动
    } else {
      return -dif.dy >= Config.swipeK * rect.shortestSide && dif.dy.abs() >= dif.dx.abs(); // 向上滑动
    }
  }

  // 滑动百分比为 unit==true?[-1,1]:[?,?]
  double swipePercent({
    required bool x,
    required Offset dif,
    required Rect rect,
    double k = Config.percentSwipeK,
    bool unit = true,
  }) {
    if (rect.isEmpty) {
      return 0;
    } else {
      if (x) {
        double p = dif.dx.abs() / (rect.shortestSide * k);
        return (unit ? math.min(1, p) : p) * (dif.dx >= 0 ? 1 : -1);
      } else {
        double p = dif.dy.abs() / (rect.shortestSide * k);
        return (unit ? math.min(1, p) : p) * (dif.dy <= 0 ? -1 : 1);
      }
    }
  }

  double rotate(Offset dif, Rect rect, bool up) =>
      swipePercent(
        x: true,
        dif: dif,
        rect: rect,
        k: Config.percentRotateK,
      ) *
      Config.maxRotate *
      (up ? 1 : -1);

  Offset end({
    bool? right, // true: right, false: left, null: up
    required Offset dif,
    required Rect rect,
    required double vX,
    required double vY,
  }) {
    // 消失边界
    Rect rc = Rect.fromCenter(
      center: rect.center,
      width: rect.width * Config.disappearK,
      height: rect.height * Config.disappearK,
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

  double backScale(double percent) => Config.backCardScale + (1 - Config.backCardScale) * percent;

  Offset backOffset(double percent, Rect rect) => Offset(
        rect.width * Config.backCardOffset.dx * (1 - percent),
        rect.height * Config.backCardOffset.dy * (1 - percent),
      );
}
