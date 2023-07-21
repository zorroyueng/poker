import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/db.dart';
import 'package:poker/base/tab_view.dart';
import 'package:poker/db/v_1.dart';
import 'package:poker/demo/find/find_tab.dart';
import 'package:poker/demo/me/me_tab.dart';
import 'package:poker/demo/msg/msg_tab.dart';
import 'package:poker/demo/poker/poker_tab.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future.wait([
    Sp.init(), // sp初始化
    Db.init(V1()),
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
          navigatorObservers: [Navi.obs()],
        ),
        child: _HomePage(),
      );
}

class _HomePage extends StatelessWidget {
  final GlobalKey _homeKey = GlobalKey();
  final Broadcast<int> ctrl = Broadcast(0);
  final List<TabDef> _lst = [
    TabDef(
      index: 0,
      page: PokerTab(),
      barItem: const BottomNavigationBarItem(icon: Icon(Icons.catching_pokemon_rounded), label: 'card'),
    ),
    TabDef(
      index: 1,
      page: FindTab(),
      barItem: const BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'find'),
    ),
    TabDef(
      index: 2,
      page: MsgTab(),
      barItem: const BottomNavigationBarItem(icon: Icon(Icons.message), label: 'msg'),
    ),
    TabDef(
      index: 3,
      page: const MeTab(),
      barItem: const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'me'),
    ),
  ];

  @override
  Widget build(BuildContext context) => GreyWidget(
        child: ThemeWidget(
          key: _homeKey,
          builder: (_, __) => AnnotatedRegion(
            value: ThemeProvider.isDark() ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            child: Scaffold(
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
        ),
      );
}
