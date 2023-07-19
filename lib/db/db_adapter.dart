import 'package:poker/db/v_1.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:poker/demo/find/find_adapter.dart';

class DbAdapter {
  DbAdapter._();

  static Future<List<Info>> infoData() => V1.find
      .innerJoin(
        other: V1.user,
        col: V1.find.userId,
        otherCol: V1.user.id,
      )
      .then(
        (lst) => lst
            .map(
              (m) => Info(
                head: V1.user.picUrl.load(m)!,
                name: V1.user.name.load(m)!,
                content: V1.find.content.load(m)!,
                medias: V1.find.medias.load(m)!,
                comments: DemoHelper.comments(),
              ),
            )
            .toList(),
      );
}
