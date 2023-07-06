import 'dart:math';

import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/demo_adapter.dart';
import 'package:poker/demo/demo_helper.dart';

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

  @override
  Widget build(BuildContext context) {
    double h = HpDevice.screenMin(context);
    _bind(context, h);
    return Scaffold(
      body: SafeArea(
        child: Common.scrollbar(
          ctx: context,
          controller: scrollCtrl,
          child: CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              SliverAppBar(
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
                  title: PercentWidget(
                    percent: barCtrl,
                    builder: (_, v, ___) => Container(
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
                          child: Text(
                            info.data.name,
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
                  background: Hero(
                    tag: info.data.id,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorProvider.itemBg(),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Common.netImage(
                        url: info.data.url,
                        w: info.w,
                        h: info.h,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    info.data.name,
                    style: Common.textStyle(
                      context,
                      scale: 1.5,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverList(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailInfo {
  final DemoData data;
  final int w;
  final int h;

  DetailInfo({
    required this.data,
    required this.w,
    required this.h,
  });
}
