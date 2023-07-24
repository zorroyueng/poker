import 'package:poker/base/adapter.dart';
import 'package:poker/db/v_1.dart';
import 'package:poker/demo/msg/contact_data.dart';

class ContactProvider extends Provider<ContactData> {
  @override
  Future<List<ContactData>> getData({int from = 0, int? limit}) => V1.msg
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

  @override
  int? pageLimit() => null;

  @override
  List<Stream>? triggers() => [
        V1.msg.trigger,
        V1.user.trigger.where(
          (m) {
            int id = V1.user.id.get(m)!;
            List<ContactData> lst = data();
            bool has = false;
            for (ContactData d in lst) {
              if (d.id == id) {
                has = true;
                break;
              }
            }
            return has;
          },
        ),
      ];
}
