import 'package:base/base.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker/base/color_provider.dart';

class Common {
  Common._();

  static double base(BuildContext c, [double d = 1]) => HpDevice.screenMin(c, d) / Sp.getBaseRatio();

  static double textSize(BuildContext c, [double d = 1]) => base(c, d) * .6;

  static BorderRadius baseRadius(BuildContext c) => BorderRadius.circular(radius(c) / 3);

  // 统一圆角尺寸
  static double radius(BuildContext ctx, [double d = 1]) => base(ctx, d * 0.9);

  static const double ratio = 16 / 9;

  static double scRatioMin(BuildContext ctx, [double d = 1]) {
    // 当趋于正方形时，圆角等随min边一期增大，故按屏幕比例增加上限
    double m = HpDevice.screenMin(ctx);
    double h = HpDevice.screenHeight(ctx);
    double w = HpDevice.screenWidth(ctx);
    if (w > 0 && h > 0) {
      if (w >= h) {
        // 横屏
        double k = w / h;
        if (k >= ratio) {
          m = h;
        } else {
          m = w / ratio;
        }
      } else {
        // 竖屏
        double k = h / w;
        if (k >= ratio) {
          m = w;
        } else {
          m = h / ratio;
        }
      }
    }
    return m * d;
  }

  static double margin(BuildContext c, [double? scale]) => (scale ?? 1) * base(c) / 20;

  // 统一圆角处理
  static BoxDecoration roundRect(
    BuildContext c, {
    Color? bgColor,
    double scale = 1,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: bgColor,
      border: Border.all(
        width: 1,
        color: borderColor ?? ColorProvider.textColor().withOpacity(.2),
      ),
      borderRadius: BorderRadius.all(Radius.circular(radius(c, scale))),
    );
  }

  // 默认文字样式
  static TextStyle textStyle(
    BuildContext ctx, {
    double scale = 1,
    double alpha = 1,
    Color? color,
  }) =>
      TextStyle(
        color: color ?? ColorProvider.textColor().withOpacity(alpha),
        fontSize: textSize(ctx, scale),
      );

  // 默认正方圆角按钮
  static Widget btn({
    required BuildContext ctx,
    Object? content,
    VoidCallback? onTap,
    double percent = .5,
    String? tip,
    Color? color,
  }) {
    double b = base(ctx);
    Widget? child;
    if (content is Widget) {
      child = Center(
        child: SizedBox(
          width: b * percent,
          height: b * percent,
          child: content,
        ),
      );
    } else if (content is String) {
      child = Text(
        content,
        maxLines: 1,
        style: textStyle(ctx),
      );
    }
    BorderRadius r = BorderRadius.circular(b / 3);
    color = color ?? ColorProvider.btnBg();
    return Container(
      width: b,
      height: b,
      margin: EdgeInsets.all(margin(ctx)),
      child: content == null
          ? null
          : (onTap == null
              ? null
              : click(
                  child: child,
                  onTap: onTap,
                  r: r,
                  color: color.withOpacity(.5),
                  cBorder: color.withOpacity(1),
                  tip: tip,
                )),
    );
  }

  // 统一点击水波纹
  static Widget click({
    Widget? child,
    required VoidCallback onTap,
    Color? color,
    Color? cBorder,
    BorderRadius? r,
    String? tip,
  }) {
    BoxDecoration? dec;
    if (cBorder != null) {
      dec = BoxDecoration(
        borderRadius: r,
        border: Border.all(width: 1, color: cBorder),
      );
    }
    Widget widget = Container(
      decoration: dec,
      child: Material(
        color: color ?? Colors.transparent,
        borderRadius: r,
        child: InkWell(
          onTap: onTap,
          borderRadius: r,
          child: Center(child: child),
        ),
      ),
    );
    return tip == null
        ? widget
        : Tooltip(
            message: tip,
            waitDuration: const Duration(milliseconds: 1000),
            child: widget,
          );
  }

  // 默认输入label样式
  static InputDecoration inputDecoration(BuildContext ctx, String name) => InputDecoration(
        labelText: name,
        isDense: true,
        // 文字padding
        contentPadding: EdgeInsets.only(bottom: base(ctx, .06)),
        labelStyle: TextStyle(
            fontSize: textSize(ctx),
            // color: ColorProvider.labelColor(),
            // fontWeight: FontWeight.bold,
            decoration: TextDecoration.none),
        // focusColor: Colors.lime,
        // focusedBorder: const UnderlineInputBorder(
        //   borderSide: BorderSide(
        //     color: Colors.amber,
        //   ),
        // ),
      );

