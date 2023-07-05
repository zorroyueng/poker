import 'package:base/base.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/demo_adapter.dart';
import 'package:poker/demo/demo_helper.dart';

class DetailPage extends StatelessWidget {
  final DetailInfo info;
  final ScrollController scrollCtrl = ScrollController();
  final Broadcast<double> barCtrl = Broadcast(0);
  VoidCallback? changeBar;

  DetailPage({super.key, required this.info});

  void _bind(BuildContext context, double h) {
    if (changeBar != null) {
      scrollCtrl.removeListener(changeBar!);
    }
    changeBar = () {
      double max = h - kToolbarHeight;
      if (scrollCtrl.offset >= max) {
        barCtrl.add(1);
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
                leading: const BackButton(color: Colors.white),
                pinned: true,
                stretch: true,
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                    ),
                  ),
                ],
                backgroundColor: Colors.white,
                expandedHeight: h,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],
                  titlePadding: const EdgeInsets.all(0),
                  title: StreamWidget<double>(
                    stream: barCtrl.stream().distinct(),
                    initialData: barCtrl.value(),
                    builder: (_, snap, ___) => Container(
                      width: double.infinity,
                      height: kToolbarHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(0, 1),
                          end: const Alignment(0, -1),
                          colors: [
                            Colors.black.withOpacity(snap.data!),
                            Colors.transparent,
                          ],
                          stops: [
                            snap.data!,
                            1,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          info.data.name,
                          style: Common.textStyle(
                            context,
                            scale: 1.2,
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  background: Hero(
                    tag: info.data.id,
                    child: Container(
                      clipBehavior: Clip.none,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                            info.data.url,
                            maxWidth: info.w,
                            maxHeight: info.h,
                          ),
                          filterQuality: FilterQuality.low,
                          // isAntiAlias: true,
                        ),
                      ),
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
                        bgColor: Colors.white,
                        borderColor: Colors.grey.withOpacity(.2),
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
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              DemoHelper.relaxed[i],
                              style: Common.textStyle(
                                context,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
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
