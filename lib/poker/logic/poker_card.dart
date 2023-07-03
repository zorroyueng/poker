import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poker/poker/base/single_touch.dart';
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
  void _updateDif(Offset o) {
    dif = o;
    if (widget.adapter.isCurrentSwipeItem(widget.item)) {
      widget.adapter.swipePercent(
        swipePercent(x: true, dif: dif, rect: widget.rect, unit: false),
        swipePercent(x: false, dif: dif, rect: widget.rect, unit: false),
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
        onPanDown: (d) {
          if (widget.adapter.swipingItem() == null) {
            stopAnim();
            onPanDown(d.localPosition - dif);
            widget.adapter.onPanDown(widget.item);
          }
        },
        onPanUpdate: (d) {
          if (widget.adapter.swipingItem() == widget.item) {
            setState(() => _updateDif(byMove(d.localPosition)));
          }
        },
        onPanEnd: (d) {
          if (widget.adapter.swipingItem() == widget.item) {
            widget.adapter.onPanEnd();
            Offset v = d.velocity.pixelsPerSecond;
            double vX = velocity(true, v, widget.rect);
            double vY = velocity(false, v, widget.rect);
            if (-vY > TouchMixin.maxSwipeV && -vY >= vX.abs()) {
              // print('top vX=${vX.floor()}, vY=${vY.floor()}');
              if (widget.adapter.handle(widget.item.data, SwipeType.up)) {
                anim(
                  begin: dif,
                  end: end(null, dif, widget.rect, vX, vY),
                  duration: duration(vX, vY),
                  curve: Curves.decelerate,
                  onEnd: () => widget.adapter.toNext(widget.item),
                );
              } else {
                toIdle(dif);
              }
            } else if (vX >= TouchMixin.maxSwipeV && vX >= vY.abs()) {
              // print('right vX=${vX.floor()}, vY=${vY.floor()}');
              if (widget.adapter.handle(widget.item.data, SwipeType.right)) {
                anim(
                  begin: dif,
                  end: end(true, dif, widget.rect, vX, vY),
                  duration: duration(vX, vY),
                  curve: Curves.decelerate,
                  onEnd: () => widget.adapter.toNext(widget.item),
                );
              } else {
                toIdle(dif);
              }
            } else if (-vX >= TouchMixin.maxSwipeV && -vX >= vY.abs()) {
              // print('left vX=${vX.floor()}, vY=${vY.floor()}');
              if (widget.adapter.handle(widget.item.data, SwipeType.left)) {
                anim(
                  begin: dif,
                  end: end(false, dif, widget.rect, vX, vY),
                  duration: duration(vX, vY),
                  curve: Curves.decelerate,
                  onEnd: () => widget.adapter.toNext(widget.item),
                );
              } else {
                toIdle(dif);
              }
            } else if (canSwipeOut(false, dif, widget.rect)) {
              // print('canSwipeOut y vX=${vX.floor()}, vY=${vY.floor()}');
              if (widget.adapter.handle(widget.item.data, SwipeType.up)) {
                anim(
                  begin: dif,
                  end: end(null, dif, widget.rect, vX, 0),
                  duration: duration(vX, vY),
                  curve: Curves.easeIn,
                  onEnd: () => widget.adapter.toNext(widget.item),
                );
              } else {
                toIdle(dif);
              }
            } else if (canSwipeOut(true, dif, widget.rect)) {
              // print('canSwipeOut x vX=${vX.floor()}, vY=${vY.floor()}');
              if (dif.dx > 0) {
                if (widget.adapter.handle(widget.item.data, SwipeType.right)) {
                  anim(
                    begin: dif,
                    end: end(true, dif, widget.rect, 0, vY),
                    duration: duration(vX, vY),
                    curve: Curves.easeIn,
                    onEnd: () => widget.adapter.toNext(widget.item),
                  );
                } else {
                  toIdle(dif);
                }
              } else {
                if (widget.adapter.handle(widget.item.data, SwipeType.left)) {
                  anim(
                    begin: dif,
                    end: end(false, dif, widget.rect, 0, vY),
                    duration: duration(vX, vY),
                    curve: Curves.easeIn,
                    onEnd: () => widget.adapter.toNext(widget.item),
                  );
                } else {
                  toIdle(dif);
                }
              }
            } else {
              // print('_ vX=${vX.floor()}, vY=${vY.floor()}');
              toIdle(dif);
            }
          }
        },
        child: SingleTouch(
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
                  child: AbsorbPointer(
                    absorbing: widget.item.percent.value() != 1,
                    child: widget.item.item,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
