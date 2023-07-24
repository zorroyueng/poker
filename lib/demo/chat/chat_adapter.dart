import 'package:flutter/material.dart';
import 'package:poker/base/adapter.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/chat/chat_data.dart';
import 'package:poker/demo/chat/chat_provider.dart';

class ChatAdapter extends Adapter<ChatProvider, ChatData> {
  ChatAdapter(super.dataProvider);

  @override
  Widget widget(BuildContext c, ChatData data) {
    double w = Common.base(c, 1.3);
    double p = Common.base(c, .1);
    BorderRadius r = Common.baseRadius(c);
    return Row(
      key: data.key(),
      textDirection: data.my ? TextDirection.rtl : TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.all(p),
          child: SizedBox(
            width: w,
            height: w,
            child: Common.click(
              onTap: () {},
              r: r,
              back: Common.netImage(
                url: data.picUrl,
                w: w,
                h: w,
                borderRadius: r,
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: data.my ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(minHeight: w),
              padding: EdgeInsets.symmetric(vertical: p, horizontal: 2 * p),
              margin: EdgeInsets.all(p),
              decoration: Common.roundRect(
                c,
                scale: .3,
                bgColor: ColorProvider.chatBg(data.my),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText(
                    data.content,
                    style: Common.textStyle(c),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: w + 2 * p),
      ],
    );
  }
}
