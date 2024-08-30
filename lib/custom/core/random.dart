// ignore_for_file: avoid_classes_with_only_static_members

part of 'core.dart';

abstract class Fortune {
  static int randomInt(int min, int max, [_math.Random? random]) {
    random = random ?? _math.Random();
    if (min == max) {
      return min;
    }
    final _rng = _math.Random();
    return min + _rng.nextInt(max - min);
  }

  static Duration randomDuration(
    Duration min,
    Duration max, [
    _math.Random? random,
  ]) {
    random = random ?? _math.Random();
    return Duration(
      milliseconds: randomInt(min.inMilliseconds, max.inMilliseconds, random),
    );
  }

  static T randomItem<T>(Iterable<T> iterable, [_math.Random? random]) {
    random = random ?? _math.Random();
    return iterable.elementAt(
      randomInt(0, iterable.length, random),
    );
  }
}
