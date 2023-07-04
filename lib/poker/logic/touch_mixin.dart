import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:poker/poker/config.dart';

mixin TouchMixin {
  Offset? _down;
  Offset _dif = Offset.zero;

  void onPanDown(Offset d) => _down = d;

  Offset byMove(Offset move) => move - _down!;

  Offset lastMove(Offset dif) => _down! + dif;

  Offset get dif => _dif;

  set dif(Offset dif) => _dif = dif;

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
    double v = min(Config.maxAnimV, max(vX.abs(), vY.abs()));
    int d = 600 - (100 * (v / Config.maxAnimV)).toInt();
    return d;
  }
}
