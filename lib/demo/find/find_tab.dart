import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/base/video_widget.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:poker/demo/find/find_adapter.dart';

class FindTab extends StatefulWidget {
  const FindTab({super.key});

  @override
  State<FindTab> createState() => _FindTabState();
}

class _FindTabState extends State<FindTab> {
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
          childCount: adapter.lstItem.length,
          (c, i) => adapter.lstItem[i].item(c),
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