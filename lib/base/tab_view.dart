import 'package:base/base.dart';
import 'package:flutter/material.dart';

class TabView extends StatelessWidget {
  final Broadcast<int> ctrl;
  final List<TabDef> children;

  const TabView({
    super.key,
    required this.ctrl,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: children
            .map(
              (t) => StreamWidget(
                initialData: ctrl.value() == t.index,
                stream: ctrl.stream().map((v) => v == t.index).distinct(),
                builder: (_, snap, __) => Positioned.fill(
                  child: Visibility(
                    visible: snap.data!,
                    maintainState: true,
                    child: t.page,
                  ),
                ),
              ),
            )
            .toList(),
      );
}

class TabDef {
  final Widget page;
  final BottomNavigationBarItem barItem;
  final int index;

  TabDef({required this.page, required this.barItem, required this.index});
}
