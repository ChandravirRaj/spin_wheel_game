part of 'core.dart';

@immutable
class FortuneItemStyle {
  final Color color;

  final Color borderColor;

  final double borderWidth;

  final TextAlign textAlign;

  final TextStyle textStyle;

  const FortuneItemStyle({
    this.color = Colors.white,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    this.textAlign = TextAlign.start,
    this.textStyle = const TextStyle(),
  });

  /// Creates an opinionated disabled style based on the current [ThemeData].
  FortuneItemStyle.disabled(ThemeData theme, {double opacity = 0.0})
      : this(
          color: Color.alphaBlend(
            theme.disabledColor.withOpacity(opacity),
            theme.disabledColor,
          ),
          borderWidth: 0.0,
          textStyle: TextStyle(color: theme.colorScheme.onPrimary),
        );

  @override
  int get hashCode => hashObjects([
        borderColor,
        borderWidth,
        color,
        textAlign,
        textStyle,
      ]);

  @override
  bool operator ==(Object other) {
    return other is FortuneItemStyle &&
        borderColor == other.borderColor &&
        borderWidth == other.borderWidth &&
        color == other.color &&
        textAlign == other.textAlign &&
        textStyle == other.textStyle;
  }
}

abstract class StyleStrategy {
  FortuneItemStyle getItemStyle(
    ThemeData theme,
    int index,
    int itemCount,
  );
}

mixin DisableAwareStyleStrategy {
  List<int> get disabledIndices;

  bool _isIndexDisabled(int index) {
    return disabledIndices.contains(index);
  }

  FortuneItemStyle getDisabledItemStyle(
    ThemeData theme,
    int index,
    int itemCount,
    FortuneItemStyle Function() orElse,
  ) {
    if (_isIndexDisabled(index)) {
      return FortuneItemStyle.disabled(
        theme,
        opacity: index % 2 == 0 ? 0.2 : 0.0,
      );
    } else {
      return orElse();
    }
  }
}

class UniformStyleStrategy
    with DisableAwareStyleStrategy
    implements StyleStrategy {
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final List<int> disabledIndices;

  const UniformStyleStrategy({
    this.color,
    this.borderColor,
    this.borderWidth,
    this.textAlign,
    this.textStyle,
    this.disabledIndices = const <int>[],
  });

  @override
  FortuneItemStyle getItemStyle(ThemeData theme, int index, int itemCount) {
    return getDisabledItemStyle(
      theme,
      index,
      itemCount,
      () => FortuneItemStyle(
        color: color ??
            Color.alphaBlend(
              theme.colorScheme.primary.withOpacity(0.3),
              theme.colorScheme.surface,
            ),
        borderColor: borderColor ?? theme.colorScheme.primary,
        borderWidth: borderWidth ?? 1.0,
        textStyle: textStyle ?? TextStyle(color: theme.colorScheme.onSurface),
        textAlign: textAlign ?? TextAlign.center,
      ),
    );
  }
}

class AlternatingStyleStrategy
    with DisableAwareStyleStrategy
    implements StyleStrategy {
  final List<int> disabledIndices;

  Color _getFillColor(ThemeData theme, int index, int itemCount) {
    final color = theme.colorScheme.primary;
    final background = theme.colorScheme.background;
    final opacity = itemCount % 2 == 1 && index == 0
        ? 0.7 // TODO: make 0.75
        : index % 2 == 0
            ? 0.5
            : 1.0;

    return Color.alphaBlend(
      color.withOpacity(opacity),
      background,
    );
  }

  const AlternatingStyleStrategy({
    this.disabledIndices = const <int>[],
  });

  @override
  FortuneItemStyle getItemStyle(ThemeData theme, int index, int itemCount) {
    return getDisabledItemStyle(
      theme,
      index,
      itemCount,
      () => FortuneItemStyle(
        color: _getFillColor(theme, index, itemCount),
        borderColor: theme.colorScheme.primary,
        borderWidth: 0.0,
        textAlign: TextAlign.start,
        textStyle: TextStyle(color: theme.colorScheme.onPrimary),
      ),
    );
  }
}
