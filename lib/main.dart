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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lime),
        useMaterial3: true,
      ),
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DemoAdapter adapter = DemoAdapter(context);
    List<DemoData> data = [];
    List<String> pics = DemoHelper.pics();
    for (int i = 0; i < pics.length; i++) {
      data.add(DemoData(i, pics[i]));
    }
    adapter.setData(data);
    return Scaffold(body: PokerView(adapter: adapter));
  }
}
