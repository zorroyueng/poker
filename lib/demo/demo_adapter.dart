import 'package:flutter/material.dart';
import 'package:poker/poker/logic/poker_adapter.dart';

class DemoAdapter extends PokerAdapter<DemoData> {
  final BuildContext _context;

  DemoAdapter(this._context);

  @override
  Object id(DemoData t) => t.id;

  @override
  Widget item(DemoData t) => Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              clipBehavior: Clip.none,
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(t.url),
                  filterQuality: FilterQuality.medium,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              clipBehavior: Clip.none,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  begin: const Alignment(0, 1),
                  end: const Alignment(0, -1),
                  colors: [Colors.black.withOpacity(.5), Colors.transparent],
                  stops: const [.5, 1],
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

  @override
  void onPreload(DemoData t) {
    precacheImage(NetworkImage(t.url), _context);
  }
}

class DemoData {
  final int id;
  final String url;

  DemoData(this.id, this.url);
}
