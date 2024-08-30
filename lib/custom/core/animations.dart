part of 'core.dart';

class FortuneCurve {
  const FortuneCurve._();
  static const Curve spin = Cubic(0, 1.0, 0, 1.0);
  static const Curve none = Threshold(0.0);
}
