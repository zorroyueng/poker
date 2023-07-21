import 'dart:async';

import 'package:base/base.dart';
import 'package:flutter/cupertino.dart';

/// ui data => ui widget
abstract class Adapter<T extends Data> {
  late final DataProvider<T> _dataProvider;
  final List<T> _data = [];
  final Broadcast<void> _ui = Broadcast(null);

  Adapter() {
    _dataProvider = provider();
    _dataProvider.loadData();
  }

  DataProvider<T> provider();

  void dispose() => _dataProvider.dispose();

  void setData(List<T> lst) => addData(lst, false);

  void addData(List<T> lst, [bool join = true]) {
    if (!join) {
      _data.clear();
    }
    _data.addAll(lst);
    _ui.add(null);
  }

  int get length => _data.length;

  T data(int i) => _data[i];

  Stream<void> get stream => _ui.stream();
}

abstract class Data {
  Object key();

  Widget widget(BuildContext c);
}

/// net||db data => ui data
abstract class DataProvider<T extends Data> {
  final int pageLimit;
  final Broadcast<List<T>> _data = Broadcast([]);
  final List<StreamSubscription> subs = [];

  DataProvider({
    required Adapter<T> adapter,
    required this.pageLimit,
    required List<Stream> streams,
  }) {
    subs.add(_data.stream().distinct().listen((lst) => adapter.setData(lst)));
    for (Stream s in streams) {
      subs.add(s.listen((_) => loadData(more: false)));
    }
  }

  Future<List<T>> getData(int? limit);

  void loadData({bool more = true}) {
    int? limit = pageLimit > 0 ? _data.value().length + (more ? pageLimit : 0) : null;
    getData(limit).then((lst) => _data.add(lst)).onError((error, stackTrace) {});
  }

  void dispose() {
    for (var s in subs) {
      s.cancel();
    }
  }
}
