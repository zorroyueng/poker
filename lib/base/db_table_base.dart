import 'dart:convert';
import 'dart:typed_data';

import 'package:base/base.dart';

abstract class TableBase {
  Broadcast<Map<String, Object?>> broadcast = Broadcast({});

  String tName();

  List<Col> tColumns();

  String _t(String name) => '${tName()}_$name';

  ColInt colInt(String name, {bool key = false, int? dValue}) => ColInt._(_t(name), key: key, dValue: dValue);

  ColStr colStr(String name, {bool key = false, String? dValue}) => ColStr._(_t(name), key: key, dValue: dValue);

  ColBool colBool(String name, {bool? dValue}) => ColBool._(_t(name), dValue: dValue);

  ColByte colByte(String name, {Uint8List? dValue}) => ColByte._(_t(name), dValue: dValue);

  ColNum colNum(String name, {num? dValue}) => ColNum._(_t(name), dValue: dValue);

  ColList<T> colList<T>(String name, {List<T>? dValue}) => ColList<T>._(_t(name), dValue: dValue);

  ColTime colTime(String name, {DateTime? dValue}) => ColTime._(_t(name), dValue: dValue);
}

abstract class Col<D, T> {
  final String name;
  final String type;
  final D? dValue;

  Col({required this.name, required this.type, this.dValue}) {
    assert(name.split('_').length == 2);
  }

  T? _encode(D? d);

  D? _decode(T? t);

  void put(Map<String, Object?> map, D? d) => map[name] = _encode(d);

  D? get(Map<String, Object?> map) => getDb(map) ?? dValue;

  D? getDb(Map<String, Object?> map) => _decode(map[name] as T?);

  @override
  String toString() => name;
}

class ColInt extends Col<int, int> {
  ColInt._(
    String name, {
    bool key = false,
    int? dValue,
  }) : super(
          name: name,
          type: 'INTEGER${key ? ' PRIMARY KEY NOT NULL' : ''}',
          dValue: dValue,
        );

  @override
  int? _decode(int? t) => t;

  @override
  int? _encode(int? d) => d;

  ColInt max() => ColInt._('MAX($name)');
}

class ColStr extends Col<String, String> {
  ColStr._(
    String name, {
    bool key = false,
    String? dValue,
  }) : super(
          name: name,
          type: 'TEXT${key ? ' PRIMARY KEY NOT NULL' : ''}',
          dValue: dValue,
        );

  @override
  String? _decode(String? t) => t;

  @override
  String? _encode(String? d) => d;
}

class ColBool extends Col<bool, int> {
  ColBool._(String name, {bool? dValue})
      : super(
          name: name,
          type: 'INTEGER${dValue == null ? '' : ' NOT NULL'}',
          dValue: dValue,
        );

  @override
  bool? _decode(int? t) => t == null || t == 0 ? false : true;

  @override
  int? _encode(bool? d) => d == null || d == false ? 0 : 1;
}

class ColList<T> extends Col<List<T>, String> {
  ColList._(String name, {List<T>? dValue}) : super(name: name, type: 'TEXT', dValue: dValue);

  @override
  List<T>? _decode(String? t) => t == null ? null : (jsonDecode(t) as List).map((e) => e as T).toList();

  @override
  String? _encode(List<T>? d) => d == null ? null : json.encode(d);
}

class ColNum extends Col<num, num> {
  ColNum._(String name, {num? dValue}) : super(name: name, type: 'REAL', dValue: dValue);

  @override
  num? _decode(num? t) => t;

  @override
  num? _encode(num? d) => d;

  ColNum max() => ColNum._('MAX($name)');
}

class ColByte extends Col<Uint8List, Uint8List> {
  ColByte._(String name, {Uint8List? dValue}) : super(name: name, type: 'BLOB', dValue: dValue);

  @override
  Uint8List? _decode(Uint8List? t) => t;

  @override
  Uint8List? _encode(Uint8List? d) => d;
}

class ColTime extends Col<DateTime, int> {
  ColTime._(String name, {DateTime? dValue}) : super(name: name, type: 'INTEGER', dValue: dValue);

  @override
  DateTime? _decode(int? t) => t == null ? null : DateTime.fromMillisecondsSinceEpoch(t);

  @override
  int? _encode(DateTime? d) => d?.millisecondsSinceEpoch;

  ColTime max() => ColTime._('max($name)');

  ColTime min() => ColTime._('min($name)');

  ColTime avg() => ColTime._('avg($name)');
}
