import 'package:poker/base/db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class V1 extends Version {
  static final User user = User._();
  static final Find find = Find._();

  @override
  int code() => 1;

  @override
  Future<void> onCreate(Database db) {
    // HpDevice.log('$runtimeType.onCreate');
    return Future.wait([
      user.createTable(db),
      find.createTable(db),
    ]);
  }

  @override
  Future<void> onUpdate(Database db) {
    // HpDevice.log('$runtimeType.onUpdate');
    return Future.wait([]);
  }

  @override
  Version? last() => null;
}

class User extends Table {
  User._();

  late final ColInt id = ColInt(name: key('id'), key: true);
  late final ColStr name = ColStr(name: key('name'));
  late final ColInt age = ColInt(name: key('age'));
  late final ColInt sex = ColInt(name: key('sex'));
  late final ColStr intro = ColStr(name: key('intro'));
  late final ColStr picUrl = ColStr(name: key('picUrl'));

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

  late final ColInt id = ColInt(name: key('id'), key: true);
  late final ColInt userId = ColInt(name: key('userId'));
  late final ColStr content = ColStr(name: key('content'));
  late final ColInt createTime = ColInt(name: key('createTime'));
  late final ColList<String> medias = ColList(name: key('medias'));

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
