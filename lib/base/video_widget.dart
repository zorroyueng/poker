import 'package:flutter/material.dart';
import 'package:poker/base/common.dart';
import 'package:poker/poker/config.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  final BorderRadiusGeometry? borderRadius;

  const VideoWidget({
    super.key,
    required this.url,
    this.borderRadius,
  });

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url))..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ctrl.value.isInitialized) {
      return LayoutBuilder(
        builder: (_, constraints) {
          double left = 0;
          double top = 0;
          double w = constraints.maxWidth;
          double h = constraints.maxHeight;
          double k = w / h;
          if (_ctrl.value.aspectRatio >= k) {
            w = h * _ctrl.value.aspectRatio;
            left = -(w - constraints.maxWidth) / 2;
          } else {
            h = w / _ctrl.value.aspectRatio;
            top = -(h - constraints.maxHeight) / 2;
          }
          return Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                Positioned.fromRect(
                  rect: Rect.fromLTWH(left, top, w, h),
                  child: VideoPlayer(_ctrl),
                ),
                Positioned.fill(
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play();
                        });
                      },
                      icon: Icon(
                        _ctrl.value.isPlaying ? Icons.pause_circle_outlined : Icons.play_arrow_outlined,
                        size: Common.base(context, Config.iconK),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return Common.loading;
    }
  }
}
