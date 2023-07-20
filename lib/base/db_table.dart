import 'package:base/base.dart';
import 'package:poker/base/db.dart';
import 'package:poker/base/db_table_mixin.dart';
import 'package:sqflite/sqflite.dart';

abstract class Table with TableMixin {
  /// read
  Future<List<Map<String, Object?>>> query({
    Transaction? txn,
    List<String>? columns,
  }) {
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
    return txn != null ? txn.rawQuery(sql) : Db.rawQuery(sql);
  }

  Future<List<Map<String, Object?>>> innerJoin({
    Transaction? txn,
    required Table join,
    List<String>? cols,
    List<String>? joinCols,
    required Col key,
    required Col joinKey,
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

    String sql = 'SELECT ${select(this, cols)},${select(join, joinCols)} FROM ${tName()} '
        'INNER JOIN ${join.tName()} '
        'ON ${tName()}.${key.name}=${join.tName()}.${joinKey.name}';
    HpDevice.log(sql);
    return txn != null ? txn.rawQuery(sql) : Db.rawQuery(sql);
  }

  Future<int> count({
    Transaction? txn,
    Map<String, Object?>? map,
    Col? col,
  }) async {
    String sql = 'SELECT COUNT(*) FROM ${tName()}';
    if (map != null && col != null) {
      sql += ' WHERE ${_equal(map, col.name)}';
    }
    List<Map<String, Object?>> lst = await (txn != null ? txn.rawQuery(sql) : Db.rawQuery(sql));
    return Sqflite.firstIntValue(lst) ?? 0;
  }

  /// write
  Future<int> insert({
    required Transaction txn,
    required Map<String, Object?> map,
  }) {
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

  Future<int> upsert({
    required Transaction txn,
    required Map<String, Object?> map,
    required Col col,
  }) =>
      count(
        txn: txn,
        map: map,
        col: col,
      ).then((n) => n == 0
          ? insert(
              txn: txn,
              map: map,
            )
          : update(
              txn: txn,
              map: map,
              col: col,
            ));

  Future<int> update({
    required Transaction txn,
    required Map<String, Object?> map,
    required Col col,
  }) {
    String set = '';
    String where = '';
    for (String k in map.keys) {
      if (k == col.name) {
        where = _equal(map, k);
      } else {
        if (set.isNotEmpty) {
          set += ',';
        }
        set += _equal(map, k);
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
      List<Col> columns = tColumns();
      for (Col c in columns) {
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

  Future<void> modifyColumn({
    required Database db,
    required bool add,
    required Col col,
  }) =>
      add
          ? db.execute('ALTER TABLE ${tName()} ADD COLUMN ${col.name} ${col.type}')
          : db.execute('ALTER TABLE ${tName()} DROP COLUMN ${col.name}');

  Future<void> dropTable(Database db) => db.execute('DROP TABLE ${tName()}');

  // tool
  String _equal(Map<String, Object?> map, String key) {
    Object? value = map[key];
    if (value is String) {
      return '$key=\'$value\'';
    } else {
      return '$key=$value';
    }
  }
}
