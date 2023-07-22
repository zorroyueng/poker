import 'package:poker/base/adapter.dart';
import 'package:poker/base/db.dart';
import 'package:poker/db/v_1.dart';
import 'package:poker/demo/chat/chat_adapter.dart';

class ChatProvider extends Provider<ChatData> {
  final int contactId;

  ChatProvider({required this.contactId});

  @override
  Future<List<ChatData>> getData(int from, int? to) {
    return V1.msg
        .innerJoin(
            join: V1.user,
            key: V1.msg.ownerId,
            joinKey: V1.user.id,
            where: '${V1.msg.otherId}=$contactId OR ${V1.msg.ownerId}=$contactId',
            orderBy: '${V1.msg.createTime} DESC',
            limit: to == null ? null : '$to OFFSET $from')
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

  void sendMsg(String s) {
    Db.transaction((txn) => V1.msg.insert(
          txn: txn,
          map: () {
            DateTime time = DateTime.now();
            Map<String, Object?> map = {};
            V1.msg.id.put(map, time.millisecondsSinceEpoch);
            V1.msg.createTime.put(map, time);
            V1.msg.ownerId.put(map, 0);
            V1.msg.otherId.put(map, contactId);
            V1.msg.contactId.put(map, contactId);
            V1.msg.msgType.put(map, 0);
            V1.msg.relationship.put(map, 1);
            V1.msg.content.put(map, s);
            return map;
          }(),
        ));
  }

  @override
  List<Stream>? triggers() => [V1.msg.trigger];

  @override
  int? pageLimit() => 20;
}
