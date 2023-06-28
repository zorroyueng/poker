import 'package:flutter/material.dart';
import 'package:poker/poker/poker_config.dart';

abstract class PokerAdapter<T> {
  AdapterView? _view;
  final List<T> _data = [];
  int _current = 0;
  final List<PokerItem> _items = [];
  final Map<Object, PokerItem> _cache = {};

  /// interface
  Object id(T t);

  Widget item(T t);

  /// definition
  void setAdapter(AdapterView view) {
    _view = view;
    _view!.update(_items);
  }

  void setData(List<T> lst) {
    _data.clear();
    _data.addAll(lst);
    _current = 0;
    _items.clear();
    _buildWidgets(from: _current, to: _current + PokerConfig.idleCardNum - 1);
    if (_view != null) {
      _view!.update(_items);
    }
  }

  void update(T t) {}

  void insert(T t) {}

  void _buildWidgets({required int from, required int to}) {
    for (int i = from; i <= to; i++) {
      PokerItem? w = _obtainItem(i);
      if (w != null) {
        _items.insert(0, w);
      } else {
        break;
      }
    }
  }

  void prepareItem(PokerItem item) {
    int indexItem = _items.indexOf(item); // 屏幕点击在_items序列中的index，当前为_items.length - 1
    int indexData = _current + (_items.length - 1 - indexItem);
    int prepareIndex = indexData + PokerConfig.idleCardNum;
    _items.clear();
    _buildWidgets(from: _current, to: prepareIndex);
    _view!.update(_items);
  }

  PokerItem? _obtainItem(int index) {
    if (index < _data.length && index >= 0) {
      T t = _data[index];
      Object key = id(t);
      PokerItem? w = _cache[key];
      if (w == null) {
        w = PokerItem(key, item(t));
        if (_cache.length >= 10) {
          _cache.remove(_cache.keys.last);
        }
        _cache[key] = w;
      } else {
        // 更新w位置
        _cache.remove(key);
        _cache[key] = w;
      }
      return w;
    } else {
      return null;
    }
  }

  bool toNext(PokerItem item) {
    // 将current向后移1位
    int current = _current + 1;
    if (current < _data.length) {
      _current = current;
      _items.remove(item);
      _view!.update(_items);
      return true;
    } else {
      // todo
      _items.remove(item);
      _view!.update(_items);
      return false;
    }
  }

  bool toLast() {
    // 将current向前移1位
    int current = _current - 1;
    if (current >= 0 && _data.isNotEmpty) {
      _current = current;
      // todo
      return true;
    } else {
      return false;
    }
  }
}

mixin AdapterView {
  void update(List<PokerItem> widgets);
}

class PokerItem {
  final Object key;
  final Widget child;

  PokerItem(this.key, this.child);
}
