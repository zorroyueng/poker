import 'dart:typed_data';

import 'package:base/base.dart';
import 'package:sqflite/sqflite.dart';
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
          await v.onCreate(db);
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

abstract class Table {
  final Map<String, Object?> map = {};

  String tName();

  List<Col> tColumns();

  Map<String, Object?> toMap() => map;

  Table(Map<String, Object?>? map) {
    if (map != null && map.isNotEmpty) {
      this.map.clear();
      this.map.addAll(map);
    }
  }

  Future<int> _insert(Transaction txn, String key) {
    String params = '';
    String values = '';
    for (String key in map.keys) {
      Object? value = map[key];
      if (value != null) {
        params += key;
        if (value is String) {
          values += '\'$value\'';
        } else {
          values += value.toString();
        }
        if (key != map.keys.last) {
          params += ',';
          values += ',';
        }
      }
    }
    String sql = 'INSERT INTO ${tName()} ($params) VALUES($values)';
    HpDevice.log(sql);
    return txn.rawInsert(sql);
  }

  Future<int> upsert(Transaction txn, String key) =>
      count(txn, key).then((n) => n == 0 ? _insert(txn, key) : update(txn, key));

  Future<int> count(Transaction txn, String key) async {
    String sql = 'SELECT COUNT(*) FROM ${tName()} WHERE ${_join(key, map[key])}';
    return Sqflite.firstIntValue(await txn.rawQuery(sql)) ?? 0;
  }

  String _join(String key, Object? value) {
    if (value is String) {
      return '$key=\'${map[key]}\'';
    } else {
      return '$key=${map[key]}';
    }
  }

  Future<int> update(Transaction txn, String key) {
    String set = '';
    String where = '';
    for (String k in map.keys) {
      if (k == key) {
        where = _join(k, map[k]);
      } else {
        if (set.isNotEmpty) {
          set += ',';
        }
        set += _join(k, map[k]);
      }
    }
    String sql = 'UPDATE ${tName()} SET $set WHERE $where';
    HpDevice.log(sql);
    return txn.rawUpdate(sql);
  }

  Future<void> createTable(Database db) {
    List<String> lst = [];
    for (Col c in tColumns()) {
      lst.add('${c.name} ${c.type}');
    }
    return Db.createTable(db, tName(), lst);
  }
}

abstract class Col<T> {
  final String name;
  final String type;

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
