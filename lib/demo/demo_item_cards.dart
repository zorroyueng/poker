import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';

class DemoItemCards extends StatelessWidget {
  final List<String> urls;
  final Broadcast<int> index;
  final Size size;
  final Object tag;
  final Widget? bottom;
  final bool hasRadius;

  const DemoItemCards({
    super.key,
    required this.tag,
    required this.urls,
    required this.size,
    required this.index,
    this.bottom,
    this.hasRadius = true,
  });

  Widget _progressBar(double radius) {
    List<Widget> lst = [];
    if (urls.length > 1) {
      double d = radius / 10;
      for (int i = 0; i < urls.length; i++) {
        bool current = i == index.value();
        lst.add(Expanded(
          child: AnimatedContainer(
            height: d,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(d),
              color: ColorProvider.base(current ? 1 : .3),
            ),
            duration: const Duration(milliseconds: 200),
          ),
        ));
        if (i < urls.length - 1) {
          lst.add(SizedBox(width: d * 2));
        }
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: lst,
    );
  }

  @override
  Widget build(BuildContext context) {
    double radius = Common.radius(context);
    List<Widget> children = [];
    children.add(
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: Common.click(
                r: BorderRadius.only(topLeft: Radius.circular(radius)),
                onTap: () {
                  int n = index.value() - 1;
                  if (n >= 0) {
                    index.add(n);
                  } else {
                    HapticFeedback.lightImpact();
                  }
                },
              ),
            ),
            Expanded(
              child: Common.click(
                r: BorderRadius.only(topRight: Radius.circular(radius)),
                onTap: () {
                  int n = index.value() + 1;
                  if (n < urls.length) {
                    index.add(n);
                  } else {
                    HapticFeedback.lightImpact();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (bottom != null) {
      children.add(bottom!);
    }
    BorderRadius? borderRadius = hasRadius ? BorderRadius.circular(radius) : null;
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Hero(
            tag: tag,
            child: Container(
              decoration: BoxDecoration(
                color: ColorProvider.itemBg(),
                borderRadius: borderRadius,
              ),
              child: StreamWidget(
                stream: index.stream().distinct(),
                initialData: index.value(),
                builder: (_, __, ___) => Common.netImage(
                  url: urls[index.value()],
                  w: size.width,
                  h: size.height,
                  borderRadius: borderRadius,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: radius / 2,
          top: radius / 2,
          right: radius / 2,
          child: StreamWidget(
            stream: index.stream().distinct(),
            initialData: index.value(),
            builder: (_, __, ___) => _progressBar(radius),
          ),
        ),
        Positioned.fill(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: children,
          ),
        ),
      ],
    );
  }
}
