import 'package:flutter/material.dart';
import 'package:poker/poker/logic/poker_card.dart';
import 'package:poker/poker/logic/poker_mixin.dart';

class PokerView extends StatelessWidget with PokerMixin {
  final Widget child;

  PokerView({super.key, required this.child});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, bc) {
          Rect rect = idle(Size(bc.maxWidth, bc.maxHeight));
          return Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              PokerCard(rect: rect, child: child),
            ],
          );
        },
      );
}
