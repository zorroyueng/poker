import 'dart:async';

import 'package:base/base.dart';
import 'package:flutter/cupertino.dart';

/// ui data => ui widget
abstract class Adapter<P extends Provider<D>, D extends Data> {
  final P _dataProvider;
  final List<D> _data = [];
  final Broadcast<void> _ui = Broadcast(null);

  Adapter(this._dataProvider) {
    _dataProvider._init(this);
    loadData(more: true);
  }

  /// define
  void loadData({required bool more}) => _dataProvider.loadData(more: more);

  P provider() => _dataProvider;

  void dispose() => _dataProvider.dispose();

  void setData(List<D> lst) => addData(lst, false);

  void addData(List<D> lst, [bool join = true]) {
    if (!join) {
      _data.clear();
    }
    _data.addAll(lst);
    _ui.add(null);
  }

  int get length => _data.length;

  Widget item(BuildContext c, int i) {
    D d = _data[i];
    Widget w = widget(c, d);
    assert(w.key is ValueKey && (w.key as ValueKey).value == d.key());
    return w;
  }

  Stream<void> get trigger => _ui.stream();

  /// interface
  Widget widget(BuildContext c, D data);
}

abstract class Data {
  Object key();
}

/// net||db data => ui data
abstract class Provider<T extends Data> {
  final Broadcast<List<T>> _data = Broadcast([]);
  final List<StreamSubscription> _subs = [];
  Future? _loading;

  void _init(Adapter adapter) {
    _subs.add(_data.stream().distinct().listen((lst) => adapter.setData(lst)));
    List<Stream>? streams = triggers();
    if (streams != null) {
      for (Stream s in streams) {
        _subs.add(s.listen((_) => loadData(more: false)));
      }
    }
  }

  List<Stream>? triggers();

  int? pageLimit();

  Future<List<T>> getData(int from, int? to);

  List<T> data() => _data.value();

  void loadData({required bool more}) {
    if (_loading == null) {
      int from = more ? _data.value().length : 0;
      var limit = pageLimit();
      int? to = limit != null && limit > 0 ? _data.value().length + (more ? limit : 0) : null;
      _loading = getData(
        from,
        to,
      ).then(
        (lst) {
          _data.add(more ? _data.value() + lst : lst);
          _loading = null;
        },
      ).onError(
        (error, stackTrace) {
          _loading = null;
        },
      );
    }
  }

  void dispose() {
    for (var s in _subs) {
      s.cancel();
    }
  }
}
