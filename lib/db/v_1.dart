import 'package:poker/base/db.dart';
import 'package:poker/db/user.dart';
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
    return Future.wait([
      Future.value(),
      onCreate(db),
    ]);
  }

  @override
  Version? last() => null;
}
