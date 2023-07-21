import 'package:flutter/material.dart';
import 'package:poker/base/adapter.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/db/v_1.dart';

class ChatAdapter extends Adapter<ChatData> {
  final int contactId;

  ChatAdapter(this.contactId);

  @override
  DataProvider<ChatData> provider() => ChatProvider(
        contactId: contactId,
        adapter: this,
        pageLimit: 10,
        streams: [],
      );
}

class ChatProvider extends DataProvider<ChatData> {
  final int contactId;

  ChatProvider({
    required this.contactId,
    required super.adapter,
    required super.pageLimit,
    required super.streams,
  });

  @override
  Future<List<ChatData>> getData(int? limit) {
    return V1.msg
        .innerJoin(
          join: V1.user,
          key: V1.msg.ownerId,
          joinKey: V1.user.id,
          where: '${V1.msg.otherId}=$contactId OR ${V1.msg.ownerId}=$contactId',
          orderBy: '${V1.msg.createTime} DESC',
        )
        .then(
          (lst) => lst
              .map(
                (m) => ChatData(
                  id: V1.msg.id.get(m)!,
                  my: 0 == V1.msg.ownerId.get(m)!,
                  picUrl: V1.user.picUrl.get(m)!,
                  content: V1.msg.content.get(m)!,
                ),
              )
              .toList(),
        );
  }
}

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
  Object key() => id;

  @override
  Widget widget(BuildContext c) {
    double w = Common.base(c, 1.3);
    double p = Common.base(c, .1);
    BorderRadius r = Common.baseRadius(c);
    return Row(
      textDirection: my ? TextDirection.rtl : TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
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
              margin: EdgeInsets.all(p),
              padding: EdgeInsets.all(p),
              decoration: Common.roundRect(
                c,
                scale: .3,
                bgColor: ColorProvider.chatBg(my),
              ),
              child: SelectableText(
                content,
                style: Common.textStyle(c),
              ),
            ),
          ),
        ),
        SizedBox(width: w + 2 * p),
      ],
    );
  }
}
