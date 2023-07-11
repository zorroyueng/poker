import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/base/video_widget.dart';
import 'package:poker/demo/demo_helper.dart';

class DemoFindTab extends StatefulWidget {
  const DemoFindTab({super.key});

  @override
  State<DemoFindTab> createState() => _DemoFindTabState();
}

class _DemoFindTabState extends State<DemoFindTab> {
  final FindAdapter adapter = FindAdapter()..setData(DemoHelper.buildInfoData());
  final ScrollController scrollCtrl = ScrollController();
  Future? future;

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(
      () {
        // android 列表无法伸缩，需要=
        if (scrollCtrl.position.pixels >= scrollCtrl.position.maxScrollExtent) {
          future ??= Future.delayed(
            const Duration(seconds: 2),
            () {
              setState(() => adapter.addData(DemoHelper.buildInfoData()));
              future = null;
            },
          );
        }
      },
    );
  }

  Widget _head(BuildContext ctx) => ThemeWidget(
        builder: (ctx, _) => SliverAppBar(
          // 标题栏是否固定
          floating: true,
          elevation: 4,
          shadowColor: ColorProvider.itemBg(),
          actions: [
            ThemeWidget(
              builder: (_, __) => IconButton(
                onPressed: () => Common.dlgSetting(ctx),
                icon: Icon(
                  Icons.more_horiz,
                  color: ColorProvider.textColor(),
                ),
              ),
            ),
          ],
          backgroundColor: ColorProvider.bg(),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: ColorProvider.bg(),
            ),
          ),
        ),
      );

  Widget _content(BuildContext ctx) => SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: adapter.lstItemData.length,
          (c, i) => adapter.lstItemData[i].item(c),
        ),
      );

  Widget _more(BuildContext ctx) => SliverFillRemaining(
        hasScrollBody: false,
        fillOverscroll: true,
        child: Padding(
          padding: EdgeInsets.all(Common.base(ctx, .2)),
          child: Common.loading,
        ),
      );

  @override
  Widget build(BuildContext context) => Common.scrollbar(
        ctx: context,
        controller: scrollCtrl,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2)); // todo
          },
          child: CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              _head(context),
              _content(context),
              _more(context),
            ],
          ),
        ),
      );
}

class InfoData {
  final String head;
  final String name;
  final String content;
  final List<String> medias;
  final List<String> comments;

  InfoData({
    required this.head,
    required this.name,
    required this.content,
    required this.medias,
    required this.comments,
  });
}

enum ItemType {
  head,
  media,
  comment,
}

class ItemData {
  final ItemType type;
  final InfoData info;
  final int index;

  ItemData({required this.type, required this.info, this.index = 0});

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
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(height: 1),
                  children: [
                    TextSpan(
                      text: 'Jack: ',
                      style: Common.textStyle(
                        c,
                        alpha: .6,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: info.comments[index],
                      style: Common.textStyle(
                        c,
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
      case ItemType.head:
        isEnd = info.medias.isEmpty && info.comments.isEmpty;
        item = _head();
        break;
      case ItemType.media:
        isEnd = info.comments.isEmpty;
        item = Common.isVideo(info.medias[0]) ? _video() : _pic();
        break;
      case ItemType.comment:
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

class FindAdapter {
  final List<InfoData> lstFindInfo = [];
  final List<ItemData> lstItemData = [];

  void addData(List<InfoData> data) {
    lstFindInfo.addAll(data);
    List<ItemData> lst = [];
    for (InfoData info in data) {
      lst.add(ItemData(type: ItemType.head, info: info));
      lst.add(ItemData(type: ItemType.media, info: info));
      for (int i = 0; i < info.comments.length; i++) {
        lst.add(ItemData(type: ItemType.comment, info: info, index: i));
      }
    }
    lstItemData.addAll(lst);
  }

  void setData(List<InfoData> data) {
    lstFindInfo.clear();
    lstItemData.clear();
    addData(data);
  }
}
