import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/chat/chat_adapter.dart';

class ChatPage extends StatelessWidget {
  final ScrollController scrollCtrl = ScrollController();
  final TextEditingController editCtrl = TextEditingController();
  final ChatAdapter adapter = ChatAdapter();

  ChatPage({super.key});

  @override
  Widget build(BuildContext context) => ThemeWidget(
        builder: (_, __) => Scaffold(
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => Focus.of(context).requestFocus(FocusNode()),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Common.scrollbar(
                      ctx: context,
                      controller: scrollCtrl,
                      child: CustomScrollView(
                        controller: scrollCtrl,
                        slivers: [
                          SliverAppBar(
                            pinned: true,
                            elevation: 4,
                            shadowColor: ColorProvider.itemBg(),
                            actions: [
                              ThemeWidget(
                                builder: (_, __) => IconButton(
                                  onPressed: () => Common.dlgSetting(context),
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
                          StreamWidget(
                            stream: adapter.stream,
                            builder: (c, _, __) {
                              // todo
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (c, i) => adapter.data(i).widget(c),
                                  childCount: adapter.length,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: ColorProvider.itemBg(),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Container(
                            color: ColorProvider.bg(),
                            margin: EdgeInsets.all(Common.margin(context, 2)),
                            child: TextField(
                              maxLines: null,
                              controller: editCtrl,
                              style: Common.textStyle(context),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: Common.base(context, 2),
                          child: Common.btn(
                            ctx: context,
                            content: 'Send',
                            onTap: () {
                              HpDevice.log(editCtrl.text);
                              editCtrl.clear();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
