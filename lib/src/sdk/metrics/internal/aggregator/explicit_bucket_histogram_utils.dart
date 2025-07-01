import 'dart:collection';

final class ExplicitBucketHistogramUtils {
  static final List<double> defaultHistogramBucketBoundaries = UnmodifiableListView(
      [0.0, 5.0, 10.0, 25.0, 50.0, 75.0, 100.0, 250.0, 500.0, 750.0, 1000.0, 2500.0, 5000.0, 7500.0, 10000.0]);

  static int findBucketIndex(List<double> boundaries, double value) {
    for (var i = 0; i < boundaries.length; i++) {
      if (value <= boundaries[i]) {
        return i;
      }
    }
    return boundaries.length;
  }

  static void validateBucketBoundaries(List<double> boundaries) {
    for (final value in boundaries) {
      if (value.isNaN) {
        throw ArgumentError('Invalid bucket boundary: NaN');
      }
    }
    for (var i = 1; i < boundaries.length; i++) {
      if (boundaries[i - 1] >= boundaries[i]) {
        throw ArgumentError('Bucket boundaries must be in increasing order: ${boundaries[i - 1]} >= ${boundaries[i]}');
      }
    }
    if (boundaries.isNotEmpty) {
      if (boundaries.first == double.negativeInfinity) {
        throw ArgumentError('Invalid bucket boundary: -Infinity');
      }
      if (boundaries.last == double.infinity) {
        throw ArgumentError('Invalid bucket boundary: +Infinity');
      }
    }
  }
}
