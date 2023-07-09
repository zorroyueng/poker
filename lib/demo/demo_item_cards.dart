import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/base/video_widget.dart';
import 'package:poker/poker/config.dart';

class DemoItemCards extends StatelessWidget {
  final List<String> urls;
  final Broadcast<int> index;
  final Size size;
  final Object tag;
  final Widget? bottom;
  final bool hasRadius;
  final Percent rotate = Percent(0, space: 0);

  DemoItemCards({
    super.key,
    required this.tag,
    required this.urls,
    required this.size,
    required this.index,
    this.bottom,
    this.hasRadius = true,
  });

  double _barHeight(double radius) => radius / 10;

  Widget _progressBar(double radius) {
    List<Widget> lst = [];
    if (urls.length > 1) {
      double d = _barHeight(radius);
      for (int i = 0; i < urls.length; i++) {
        bool current = i == index.value();
        lst.add(Expanded(
          child: AnimatedContainer(
            height: d,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(d),
              color: ColorProvider.base(current ? 1 : .3),
            ),
            duration: const Duration(milliseconds: 400),
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

  Widget _switch(BuildContext context, double radius) => Expanded(
        child: Row(
          children: [
            Expanded(
              child: Common.click(
                r: hasRadius ? BorderRadius.only(topLeft: Radius.circular(radius)) : null,
                onTap: () {
                  int n = index.value() - 1;
                  if (n >= 0) {
                    index.add(n);
                    HapticFeedback.lightImpact();
                  } else {
                    if (!rotate.inAnim()) {
                      rotate.add(0);
                      rotate.anim(1, ms: 200, curve: _Sin());
                      HapticFeedback.heavyImpact();
                    }
                  }
                },
              ),
            ),
            Expanded(
              child: Common.click(
                r: hasRadius ? BorderRadius.only(topRight: Radius.circular(radius)) : null,
                onTap: () {
                  int n = index.value() + 1;
                  if (n < urls.length) {
                    index.add(n);
                    int next = n + 1;
                    if (next < urls.length) {
                      Common.precache(context, urls[next], size);
                    }
                    HapticFeedback.lightImpact();
                  } else {
                    if (!rotate.inAnim()) {
                      rotate.add(0);
                      rotate.anim(-1, ms: 200, curve: _Sin());
                      HapticFeedback.heavyImpact();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    double radius = Common.radius(context);
    double barPaddingV = hasRadius ? radius / 2 : (kToolbarHeight - _barHeight(radius)) / 2;
    double barPaddingH = hasRadius ? barPaddingV : barPaddingV * 2;
    Widget ctrl = () {
      List<Widget> children = [];
      children.add(_switch(context, radius));
      if (bottom != null) {
        children.add(bottom!);
      }
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: children,
      );
    }();
    BorderRadius? borderRadius = hasRadius ? BorderRadius.circular(radius) : null;
    return PercentWidget(
      percent: rotate,
      builder: (_, p, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, .0005)
            ..rotateY(Config.rotateY * p),
          alignment: const Alignment(0, 0),
          child: child,
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: ColorProvider.itemBg(),
                borderRadius: borderRadius,
              ),
              child: StreamWidget(
                stream: index.stream().distinct(),
                initialData: index.value(),
                builder: (_, __, ___) {
                  String url = urls[index.value()];
                  if (Common.isVideo(url)) {
                    return VideoWidget(
                      url: url,
                      ctrl: ctrl,
                      tag: tag,
                      borderRadius: borderRadius,
                    );
                  } else {
                    return Stack(
                      clipBehavior: Clip.none,
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: Hero(
                            tag: tag,
                            child: Common.netImage(
                              url: url,
                              w: size.width,
                              h: size.height,
                              borderRadius: borderRadius,
                            ),
                          ),
                        ),
                        Positioned.fill(child: ctrl),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          Positioned(
            top: barPaddingV,
            left: barPaddingH,
            right: barPaddingH,
            child: StreamWidget(
              stream: index.stream().distinct(),
              initialData: index.value(),
              builder: (_, __, ___) => _progressBar(radius),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sin extends Curve {
  @override
  double transform(double t) => 4 * t * (1 - t);
}
