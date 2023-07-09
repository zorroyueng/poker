import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:poker/demo/demo_item_mixin.dart';
import 'package:poker/poker/logic/poker_adapter.dart';

class DemoAdapter extends PokerAdapter<DemoData> with DemoItemMixin {
  late final Widget _loading = GestureDetector(
    onTap: () => setData(DemoHelper.data()),
    child: ThemeWidget(
      builder: (_,__) => const Center(child: CircularProgressIndicator()),
    ),
  );

  @override
  Widget item(DemoData t, Size imgSize, Percent percent) => build(this, t, imgSize, percent);

  @override
  Object id(DemoData t) => t.id;

  @override
  bool canSwipe(DemoData t, SwipeType type) => true;

  @override
  Widget onLoading() => _loading;

  @override
  bool canUndo(DemoData t) => true;
}

class DemoData {
  final int id;
  final List<String> urls;
  final String name;

  DemoData({required this.id, required this.name, required this.urls});
}
