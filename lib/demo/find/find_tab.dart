import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:poker/demo/find/find_adapter.dart';

class FindTab extends StatefulWidget {
  FindTab({super.key});

  final FindAdapter adapter = FindAdapter()..setData(DemoHelper.findData());
  double scrollOffset = 0;

  @override
  State<FindTab> createState() => _FindTabState();
}

class _FindTabState extends State<FindTab> {
  late final ScrollController scrollCtrl = ScrollController(initialScrollOffset: widget.scrollOffset);
  Future? future;

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(
      () {
        widget.scrollOffset = scrollCtrl.offset;
        // android 列表无法伸缩，需要=
        if (scrollCtrl.position.pixels >= scrollCtrl.position.maxScrollExtent) {
          future ??= Future.delayed(
            const Duration(seconds: 2),
            () {
              widget.adapter.addData(DemoHelper.findData());
              future = null;
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollCtrl.dispose();
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

  Widget _content(BuildContext ctx) => StreamWidget(
        stream: widget.adapter.update.stream(),
        initialData: widget.adapter.update.value(),
        builder: (_, __, ___) => SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: widget.adapter.lstItem.length,
            (c, i) => widget.adapter.lstItem[i].item(c),
          ),
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
            await Future.delayed(
              const Duration(seconds: 2),
              () => widget.adapter.setData(DemoHelper.findData()),
            );
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
