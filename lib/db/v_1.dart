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

  late final String id = key('id');
  late final String name = key('name');
  late final String age = key('age');
  late final String sex = key('sex');
  late final String intro = key('intro');
  late final String picUrl = key('picUrl');

  @override
  String tName() => 'User';

  @override
  List<Col> tColumns() => [
        ColInt(name: id, key: true),
        ColStr(name: name),
        ColInt(name: age),
        ColInt(name: sex),
        ColStr(name: intro),
        ColStr(name: picUrl),
      ];
}

class Find extends Table {
  Find._();

  late final String id = key('id');
  late final String userId = key('userId');
  late final String content = key('content');
  late final String createTime = key('createTime');

  @override
  List<Col> tColumns() => [
        ColInt(name: id, key: true),
        ColInt(name: userId),
        ColStr(name: content),
        ColInt(name: createTime),
      ];

  @override
  String tName() => 'Find';
}
