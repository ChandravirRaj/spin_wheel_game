part of 'wheel.dart';

enum HapticImpact { none, light, medium, heavy }

Offset _calculateWheelOffset(
    BoxConstraints constraints, TextDirection textDirection) {
  final smallerSide = getSmallerSide(constraints);
  var offsetX = constraints.maxWidth / 2;
  if (textDirection == TextDirection.rtl) {
    offsetX = offsetX * -1 + smallerSide / 2;
  }
  return Offset(offsetX, constraints.maxHeight / 2);
}

double _calculateSliceAngle(int index, int itemCount) {
  final anglePerChild = 2 * _math.pi / itemCount;
  final childAngle = anglePerChild * index;
  final angleOffset = -(_math.pi / 2 + anglePerChild / 2);
  return childAngle + angleOffset;
}

double _calculateAlignmentOffset(Alignment alignment) {
  if (alignment == Alignment.topRight) {
    return _math.pi * 0.25;
  }

  if (alignment == Alignment.centerRight) {
    return _math.pi * 0.5;
  }

  if (alignment == Alignment.bottomRight) {
    return _math.pi * 0.75;
  }

  if (alignment == Alignment.bottomCenter) {
    return _math.pi;
  }

  if (alignment == Alignment.bottomLeft) {
    return _math.pi * 1.25;
  }

  if (alignment == Alignment.centerLeft) {
    return _math.pi * 1.5;
  }

  if (alignment == Alignment.topLeft) {
    return _math.pi * 1.75;
  }

  return 0;
}

class _WheelData {
  final BoxConstraints constraints;
  final int itemCount;
  final TextDirection textDirection;

  late final double smallerSide = getSmallerSide(constraints);
  late final double largerSide = getLargerSide(constraints);
  late final double sideDifference = largerSide - smallerSide;
  late final Offset offset = _calculateWheelOffset(constraints, textDirection);
  late final Offset dOffset = Offset(
    (constraints.maxHeight - smallerSide) / 2,
    (constraints.maxWidth - smallerSide) / 2,
  );
  late final double diameter = smallerSide;
  late final double radius = diameter / 2;
  late final double itemAngle = 2 * _math.pi / itemCount;

  _WheelData({
    required this.constraints,
    required this.itemCount,
    required this.textDirection,
  });
}

class FortuneWheel extends HookWidget implements FortuneWidget {

  static const List<FortuneIndicator> kDefaultIndicators = <FortuneIndicator>[
    FortuneIndicator(
      alignment: Alignment.topCenter,
      child: TriangleIndicator(),
    ),
  ];

  static const StyleStrategy kDefaultStyleStrategy = AlternatingStyleStrategy();

  final List<FortuneItem> items;

  final Stream<int> selected;

  final int rotationCount;

  final Duration duration;

  final List<FortuneIndicator> indicators;

  final Curve curve;

  final VoidCallback? onAnimationStart;

  final VoidCallback? onAnimationEnd;

  final StyleStrategy styleStrategy;

  final bool animateFirst;

  final PanPhysics physics;

  final VoidCallback? onFling;

  final Alignment alignment;

  final HapticImpact hapticImpact;

  final ValueChanged<int>? onFocusItemChanged;

  double _getAngle(double progress) {
    return 2 * _math.pi * rotationCount * progress;
  }

  FortuneWheel({
    Key? key,
    required this.items,
    this.rotationCount = FortuneWidget.kDefaultRotationCount,
    this.selected = const Stream<int>.empty(),
    this.duration = FortuneWidget.kDefaultDuration,
    this.curve = FortuneCurve.spin,
    this.indicators = kDefaultIndicators,
    this.styleStrategy = kDefaultStyleStrategy,
    this.animateFirst = true,
    this.onAnimationStart,
    this.onAnimationEnd,
    this.alignment = Alignment.topCenter,
    this.hapticImpact = HapticImpact.none,
    PanPhysics? physics,
    this.onFling,
    this.onFocusItemChanged,
  })  : physics = physics ?? CircularPanPhysics(),
        assert(items.length > 1),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final rotateAnimCtrl = useAnimationController(duration: duration);
    final rotateAnim = CurvedAnimation(parent: rotateAnimCtrl, curve: curve);
    Future<void> animate() async {
      if (rotateAnimCtrl.isAnimating) {
        return;
      }

      await Future.microtask(() => onAnimationStart?.call());
      await rotateAnimCtrl.forward(from: 0);
      await Future.microtask(() => onAnimationEnd?.call());
    }

