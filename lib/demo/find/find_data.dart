import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/adapter.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/base/video_widget.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:poker/demo/media_page.dart';

class FindData {
  final int id;
  final String head;
  final String name;
  final String content;
  final List<String> medias;
  final List<String> comments;

  FindData({
    required this.id,
    required this.head,
    required this.name,
    required this.content,
    required this.medias,
    required this.comments,
  });

  List<FindItemData> items() {
    List<FindItemData> lst = [];
    lst.add(FindItemData(type: Type.head, find: this));
    lst.add(FindItemData(type: Type.media, find: this));
    for (int i = 0; i < comments.length; i++) {
      lst.add(FindItemData(type: Type.comment, find: this, index: i));
    }
    return lst;
  }
}

enum Type {
  head,
  media,
  comment,
}

class FindItemData extends Data {
  final Type type;
  final FindData find;
  final int index;

  FindItemData({required this.type, required this.find, this.index = 0});

  @override
  ValueKey key() => ValueKey('${type}_${find.id}');

  double _padding(BuildContext c) => Common.base(c, .2);

  double _paddingLeft(BuildContext c) => _padding(c) + _headSize(c);

  double _headSize(BuildContext c) => Common.base(c, 1.3);

  Widget _head() => ThemeWidget(
        builder: (c, __) {
          double w = _headSize(c);
          double p = _padding(c);
          BorderRadius r = Common.baseRadius(c);
          return Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: p,
                  right: p,
                  bottom: p,
                ),
                child: SizedBox(
                  width: w,
                  height: w,
                  child: Common.click(
                    onTap: () {},
                    r: r,
                    back: Common.netImage(
                      url: find.head,
                      w: w,
                      h: w,
                      borderRadius: r,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        find.name,
                        maxLines: 1,
                        style: Common.textStyle(
                          c,
                          scale: 1.2,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      find.content,
                      style: Common.textStyle(
                        c,
                        alpha: .8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

  int _gvCrossAxisCount() {
    if (find.medias.length == 1) {
      return 1;
    } else if (find.medias.length == 2 || find.medias.length == 4) {
      return 2;
    } else {
      return 3;
    }
  }

  Widget _pic() => ThemeWidget(
        builder: (c, _) {
          double p = _padding(c);
          return Container(
            padding: EdgeInsets.only(
              left: _paddingLeft(c),
              top: p,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              //解决无限高度问题
              physics: const NeverScrollableScrollPhysics(),
              itemCount: find.medias.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gvCrossAxisCount(),
                mainAxisSpacing: p / 2,
                crossAxisSpacing: p / 2,
              ),
              itemBuilder: (c, i) => LayoutBuilder(
                builder: (c, constraints) {
                  double size = constraints.maxWidth * HpDevice.pixelRatio(c) * 2;
                  String url = find.medias[i];
                  return Common.click(
                    onTap: () => Navi.pushAlpha(
                      c,
                      MediaPage(
                        urls: find.medias,
                        id: find.name,
                        index: i,
                        w: size,
                        h: size,
                      ),
                    ),
                    back: Hero(
                      tag: DemoHelper.mediaTag(find.name, i, url),
                      child: Common.netImage(
                        url: url,
                        w: size,
                        h: size,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );

  Widget _video() => ThemeWidget(
        builder: (c, _) {
          double p = _padding(c);
          String url = find.medias[0];
          Object tag = '${find.name}_0_$url';
          return Container(
            padding: EdgeInsets.only(
              left: _paddingLeft(c),
              top: p,
            ),
            child: AspectRatio(
              aspectRatio: 1.6,
              child: Hero(
                tag: tag,
                child: VideoWidget(
                  url: url,
                  cover: false,
                  ctrl: Common.click(
                    onTap: () => Navi.pushAlpha(
                      c,
                      MediaPage(
                        urls: find.medias,
                        id: find.name,
                        index: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget _comment() => ThemeWidget(
        builder: (c, _) {
          double p = _padding(c);
          BorderRadius? borderRadius = () {
            if (find.comments.length == 1) {
              Radius r = Radius.circular(p);
              return BorderRadius.all(r);
            } else if (index == 0) {
              Radius r = Radius.circular(p);
              return BorderRadius.only(topLeft: r, topRight: r);
            } else if (index == find.comments.length - 1) {
              Radius r = Radius.circular(p);
              return BorderRadius.only(bottomLeft: r, bottomRight: r);
            } else {
              return null;
            }
          }();
          return Padding(
            padding: EdgeInsets.only(
              left: _paddingLeft(c),
              top: index == 0 ? p : 0,
            ),
            child: Common.click(
              onTap: () {},
              color: ColorProvider.itemBg(),
              r: borderRadius,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: (index > 0 ? p / 2 : 0) + (index == 0 ? p : 0),
                  left: p,
                  right: p,
                  bottom: index == find.comments.length - 1 ? p : p / 2,
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Jack: ',
                        style: Common.textStyle(
                          c,
                          scale: .9,
                          alpha: .6,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: find.comments[index],
                        style: Common.textStyle(
                          c,
                          scale: .9,
                          alpha: .6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

  @override
  Widget widget(BuildContext c) {
    late Widget item;
    bool isEnd = false;
    switch (type) {
      case Type.head:
        isEnd = find.medias.isEmpty && find.comments.isEmpty;
        item = _head();
        break;
      case Type.media:
        isEnd = find.comments.isEmpty;
        item = Common.isVideo(find.medias[0]) ? _video() : _pic();
        break;
      case Type.comment:
        isEnd = index == find.comments.length - 1;
        item = _comment();
        break;
    }
    double p = _padding(c) * 2;
    return Padding(
      key: key(),
      padding: EdgeInsets.only(
        left: p,
        right: p,
      ),
      child: Column(
        children: [
          item,
          Visibility(
            visible: isEnd,
            child: Divider(color: ColorProvider.textColor().withOpacity(.2)),
          )
        ],
      ),
    );
  }
}
