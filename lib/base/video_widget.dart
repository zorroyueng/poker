import 'dart:async';

import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/poker/config.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  final Widget ctrl;
  final BorderRadiusGeometry? borderRadius;

  const VideoWidget({
    super.key,
    required this.url,
    this.borderRadius,
    required this.ctrl,
  });

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _video;
  final Broadcast<bool> _playing = Broadcast(false);
  final Broadcast<bool> _init = Broadcast(false);

  @override
  void initState() {
    super.initState();
    _video = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _video.setLooping(true);
    _video.initialize().then(
      (_) {
        _init.add(true);
        _play(true);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _video.dispose();
  }

  void _play(bool play) {
    play ? _video.play() : _video.pause();
    _playing.add(_video.value.isPlaying);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, constraints) => Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              StreamWidget(
                stream: _init.stream().distinct(),
                initialData: _init.value(),
                builder: (_, __, ___) {
                  if (_init.value()) {
                    double left = 0;
                    double top = 0;
                    double w = constraints.maxWidth;
                    double h = constraints.maxHeight;
                    double k = w / h;
                    if (_video.value.aspectRatio >= k) {
                      w = h * _video.value.aspectRatio;
                      left = -(w - constraints.maxWidth) / 2;
                    } else {
                      h = w / _video.value.aspectRatio;
                      top = -(h - constraints.maxHeight) / 2;
                    }
                    return Positioned.fromRect(
                      rect: Rect.fromLTWH(left, top, w, h),
                      child: VideoPlayer(_video),
                    );
                  } else {
                    return Common.loading;
                  }
                },
              ),
              Positioned.fill(child: widget.ctrl),
              Positioned.fill(
                child: StreamWidget(
                  stream: _init.stream().distinct(),
                  initialData: _init.value(),
                  builder: (_, __, child) {
                    if (_init.value()) {
                      return child!;
                    } else {
                      return Visibility(
                        visible: false,
                        child: child!,
                      );
                    }
                  },
                  child: Center(
                    child: StreamWidget<bool>(
                      initialData: _playing.value(),
                      stream: _playing.stream().distinct(),
                      builder: (_, __, ___) => IconButton(
                        onPressed: () => _play(!_video.value.isPlaying),
                        icon: Icon(
                          _video.value.isPlaying ? Icons.pause_circle_outlined : Icons.play_arrow_outlined,
                          size: Common.base(context, Config.iconK),
                          color: ColorProvider.base(.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
