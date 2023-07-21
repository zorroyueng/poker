import 'package:poker/base/db.dart';
import 'package:poker/base/db_table.dart';
import 'package:poker/base/db_table_base.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class V1 extends Version {
  static final User user = User._();
  static final Find find = Find._();
  static final Msg msg = Msg._();

  @override
  int code() => 1;

  @override
  Future<void> onCreate(Database db) {
    // HpDevice.log('$runtimeType.onCreate');
    return Future.wait([
      user.createTable(db),
      find.createTable(db),
      msg.createTable(db),
    ]);
  }

  @override
  Future<void> onUpdate(Database db) {
    // HpDevice.log('$runtimeType.onUpdate');
    return Future.wait([]);
  }

  @override
  Version? last() => null;

  static Future<void> mockDb() async {
    int count = await Db.transaction((txn) {
      return user.count(txn: txn);
    });
    if (count == 0) {
      await Future.wait([
        DemoHelper.upsertChat(),
        DemoHelper.upsertFind(),
        DemoHelper.upsertUser(),
      ]);
    }
  }
}

class User extends Table {
  User._();

  late final ColInt id = colInt('id', key: true, dValue: -1);
  late final ColStr name = colStr('name', dValue: '');
  late final ColInt age = colInt('age', dValue: 18);
  late final ColInt sex = colInt('sex', dValue: 0);
  late final ColStr intro = colStr('intro', dValue: '');
  late final ColStr picUrl = colStr('picUrl', dValue: '');

  @override
  String tName() => 'User';

  @override
  List<Col> tColumns() => [
        id,
        name,
        age,
        sex,
        intro,
        picUrl,
      ];
}

class Find extends Table {
  Find._();

  late final ColInt id = colInt('id', key: true, dValue: -1);
  late final ColInt userId = colInt('userId', dValue: -1);
  late final ColStr content = colStr('content', dValue: '');
  late final ColTime createTime = colTime('createTime', dValue: DateTime.now());
  late final ColList<String> medias = colList<String>('medias', dValue: ['']);

  @override
  List<Col> tColumns() => [
        id,
        userId,
        content,
        createTime,
        medias,
      ];

  @override
  String tName() => 'Find';
}

class Msg extends Table {
  Msg._();

  late final ColInt id = colInt('id', key: true, dValue: -1);
  late final ColTime createTime = colTime('createTime', dValue: DateTime.now());
  late final ColInt ownerId = colInt('ownerId', dValue: -1);
  late final ColInt otherId = colInt('otherId', dValue: -1);
  late final ColInt contactId = colInt('contactId', dValue: -1);
  late final ColInt msgType = colInt('msgType', dValue: 0);
  late final ColInt relationship = colInt('relationship', dValue: 0);
  late final ColStr content = colStr('content', dValue: '');

  @override
  List<Col> tColumns() => [
        id,
        createTime,
        ownerId,
        otherId,
        contactId,
        msgType,
        relationship,
        content,
      ];

  @override
  String tName() => 'Msg';
}
