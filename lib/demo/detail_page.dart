import 'dart:math';

import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/demo_adapter.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:poker/demo/demo_item_cards.dart';

class DetailPage extends StatelessWidget {
  final DetailInfo info;
  final ScrollController scrollCtrl = ScrollController();
  final Percent barCtrl = Percent(0, space: 0);
  VoidCallback? changeBar;

  DetailPage({super.key, required this.info});

  void _bind(BuildContext context, double h) {
    if (changeBar != null) {
      scrollCtrl.removeListener(changeBar!);
    }
    changeBar = () {
      double max = h - kToolbarHeight;
      if (scrollCtrl.offset >= max) {
        if (scrollCtrl.offset >= h) {
          barCtrl.add(2);
        } else {
          barCtrl.add(1 + (scrollCtrl.offset - max) / kToolbarHeight);
        }
      } else {
        double limit = kToolbarHeight * .5;
        double zero = max - limit;
        if (scrollCtrl.offset <= zero) {
          barCtrl.add(0);
        } else {
          barCtrl.add((scrollCtrl.offset - zero) / limit);
        }
      }
    };
    scrollCtrl.addListener(changeBar!);
  }

  Widget _head(BuildContext context, double h) => SliverAppBar(
        leading: PercentWidget(
          percent: barCtrl,
          builder: (_, v, __) => BackButton(
            color: ColorTween(
              begin: ColorProvider.base(),
              end: ColorProvider.textColor(),
            ).lerp(max(0, v - 1)),
          ),
        ),
        pinned: true,
        stretch: true,
        elevation: 4,
        shadowColor: ColorProvider.itemBg(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: PercentWidget(
              percent: barCtrl,
              builder: (_, v, __) => Icon(
                Icons.more_horiz,
                color: ColorTween(
                  begin: ColorProvider.base(),
                  end: ColorProvider.textColor(),
                ).lerp(max(0, v - 1)),
              ),
            ),
          ),
        ],
        backgroundColor: ColorProvider.bg(),
        expandedHeight: h,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.all(0),
          title: IgnorePointer(
            child: PercentWidget(
              percent: barCtrl,
              builder: (_, v, ___) => Container(
                padding: const EdgeInsets.only(
                  left: kToolbarHeight / 2,
                  right: kToolbarHeight / 2,
                ),
                width: double.infinity,
                height: kToolbarHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(0, 1),
                    end: const Alignment(0, -1),
                    colors: [
                      ColorProvider.bg().withOpacity(min(1, v)),
                      Colors.transparent,
                    ],
                    stops: [
                      min(1, v),
                      1,
                    ],
                  ),
                ),
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, kToolbarHeight * (2 - v)),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        info.data.name,
                        maxLines: 1,
                        style: Common.textStyle(
                          context,
                          scale: 1.5,
                          alpha: Curves.easeIn.transform(max(0, v - 1)),
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          background: DemoItemCards(
            tag: info.data.id,
            urls: info.data.urls,
            index: info.index,
            imgSize: info.imgSize,
            hasRadius: false,
          ),
        ),
      );

  Widget _title(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Align(
            alignment: const Alignment(-1, 0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                info.data.name,
                maxLines: 1,
                style: Common.textStyle(
                  context,
                  scale: 1.5,
                ).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _tags(BuildContext context) {
    double d = Common.base(context, .2);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          spacing: d,
          runSpacing: d,
          children: List.generate(
            DemoHelper.name.length ~/ 3,
            (i) => Container(
              decoration: Common.roundRect(
                context,
                scale: .5,
                bgColor: ColorProvider.itemBg(),
              ),
              padding: EdgeInsets.all(d),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    DemoHelper.random(DemoHelper.icon),
                    color: ThemeProvider.currentColor(),
                  ),
                  SizedBox(width: d / 2),
                  Text(
                    DemoHelper.random(DemoHelper.name).split(',')[0].split(' ')[0],
                    style: Common.textStyle(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _details(BuildContext context) => SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: DemoHelper.name.length,
          (_, i) => Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: Common.roundRect(
                context,
                scale: .5,
                bgColor: ColorProvider.itemBg(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      DemoHelper.name[i],
                      style: Common.textStyle(
                        context,
                        color: ColorProvider.textColor(),
                      ),
                    ),
                    Text(
                      DemoHelper.relaxed[i],
                      style: Common.textStyle(
                        context,
                        alpha: .5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _quit({required BuildContext context, required Widget child}) {
    Offset? from;
    double w = HpDevice.screenMin(context) / 10;
    return GestureDetector(
      onPanDown: (d) {
        from = d.localPosition;
        if (from!.dx > w) {
          from = null;
        }
      },
      onPanUpdate: (d) {
        if (from != null) {
          if (d.localPosition.dx - from!.dx >= w && (d.localPosition.dy - from!.dy).abs() <= w) {
            Navigator.of(context).pop();
          }
        }
      },
      onPanEnd: (d) => from = null,
      onPanCancel: () => from = null,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    double h = HpDevice.screenMin(context);
    _bind(context, h);
    return Scaffold(
      body: SafeArea(
        child: _quit(
          context: context,
          child: Common.scrollbar(
            ctx: context,
            controller: scrollCtrl,
            child: CustomScrollView(
              controller: scrollCtrl,
              slivers: [
                _head(context, h),
                _title(context),
                _tags(context),
                _details(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailInfo {
  final DemoData data;
  final Size imgSize;
  final Broadcast<int> index;

  DetailInfo({
    required this.data,
    required this.imgSize,
    required this.index,
  });
}
