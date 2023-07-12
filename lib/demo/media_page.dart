import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/common.dart';
import 'package:poker/base/video_widget.dart';

class MediaPage extends StatelessWidget {
  final String url;
  final Object tag;

  const MediaPage({super.key, required this.url, required this.tag});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: QuitContainer(
            context: context,
            intercept: false,
            slideOut: true,
            child: Hero(
              tag: tag,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (Common.isVideo(url)) {
                    return VideoWidget(
                      url: url,
                      ctrl: Common.click(onTap: () => Navi.pop(context)),
                    );
                  } else {
                    double ratio = HpDevice.pixelRatio(context);
                    return Common.click(
                      onTap: () => Navi.pop(context),
                      back: Common.netImage(
                        url: url,
                        w: constraints.maxWidth * ratio,
                        h: constraints.maxHeight * ratio,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      );
}
