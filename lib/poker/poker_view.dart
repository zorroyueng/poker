import 'package:flutter/material.dart';
import 'package:poker/poker/logic/anim_mixin.dart';
import 'package:poker/poker/logic/layout_mixin.dart';
import 'package:poker/poker/logic/touch_mixin.dart';

class PokerView extends StatefulWidget {
  final Widget child;

  const PokerView({super.key, required this.child});

  @override
  State<PokerView> createState() => PokerViewState();
}

class PokerViewState extends State<PokerView> with SingleTickerProviderStateMixin, TouchMixin, AnimMixin, LayoutMixin {
  @override
  void initState() {
    initAnim(this, () => setState(() => dif = byAnim()));
    super.initState();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        Rect rect = idle(Size(constraints.maxWidth, constraints.maxHeight));
        Alignment alignment = byDown(rect);
        return GestureDetector(
          onPanDown: (d) {
            ctrl.stop();
            onPanDown(d.localPosition);
          },
          onPanUpdate: (d) => setState(() => dif = byMove(d.localPosition)),
          onPanEnd: (d) {
            double vX = velocity(true, d.velocity.pixelsPerSecond, rect);
            double vY = velocity(false, d.velocity.pixelsPerSecond, rect);
            if (vY > TouchMixin.maxVelocity || canSwipeOut(false, dif)) {
              toTop();
              toIdle(dif);
            } else if (vX.abs() > TouchMixin.maxVelocity || canSwipeOut(true, dif)) {
              if (dif.dx > 0) {
                toRight();
                toIdle(dif);
              } else {
                toLeft();
                toIdle(dif);
              }
            } else {
              toIdle(dif);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fromRect(
                rect: rect.translate(dif.dx, dif.dy),
                child: Transform.rotate(
                  angle: rotate(dif, alignment.y <= 0),
                  alignment: alignment,
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
