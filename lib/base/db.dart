import 'package:base/base.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class Db {
  Db._();

  static const String _name = 'Db.db';
  static late Database _db;

  static Future init(Version v) async {
    // 初始化db
    late DatabaseFactory databaseFactory;
    late String path;
    if (HpPlatform.isWeb()) {
      databaseFactory = databaseFactoryFfiWeb;
      path = _name;
    } else {
      databaseFactory = databaseFactoryFfi;
      path = '${(await HpFile.appDirectory())!.path}/$_name';
    }
    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: v.code(),
        onCreate: (db, version) async {
          HpDevice.log('onCreate: $version');
          await v.onCreate(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          List<Version> versions = v._versions();
          for (Version v in versions) {
            if (v.code() > oldVersion) {
              await v.onUpdate(db);
            }
          }
        },
      ),
    );
  }

  static Future<T> transaction<T>(Future<T> Function(Transaction txn) action, {bool? exclusive}) => _db.transaction(
        (txn) => action.call(txn),
        exclusive: exclusive,
      );

  static Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? args]) => _db.rawQuery(sql, args);
}

abstract class Version {
  int code();

  Future<void> onCreate(Database db);

  Future<void> onUpdate(Database db);

  Version? last();

  List<Version> _versions() {
    List<Version> lst = [];
    Version? v = this;
    while (v != null) {
      lst.insert(0, v);
      v = v.last();
    }
    return lst;
  }
}
