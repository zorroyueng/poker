import 'dart:typed_data';

import 'package:base/base.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class Db {
  Db._();

  static const String _name = 'Db.db';
  static late Database _db;

  static Future init(Version v) async {
    // 确保升序
    List<Version> versions = v._versions();
    versions.sort((a, b) => a.code().compareTo(b.code()));
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
          for (Version v in versions) {
            await v.onCreate(db);
          }
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          for (Version v in versions) {
            if (v.code() > oldVersion) {
              await v.onUpdate(db);
            }
          }
        },
      ),
    );
  }

  static Future<void> createTable(Database db, String name, List<String> param) {
    String str = 'CREATE TABLE $name (';
    for (String s in param) {
      str += s;
      if (s != param.last) {
        str += ',';
      }
    }
    str += ')';
    HpDevice.log(str);
    return db.execute(str);
  }

  // name TEXT
  static Future<void> addColumn(Database db, String name, String s) => db.execute('ALTER TABLE $name ADD COLUMN $s');

  static Future<void> dropTable(Database db, String name) => db.execute('DROP TABLE  $name');

  static get db => _db;
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

abstract class DbTable {
  String tName();

  final List<Col> _columns = [];

  void init(List<Col> columns);

  Map<String, Object?> toMap() {
    Map<String, Object?> map = {};
    for (Col c in _columns) {
      map[c.name] = c.value;
    }
    return map;
  }

  DbTable(Map<String, Object?>? map) {
    init(_columns);
    if (map != null && map.isNotEmpty) {
      for (Col c in _columns) {
        c.value = map[c.name];
      }
    }
  }

  Future<void> insert(Transaction txn) {
    String params = '';
    String values = '';
    for (Col c in _columns) {
      params += c.name;
      values += c.value;
      if (c != _columns.last) {
        params += ',';
        values += ',';
      }
    }
    String sql = 'INSERT INTO ${tName()} ($params) VALUES($values)';
    HpDevice.log(sql);
    return txn.rawInsert(sql);
  }

  Future<void> createTable(Database db) {
    List<String> lst = [];
    for (Col c in _columns) {
      lst.add('${c.name} ${c.type}');
    }
    return Db.createTable(db, tName(), lst);
  }
}

abstract class Col<T> {
  final String name;
  final String type;
  T? value;

  Col({required this.name, required this.type});
}

class ColInt extends Col<int> {
  ColInt({required super.name, bool key = false}) : super(type: 'INTEGER${key ? ' PRIMARY KEY' : ''}');
}

class ColNum extends Col<num> {
  ColNum({required super.name}) : super(type: 'REAL');
}

class ColStr extends Col<String> {
  ColStr({required super.name, bool key = false}) : super(type: 'TEXT${key ? ' PRIMARY KEY' : ''}');
}

class ColByte extends Col<Uint8List> {
  ColByte({required super.name}) : super(type: 'BLOB');
}
