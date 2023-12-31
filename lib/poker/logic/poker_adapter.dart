import 'dart:math';

import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/poker/config.dart';
import 'package:poker/poker/logic/poker_card.dart';

abstract class PokerAdapter<T> {
  AdapterView? _view;
  final List<T> _lstData = [];
  final List<T> _lstTemp = [];
  int _firstIndex = 0;
  final List<PokerItem> items = [];
  final Map<Object, PokerItem> _cache = {};
  PokerItem? _updatePercentItem; // 最新操作的item，计算滑动percent
  PokerItem? _swipingItem; // 正在相应手势的item，为屏蔽多指触摸使用
  final Percent _percentX = Percent(0);
  final Percent _percentY = Percent(0);
  final Map<Object, Offset> _mapPosition = {};
  final Broadcast update = Broadcast(null);

  /// interface
  Object id(T t);

  Widget item(T t, Size imgSize, Percent percent);

  void onPreload(T t, Size imgSize, int index, int total); // 预加载t；还剩下几个数据

  bool canSwipe(T t, SwipeType type); // 判断卡片是否可以执行操作

  bool canUndo(T t);

  Widget onLoading(); // 没有卡片时展示的loading动画

  /// definition
  Broadcast<double> percentX() => _percentX;

  Broadcast<double> percentY() => _percentY;

  PokerItem? _canSwipe() {
    PokerItem? can;
    if (_swipingItem == null) {
      for (int i = items.length - 1; i >= 0; i--) {
        PokerItem item = items[i];
        if (item.card != null && item.card!.dif == Offset.zero && item.percent.value() == 1) {
          can = item;
          break;
        }
      }
    }
    return can;
  }

  // 提供给undo使用，需要在idle状态撤回卡片
  bool _isIdle() {
    bool isIdle = true;
    for (PokerItem item in items) {
      if (item.card != null && item.card!.dif != Offset.zero) {
        isIdle = false;
        break;
      }
    }
    return isIdle;
  }

  bool swipe(SwipeType type) {
    bool can = false;
    PokerItem? item = _canSwipe();
    if (item != null && canSwipe(item.data, type)) {
      item.card!.onPanDown(Offset.zero);
      onPanDown(item);
      _swipingItem = null;
      double vX = 0;
      double vY = 0;
      switch (type) {
        case SwipeType.right:
          vX = Config.maxSwipeV;
          break;
        case SwipeType.left:
          vX = -Config.maxSwipeV;
          break;
        case SwipeType.up:
          vY = -Config.maxSwipeV;
          break;
      }
      item.card!.animTo(type, vX, vY, Curves.easeIn);
      can = true;
    }
    return can;
  }

  bool undo() {
    bool can = false;
    if (_isIdle()) {
      int current = _firstIndex - 1;
      if (current >= 0 && current < _lstData.length) {
        if (canUndo(_lstData[current])) {
          _firstIndex = current;
          _buildItems(from: _firstIndex, to: _firstIndex + Config.idleCardNum);
          PokerItem item = items[items.length - 1];
          item.difK = _mapPosition[id(item.data)];
          _updatePercentItem = item;
          update.add(null);
          //需要设置back卡片初始percent，因为top卡片后画，会先绘制出percent为0的情况
          int nextIndex = items.length - 2;
          if (nextIndex >= 0) {
            items[nextIndex].percent.add(1);
          }
          can = true;
        }
      }
    }
    return can;
  }

  void setView(AdapterView view) {
    bool first = _view == null;
    bool change = _view != view;
    if (change) {
      _view = view;
      if (first) {
        setData(_lstTemp);
        _lstTemp.clear();
      } else {
        update.add(null);
      }
    }
  }

  void setData(List<T> lst) {
    if (_view == null) {
      _lstTemp.clear();
      _lstTemp.addAll(lst);
    } else {
      _cache.clear();
      _lstData.clear();
      _lstData.addAll(lst);
      _firstIndex = 0;
      _buildItems(from: _firstIndex, to: _firstIndex + Config.idleCardNum - 1);
      for (int i = items.length - 1; i >= 0; i--) {
        PokerItem item = items[i];
        Offset difK = Offset(
          (Random().nextDouble() >= .5 ? 1 : -1) * Random().nextDouble(),
          (Random().nextDouble() >= .5 ? 1 : -1) * Random().nextDouble(),
        );
        item.difK = difK;
      }
      update.add(null);
      _updatePercentItem = items.isEmpty ? null : items[0];
      _swipingItem = null;
      _updatePercentItem = null;
      _mapPosition.clear();
    }
  }

