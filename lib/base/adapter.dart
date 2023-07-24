import 'dart:async';

import 'package:base/base.dart';
import 'package:flutter/cupertino.dart';

/// join Provider & ui
class Adapter<P extends Provider<D>, D extends Data> {
  final P _dataProvider;
  final List<D> _data = [];
  final Broadcast<void> _ui = Broadcast(null);

  Adapter(this._dataProvider) {
    _dataProvider._init(onData: (lst) => setData(lst));
    load(more: true);
  }

  /// define
  void load({required bool more}) => _dataProvider.load(more: more);

  P get provider => _dataProvider;

  void dispose() => _dataProvider.dispose();

  void setData(List<D> lst) {
    _data.clear();
    _data.addAll(lst);
    _ui.add(null);
  }

  int get length => _data.length;

  Widget item(BuildContext c, int i) {
    D d = _data[i];
    Widget w = d.widget(c);
    assert(w.key == d.key());
    return w;
  }

  Stream<void> get trigger => _ui.stream();
}

/// ui data => ui widget
abstract class Data {
  ValueKey key();

  Widget widget(BuildContext c);
}

/// net||db data => ui data
abstract class Provider<T extends Data> {
  final Broadcast<List<T>> _data = Broadcast([]);
  final List<StreamSubscription> _subs = [];
  Future? _loading;

  /// define
  void _init({required void Function(List<T> lst) onData}) {
    _subs.add(_data.stream().distinct().listen((lst) => onData.call(lst)));
    List<Stream>? streams = triggers();
    if (streams != null) {
      for (Stream s in streams) {
        _subs.add(s.listen((_) => load(more: false)));
      }
    }
  }

  List<T> data() => _data.value();

  Future<void> load({required bool more}) async {
    if (_loading == null) {
      int from = more ? _data.value().length : 0;
      _loading = getData(
        from: from,
        limit: pageLimit(),
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
      return await _loading;
    } else {
      // todo
      return;
    }
  }

  void dispose() {
    for (var s in _subs) {
      s.cancel();
    }
  }

  /// interface
  List<Stream>? triggers();

  int? pageLimit();

  Future<List<T>> getData({int from = 0, int? limit});
}
