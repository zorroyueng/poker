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
  final Broadcast<bool> loading = Broadcast(false);

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(
      () {
        widget.scrollOffset = scrollCtrl.offset;
        HpDevice.log(
            'scrollCtrl.offset=${scrollCtrl.offset}, scrollCtrl.position.maxScrollExtent=${scrollCtrl.position.maxScrollExtent}');
        // android 列表无法伸缩，需要=
        if (scrollCtrl.offset >= scrollCtrl.position.maxScrollExtent) {
          if (!loading.value()) {
            loading.add(true);
            Future.delayed(
              const Duration(seconds: 2),
              () {
                widget.adapter.addData(DemoHelper.findData());
                loading.add(false);
              },
            );
          }
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
        stream: widget.adapter.items.stream(),
        initialData: widget.adapter.items.value(),
        builder: (_, __, ___) => SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: widget.adapter.items.value().length,
            (c, i) => widget.adapter.items.value()[i].item(c),
          ),
        ),
      );

  Widget _more(BuildContext ctx) => SliverFillRemaining(
        hasScrollBody: false,
        fillOverscroll: true,
        child: SizedBox(
          width: double.infinity,
          height: Common.base(ctx, 2),
          child: Padding(
            padding: EdgeInsets.all(Common.base(ctx, .2)),
            child: StreamWidget(
              initialData: loading.value(),
              stream: loading.stream().distinct(),
              builder: (ctx, _, __) => loading.value()
                  ? Common.loading
                  : Center(
                      child: Text(
                        'the end',
                        style: Common.textStyle(ctx, alpha: .5),
                      ),
                    ),
            ),
          ),
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
