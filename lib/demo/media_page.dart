import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/common.dart';
import 'package:poker/base/video_widget.dart';

class MediaPage extends StatelessWidget {
  final String url;
  final Object tag;
  final Size? size;

  const MediaPage({super.key, required this.url, required this.tag, this.size});

  @override
  Widget build(BuildContext context) {
    Widget child = () {
      if (Common.isVideo(url)) {
        return VideoWidget(
          url: url,
          cover: false,
          ctrl: Common.click(onTap: () => Navi.pop(context)),
        );
      } else {
        return Common.click(
          onTap: () => Navi.pop(context),
          back: Common.netImage(url: url, w: size!.width, h: size!.height),
        );
      }
    }();
    return Scaffold(
      body: SafeArea(
        child: QuitContainer(
          context: context,
          intercept: false,
          slideOut: true,
          child: Hero(
            tag: tag,
            child: child,
          ),
        ),
      ),
    );
  }
}
