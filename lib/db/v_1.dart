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

  late final ColInt id = ColInt(this, name: 'id', key: true);
  late final ColStr name = ColStr(this, name: 'name');
  late final ColInt age = ColInt(this, name: 'age');
  late final ColInt sex = ColInt(this, name: 'sex');
  late final ColStr intro = ColStr(this, name: 'intro');
  late final ColStr picUrl = ColStr(this, name: 'picUrl');

  @override
  String tName() => 'User';

  @override
  List<Col> tColumns() => [id, name, age, sex, intro, picUrl];
}

class Find extends Table {
  Find._();

  late final ColInt id = ColInt(this, name: 'id', key: true);
  late final ColInt userId = ColInt(this, name: 'userId');
  late final ColStr content = ColStr(this, name: 'content');
  late final ColInt createTime = ColInt(this, name: 'createTime');

  @override
  List<Col> tColumns() => [id, userId, content, createTime];

  @override
  String tName() => 'Find';
}
