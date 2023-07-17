import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/demo/detail_page.dart';
import 'package:poker/demo/poker/adapter.dart';
import 'package:poker/demo/poker/adapter_item.dart';

mixin AdapterMixin {
  Widget build(Adapter adapter, DemoData t, Size imgSize, Percent percent) {
    Percent alpha = Percent(1);
    Broadcast<int> index = Broadcast(0);
    return ThemeWidget(
      builder: (ctx, child) {
        double radius = Common.radius(ctx);
        double padding = radius / 4;
        return AdapterItem(
          tag: t.id,
          urls: t.urls,
          index: index,
          imgSize: imgSize,
          percent: percent,
          bottom: Common.click(
            r: BorderRadius.only(
              bottomLeft: Radius.circular(radius),
              bottomRight: Radius.circular(radius),
            ),
            child: PercentWidget(
              percent: alpha,
              builder: (_, p, __) => Container(
                margin: EdgeInsets.all(padding),
                padding: EdgeInsets.only(
                  left: padding,
                  right: padding,
                  bottom: padding,
                ),
                decoration: BoxDecoration(
                  color: ColorProvider.base(.3 * p, true),
                  borderRadius: BorderRadius.all(Radius.circular(radius - padding)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${t.name} ${t.id}',
                        maxLines: 1,
                        style: Common.textStyle(
                          ctx,
                          color: ColorProvider.base(p),
                          scale: 2,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      t.urls[0],
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
            onTap: () {
              DetailPage page = DetailPage(
                info: DetailInfo(
                  data: t,
                  imgSize: imgSize,
                  index: index,
                ),
              );
              bool send = false;
              Navi.pushAlpha(
                ctx,
                page,
                onBack: (p) {
                  if (p == 1) {
                    alpha.add(0);
                  } else if (p == 0 && !send) {
                    alpha.anim(1, ms: 200);
                    send = true;
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  void onPreload(DemoData t, Size imgSize, int index, int total) => Common.precache(
        url: t.urls[0],
        size: imgSize,
      );
}
