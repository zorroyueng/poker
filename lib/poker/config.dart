import 'dart:ui';
import 'dart:math' as math;

class Config {
  // idle
  static const int idleCardNum = 2; // idle时上屏的卡片数
  static const double backCardScale = .9;
  static const Offset backCardOffset = Offset(0, 0.07); // 露出百分比
  static const int preloadNum = 2;
  static const double maxIconPercent = 2;

  // layout
  static const double paddingK = .05; // 最小边比例
  static const double aspectRatio = .66; // 卡片宽高比
  static const double percentSwipeK = .3; // 滑动超出宽高范围，计算滑动百分比使用，back也使用做变换
  static const double percentRotateK = 1; // 滑动超出宽高范围，计算旋转百分比使用
  static const double swipeK = .2; // 滑动超出宽高范围，判断滑动阈值
  static const double maxRotate = 10 * math.pi / 180; // 卡片横向滑动最大旋转角度
  static const double disappearK = 2.7; // 消失边界为宽or高的倍数

  // touch
  static const double maxSwipeV = 3; // 滑动速度判断swipeOut最大值
  static const double minSwipeV = 1; // 滑动速度判断swipeOut最小值
  static const double maxAnimV = 7; // 动画速度最大值
}
