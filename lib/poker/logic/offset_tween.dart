import 'package:flutter/material.dart';

class OffsetTween extends Tween<Offset> {
  /// Creates a fractional offset tween.
  ///
  /// The [begin] and [end] properties may be null; the null value
  /// is treated as meaning the center.
  OffsetTween({super.begin, super.end});

  /// Returns the value this variable has at the given animation clock value.
  @override
  Offset lerp(double t) => Offset.lerp(begin, end, t)!;
}
