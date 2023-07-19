import 'dart:convert';
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

  static Future<T> transaction<T>(Future<T> Function(Transaction txn) action, {bool? exclusive}) => _db.transaction(
        (txn) => action.call(txn),
        exclusive: exclusive,
      );
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
  String tName();

  List<Col> tColumns();

  String key(String name) => '${tName()}_$name';

  Future<int> _insert(Transaction txn, Map<String, Object?> map, Col col) {
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

  Future<int> upsert(Transaction txn, Map<String, Object?> map, Col col) =>
      count(txn, map, col).then((n) => n == 0 ? _insert(txn, map, col) : update(txn, map, col));

  Future<int> count(Transaction txn, Map<String, Object?> map, Col col) async {
    String sql = 'SELECT COUNT(*) FROM ${tName()} '
        'WHERE ${_join(map, col.name)}';
    return Sqflite.firstIntValue(await txn.rawQuery(sql)) ?? 0;
  }

  String _join(Map<String, Object?> map, String key) {
    Object? value = map[key];
    if (value is String) {
      return '$key=\'$value\'';
    } else {
      return '$key=$value';
    }
  }

  Future<List<Map<String, Object?>>> query({List<String>? columns}) {
    select(Table table, List<String>? columns) {
      String select = '';
      if (columns != null && columns.isNotEmpty) {
        for (String s in columns) {
          if (select.isNotEmpty) {
            select += ',';
          }
          select += '${table.tName()}.$s';
        }
      } else {
        select = '${table.tName()}.*';
      }
      return select;
    }

    String sql = 'SELECT ${select(this, columns)} FROM ${tName()}';
    HpDevice.log(sql);
    return Db._db.rawQuery(sql);
  }

  Future<List<Map<String, Object?>>> innerJoin({
    List<String>? cols,
    required Table other,
    List<String>? otherCols,
    required Col col,
    required Col otherCol,
  }) {
    select(Table table, List<String>? columns) {
      String select = '';
      Iterable<String> lst = (columns != null && columns.isNotEmpty) ? columns : table.tColumns().map((c) => c.name);
      for (String s in lst) {
        if (select.isNotEmpty) {
          select += ',';
        }
        select += '${table.tName()}.$s';
      }
      return select;
    }

    String sql = 'SELECT ${select(this, cols)},${select(other, otherCols)} FROM ${tName()} '
        'INNER JOIN ${other.tName()} '
        'ON ${tName()}.${col.name}=${other.tName()}.${otherCol.name}';
    HpDevice.log(sql);
    return Db._db.rawQuery(sql);
  }

  Future<int> update(Transaction txn, Map<String, Object?> map, Col col) {
    String set = '';
    String where = '';
    for (String k in map.keys) {
      if (k == col.name) {
        where = _join(map, k);
      } else {
        if (set.isNotEmpty) {
          set += ',';
        }
        set += _join(map, k);
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

abstract class Col<D, T> {
  final String name;
  final String type;

  Col({required this.name, required this.type}) {
    assert(name.split('_').length == 2);
  }

  T? _encode(D? d);

  D? _decode(T? t);

  void save(Map<String, Object?> map, D? d) => map[name] = _encode(d);

  D? load(Map<String, Object?> map) => _decode(map[name] as T?);
}

class ColInt extends Col<int, int> {
  ColInt({
    required super.name,
    bool key = false,
  }) : super(
          type: 'INTEGER${key ? ' PRIMARY KEY' : ''}',
        );

  @override
  int? _decode(int? t) => t;

  @override
  int? _encode(int? d) => d;
}

class ColStr extends Col<String, String> {
  ColStr({
    required super.name,
    bool key = false,
  }) : super(
          type: 'TEXT${key ? ' PRIMARY KEY' : ''}',
        );

  @override
  String? _decode(String? t) => t;

  @override
  String? _encode(String? d) => d;
}

class ColBool extends Col<bool, int> {
  ColBool({required super.name}) : super(type: 'INTEGER');

  @override
  bool? _decode(int? t) => t == null || t == 0 ? false : true;

  @override
  int? _encode(bool? d) => d == null || d == false ? 0 : 1;
}

class ColList<T> extends Col<List<T>, String> {
  ColList({required super.name}) : super(type: 'TEXT');

  @override
  List<T>? _decode(String? t) => t == null ? null : (jsonDecode(t) as List).map((e) => e as T).toList();

  @override
  String? _encode(List<T>? d) => d == null ? null : json.encode(d);
}

class ColNum extends Col<num, num> {
  ColNum({required super.name}) : super(type: 'REAL');

  @override
  num? _decode(num? t) => t;

  @override
  num? _encode(num? d) => d;
}

class ColByte extends Col<Uint8List, Uint8List> {
  ColByte({required super.name}) : super(type: 'BLOB');

  @override
  Uint8List? _decode(Uint8List? t) => t;

  @override
  Uint8List? _encode(Uint8List? d) => d;
}