  void updateData(T t) {}

  void insertData(T t) {}

  // 需要在静止状态执行此函数，保证current正确赋值percent
  void _buildItems({required int from, required int to}) {
    items.clear();
    for (int i = from; i <= to; i++) {
      PokerItem? w = _obtainItem(i);
      if (w != null) {
        if (i == from) {
          w.percent.add(1);
        } else if (_swipingItem == null) {
          // 非触摸状态下，更新back的percent
          w.percent.add(0);
        }
        items.insert(0, w);
      } else {
        break;
      }
    }
    _preload(to + 1, to + Config.preloadNum);
  }

  void _preload(int from, int to) {
    for (int i = from; i <= min(to, _lstData.length - 1); i++) {
      onPreload(_lstData[i], _view!.cardSize(), i, _lstData.length);
    }
  }

  int _itemIndex(PokerItem item) => items.indexWhere((e) => e.key == item.key);

  void onPanDown(PokerItem item) {
    _updatePercentItem = item;
    _swipingItem = item;
    int indexItem = _itemIndex(item); // 屏幕点击在_items序列中的index，当前为_items.length - 1
    int indexData = _firstIndex + (items.length - 1 - indexItem);
    int prepareIndex = indexData + Config.idleCardNum;
    _buildItems(from: _firstIndex, to: prepareIndex);
    item.percent.add(1); // 被滑动的card强制percent为1，解决在back状态下被操作
    update.add(null);
  }

  void onPanEnd() => _swipingItem = null;

  PokerItem? swipingItem() => _swipingItem;

  bool isCurrentSwipeItem(PokerItem item) => item == _updatePercentItem;

  void swipePercent(double pX, double pY) {
    if (pY.abs() >= pX.abs()) {
      _percentX.add(0);
      double y = pY.abs() - pX.abs();
      if (_swipingItem == null) {
        if (y > 1 && y < Config.maxIconPercent) {
          y = Config.maxIconPercent - y;
        } else if (y >= Config.maxIconPercent) {
          y = 0;
        }
      }
      _percentY.add((pY > 0 ? 1 : -1) * min(1, y));
    } else {
      double x = pX.abs() - pY.abs();
      if (_swipingItem == null) {
        if (x > 1 && x < Config.maxIconPercent) {
          x = Config.maxIconPercent - x;
        } else if (x >= Config.maxIconPercent) {
          x = 0;
        }
      }
      _percentX.add((pX > 0 ? 1 : -1) * min(1, x));
      _percentY.add(0);
    }
    int index = _itemIndex(_updatePercentItem!);
    // next3
    int next = index - 1;
    for (int i = next; i >= 0; i--) {
      PokerItem item = items[i];
      if (i == next) {
        item.percent.add(Curves.decelerate.transform(min(1, max(pX.abs(), pY.abs()))));
      } else {
        item.percent.add(0);
      }
    }
  }

  PokerItem? _obtainItem(int index) {
    if (index < _lstData.length && index >= 0) {
      T t = _lstData[index];
      Object key = id(t);
      PokerItem? w = _cache[key];
      if (w == null) {
        Percent percent = Percent(0, space: 0);
        w = PokerItem(
          key: key,
          data: t,
          item: item(t, _view!.cardSize(), percent),
          percent: percent,
        );
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

  bool toNext(PokerItem item, Offset dif) {
    _mapPosition[id(item.data)] = dif;
    if (item == _updatePercentItem) {
      _percentX.add(0);
      _percentY.add(0);
      _updatePercentItem = null;
    }
    // 将current向后移1位
    int current = _firstIndex + 1;
    if (current < _lstData.length) {
      _firstIndex = current;
      items.remove(item);
      update.add(null);
      return true;
    } else {
      items.remove(item);
      update.add(null);
      return false;
    }
  }
}

mixin AdapterView {
  Size pokerSize();

  Size cardSize();

  Rect cardRect();
}

class PokerItem<T> {
  final Object key;
  final T data;
  final Widget item;

  final Percent percent; // 0 为back状态，1为展示状态
  Offset? difK;
  PokerCardState? card;

  PokerItem({required this.key, required this.data, required this.item, required this.percent});
}

enum SwipeType {
  right,
  left,
  up,
}
