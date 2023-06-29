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
    if (widget.adapter.isLastSwipeItem(widget.item)) {
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
    widget.item.update ??= () => setState(() {});
    return Positioned.fromRect(
      rect: widget.rect.translate(dif.dx, dif.dy),
      child: Listener(
        onPointerDown: onTouch,
        onPointerMove: onTouch,
        onPointerUp: onTouch,
        child: GestureDetector(
          onPanDown: (d) {
            if (singleTouch()) {
              stopAnim();
              onPanDown(d.localPosition - dif);
              widget.adapter.onPanDown(widget.item);
            }
          },
          onPanUpdate: (d) {
            if (singleTouch()) {
              Offset delta = d.localPosition - lastMove(dif);
              if ((delta - d.delta).distance <= 1) {
                setState(() => _updateDif(byMove(d.localPosition)));
              } else {
                print('d.localPosition: ${d.localPosition}, dif: ${dif}');
                print('delta: $delta, d.delta: ${d.delta}');
              }
            }
          },
          onPanEnd: (d) {
            if (singleTouch()) {
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
            }
          },
          child: Transform.rotate(
            angle: rotate(dif, widget.rect, dragAtTop(widget.rect)),
            alignment: byDown(widget.rect),
            child: Transform.scale(
              scale: PokerConfig.backCardScale + (1 - PokerConfig.backCardScale) * widget.item.percent,
              child: Transform.translate(
                offset: Offset(
                  widget.rect.width * PokerConfig.backCardOffset.dx * (1 - widget.item.percent),
                  widget.rect.height * PokerConfig.backCardOffset.dy * (1 - widget.item.percent),
                ),
                child: widget.item.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
