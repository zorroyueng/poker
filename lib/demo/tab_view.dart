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
        builder: (_, __, ___) => children[ctrl.value()].page,
      );
}

class TabDef {
  final Widget page;
  final BottomNavigationBarItem barItem;

  TabDef({required this.page, required this.barItem});
}
