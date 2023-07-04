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
  late Widget _child;

  void _updateDif(Offset o) {
    dif = o;
    if (widget.adapter.isCurrentSwipeItem(widget.item)) {
      widget.adapter.swipePercent(
        swipePercent(x: true, dif: dif, rect: widget.rect, unit: false),
        swipePercent(x: false, dif: dif, rect: widget.rect, unit: false),
      );
    }
  }

  void _initByWidget() {
    widget.item.card = this;
    if (widget.item.difK != null) {
      dif = Offset(
        widget.item.difK!.dx * widget.rect.width,
        widget.item.difK!.dy * widget.rect.height,
      );
      toIdle(dif);
      widget.item.difK = null;
    }
    _child = GestureDetector(
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
            animTo(SwipeType.up, vX, vY, Curves.decelerate);
          } else if (vX >= TouchMixin.maxSwipeV && vX >= vY.abs()) {
            animTo(SwipeType.right, vX, vY, Curves.decelerate);
          } else if (-vX >= TouchMixin.maxSwipeV && -vX >= vY.abs()) {
            animTo(SwipeType.left, vX, vY, Curves.decelerate);
          } else if (vY >= vX.abs() && vY >= TouchMixin.minSwipeV) {
            // 判断为向下滑动时，返回idle
            toIdle(dif);
          } else if (canSwipeOut(false, dif, widget.rect)) {
            // 如果卡片速度方向 与 目标位移方向 相反，则速度置0
            animTo(SwipeType.up, vX, min(vY, 0));
          } else if (canSwipeOut(true, dif, widget.rect)) {
            if (dif.dx > 0) {
              animTo(SwipeType.right, max(vX, 0), vY);
            } else {
              animTo(SwipeType.left, min(vX, 0), vY);
            }
          } else {
            toIdle(dif);
          }
        }
      },
      onPanCancel: () {
        widget.adapter.onPanEnd();
        toIdle(dif);
      },
      child: SingleTouch(
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
    );
  }

  @override
  void initState() {
    initAnim(this, () => setState(() => _updateDif(byAnim())));
    _initByWidget();
    super.initState();
  }

  @override
  void didUpdateWidget(PokerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initByWidget();
  }

  @override
  void dispose() {
    disposeAnim();
    widget.item.card = null;
    super.dispose();
  }

  void animTo(
    SwipeType type,
    double vX,
    double vY, [
    Curve curve = Curves.easeIn,
  ]) {
    if (widget.adapter.canSwipe(widget.item.data, type)) {
      bool? right;
      if (type == SwipeType.right) {
        right = true;
      } else if (type == SwipeType.left) {
        right = false;
      }
      Offset endDif = end(right, dif, widget.rect, vX, vY);
      anim(
        begin: dif,
        end: endDif,
        duration: duration(vX, vY),
        curve: curve,
        onEnd: () => widget.adapter.toNext(
            widget.item,
            Offset(
              endDif.dx / widget.rect.width,
              endDif.dy / widget.rect.height,
            )),
      );
    } else {
      toIdle(dif);
    }
  }

  @override
  Widget build(BuildContext context) => Positioned.fromRect(
        rect: widget.rect.translate(dif.dx, dif.dy),
        child: Transform.rotate(
          angle: rotate(dif, widget.rect, dragAtTop(widget.rect)),
          alignment: byDown(widget.rect),
          child: _child,
        ),
      );
}
