import 'dart:convert';
import 'dart:typed_data';

abstract class TableBase {
  String tName();

  List<Col> tColumns();

  String _t(String name) => '${tName()}_$name';

  ColInt colInt(String name, [bool key = false]) => ColInt._(_t(name), key);

  ColStr colStr(String name, [bool key = false]) => ColStr._(_t(name), key);

  ColBool colBool(String name) => ColBool._(_t(name));

  ColByte colByte(String name) => ColByte._(_t(name));

  ColNum colNum(String name) => ColNum._(_t(name));

  ColList<T> colList<T>(String name) => ColList<T>._(_t(name));

  ColTime colTime(String name) => ColTime._(_t(name));
}

abstract class Col<D, T> {
  final String name;
  final String type;

  Col({required this.name, required this.type}) {
    assert(name.split('_').length == 2);
  }

  T? _encode(D? d);

  D? _decode(T? t);

  void put(Map<String, Object?> map, D? d) => map[name] = _encode(d);

  D? get(Map<String, Object?> map) => _decode(map[name] as T?);

  @override
  String toString() => name;
}

class ColInt extends Col<int, int> {
  ColInt._(String name, [bool key = false])
      : super(
          name: name,
          type: 'INTEGER${key ? ' PRIMARY KEY' : ''}',
        );

  @override
  int? _decode(int? t) => t;

  @override
  int? _encode(int? d) => d;

  ColInt max() => ColInt._('MAX($name)');
}

class ColStr extends Col<String, String> {
  ColStr._(String name, [bool key = false])
      : super(
          name: name,
          type: 'TEXT${key ? ' PRIMARY KEY' : ''}',
        );

  @override
  String? _decode(String? t) => t;

  @override
  String? _encode(String? d) => d;
}

class ColBool extends Col<bool, int> {
  ColBool._(String name) : super(name: name, type: 'INTEGER');

  @override
  bool? _decode(int? t) => t == null || t == 0 ? false : true;

  @override
  int? _encode(bool? d) => d == null || d == false ? 0 : 1;
}

class ColList<T> extends Col<List<T>, String> {
  ColList._(String name) : super(name: name, type: 'TEXT');

  @override
  List<T>? _decode(String? t) => t == null ? null : (jsonDecode(t) as List).map((e) => e as T).toList();

  @override
  String? _encode(List<T>? d) => d == null ? null : json.encode(d);
}

class ColNum extends Col<num, num> {
  ColNum._(String name) : super(name: name, type: 'REAL');

  @override
  num? _decode(num? t) => t;

  @override
  num? _encode(num? d) => d;

  ColNum max() => ColNum._('MAX($name)');
}

class ColByte extends Col<Uint8List, Uint8List> {
  ColByte._(String name) : super(name: name, type: 'BLOB');

  @override
  Uint8List? _decode(Uint8List? t) => t;

  @override
  Uint8List? _encode(Uint8List? d) => d;
}

class ColTime extends Col<DateTime, int> {
  ColTime._(String name) : super(name: name, type: 'INTEGER');

  @override
  DateTime? _decode(int? t) => t == null ? null : DateTime.fromMillisecondsSinceEpoch(t);

  @override
  int? _encode(DateTime? d) => d?.millisecondsSinceEpoch;

  ColTime max() => ColTime._('max($name)');

  ColTime min() => ColTime._('min($name)');

  ColTime avg() => ColTime._('avg($name)');
}
