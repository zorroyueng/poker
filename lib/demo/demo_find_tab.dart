import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/demo_helper.dart';

class DemoFindTab extends StatefulWidget {
  const DemoFindTab({super.key});

  @override
  State<DemoFindTab> createState() => _DemoFindTabState();
}

class _DemoFindTabState extends State<DemoFindTab> {
  final ScrollController scrollCtrl = ScrollController();
  final FindAdapter adapter = FindAdapter()..setData(DemoHelper.buildInfoData());

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(() {
      if (scrollCtrl.position.pixels > scrollCtrl.position.maxScrollExtent) {
        print(
            'scrollCtrl.position.pixels=${scrollCtrl.position.pixels}, scrollCtrl.position.maxScrollExtent=${scrollCtrl.position.maxScrollExtent}');
      }
    });
  }

  Widget _head(BuildContext ctx) => SliverAppBar(
        // 标题栏是否固定
        pinned: true,
        elevation: 4,
        shadowColor: ColorProvider.itemBg(),
        actions: [
          ThemeWidget(
            builder: (_, __) => IconButton(
              onPressed: () {},
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
            await Future.delayed(const Duration(milliseconds: 200)); // todo
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
  final List<String> pics;
  final List<String> comments;

  InfoData({
    required this.head,
    required this.name,
    required this.content,
    required this.pics,
    required this.comments,
  });
}

enum ItemType {
  head,
  pic,
  comment,
}

class ItemData {
  final ItemType type;
  final InfoData info;
  final int index;

  ItemData({required this.type, required this.info, this.index = 0});

  double _padding(BuildContext c) => Common.base(c, .2);

  double _headSize(BuildContext c) => Common.base(c, 1.5);

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
                    Text(
                      info.name,
                      style: Common.textStyle(c, scale: 1.3)..copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      info.content,
                      style: Common.textStyle(c, alpha: .8),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      );

  int _gvCrossAxisCount() {
    if (info.pics.length == 1) {
      return 1;
    } else if (info.pics.length == 2 || info.pics.length == 4) {
      return 2;
    } else {
      return 3;
    }
  }

  Widget _pic() => ThemeWidget(
        builder: (c, _) {
          double p = _padding(c);
          return Container(
            padding: EdgeInsets.only(left: p * 2 + _headSize(c)),
            child: GridView.builder(
              shrinkWrap: true,
              //解决无限高度问题
              physics: const NeverScrollableScrollPhysics(),
              itemCount: info.pics.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gvCrossAxisCount(),
                mainAxisSpacing: p / 2,
                crossAxisSpacing: p / 2,
              ),
              itemBuilder: (c, i) => LayoutBuilder(
                builder: (c, constraints) {
                  double size = constraints.maxWidth; //  * HpDevice.pixelRatio(c)
                  return Common.netImage(url: info.pics[i], w: size, h: size);
                },
              ),
            ),
          );
        },
      );

  Widget _comment() => ThemeWidget(
        builder: (c, _) => Padding(
          padding: EdgeInsets.only(left: _padding(c) * 2 + _headSize(c)),
          child: Container(
            width: double.infinity,
            color: ColorProvider.itemBg(),
            child: Text(
              info.comments[index],
              style: Common.textStyle(
                c,
                scale: .8,
                alpha: .6,
              ),
            ),
          ),
        ),
      );

  Widget item(BuildContext c) {
    late Widget item;
    bool isEnd = false;
    switch (type) {
      case ItemType.head:
        isEnd = info.pics.isEmpty && info.comments.isEmpty;
        item = _head();
        break;
      case ItemType.pic:
        isEnd = info.comments.isEmpty;
        item = _pic();
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

  void setData(List<InfoData> data) {
    lstFindInfo.clear();
    lstFindInfo.addAll(data);
    lstItemData.clear();
    for (InfoData info in lstFindInfo) {
      lstItemData.add(ItemData(type: ItemType.head, info: info));
      lstItemData.add(ItemData(type: ItemType.pic, info: info));
      for (int i = 0; i < info.comments.length; i++) {
        lstItemData.add(ItemData(type: ItemType.comment, info: info, index: i));
      }
    }
  }
}
