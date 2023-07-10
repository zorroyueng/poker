import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/poker/config.dart';
import 'package:poker/poker/logic/poker_adapter.dart';
import 'package:poker/poker/logic/poker_card.dart';

class PokerView<T> extends StatelessWidget {
  final PokerAdapter<T> adapter;

  const PokerView({super.key, required this.adapter});

  Rect _cardRect(Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double p = size.shortestSide * Config.paddingK;
    double width = size.width - 2 * p;
    double height = size.height - 2 * p;
    if (width / height >= Config.aspectRatio) {
      width = height * Config.aspectRatio;
    } else {
      height = width / Config.aspectRatio;
    }
    return Rect.fromLTWH(
      centerX - width / 2,
      centerY - height / 2,
      width,
      height,
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, bc) {
          Size pokerSize = Size(bc.maxWidth, bc.maxHeight);
          Rect cardRect = _cardRect(pokerSize);
          return _Poker<T>(
            adapter: adapter,
            pokerSize: pokerSize,
            cardRect: cardRect,
            cardSize: cardRect.size * HpDevice.pixelRatio(context),
          );
        },
      );
}

class _Poker<T> extends StatefulWidget {
  final PokerAdapter<T> adapter;
  final Rect cardRect;
  final Size cardSize;
  final Size pokerSize;

  const _Poker({
    super.key,
    required this.adapter,
    required this.cardRect,
    required this.cardSize,
    required this.pokerSize,
  });

  @override
  State<_Poker> createState() => _PokerState();
}

class _PokerState extends State<_Poker> with AdapterView {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = widget.adapter.items.isNotEmpty
        ? widget.adapter.items.map((item) {
            if (item.card == null || widget.cardRect != item.card!.widget.rect) {
              return PokerCard(
                key: ValueKey(item.key),
                rect: widget.cardRect,
                adapter: widget.adapter,
                item: item,
              );
            } else {
              return item.card!.widget;
            }
          }).toList()
        : [widget.adapter.onLoading()];
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: children,
    );
  }

  @override
  void update() => setState(() {});

  void _init() => widget.adapter.setView(this);

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(_Poker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
  }

  @override
  Rect cardRect() => widget.cardRect;

  @override
  Size pokerSize() => widget.pokerSize;

  @override
  Size cardSize() => widget.cardSize;
}
