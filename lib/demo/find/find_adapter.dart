import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/base/video_widget.dart';

class FindAdapter {
  final List<Info> lstInfo = [];
  final List<ItemModel> lstItem = [];

  void addData(List<Info> data) {
    lstInfo.addAll(data);
    List<ItemModel> lst = [];
    for (Info info in data) {
      lst.add(ItemModel(type: Type.head, info: info));
      lst.add(ItemModel(type: Type.media, info: info));
      for (int i = 0; i < info.comments.length; i++) {
        lst.add(ItemModel(type: Type.comment, info: info, index: i));
      }
    }
    lstItem.addAll(lst);
  }

  void setData(List<Info> data) {
    lstInfo.clear();
    lstItem.clear();
    addData(data);
  }
}

class Info {
  final String head;
  final String name;
  final String content;
  final List<String> medias;
  final List<String> comments;

  Info({
    required this.head,
    required this.name,
    required this.content,
    required this.medias,
    required this.comments,
  });
}

enum Type {
  head,
  media,
  comment,
}

class ItemModel {
  final Type type;
  final Info info;
  final int index;

  ItemModel({required this.type, required this.info, this.index = 0});

  double _padding(BuildContext c) => Common.base(c, .2);

  double _headSize(BuildContext c) => Common.base(c, 1.3);

  Widget _head() => ThemeWidget(
        builder: (c, __) {
          double w = _headSize(c);
          double p = _padding(c);
          return Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: p,
                  right: p * 2,
                  bottom: p,
                ),
                child: SizedBox(
                  width: w,
                  height: w,
                  child: Common.netImage(
                    url: info.head,
                    w: w,
                    h: w,
                    borderRadius: Common.baseRadius(c),
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
                        info.name,
                        maxLines: 1,
                        style: Common.textStyle(
                          c,
                          scale: 1.2,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      info.content,
                      style: Common.textStyle(
                        c,
                        alpha: .8,
                      ).copyWith(height: 1),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      );

  int _gvCrossAxisCount() {
    if (info.medias.length == 1) {
      return 1;
    } else if (info.medias.length == 2 || info.medias.length == 4) {
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
              left: p * 2 + _headSize(c),
              top: p,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              //解决无限高度问题
              physics: const NeverScrollableScrollPhysics(),
              itemCount: info.medias.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gvCrossAxisCount(),
                mainAxisSpacing: p / 2,
                crossAxisSpacing: p / 2,
              ),
              itemBuilder: (c, i) => LayoutBuilder(
                builder: (c, constraints) {
                  double size = constraints.maxWidth; //  * HpDevice.pixelRatio(c)
                  return Common.netImage(url: info.medias[i], w: size, h: size);
                },
              ),
            ),
          );
        },
      );

  Widget _video() => ThemeWidget(
        builder: (c, _) {
          double p = _padding(c);
          return Container(
            padding: EdgeInsets.only(
              left: p * 2 + _headSize(c),
              top: p,
            ),
            child: AspectRatio(
              aspectRatio: 1.6,
              child: VideoWidget(url: info.medias[0]),
            ),
          );
        },
      );

  Widget _comment() => ThemeWidget(
        builder: (c, _) {
          double p = _padding(c);
          return Padding(
            padding: EdgeInsets.only(
              left: p * 2 + _headSize(c),
              top: index == 0 ? p : 0,
            ),
            child: Container(
              width: double.infinity,
              color: ColorProvider.itemBg(),
              padding: EdgeInsets.only(
                top: index > 0 ? p / 2 : 0,
              ),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(height: 1),
                  children: [
                    TextSpan(
                      text: 'Jack: ',
                      style: Common.textStyle(
                        c,
                        scale: .8,
                        alpha: .6,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: info.comments[index],
                      style: Common.textStyle(
                        c,
                        scale: .8,
                        alpha: .6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

  Widget item(BuildContext c) {
    late Widget item;
    bool isEnd = false;
    switch (type) {
      case Type.head:
        isEnd = info.medias.isEmpty && info.comments.isEmpty;
        item = _head();
        break;
      case Type.media:
        isEnd = info.comments.isEmpty;
        item = Common.isVideo(info.medias[0]) ? _video() : _pic();
        break;
      case Type.comment:
        isEnd = index == info.comments.length - 1;
        item = _comment();
        break;
    }
    double p = _padding(c) * 2;
    return Padding(
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
