import 'package:poker/base/db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class V1 extends Version {
  @override
  int code() => 1;

  @override
  Future<void> onCreate(Database db) {
    // HpDevice.log('$runtimeType.onCreate');
    return Future.wait([
      User(null).createTable(db),
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
  static final ColInt cId = ColInt(name: 'id', key: true);
  static final ColStr cName = ColStr(name: 'name');
  static final ColInt cAge = ColInt(name: 'age');
  static final ColInt cSex = ColInt(name: 'sex');
  static final ColStr cIntro = ColStr(name: 'intro');
  static final ColStr cPicUrl = ColStr(name: 'picUrl');

  User(super.map);

  @override
  String tName() => 'User';

  @override
  List<Col> tColumns() => [cId, cName, cAge, cSex, cIntro, cPicUrl];
}
