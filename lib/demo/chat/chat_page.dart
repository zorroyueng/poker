import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/adapter.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/chat/chat_data.dart';
import 'package:poker/demo/chat/chat_provider.dart';

class ChatPage extends StatefulWidget {
  final int contactId;

  const ChatPage({super.key, required this.contactId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController scrollCtrl = ScrollController();

  final TextEditingController editCtrl = TextEditingController();

  late final Adapter<ChatProvider, ChatData> adapter;

  @override
  void initState() {
    super.initState();
    adapter = Adapter(ChatProvider(contactId: widget.contactId));
    scrollCtrl.addListener(
      () {
        if (scrollCtrl.offset >= scrollCtrl.position.maxScrollExtent) {
          adapter.load(more: true);
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollCtrl.dispose();
    adapter.dispose();
  }

  @override
  Widget build(BuildContext context) => ThemeWidget(
        builder: (c, __) => Scaffold(
          appBar: AppBar(
            elevation: 4,
            shadowColor: ColorProvider.itemBg(),
            leading: Common.iconBtn(
              c: c,
              icon: Common.icBack(),
              onPressed: () => Navi.pop(c),
            ),
            actions: [
              Common.iconBtn(
                c: c,
                icon: Common.icMore(),
                onPressed: () => Common.dlgSetting(c),
              ),
            ],
            surfaceTintColor: ColorProvider.itemBg(),
            backgroundColor: ColorProvider.itemBg(),
          ),
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => HpDevice.hideInput(c),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Common.scrollbar(
                      ctx: context,
                      controller: scrollCtrl,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: StreamWidget(
                          stream: adapter.trigger,
                          builder: (c, _, __) => ListView.builder(
                            controller: scrollCtrl,
                            reverse: true,
                            shrinkWrap: true,
                            itemCount: adapter.length,
                            itemBuilder: (c, i) => adapter.item(c, i),
                          ),
                        ),
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
                              adapter.provider.sendMsg(editCtrl.text);
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
