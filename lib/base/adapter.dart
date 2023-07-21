import 'package:base/base.dart';
import 'package:flutter/cupertino.dart';

abstract class Adapter<T extends Data> {
  final List<T> _data = [];
  final Broadcast<void> _update = Broadcast(null);

  void setData(List<T> lst) => addData(lst, false);

  void addData(List<T> lst, [bool join = true]) {
    HpDevice.log('addData');
    if (!join) {
      _data.clear();
    }
    _data.addAll(lst);
    _update.add(null);
  }

  int get length => _data.length;

  T data(int i) => _data[i];
  
  get stream => _update.stream();
}

abstract class Data {
  Object key();

  Widget widget(BuildContext c);
}
