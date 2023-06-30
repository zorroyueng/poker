import 'dart:math';

import 'package:flutter/cupertino.dart';

mixin TouchMixin {
  Offset? _down;
  Offset dif = Offset.zero;
  static const double maxSwipeVelocity = 3; // 滑动速度判断swipeOut最大值
  static const double maxAnimVelocity = 7; // 动画速度最大值

  void onPanDown(Offset d) => _down = d;

  Offset byMove(Offset move) => move - _down!;

  Offset lastMove(Offset dif) => _down! + dif;

  Alignment byDown(Rect rc) {
    if (_down == null) {
      return const Alignment(0, 0);
    } else {
      double w = rc.width / 2;
      double h = rc.height / 2;
      return Alignment(
        (_down!.dx - w) / w,
        (_down!.dy - h) / h,
      );
    }
  }

  bool dragAtTop(Rect rc) {
    if (_down == null) {
      return true;
    } else {
      return _down!.dy <= rc.height / 2;
    }
  }

  double velocity(bool x, Offset o, Rect rc) {
    if (x) {
      return o.dx / rc.shortestSide;
    } else {
      return o.dy / rc.shortestSide;
    }
  }

  int duration(double vX, double vY) {
    double v = min(maxAnimVelocity, sqrt(vX * vX + vY * vY));
    int d = 500 - (300 * (v / maxAnimVelocity)).toInt();
    return d;
  }
}
