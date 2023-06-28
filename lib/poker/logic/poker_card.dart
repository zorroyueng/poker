import 'package:flutter/material.dart';
import 'package:poker/poker/logic/anim_mixin.dart';
import 'package:poker/poker/logic/layout_mixin.dart';
import 'package:poker/poker/logic/poker_adapter.dart';
import 'package:poker/poker/logic/touch_mixin.dart';

class PokerCard extends StatefulWidget {
  final PokerAdapter adapter;
  final PokerItem item;
  final Rect rect;

  const PokerCard({super.key, required this.item, required this.rect, required this.adapter});

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
    disposeAnim();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: widget.rect.translate(dif.dx, dif.dy),
      child: GestureDetector(
        onPanDown: (d) {
          stopAnim();
          onPanDown(d.localPosition);
          widget.adapter.prepareItem(widget.item);
        },
        onPanUpdate: (d) => setState(() => dif = byMove(d.localPosition)),
        onPanEnd: (d) {
          Offset v = d.velocity.pixelsPerSecond;
          double vX = velocity(true, v, widget.rect);
          double vY = velocity(false, v, widget.rect);
          if (vY > TouchMixin.maxSwipeVelocity && vY > vX.abs() && canSwipeOut(false, dif, widget.rect)) {
            toTop();
            toIdle(dif);
          } else if (vX >= TouchMixin.maxSwipeVelocity) {
            Offset e = end(dif, widget.rect, vX, vY);
            toRight(
              dif,
              e,
              duration(vX, vY),
              () => widget.adapter.toNext(widget.item),
            );
          } else if (-vX >= TouchMixin.maxSwipeVelocity) {
            toLeft();
            toIdle(dif);
          } else if (canSwipeOut(true, dif, widget.rect)) {
            if (dif.dx > 0) {
              // Offset e = end(dif, widget.rect, vX, vY);
              // toRight(dif, e, duration(vX, vY));
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
          child: widget.item.child,
        ),
      ),
    );
  }
}
