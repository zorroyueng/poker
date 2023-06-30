import 'package:flutter/material.dart';
import 'package:poker/poker/logic/anim_mixin.dart';
import 'package:poker/poker/logic/layout_mixin.dart';
import 'package:poker/poker/logic/poker_adapter.dart';
import 'package:poker/poker/logic/touch_mixin.dart';
import 'package:poker/poker/poker_config.dart';

class PokerCard extends StatefulWidget {
  final PokerAdapter adapter;
  final PokerItem item;
  final Rect rect;

  const PokerCard({super.key, required this.item, required this.rect, required this.adapter});

  @override
  State<PokerCard> createState() => PokerCardState();
}

class PokerCardState extends State<PokerCard> with SingleTickerProviderStateMixin, TouchMixin, AnimMixin, LayoutMixin {
  void _updateDif(Offset o) {
    dif = o;
    if (widget.adapter.isCurrentSwipeItem(widget.item)) {
      widget.adapter.swipePercent(
        swipePercent(true, dif, widget.rect),
        swipePercent(false, dif, widget.rect),
      );
    }
  }

  @override
  void initState() {
    initAnim(this, () => setState(() => _updateDif(byAnim())));
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
        // todo 需要仅响应单指
        onPanDown: (d) {
          stopAnim();
          onPanDown(d.localPosition - dif);
          widget.adapter.onPanDown(widget.item);
        },
        onPanUpdate: (d) => setState(() => _updateDif(byMove(d.localPosition))),
        onPanEnd: (d) {
          Offset v = d.velocity.pixelsPerSecond;
          double vX = velocity(true, v, widget.rect);
          double vY = velocity(false, v, widget.rect);
          if (-vY > TouchMixin.maxSwipeVelocity && -vY >= vX.abs() && canSwipeOut(false, dif, widget.rect)) {
            // print('top vX=${vX.floor()}, vY=${vY.floor()}');
            anim(
              begin: dif,
              end: end(null, dif, widget.rect, vX, vY),
              duration: duration(vX, vY),
              curve: Curves.decelerate,
              onEnd: () => widget.adapter.toNext(widget.item),
            );
          } else if (vX >= TouchMixin.maxSwipeVelocity && vX >= vY.abs()) {
            // print('right vX=${vX.floor()}, vY=${vY.floor()}');
            anim(
              begin: dif,
              end: end(true, dif, widget.rect, vX, vY),
              duration: duration(vX, vY),
              curve: Curves.decelerate,
              onEnd: () => widget.adapter.toNext(widget.item),
            );
          } else if (-vX >= TouchMixin.maxSwipeVelocity && -vX >= vY.abs()) {
            // print('left vX=${vX.floor()}, vY=${vY.floor()}');
            anim(
              begin: dif,
              end: end(false, dif, widget.rect, vX, vY),
              duration: duration(vX, vY),
              curve: Curves.decelerate,
              onEnd: () => widget.adapter.toNext(widget.item),
            );
          } else if (canSwipeOut(false, dif, widget.rect)) {
            // print('canSwipeOut y vX=${vX.floor()}, vY=${vY.floor()}');
            anim(
              begin: dif,
              end: end(null, dif, widget.rect, vX, 0),
              duration: duration(vX, vY),
              curve: Curves.decelerate,
              onEnd: () => widget.adapter.toNext(widget.item),
            );
          } else if (canSwipeOut(true, dif, widget.rect)) {
            // print('canSwipeOut x vX=${vX.floor()}, vY=${vY.floor()}');
            if (dif.dx > 0) {
              anim(
                begin: dif,
                end: end(true, dif, widget.rect, 0, vY),
                duration: duration(vX, vY),
                curve: Curves.decelerate,
                onEnd: () => widget.adapter.toNext(widget.item),
              );
            } else {
              anim(
                begin: dif,
                end: end(false, dif, widget.rect, 0, vY),
                duration: duration(vX, vY),
                curve: Curves.decelerate,
                onEnd: () => widget.adapter.toNext(widget.item),
              );
            }
          } else {
            // print('_ vX=${vX.floor()}, vY=${vY.floor()}');
            toIdle(dif);
          }
        },
        child: Transform.rotate(
          angle: rotate(dif, widget.rect, dragAtTop(widget.rect)),
          alignment: byDown(widget.rect),
          child: StreamBuilder<double>(
            stream: widget.item.percent.stream().distinct(),
            initialData: widget.item.percent.value(),
            builder: (_, __) => Transform.scale(
              scale: backScale(widget.item.percent.value()),
              child: Transform.translate(
                offset: backOffset(widget.item.percent.value(), widget.rect),
                child: widget.item.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