  // 默认数字输入框，仅支持double & int
  static Widget textField<T extends num>({
    required BuildContext ctx,
    required String name,
    required T Function() get,
    void Function(T value, T Function() get)? onChange,
    ValueChanged<bool>? onFocus,
  }) {
    List<TextInputFormatter> inputFormatters = [];
    late bool isDouble;
    if (get is double Function()) {
      isDouble = true;
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp("[0-9.]")));
    } else if (get is int Function()) {
      isDouble = false;
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp("[0-9]")));
    } else {
      throw HpDevice.exp('Common.textFiled() unknown T: $get');
    }
    TextEditingController ctrl = TextEditingController(text: get.call().toString());
    return Container(
      margin: EdgeInsets.all(margin(ctx)),
      child: Focus(
        onFocusChange: (b) {
          onFocus?.call(b);
          if (!b) {
            ctrl.text = get.call().toString();
          }
        },
        child: TextField(
          //限制仅输入带小数点的数字
          inputFormatters: inputFormatters,
          textAlign: TextAlign.center,
          onChanged: onChange == null
              ? null
              : (s) {
                  if (isDouble) {
                    onChange.call((double.tryParse(s) ?? 0) as T, get);
                  } else {
                    onChange.call((int.tryParse(s) ?? 0) as T, get);
                  }
                },
          // focusNode: focusNode,
          controller: ctrl,
          // cursorColor: Colors.amber, // 光标颜色
          // 键盘类型
          keyboardType: TextInputType.number,
          // 自动更正
          autocorrect: false,
          maxLines: 1,
          style: textStyle(ctx),
          decoration: inputDecoration(ctx, name),
        ),
      ),
    );
  }

  // 统一下拉菜单
  static Widget dropdownMenu({
    required BuildContext ctx,
    String? name,
    required String value,
    required List<String> lst,
    Widget Function(String)? content,
    bool noText = false,
    bool noLine = false,
    required ValueChanged<String?> onChange,
    VoidCallback? onTap,
  }) {
    text(String s) => FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            s,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: Common.textStyle(ctx).copyWith(
              height: 1,
              color: ColorProvider.textColor().withOpacity(content == null
                  ? 1
                  : ThemeProvider.isDark()
                      ? 0.4
                      : 0.2),
            ),
          ),
        );
    double h = Common.base(ctx);
    InputDecoration? label =
        name == null ? null : inputDecoration(ctx, name).copyWith(contentPadding: const EdgeInsets.all(0));
    if (noLine) {
      if (label == null) {
        label = const InputDecoration(border: InputBorder.none);
      } else {
        label = label.copyWith(border: InputBorder.none);
      }
    }
    label = label?.copyWith();
    return Container(
      margin: EdgeInsets.all(margin(ctx)),
      child: DropdownButtonFormField(
        focusColor: Colors.transparent,
        elevation: 0,
        decoration: label,
        borderRadius: Common.baseRadius(ctx),
        dropdownColor: ColorProvider.menuBg(),
        isExpanded: true,
        isDense: HpPlatform.isMac() ? false : true,
        onTap: onTap,
        items: lst
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: SizedBox(
                  width: double.infinity,
                  height: h,
                  child: content == null
                      ? text(e)
                      : (noText
                          ? Container(
                              padding: EdgeInsets.only(top: h / 10, bottom: h / 10),
                              child: content(e),
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: h / 10, bottom: h / 10),
                                  child: content(e),
                                ),
                                text(e),
                              ],
                            )),
                ),
              ),
            )
            .toList(),
        value: value,
        onChanged: onChange,
      ),
    );
  }

  // 统一dlg
  static Future<T?> dlg<T>({
    required BuildContext ctx,
    required String name,
    double? w,
    double? h,
    required Future<Widget> future,
  }) =>
      showDialog<T>(
        routeSettings: NavigatorObs.rs(name, dlg: true),
        barrierDismissible: true, //点击空白是否退出
        context: ctx,
        builder: (ctx) => FutureBuilder(
          future: future,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            double padding = Common.textSize(ctx, .5);
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (Widget child, Animation<double> anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(
                  opacity: anim,
                  child: child,
                ),
              ),
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator()
                  : AlertDialog(
                      backgroundColor: ColorProvider.itemBg(),
                      surfaceTintColor: ColorProvider.itemBg(),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorProvider.textColor(),
                          fontSize: Common.textSize(ctx, 2),
                        ),
                      ),
                      titlePadding: EdgeInsets.only(left: padding, top: 0),
                      contentPadding: EdgeInsets.zero,
                      content: SizedBox(
                        width: w,
                        height: h,
                        child: snapshot.data,
                      ),
                    ),
            );
          },
        ),
      );

  // 统一滚动条样式
  static Widget scrollbar({required BuildContext ctx, required ScrollController controller, required Widget child}) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: ScrollConfiguration(
        // 支持鼠标操作
        behavior: ScrollConfiguration.of(ctx).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: child,
      ),
    );
  }

  // 统一画笔
  static Paint paint([FilterQuality quality = FilterQuality.low]) => Paint()
    ..isAntiAlias = true
    ..filterQuality = quality;

  // 统一文字介绍
  static Widget itemName({
    required BuildContext ctx,
    required String name,
    required double scale,
    double radius = 0,
    int maxLines = 1,
  }) {
    TextStyle style = Common.textStyle(ctx, scale: scale);
    return Container(
      padding: EdgeInsets.only(
        left: radius / 2,
        right: radius / 2,
      ),
      height: Common.base(ctx, scale),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Center(
          child: Stack(
            children: [
              Text(
                name,
                maxLines: maxLines,
                style: style.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeCap = StrokeCap.round
                      ..strokeJoin = StrokeJoin.round
                      ..strokeWidth = textSize(ctx, scale) / 5
                      ..color = ColorProvider.textBorderColor()),
              ),
              Text(
                name,
                maxLines: maxLines,
                style: style,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget loading = const Center(child: CircularProgressIndicator());

  static Widget netImage({
    required String url,
    required double w,
    required double h,
    BorderRadiusGeometry? borderRadius,
  }) =>
      CachedNetworkImage(
        imageUrl: url,
        width: w,
        height: h,
        maxWidthDiskCache: w.toInt(),
        maxHeightDiskCache: h.toInt(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 200),
        imageBuilder: (_, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              // isAntiAlias: true,
            ),
            borderRadius: borderRadius,
          ),
        ),
        placeholder: (context, url) => loading,
        errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
      );

  static void precache(BuildContext ctx, String url, Size size) => precacheImage(
        size: size,
        CachedNetworkImageProvider(
          url,
          maxWidth: size.width.toInt(),
          maxHeight: size.height.toInt(),
        ),
        ctx,
      );
}
