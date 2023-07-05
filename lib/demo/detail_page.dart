import 'package:base/base.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/demo_adapter.dart';
import 'package:poker/demo/demo_helper.dart';

class DetailPage extends StatelessWidget {
  final DetailInfo info;

  const DetailPage({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    ScrollController s = ScrollController();
    return Scaffold(
      body: SafeArea(
        child: Common.scrollbar(
          ctx: context,
          controller: s,
          child: CustomScrollView(
            controller: s,
            slivers: [
              SliverAppBar(
                leading: const BackButton(color: Colors.white),
                pinned: true,
                stretch: true,
                backgroundColor: Colors.white,
                expandedHeight: HpDevice.screenMin(context),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(info.data.name, style: Common.textStyle(context)),
                  centerTitle: false,
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
                            Text(DemoHelper.name[i],
                                style: Common.textStyle(
                                  context,
                                  color: Colors.black,
                                )),
                            Text(DemoHelper.relaxed[i],
                                style: Common.textStyle(
                                  context,
                                  color: Colors.grey,
                                )),
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
