import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/adapter.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/find/find_provider.dart';

class FindTab extends StatefulWidget {
  FindTab({super.key});

  final Adapter adapter = Adapter(FindProvider());
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
        // android 列表无法伸缩，需要=
        if (scrollCtrl.offset >= scrollCtrl.position.maxScrollExtent) {
          if (!loading.value()) {
            loading.add(true);
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
          pinned: true,
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
        stream: widget.adapter.trigger,
        initialData: null,
        builder: (_, __, ___) => SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: widget.adapter.length,
            (c, i) => widget.adapter.item(c, i),
          ),
        ),
      );

  Widget _more(BuildContext ctx) => SliverFillRemaining(
        hasScrollBody: false,
        fillOverscroll: true,
        child: SizedBox(
          width: double.infinity,
          height: Common.base(ctx, 2),
          child: Common.click(
            onTap: () => loading.add(true),
            child: Padding(
              padding: EdgeInsets.all(Common.base(ctx, .2)),
              child: StreamWidget(
                initialData: loading.value(),
                stream: loading.stream().distinct(),
                builder: (ctx, _, __) {
                  if (loading.value()) {
                    widget.adapter.provider.load(more: true).then(
                          (_) => loading.add(false),
                        );
                  }
                  return loading.value()
                      ? Common.loading
                      : Center(
                          child: Text(
                            'the end',
                            style: Common.textStyle(ctx, alpha: .5),
                          ),
                        );
                },
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
          onRefresh: () => widget.adapter.provider.load(more: false),
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
