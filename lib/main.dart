import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) => Scaffold(
        body: PokerView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.lime.withOpacity(.5),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
}
