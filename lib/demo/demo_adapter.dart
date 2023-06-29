import 'package:flutter/material.dart';
import 'package:poker/poker/logic/poker_adapter.dart';

class DemoAdapter extends PokerAdapter<DemoData> {
  @override
  Object id(DemoData t) => t.id;

  @override
  Widget item(DemoData t) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(t.url),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      );
}

class DemoData {
  final int id;
  final String url;

  DemoData(this.id, this.url);
}
