import 'package:flutter/material.dart';
import 'package:poker/base/adapter.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';

class ChatData extends Data {
  final int id;
  final bool my;
  final String picUrl;
  final String content;

  ChatData({
    required this.id,
    required this.my,
    required this.picUrl,
    required this.content,
  });

  @override
  ValueKey key() => ValueKey(id);

  @override
  Widget widget(BuildContext c) {
    double w = Common.base(c, 1.3);
    double p = Common.base(c, .1);
    BorderRadius r = Common.baseRadius(c);
    return Row(
      key: key(),
      textDirection: my ? TextDirection.rtl : TextDirection.ltr,
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
                url: picUrl,
                w: w,
                h: w,
                borderRadius: r,
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: my ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(minHeight: w),
              padding: EdgeInsets.symmetric(vertical: p, horizontal: 2 * p),
              margin: EdgeInsets.all(p),
              decoration: Common.roundRect(
                c,
                scale: .3,
                bgColor: ColorProvider.chatBg(my),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText(
                    content,
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