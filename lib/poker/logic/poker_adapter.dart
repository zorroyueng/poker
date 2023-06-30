import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poker/poker/poker_config.dart';

abstract class PokerAdapter<T> {
  AdapterView? _view;
  final List<T> _data = [];
  int _current = 0;
  final List<PokerItem> _items = [];
  final Map<Object, PokerItem> _cache = {};
  PokerItem? _lastSwipeItem;

  /// interface
  Object id(T t);

  Widget item(T t);

  void onPreload(T t);

  /// definition
  void setView(AdapterView view) {
    _view = view;
    _view!.update(_items);
    _preload(_current, _current + PokerConfig.idleCardNum + 3);
  }

  void setData(List<T> lst) {
    _data.clear();
    _data.addAll(lst);
    _current = 0;
    _lastSwipeItem = null;
    _items.clear();
    _buildWidgets(from: _current, to: _current + PokerConfig.idleCardNum - 1);
    if (_view != null) {
      _view!.update(_items);
    }
  }

  void update(T t) {}

  void insert(T t) {}

  // 需要在静止状态执行此函数，保证current正确赋值percent
  void _buildWidgets({required int from, required int to}) {
    for (int i = from; i <= to; i++) {
      PokerItem? w = _obtainItem(i);
      if (w != null) {
        if (i == from) {
          w.percent = 1;
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
    _lastSwipeItem = item;
    int indexItem = _itemIndex(item); // 屏幕点击在_items序列中的index，当前为_items.length - 1
    int indexData = _current + (_items.length - 1 - indexItem);
    int prepareIndex = indexData + PokerConfig.idleCardNum;
    _items.clear();
    _buildWidgets(from: _current, to: prepareIndex);
    _view!.update(_items);
  }

  bool hasLastSwipeItem() => _lastSwipeItem != null;

  bool isLastSwipeItem(PokerItem item) => item == _lastSwipeItem;

  void swipePercent(double pX, double pY) {
    int index = _itemIndex(_lastSwipeItem!);
    // next
    if (index - 1 >= 0) {
      PokerItem next = _items[index - 1];
      double percent = Curves.decelerate.transform(max(pX, pY));
      if (percent != next.percent) {
        next.percent = percent;
        next.update!.call();
      }
    }
    // afterNext
    // if (index - 2 >= 0) {
    //   PokerItem afterNext = _items[index - 2];
    //   double percent = Curves.decelerate.transform(max(pX, pY));
    //   if (percent != afterNext.percent) {
    //     afterNext.percent = percent;
    //     afterNext.update!.call();
    //   }
    // }
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
  double percent = 0; // 0 为back状态，1为展示状态
  void Function()? update;

  PokerItem(this.key, this.child);
}
