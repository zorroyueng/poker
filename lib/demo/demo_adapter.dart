import 'package:base/base.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/detail_page.dart';
import 'package:poker/poker/logic/poker_adapter.dart';

class DemoAdapter extends PokerAdapter<DemoData> {
  final BuildContext _context;

  DemoAdapter(this._context);

  @override
  Object id(DemoData t) => t.id;

  @override
  Widget item(DemoData t, Size size) => Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Hero(
              tag: t.id,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(
                      t.url,
                      maxWidth: size.width.toInt(),
                      maxHeight: size.height.toInt(),
                    ),
                    filterQuality: FilterQuality.low,
                    // isAntiAlias: true,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t.name} ${t.id}',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 37,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      t.url,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Common.click(
              onTap: () {
                NavigatorObs.pushAlpha(
                  NavigatorObs.ctx(),
                  DetailPage(
                    info: DetailInfo(
                      data: t,
                      w: size.width.toInt(),
                      h: size.height.toInt(),
                    ),
                  ),
                );
              },
              r: BorderRadius.circular(30),
            ),
          ),
        ],
      );

  @override
  void onPreload(DemoData t, Size size, int index, int total) => precacheImage(
        CachedNetworkImageProvider(
          t.url,
          maxWidth: size.width.toInt(),
          maxHeight: size.height.toInt(),
        ),
        _context,
      );

  @override
  bool canSwipe(DemoData t, SwipeType type) => true;

  @override
  Widget onLoading() => const Center(child: CircularProgressIndicator());

  @override
  bool canUndo(DemoData t) => true;
}

class DemoData {
  final int id;
  final String url;
  final String name;

  DemoData({required this.id, required this.name, required this.url});
}
