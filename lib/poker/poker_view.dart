import 'package:flutter/material.dart';
import 'package:poker/poker/logic/poker_adapter.dart';
import 'package:poker/poker/logic/poker_card.dart';
import 'package:poker/poker/logic/poker_mixin.dart';

class PokerView<T> extends StatefulWidget with PokerMixin {
  final PokerAdapter<T> adapter;

  PokerView({super.key, required this.adapter});

  @override
  State<PokerView> createState() => _PokerViewState();
}

class _PokerViewState extends State<PokerView> with PokerMixin, AdapterView {
  List<PokerItem> _items = [];

  @override
  void initState() {
    widget.adapter.setView(this);
    super.initState();
  }

  @override
  void didUpdateWidget(PokerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.adapter.setView(this);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, bc) {
          Rect rect = idle(Size(bc.maxWidth, bc.maxHeight));
          List<Widget> children = _items.isNotEmpty
              ? _items
                  .map((item) => PokerCard(
                        key: ValueKey(item.key),
                        rect: rect,
                        adapter: widget.adapter,
                        item: item,
                      ))
                  .toList()
              : [widget.adapter.onLoading()];
          return Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: children,
          );
        },
      );

  @override
  void update(List<PokerItem> items) => setState(() => _items = items);
}
