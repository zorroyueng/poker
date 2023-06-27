import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:poker/poker/logic/offset_tween.dart';
import 'package:poker/poker/logic/poker_card.dart';
import 'package:poker/poker/poker_view.dart';

mixin AnimMixin {
  late final AnimationController ctrl;
  Animation<Offset>? _animation;

  Offset byAnim() => _animation!.value;

  void toTop() {}

  void toRight() {}

  void toLeft() {}

  void toIdle(Offset dif) {
    _animation = ctrl.drive(
      OffsetTween(
        begin: dif,
        end: Offset.zero,
      ),
    );
    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );
    final simulation = SpringSimulation(spring, 0, 1, 0);
    ctrl.animateWith(simulation);
  }

  void initAnim(PokerCardState t, VoidCallback cb) {
    ctrl = AnimationController(vsync: t);
    ctrl.addListener(cb);
  }

  void disposeAnim() => ctrl.dispose();
}

class AlignmentTween extends Tween<Alignment> {
  /// Creates a fractional offset tween.
  ///
  /// The [begin] and [end] properties may be null; the null value
  /// is treated as meaning the center.
  AlignmentTween({super.begin, super.end});

  /// Returns the value this variable has at the given animation clock value.
  @override
  Alignment lerp(double t) => Alignment.lerp(begin, end, t)!;
}
