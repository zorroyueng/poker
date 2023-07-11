import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/demo/demo_find_tab.dart';
import 'package:poker/demo/demo_poker_tab.dart';
import 'package:poker/demo/tab_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future.wait([
    Sp.init(), // sp初始化
  ]).then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => ThemeWidget(
        builder: (_, Widget? child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeProvider.data(),
          home: child,
          navigatorObservers: [NavigatorObs.obs()],
        ),
        child: _HomePage(),
      );
}

class _HomePage extends StatelessWidget {
  final GlobalKey _homeKey = GlobalKey();
  final Broadcast<int> ctrl = Broadcast(0);
  final List<TabDef> _lst = [
    TabDef(
      page: DemoPokerTab(),
      barItem: const BottomNavigationBarItem(icon: Icon(Icons.catching_pokemon_rounded), label: 'card'),
    ),
    TabDef(
      page: const DemoFindTab(),
      barItem: const BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'photo'),
    ),
    TabDef(
      page: Container(),
      barItem: const BottomNavigationBarItem(icon: Icon(Icons.message), label: 'msg'),
    ),
    TabDef(
      page: Container(),
      barItem: const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'me'),
    ),
  ];

  @override
  Widget build(BuildContext context) => GreyWidget(
        child: ThemeWidget(
          key: _homeKey,
          builder: (_, __) => Scaffold(
            body: SafeArea(child: TabView(ctrl: ctrl, children: _lst)),
            bottomNavigationBar: StreamWidget(
              stream: ctrl.stream().distinct(),
              initialData: ctrl.value(),
              builder: (_, __, ___) => BottomNavigationBar(
                backgroundColor: ColorProvider.itemBg(),
                currentIndex: ctrl.value(),
                onTap: (i) => ctrl.add(i),
                items: _lst.map((p) => p.barItem).toList(),
              ),
            ),
          ),
        ),
      );
}
