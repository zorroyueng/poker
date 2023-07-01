import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poker/poker/base/broadcast.dart';
import 'package:poker/poker/poker_config.dart';

abstract class PokerAdapter<T> {
  AdapterView? _view;
  final List<T> _data = [];
  int _firstIndex = 0;
  final List<PokerItem> _items = [];
  final Map<Object, PokerItem> _cache = {};
  PokerItem? _currentSwipeItem;

  /// interface
  Object id(T t);

  Widget item(T t);

  void onPreload(T t);

  /// definition
  void setView(AdapterView view) {
    _view = view;
    _view!.update(_items);
    _preload(_firstIndex, _firstIndex + PokerConfig.idleCardNum + 3);
  }

  void setData(List<T> lst) {
    _data.clear();
    _data.addAll(lst);
    _firstIndex = 0;
    _buildItems(from: _firstIndex, to: _firstIndex + PokerConfig.idleCardNum - 1);
    if (_view != null) {
      _view!.update(_items);
    }
    _currentSwipeItem = _items.isEmpty ? null : _items[0];
  }

  void update(T t) {}

  void insert(T t) {}

  // 需要在静止状态执行此函数，保证current正确赋值percent
  void _buildItems({required int from, required int to}) {
    _items.clear();
    for (int i = from; i <= to; i++) {
      PokerItem? w = _obtainItem(i);
      if (w != null) {
        if (i == from) {
          w.percent.add(1);
        }
        _items.insert(0, w);
      } else {
        break;
      }
    }
    if (_view != null) {
      _preload(to + 1, to + 3);
    }
  }

  void _preload(int from, int to) {
    for (int i = from; i < min(to, _data.length); i++) {
      onPreload(_data[i]);
    }
  }

  int _itemIndex(PokerItem item) => _items.indexWhere((e) => e.key == item.key);

  void onPanDown(PokerItem item) {
    _currentSwipeItem = item;
    int indexItem = _itemIndex(item); // 屏幕点击在_items序列中的index，当前为_items.length - 1
    int indexData = _firstIndex + (_items.length - 1 - indexItem);
    int prepareIndex = indexData + PokerConfig.idleCardNum;
    _buildItems(from: _firstIndex, to: prepareIndex);
    _view!.update(_items);
  }

  bool isCurrentSwipeItem(PokerItem item) => item == _currentSwipeItem;

  void swipePercent(double pX, double pY) {
    int index = _itemIndex(_currentSwipeItem!);
    // next
    int next = index - 1;
    for (int i = next; i >= 0; i--) {
      PokerItem item = _items[i];
      if (i == next) {
        item.percent.add(Curves.decelerate.transform(max(pX, pY)));
      } else {
        item.percent.add(0);
      }
    }
  }

  PokerItem? _obtainItem(int index) {
    if (index < _data.length && index >= 0) {
      T t = _data[index];
      Object key = id(t);
      PokerItem? w = _cache[key];
      if (w == null) {
        w = PokerItem(key, item(t));
        if (_cache.length >= 10) {
          _cache.remove(_cache.keys.first);
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
    int current = _firstIndex + 1;
    if (current < _data.length) {
      _firstIndex = current;
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
    int current = _firstIndex - 1;
    if (current >= 0 && _data.isNotEmpty) {
      _firstIndex = current;
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

  // 0 为back状态，1为展示状态
  final Broadcast<double> percent = Broadcast(0);

  PokerItem(this.key, this.child);
}
