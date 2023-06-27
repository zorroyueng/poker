import 'package:flutter/cupertino.dart';

mixin TouchMixin {
  Offset? _down;
  Offset dif = Offset.zero;
  static const double maxVelocity = 5;

  void onPanDown(Offset d) => _down = d;

  Offset byMove(Offset move) => move - _down!;

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
      return _down!.dy <= rc.center.dy;
    }
  }

  double velocity(bool x, Offset o, Rect rc) {
    if (x) {
      return o.dx / rc.width;
    } else {
      return o.dy / rc.height;
    }
  }
}
