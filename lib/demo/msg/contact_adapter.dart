import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/adapter.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/chat/chat_page.dart';
import 'package:poker/demo/msg/contact_data.dart';
import 'package:poker/demo/msg/contact_provider.dart';

class ContactAdapter extends Adapter<ContactProvider, ContactData> {
  ContactAdapter(super.dataProvider);

  @override
  Widget widget(BuildContext c, ContactData data) => ThemeWidget(
        key: data.key(),
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
                          url: data.url,
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
                            data.name,
                            maxLines: 1,
                            style: Common.textStyle(c),
                          ),
                        ),
                        Text(
                          data.lastMsg,
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
            onTap: () => Navi.push(c, ChatPage(contactId: data.id)),
          );
        },
      );
}
