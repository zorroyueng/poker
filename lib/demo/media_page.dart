import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/common.dart';
import 'package:poker/base/video_widget.dart';
import 'package:poker/demo/demo_helper.dart';

class MediaPage extends StatelessWidget {
  final List<String> urls;
  final int index;
  final String id;
  final Size? size;

  const MediaPage({
    super.key,
    required this.urls,
    this.size,
    required this.index,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = () {
      if (Common.isVideo(urls[0])) {
        return Hero(
          tag: DemoHelper.mediaTag(id, index, urls[0]),
          child: VideoWidget(
            url: urls[0],
            cover: false,
            ctrl: Common.click(onTap: () => Navi.pop(context)),
          ),
        );
      } else {
        return PageView.builder(
          controller: PageController(initialPage: index),
          itemCount: urls.length,
          itemBuilder: (context, index) => Hero(
            tag: DemoHelper.mediaTag(id, index, urls[index]),
            child: Common.click(
              onTap: () => Navi.pop(context),
              back: Common.netImage(
                url: urls[index],
                w: size!.width,
                h: size!.height,
              ),
            ),
          ),
        );
      }
    }();
    return Scaffold(
      body: SafeArea(
        child: QuitContainer(
          context: context,
          intercept: false,
          slideOut: true,
          child: child,
        ),
      ),
    );
  }
}
