part of 'core.dart';

abstract class FortuneWidget implements Widget {
  static const Duration kDefaultDuration = Duration(seconds: 5);

  static const int kDefaultRotationCount = 100;
  List<FortuneItem> get items;

  Stream<int> get selected;

  int get rotationCount;
  Duration get duration;

  Curve get curve;
  VoidCallback? get onAnimationStart;
  VoidCallback? get onAnimationEnd;

  List<FortuneIndicator> get indicators;

  StyleStrategy get styleStrategy;
  bool get animateFirst;
  PanPhysics get physics;
  VoidCallback? get onFling;
}
