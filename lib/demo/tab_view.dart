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
  Widget build(BuildContext context) => StreamWidget(
        initialData: ctrl.value(),
        stream: ctrl.stream().distinct(),
        builder: (_, __, ___) => Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: children
              .map(
                (t) => Positioned.fill(
                  child: Visibility(
                    visible: t.index == ctrl.value(),
                    maintainState: true,
                    child: t.page,
                  ),
                ),
              )
              .toList(),
        ),
      );
}

class TabDef {
  final Widget page;
  final BottomNavigationBarItem barItem;
  final int index;

  TabDef({required this.page, required this.barItem, required this.index});
}
