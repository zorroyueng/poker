import 'package:base/base.dart';
import 'package:poker/base/db.dart';
import 'package:poker/base/db_table_base.dart';
import 'package:sqflite/sqflite.dart';

abstract class Table extends TableBase {
  /// read
  Future<List<Map<String, Object?>>> query({
    Transaction? txn,
    List<Col>? columns,
    String? where,
    String? groupBy,
    String? orderBy,
  }) {
    String sql = _joinSelect(
      select: 'SELECT ${_connect(this, columns)}',
      from: tName(),
      where: where,
      groupBy: groupBy,
      orderBy: orderBy,
    );
    HpDevice.log(sql);
    return txn != null ? txn.rawQuery(sql) : Db.rawQuery(sql);
  }

  Future<List<Map<String, Object?>>> innerJoin({
    Transaction? txn,
    required Table join,
    List<Col>? cols,
    List<Col>? joinCols,
    required Col key,
    required Col joinKey,
    String? where,
    String? groupBy,
    String? orderBy,
  }) {
    String sql = _joinSelect(
      select: 'SELECT ${_connect(this, cols)},${_connect(join, joinCols)}',
      from: tName(),
      join: ' INNER JOIN ${join.tName()} ON ${key.name}=${joinKey.name}',
      where: where,
      groupBy: groupBy,
      orderBy: orderBy,
    );
    HpDevice.log(sql);
    return txn != null ? txn.rawQuery(sql) : Db.rawQuery(sql);
  }

  Future<int> count({
    Transaction? txn,
    Map<String, Object?>? map,
    Col? col,
  }) async {
    String sql = _joinSelect(
      select: 'SELECT COUNT(*)',
      from: tName(),
      where: map != null && col != null ? _equal(map, col.name) : null,
    );
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
  }) async {
    List<Map<String, Object?>> lst = await query(
      txn: txn,
      where: _equal(map, col.name),
    );
    if (lst.isEmpty) {
      return await insert(txn: txn, map: map);
    } else {
      // map中有key的值，要和db中完全一致
      bool needUpdate = false;
      for (String k in map.keys) {
        if (map[k] != lst[0][k]) {
          needUpdate = true;
          break;
        }
      }
      if (needUpdate) {
        return await update(txn: txn, map: map, col: col);
      } else {
        return 0;
      }
    }
  }

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

  String _joinSelect({
    required String select,
    required String from,
    String? join,
    String? where,
    String? groupBy,
    String? orderBy,
  }) {
    select += ' FROM $from';
    if (join != null) {
      select += join;
    }
    if (where != null) {
      select += ' WHERE $where';
    }
    if (groupBy != null) {
      select += ' GROUP BY $groupBy';
    }
    if (orderBy != null) {
      select += ' ORDER BY $orderBy';
    }
    return select;
  }

  String _connect(TableBase table, List<Col>? columns) {
    String connect = '';
    if (columns != null && columns.isNotEmpty) {
      for (Col c in columns) {
        if (connect.isNotEmpty) {
          connect += ',';
        }
        connect += c.name;
      }
    } else {
      connect = '${table.tName()}.*';
    }
    return connect;
  }
}
