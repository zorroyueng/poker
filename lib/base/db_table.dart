import 'package:base/base.dart';
import 'package:poker/base/db.dart';
import 'package:poker/base/db_table_mixin.dart';
import 'package:sqflite/sqflite.dart';

abstract class Table with TableMixin {
  /// read
  Future<List<Map<String, Object?>>> query({List<String>? columns}) {
    select(TableMixin table, List<String>? columns) {
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
    return Db.rawQuery(sql);
  }

  Future<List<Map<String, Object?>>> innerJoin({
    List<String>? cols,
    required Table other,
    List<String>? otherCols,
    required Col col,
    required Col otherCol,
  }) {
    select(TableMixin table, List<String>? columns) {
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
    return Db.rawQuery(sql);
  }

  Future<int> count(Transaction txn, Map<String, Object?> map, Col col) async {
    String sql = 'SELECT COUNT(*) FROM ${tName()} '
        'WHERE ${_join(map, col.name)}';
    return Sqflite.firstIntValue(await txn.rawQuery(sql)) ?? 0;
  }

  /// write
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

  /// structure
  Future<void> createTable(Database db) {
    List<String> lst = () {
      List<String> lst = [];
      for (Col c in tColumns()) {
        lst.add('${c.name} ${c.type}');
      }
      return lst;
    }();
    String sql = () {
      String sql = 'CREATE TABLE ${tName()} (';
      for (String s in lst) {
        sql += s;
        if (s != lst.last) {
          sql += ',';
        }
      }
      sql += ')';
      return sql;
    }();
    HpDevice.log(sql);
    return db.execute(sql);
  }

  Future<void> addColumn(Database db, String name, String s) => db.execute('ALTER TABLE $name ADD COLUMN $s');

  Future<void> dropTable(Database db, String name) => db.execute('DROP TABLE  $name');

  // tool
  String _join(Map<String, Object?> map, String key) {
    Object? value = map[key];
    if (value is String) {
      return '$key=\'$value\'';
    } else {
      return '$key=$value';
    }
  }
}
