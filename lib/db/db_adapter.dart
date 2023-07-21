import 'package:poker/db/v_1.dart';
import 'package:poker/demo/chat/chat_adapter.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:poker/demo/find/find_adapter.dart';
import 'package:poker/demo/msg/contact_adapter.dart';

class DbAdapter {
  DbAdapter._();

  static Future<List<Info>> infoData() => V1.find
      .innerJoin(
        join: V1.user,
        key: V1.find.userId,
        joinKey: V1.user.id,
      )
      .then(
        (lst) => lst
            .map(
              (m) => Info(
                head: V1.user.picUrl.get(m)!,
                name: V1.user.name.get(m)!,
                content: V1.find.content.get(m)!,
                medias: V1.find.medias.get(m)!,
                comments: DemoHelper.comments(),
              ),
            )
            .toList(),
      );

  static Future<List<ContactData>> contactData() => V1.msg
      .innerJoin(
        join: V1.user,
        key: V1.msg.contactId,
        joinKey: V1.user.id,
        cols: V1.msg.tColumns()..add(V1.msg.createTime.max()),
        groupBy: '${V1.msg.contactId}',
        orderBy: '${V1.msg.createTime} ASC',
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

  static Future<List<ChatData>> chatData(int userId) => V1.msg
      .innerJoin(
        join: V1.user,
        key: V1.msg.ownerId,
        joinKey: V1.user.id,
        where: '${V1.msg.otherId}=$userId OR ${V1.msg.ownerId}=$userId',
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
