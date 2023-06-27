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
      return Alignment(
        (_down!.dx - rc.center.dx) / rc.width * 2,
        (_down!.dy - rc.center.dy) / rc.height * 2,
      );
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
