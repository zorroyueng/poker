import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/demo_adapter.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:poker/demo/tab_mixin.dart';
import 'package:poker/poker/config.dart';
import 'package:poker/poker/logic/poker_adapter.dart';
import 'package:poker/poker/poker_view.dart';

class DemoPokerTab extends StatelessWidget with TabMixin {
  final DemoAdapter adapter = DemoAdapter()..setData(DemoHelper.cardData());

  DemoPokerTab({super.key});

  Widget _btn({
    required BuildContext ctx,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
    required double percent,
    bool rotate = false,
  }) =>
      Expanded(
        child: IconButton(
          onPressed: onPressed,
          alignment: Alignment.center,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((_) => color.withOpacity(.3 * percent)),
          ),
          icon: RotatedBox(
            quarterTurns: rotate ? -2 : 0,
            child: Icon(
              icon,
              color: color.withOpacity(.2 + .8 * percent),
              size: Common.base(ctx, Config.iconK),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          PokerView(adapter: adapter),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  StreamBuilder(
                    initialData: adapter.percentX().value(),
                    stream: adapter.percentX().stream().map<double>((v) {
                      if (v < 0) {
                        return -v;
                      } else {
                        return 0;
                      }
                    }).distinct(),
                    builder: (_, snap) => _btn(
                      ctx: context,
                      color: Colors.lime,
                      icon: Icons.recommend,
                      onPressed: () => adapter.swipe(SwipeType.left),
                      percent: snap.data!,
                      rotate: true,
                    ),
                  ),
                  StreamBuilder(
                    initialData: adapter.percentY().value(),
                    stream: adapter.percentY().stream().map<double>((v) {
                      if (v < 0) {
                        return -v;
                      } else {
                        return 0;
                      }
                    }).distinct(),
                    builder: (_, snap) => _btn(
                      ctx: context,
                      color: Colors.blue,
                      icon: Icons.stars,
                      onPressed: () => adapter.swipe(SwipeType.up),
                      percent: snap.data!,
                    ),
                  ),
                  StreamBuilder(
                    initialData: adapter.percentX().value(),
                    stream: adapter.percentX().stream().map<double>((v) {
                      if (v < 0) {
                        return 0;
                      } else {
                        return v;
                      }
                    }).distinct(),
                    builder: (_, snap) => _btn(
                      ctx: context,
                      color: Colors.pinkAccent,
                      icon: Icons.recommend,
                      onPressed: () => adapter.swipe(SwipeType.right),
                      percent: snap.data!,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: ThemeWidget(
              builder: (_, __) => Padding(
                padding: const EdgeInsets.all(20),
                child: IconButton(
                  icon: Icon(
                    Icons.settings,
                    size: Common.base(context),
                    color: ColorProvider.textColor().withOpacity(.5),
                  ),
                  onPressed: () => Common.dlgSetting(context),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: ThemeWidget(
              builder: (_, __) => Padding(
                padding: const EdgeInsets.all(20),
                child: IconButton(
                  icon: Icon(
                    Icons.redo,
                    size: Common.base(context),
                    color: ColorProvider.textColor().withOpacity(.5),
                  ),
                  onPressed: () => adapter.undo(),
                ),
              ),
            ),
          ),
        ],
      );
}
