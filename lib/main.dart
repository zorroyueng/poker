import 'package:flutter/material.dart';
import 'package:poker/demo/demo_adapter.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:poker/poker/poker_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  Widget _btn({
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
    double? percent,
    bool rotate = false,
  }) {
    return Expanded(
      child: Transform.scale(
        scale: 1 + (percent != null ? (percent * .2) : 0),
        child: IconButton(
          onPressed: onPressed,
          alignment: Alignment.center,
          style: percent != null
              ? ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((_) => color.withOpacity(.2 * percent)))
              : null,
          icon: RotatedBox(
            quarterTurns: rotate ? -2 : 0,
            child: Icon(
              icon,
              color: percent != null ? color.withOpacity(.2 + .8 * percent) : color,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DemoAdapter adapter = DemoAdapter(context);
    adapter.setData(DemoHelper.data());
    return Scaffold(
        body: Stack(
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
                  onPressed: () {},
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
                    onPressed: () {},
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
                    onPressed: () {},
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
                    onPressed: () {},
                    percent: snap.data!,
                  ),
                ),
                _btn(
                  color: Colors.orangeAccent,
                  icon: Icons.sync,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        )
      ],
    ));
  }
}
