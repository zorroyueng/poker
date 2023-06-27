import 'package:flutter/material.dart';
import 'package:poker/poker/logic/poker_card.dart';
import 'package:poker/poker/logic/poker_mixin.dart';

class PokerView extends StatelessWidget with PokerMixin {
  final Widget child;

  PokerView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            PokerCard(
              rect: idle(
                Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                ),
              ),
              child: child,
            ),
          ],
        );
      },
    );
  }
}
