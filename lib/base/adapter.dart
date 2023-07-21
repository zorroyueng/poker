import 'dart:async';

import 'package:base/base.dart';
import 'package:flutter/cupertino.dart';

/// ui data => ui widget
abstract class Adapter<T extends Data> {
  final DataProvider<T> _dataProvider;
  final List<T> _data = [];
  final Broadcast<void> _ui = Broadcast(null);

  Adapter(this._dataProvider) {
    // todo dispose
    StreamSubscription sub = _dataProvider._data.stream().distinct().listen((lst) => setData(lst));
    _dataProvider.loadData();
  }

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
abstract class DataProvider<T> {
  final int pageLimit;
  int currentIndex = 0;
  final Broadcast<List<T>> _data = Broadcast([]);

  DataProvider({this.pageLimit = 0});

  T toUiData(Map<String, Object?> map);

  Future<List<T>> getData(int? limit);

  void loadData() {
    int? limit = pageLimit > 0 ? currentIndex + pageLimit : null;
    getData(limit).then(
      (lst) {
        currentIndex = lst.length;
        _data.add(lst);
      },
    ).onError(
      (error, stackTrace) {},
    );
  }
}
