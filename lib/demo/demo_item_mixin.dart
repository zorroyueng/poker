import 'package:base/base.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/demo_adapter.dart';
import 'package:poker/demo/detail_page.dart';

mixin DemoItemMixin {
  Widget build(DemoAdapter adapter, DemoData t, Size size) {
    Percent alpha = Percent(1);
    return LayoutBuilder(
      builder: (ctx, _) {
        double radius = Common.radius(ctx);
        return ThemeWidget(
          builder: (_) => Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Hero(
                  tag: t.id,
                  child: Container(
                    decoration: Common.roundRect(
                      ctx,
                      bgColor: ColorProvider.itemBg(),
                    ),
                    child: Common.netImage(
                      url: t.url,
                      w: size.width.toInt(),
                      h: size.height.toInt(),
                      borderRadius: BorderRadius.circular(radius),
                    ),
                  ),
                ),
              ),
              // 露出border
              Positioned(
                left: 1,
                bottom: 1,
                right: 1,
                child: PercentWidget(
                  percent: alpha,
                  builder: (_, p, __) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(radius),
                        bottomRight: Radius.circular(radius),
                      ),
                      gradient: LinearGradient(
                        begin: const Alignment(0, 1),
                        end: const Alignment(0, -1),
                        colors: [Colors.black.withOpacity(.5 * p), Colors.transparent],
                        stops: const [.5, 1],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${t.name} ${t.id}',
                            maxLines: 1,
                            style: Common.textStyle(
                              ctx,
                              color: ColorProvider.base(p),
                              scale: 2,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            t.url,
                            maxLines: 3,
                            style: Common.textStyle(
                              ctx,
                              color: ColorProvider.base(.7 * p),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Common.click(
                  onTap: () {
                    DetailPage page = DetailPage(
                      info: DetailInfo(
                        data: t,
                        w: size.width.toInt(),
                        h: size.height.toInt(),
                      ),
                    );
                    bool send = false;
                    NavigatorObs.pushAlpha(
                      ctx,
                      page,
                      onEnter: (p) => adapter.pRoute.add(p),
                      onBack: (p) {
                        adapter.pRoute.add(p);
                        if (p == 0 && !send) {
                          alpha.add(0);
                          alpha.anim(1, ms: 200);
                          send = true;
                        }
                      },
                    );
                  },
                  r: BorderRadius.circular(radius),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void onPreload(DemoData t, Size size, int index, int total) {
    BuildContext? ctx = NavigatorObs.ctx();
    if (ctx != null) {
      precacheImage(
        CachedNetworkImageProvider(
          t.url,
          maxWidth: size.width.toInt(),
          maxHeight: size.height.toInt(),
        ),
        ctx,
      );
    } else {
      HpDevice.log('no ctx');
    }
  }
}
