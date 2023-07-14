import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:poker/demo/msg/contact_adapter.dart';

class MsgTab extends StatefulWidget {
  MsgTab({super.key});

  final ContactAdapter adapter = ContactAdapter()..setData(DemoHelper.contactData());
  double scrollOffset = 0;

  @override
  State<MsgTab> createState() => _MsgTabState();
}

class _MsgTabState extends State<MsgTab> {
  late final ScrollController scrollCtrl = ScrollController(initialScrollOffset: widget.scrollOffset);
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(() => widget.scrollOffset = scrollCtrl.offset);
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
        stream: widget.adapter.stream,
        builder: (_, __, ___) => SliverList(
          delegate: SliverChildBuilderDelegate(
            (c, i) => widget.adapter.data(i).widget(c),
            childCount: widget.adapter.length,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Common.scrollbar(
        ctx: context,
        controller: scrollCtrl,
        child: CustomScrollView(
          controller: scrollCtrl,
          slivers: [
            _head(context),
            _content(context),
          ],
        ),
      );
}
