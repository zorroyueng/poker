import 'package:flutter/material.dart';
import 'package:poker/poker/logic/poker_adapter.dart';

class DemoAdapter extends PokerAdapter<DemoData> {
  @override
  Object id(DemoData t) => t.id;

  @override
  Widget item(DemoData t) => Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(t.url),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment(0, 1),
                  end: Alignment(0, -1),
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
              child: Align(
                alignment: const Alignment(0, 1),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    t.id.toString(),
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ],
      );
}

class DemoData {
  final int id;
  final String url;

  DemoData(this.id, this.url);
}
