import 'package:flutter/material.dart';
import 'package:poker/poker/logic/poker_card.dart';

mixin AnimMixin {
  late final AnimationController _ctrl;
  Animation<Offset>? _animation;
  VoidCallback? _onEnd;

  Offset byAnim() => _animation!.value;

  void toTop() {}

  void anim({
    required Offset begin,
    required Offset end,
    required int duration,
    required Curve curve,
    VoidCallback? onEnd,
  }) {
    stopAnim();
    _animation = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: curve,
    ));
    _ctrl.duration = Duration(milliseconds: duration);
    if (onEnd != null) {
      _onEnd = () {
        if (_ctrl.value == 1) {
          onEnd.call();
          _ctrl.removeListener(_onEnd!);
        }
      };
      _ctrl.addListener(_onEnd!);
    }
    _ctrl.forward(from: 0);
  }

  void toLeft() {}

  void toIdle(Offset dif) {
    stopAnim();
    _animation = Tween<Offset>(
      begin: dif,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.duration = Duration(milliseconds: dif == Offset.zero ? 0 : 500);
    _ctrl.forward(from: 0);
  }

  void initAnim(PokerCardState t, VoidCallback cb) {
    _ctrl = AnimationController(vsync: t);
    _ctrl.addListener(cb);
  }

  void disposeAnim() => _ctrl.dispose();

  void stopAnim() {
    if (_onEnd != null) {
      _ctrl.removeListener(_onEnd!);
      _onEnd = null;
    }
    _ctrl.stop();
  }
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

class Jump extends Curve {
  final double _k = .8;

  @override
  double transform(double t) {
    return t * t * ((_k + 1) * t - _k);
  }
}
