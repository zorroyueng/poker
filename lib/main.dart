import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/demo_adapter.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:poker/poker/logic/poker_adapter.dart';
import 'package:poker/poker/poker_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Future.wait([
    Sp.init(), // sp初始化
  ]).then((_) {
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarIconBrightness: Brightness.light, // 状态栏白字
    //     statusBarColor: Colors.black, // 状态栏背景
    //   ),
    // );
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => ThemeWidget(
        builder: (Widget? child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeProvider.data(),
          home: child,
          navigatorObservers: [NavigatorObs.obs()],
        ),
        child: _HomePage(),
      );
}

class _HomePage extends StatelessWidget {
  late final DemoAdapter adapter = DemoAdapter()..setData(DemoHelper.data());
  final GlobalKey _homeKey = GlobalKey();

  Widget _btn({
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
    double? percent,
    bool rotate = false,
  }) =>
      Expanded(
        child: PercentBuilder(
          percent: percent ?? 0,
          duration: Duration(milliseconds: percent == 0 ? 200 : 0),
          builder: (_, p) => IconButton(
            onPressed: onPressed,
            alignment: Alignment.center,
            style: percent != null
                ? ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((_) => color.withOpacity(.2 * p)),
                  )
                : null,
            icon: RotatedBox(
              quarterTurns: rotate ? -2 : 0,
              child: Icon(
                icon,
                color: percent != null ? color.withOpacity(.2 + .8 * p) : color,
                size: 50,
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => GreyWidget(
        child: ThemeWidget(
          key: _homeKey,
          builder: (_) {
            return Scaffold(
              body: SafeArea(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PokerView(adapter: adapter),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _btn(
                              color: Colors.yellow,
                              icon: Icons.redo,
                              onPressed: () => adapter.undo(),
                            ),
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
                                color: Colors.blueGrey,
                                icon: Icons.upload,
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
                                color: Colors.pinkAccent,
                                icon: Icons.recommend,
                                onPressed: () => adapter.swipe(SwipeType.right),
                                percent: snap.data!,
                              ),
                            ),
                            _btn(
                              color: Colors.orangeAccent,
                              icon: Icons.sync,
                              onPressed: () => adapter.setData(DemoHelper.data()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: IconButton(
                          icon: Icon(
                            Icons.settings,
                            size: Common.base(context),
                            color: ColorProvider.textColor().withOpacity(.5),
                          ),
                          onPressed: () {
                            Common.dlg(
                              w: HpDevice.screenMin(context, .5),
                              ctx: context,
                              name: 'Setting',
                              future: Future.value(
                                ThemeWidget(
                                  builder: (_) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      StreamWidget(
                                        stream: GreyProvider.ctrl().stream,
                                        initialData: GreyProvider.grey(),
                                        builder: (c, s, child) => SwitchListTile.adaptive(
                                          activeColor: ThemeProvider.data().colorScheme.primary,
                                          title: ThemeWidget(
                                              builder: (child) => Text(
                                                    'Home Grey',
                                                    style: Common.textStyle(c),
                                                  )),
                                          value: GreyProvider.grey(),
                                          onChanged: (v) => GreyProvider.change(v),
                                        ),
                                      ),
                                      SwitchListTile.adaptive(
                                        activeColor: ThemeProvider.data().colorScheme.primary,
                                        title: Text(
                                          'Dark',
                                          style: Common.textStyle(context),
                                        ),
                                        value: ThemeProvider.isDark(),
                                        onChanged: (bool value) => ThemeProvider.change(dark: !ThemeProvider.isDark()),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: Common.base(context, .5), right: Common.base(context, .5)),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Common.dropdownMenu(
                                                ctx: context,
                                                value: ThemeProvider.currentColorName(),
                                                lst: ThemeProvider.map.keys.toList(),
                                                content: (s) => Container(color: ThemeProvider.map[s]),
                                                noText: true,
                                                noLine: true,
                                                onChange: (s) => ThemeProvider.change(colorName: s),
                                              ),
                                            ),
                                            Expanded(
                                              child: Slider.adaptive(
                                                max: 20,
                                                min: 10,
                                                divisions: 11,
                                                value: Sp.getBaseRatio().toDouble(),
                                                onChanged: (v) => ThemeProvider.change(ratio: v.floor()),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
}
