import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/adapter.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/db/v_1.dart';
import 'package:poker/demo/chat/chat_page.dart';

class ContactAdapter extends Adapter<ContactData> {
  @override
  DataProvider<ContactData> provider() => ContactProvider(
        adapter: this,
        pageLimit: 0,
        streams: [],
      );
}

class ContactProvider extends DataProvider<ContactData> {
  ContactProvider({required super.adapter, required super.pageLimit, required super.streams});

  @override
  Future<List<ContactData>> getData(int? limit) => V1.msg
      .innerJoin(
        join: V1.user,
        key: V1.msg.contactId,
        joinKey: V1.user.id,
        cols: V1.msg.tColumns()..add(V1.msg.createTime.max()),
        groupBy: '${V1.msg.contactId}',
        orderBy: '${V1.msg.createTime} DESC',
      )
      .then(
        (lst) => lst
            .map(
              (m) => ContactData(
                id: V1.msg.contactId.get(m)!,
                url: V1.user.picUrl.get(m)!,
                name: V1.user.name.get(m)!,
                lastMsg: V1.msg.content.get(m)!,
              ),
            )
            .toList(),
      );
}

class ContactData extends Data {
  final int id;
  final String url;
  final String name;
  final String lastMsg;

  ContactData({
    required this.id,
    required this.url,
    required this.name,
    required this.lastMsg,
  });

  @override
  Object key() => id;

  @override
  Widget widget(BuildContext c) => ThemeWidget(
        builder: (c, _) {
          double p = Common.base(c, .2);
          double w = Common.base(c, 1.3);
          BorderRadius r = Common.baseRadius(c);
          return Common.click(
            child: Container(
              margin: EdgeInsets.all(p / 2),
              decoration: Common.roundRect(
                c,
                scale: .5,
                bgColor: ColorProvider.itemBg(),
                border: false,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
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
                          url: url,
                          w: w,
                          h: w,
                          borderRadius: r,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            name,
                            maxLines: 1,
                            style: Common.textStyle(c),
                          ),
                        ),
                        Text(
                          lastMsg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Common.textStyle(c, alpha: .5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            onTap: () => Navi.push(c, ChatPage(contactId: id)),
          );
        },
      );
}
