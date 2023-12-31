import 'package:base/base.dart';
import 'package:flutter/material.dart';
import 'package:poker/base/color_provider.dart';
import 'package:poker/base/common.dart';
import 'package:poker/poker/config.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  final Widget? ctrl;
  final BorderRadiusGeometry? borderRadius;
  final Object? tag;
  final bool cover;

  const VideoWidget({
    super.key,
    required this.url,
    this.borderRadius,
    this.ctrl,
    this.tag,
    this.cover = true,
  });

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoDef _videoDef;

  @override
  void initState() {
    _videoDef = _VideoManager._initState(widget.url);
    super.initState();
  }

  @override
  void dispose() {
    _VideoManager._dispose(widget.url);
    super.dispose();
  }

  Widget _hero(Widget child) {
    if (widget.tag != null) {
      child = Hero(tag: widget.tag!, child: child);
    }
    return child;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, constraints) {
          List<Widget> children = [
            Positioned.fill(
              child: _hero(
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: ColorProvider.itemBg(),
                    borderRadius: widget.borderRadius,
                  ),
                  child: StreamWidget(
                    stream: _videoDef.init.stream().distinct(),
                    initialData: _videoDef.init.value(),
                    builder: (_, __, ___) {
                      if (_videoDef.init.value()) {
                        double left = 0;
                        double top = 0;
                        double w = constraints.maxWidth;
                        double h = constraints.maxHeight;
                        double k = w / h;
                        if (widget.cover) {
                          if (_videoDef.ctrl.value.aspectRatio >= k) {
                            w = h * _videoDef.ctrl.value.aspectRatio;
                            left = -(w - constraints.maxWidth) / 2;
                          } else {
                            h = w / _videoDef.ctrl.value.aspectRatio;
                            top = -(h - constraints.maxHeight) / 2;
                          }
                        } else {
                          if (_videoDef.ctrl.value.aspectRatio >= k) {
                            h = w / _videoDef.ctrl.value.aspectRatio;
                            top = -(h - constraints.maxHeight) / 2;
                          } else {
                            w = h * _videoDef.ctrl.value.aspectRatio;
                            left = -(w - constraints.maxWidth) / 2;
                          }
                        }
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fromRect(
                              rect: Rect.fromLTWH(left, top, w, h),
                              child: VideoPlayer(_videoDef.ctrl),
                            ),
                          ],
                        );
                      } else {
                        return Common.loading;
                      }
                    },
                  ),
                ),
              ),
            )
          ];
          if (widget.ctrl != null) {
            children.add(Positioned.fill(child: widget.ctrl!));
          }
          double w = Common.base(context, Config.iconK);
          children.add(Positioned.fill(
            child: StreamWidget(
              stream: _videoDef.init.stream().distinct(),
              initialData: _videoDef.init.value(),
              builder: (_, __, child) {
                if (_videoDef.init.value()) {
                  return child!;
                } else {
                  return Visibility(
                    visible: false,
                    child: child!,
                  );
                }
              },
              child: Center(
                child: SizedBox(
                  width: w * 2,
                  height: w * 2,
                  child: StreamWidget<bool>(
                    initialData: _videoDef.playing.value(),
                    stream: _videoDef.playing.stream().distinct(),
                    builder: (_, __, ___) {
                      _videoDef.playing.value() ? _videoDef.ctrl.play() : _videoDef.ctrl.pause();
                      return TweenAnimationBuilder<double>(
                        key: ValueKey(HpDevice.time()),
                        duration: const Duration(seconds: 2),
                        tween: Tween(begin: 1, end: .2),
                        builder: (context, v, _) => IconButton(
                          onPressed: () => _videoDef.playing.add(!_videoDef.ctrl.value.isPlaying),
                          icon: Icon(
                            _videoDef.ctrl.value.isPlaying ? Icons.pause_circle_outlined : Icons.play_arrow_outlined,
                            size: w,
                            color: ColorProvider.base(v),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ));
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: children,
            ),
          );
        },
      );
}

class _VideoManager {
  _VideoManager._();

  static final Map<String, VideoDef> _map = {};

  static VideoDef _initState(String url) {
    VideoDef? video = _map[url];
    if (video == null) {
      video = VideoDef(VideoPlayerController.networkUrl(Uri.parse(url)));
      video.ctrl.setLooping(true);
      video.ctrl.initialize().then(
        (_) {
          video!.init.add(true);
          video.playing.add(true);
        },
      ).onError(
        (_, __) => null,
      ); // todo
      _map[url] = video;
    }
    video._use++;
    return video;
  }

  static void _dispose(String url) {
    VideoDef? video = _map[url];
    if (video != null) {
      video._use--;
      if (video._use <= 0) {
        assert(video._use == 0);
        video.ctrl.dispose();
        _map.remove(url);
      }
    }
  }
}

class VideoDef {
  final VideoPlayerController ctrl;
  final Broadcast<bool> playing = Broadcast(false);
  final Broadcast<bool> init = Broadcast(false);
  int _use = 0;

  VideoDef(this.ctrl);
}
