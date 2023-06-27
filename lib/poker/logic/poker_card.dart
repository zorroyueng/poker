import 'package:flutter/material.dart';
import 'package:poker/poker/logic/anim_mixin.dart';
import 'package:poker/poker/logic/layout_mixin.dart';
import 'package:poker/poker/logic/touch_mixin.dart';

class PokerCard extends StatefulWidget {
  final Widget child;
  final Rect rect;

  const PokerCard({super.key, required this.child, required this.rect});

  @override
  State<PokerCard> createState() => PokerCardState();
}

class PokerCardState extends State<PokerCard> with SingleTickerProviderStateMixin, TouchMixin, AnimMixin, LayoutMixin {
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
    return Positioned.fromRect(
      rect: widget.rect.translate(dif.dx, dif.dy),
      child: GestureDetector(
        onPanDown: (d) {
          ctrl.stop();
          onPanDown(d.localPosition);
        },
        onPanUpdate: (d) => setState(() => dif = byMove(d.localPosition)),
        onPanEnd: (d) {
          double vX = velocity(true, d.velocity.pixelsPerSecond, widget.rect);
          double vY = velocity(false, d.velocity.pixelsPerSecond, widget.rect);
          if (vY > TouchMixin.maxVelocity || canSwipeOut(false, dif, widget.rect)) {
            toTop();
            toIdle(dif);
          } else if (vX.abs() > TouchMixin.maxVelocity || canSwipeOut(true, dif, widget.rect)) {
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
        child: Transform.rotate(
          angle: rotate(dif, widget.rect, dragAtTop(widget.rect)),
          alignment: byDown(widget.rect),
          child: widget.child,
        ),
      ),
    );
  }
}
