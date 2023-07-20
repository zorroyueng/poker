import 'package:poker/base/db.dart';
import 'package:poker/base/db_table.dart';
import 'package:poker/base/db_table_mixin.dart';
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

  late final ColInt id = colInt('id', true);
  late final ColStr name = colStr('name');
  late final ColInt age = colInt('age');
  late final ColInt sex = colInt('sex');
  late final ColStr intro = colStr('intro');
  late final ColStr picUrl = colStr('picUrl');

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

  late final ColInt id = colInt('id', true);
  late final ColInt userId = colInt('userId');
  late final ColStr content = colStr('content');
  late final ColInt createTime = colInt('createTime');
  late final ColList<String> medias = colList<String>('medias');

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