    useEffect(() {
      if (animateFirst) animate();
      return null;
    }, []);

    final selectedIndex = useState<int>(0);

    useEffect(() {
      final subscription = selected.listen((event) {
        selectedIndex.value = event;
        animate();
      });
      return subscription.cancel;
    }, []);

    final lastVibratedAngle = useRef<double>(0);

    return PanAwareBuilder(
      behavior: HitTestBehavior.translucent,
      physics: physics,
      onFling: onFling,
      builder: (context, panState) {
        return Stack(
          children: [
            AnimatedBuilder(
              animation: rotateAnim,
              builder: (context, _) {
                final size = MediaQuery.of(context).size;
                final meanSize = (size.width + size.height) / 2;
                final panFactor = 6 / meanSize;

                return LayoutBuilder(builder: (context, constraints) {
                  final wheelData = _WheelData(
                    constraints: constraints,
                    itemCount: items.length,
                    textDirection: Directionality.of(context),
                  );

                  final isAnimatingPanFactor =
                      rotateAnimCtrl.isAnimating ? 0 : 1;
                  final selectedAngle =
                      -2 * _math.pi * (selectedIndex.value / items.length);
                  final panAngle =
                      panState.distance * panFactor * isAnimatingPanFactor;
                  final rotationAngle = _getAngle(rotateAnim.value);
                  final alignmentOffset = _calculateAlignmentOffset(alignment);
                  final totalAngle = selectedAngle + panAngle + rotationAngle;

                  final focusedIndex = _vibrateIfBorderCrossed(
                    totalAngle,
                    lastVibratedAngle,
                    items.length,
                    hapticImpact,
                  );
                  if (focusedIndex != null) {
                    onFocusItemChanged?.call(focusedIndex % items.length);
                  }

                  final transformedItems = [
                    for (var i = 0; i < items.length; i++)
                      TransformedFortuneItem(
                        item: items[i],
                        angle: totalAngle +
                            alignmentOffset +
                            _calculateSliceAngle(i, items.length),
                        offset: wheelData.offset,
                      ),
                  ];

                  return SizedBox.expand(
                    child: _CircleSlices(
                      items: transformedItems,
                      wheelData: wheelData,
                      styleStrategy: styleStrategy,
                    ),
                  );
                });
              },
            ),
            for (var it in indicators)
              IgnorePointer(
                child: _WheelIndicator(indicator: it),
              ),
          ],
        );
      },
    );
  }

  int? _vibrateIfBorderCrossed(
    double angle,
    ObjectRef<double> lastVibratedAngle,
    int itemsNumber,
    HapticImpact hapticImpact,
  ) {
    final step = 360 / itemsNumber;
    final angleDegrees = (angle * 180 / _math.pi).abs() + step / 2;
    if (step.isNaN ||
        angleDegrees.isNaN ||
        lastVibratedAngle.value.isNaN ||
        lastVibratedAngle.value.isInfinite ||
        angleDegrees.isInfinite ||
        step == 0) {
      return null;
    }
    if (lastVibratedAngle.value ~/ step == angleDegrees ~/ step) {
      return null;
    }
    final index = angleDegrees ~/ step * angle.sign.toInt() * -1;
    final hapticFeedbackFunction;
    switch (hapticImpact) {
      case HapticImpact.none:
        return index;
      case HapticImpact.heavy:
        hapticFeedbackFunction = HapticFeedback.heavyImpact;
        break;
      case HapticImpact.medium:
        hapticFeedbackFunction = HapticFeedback.mediumImpact;
        break;
      case HapticImpact.light:
        hapticFeedbackFunction = HapticFeedback.lightImpact;
        break;
    }
    hapticFeedbackFunction();
    lastVibratedAngle.value = angleDegrees ~/ step * step;
    return index;
  }
}
