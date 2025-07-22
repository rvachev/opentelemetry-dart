// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/src/sdk/metrics/data/exponential_histogram_buckets.dart';

sealed class BasePointData {
  final Int64 startEpochNanos;
  final Int64 epochNanos;
  final List<Attribute> attributes;

  const BasePointData({
    required this.startEpochNanos,
    required this.epochNanos,
    required this.attributes,
  });

  @override
  String toString() {
    return 'BasePointData(startEpochNanos: $startEpochNanos, epochNanos: $epochNanos, attributes: $attributes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BasePointData &&
        other.startEpochNanos == startEpochNanos &&
        other.epochNanos == epochNanos &&
        other.attributes == attributes;
  }

  @override
  int get hashCode => startEpochNanos.hashCode ^ epochNanos.hashCode ^ attributes.hashCode;
}

final class PointData<T extends num> extends BasePointData {
  final T value;

  const PointData({
    required this.value,
    required super.startEpochNanos,
    required super.epochNanos,
    required super.attributes,
  });

  @override
  String toString() {
    return 'PointData{value: $value, startEpochNanos: $startEpochNanos, epochNanos: $epochNanos, attributes: $attributes}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PointData &&
        other.value == value &&
        other.startEpochNanos == startEpochNanos &&
        other.epochNanos == epochNanos &&
        other.attributes == attributes;
  }

  @override
  int get hashCode => value.hashCode ^ startEpochNanos.hashCode ^ epochNanos.hashCode ^ attributes.hashCode;
}

class HistogramPointData extends BasePointData {
  final int count;
  final double sum;
  final bool hasMinMax;
  final double min;
  final double max;
  final List<double> boundaries;
  final List<int> counts;

  const HistogramPointData({
    required this.count,
    required super.startEpochNanos,
    required super.epochNanos,
    required super.attributes,
    required this.sum,
    required this.hasMinMax,
    required this.min,
    required this.max,
    required this.boundaries,
    required this.counts,
  });

  @override
  String toString() {
    return 'HistogramPointData(startEpochNanos: $startEpochNanos, epochNanos: $epochNanos, attributes: $attributes, sum: $sum, hasMinMax: $hasMinMax, min: $min, max: $max, boundaries: $boundaries, counts: $counts, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HistogramPointData &&
        other.startEpochNanos == startEpochNanos &&
        other.epochNanos == epochNanos &&
        other.attributes == attributes &&
        other.sum == sum &&
        other.hasMinMax == hasMinMax &&
        other.min == min &&
        other.max == max &&
        other.boundaries == boundaries &&
        other.counts == counts &&
        other.count == count;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      sum.hashCode ^
      hasMinMax.hashCode ^
      min.hashCode ^
      max.hashCode ^
      boundaries.hashCode ^
      counts.hashCode ^
      count.hashCode;
}

class ExponentialHistogramPointData extends BasePointData {
  final int scale;
  final double sum;
  final int count;
  final int zeroCount;
  final bool hasMinMax;
  final double min;
  final double max;
  final Base2ExponentialHistogramBuckets positiveBuckets;
  final Base2ExponentialHistogramBuckets negativeBuckets;

  const ExponentialHistogramPointData({
    required this.scale,
    required this.sum,
    required this.count,
    required this.zeroCount,
    required this.hasMinMax,
    required this.min,
    required this.max,
    required this.positiveBuckets,
    required this.negativeBuckets,
    required super.startEpochNanos,
    required super.epochNanos,
    required super.attributes,
  });

  @override
  String toString() {
    return 'ExponentialHistogramPointData(startEpochNanos: $startEpochNanos, epochNanos: $epochNanos, attributes: $attributes, scale: $scale, sum: $sum, count: $count, zeroCount: $zeroCount, hasMinMax: $hasMinMax, min: $min, max: $max, positiveBuckets: $positiveBuckets, negativeBuckets: $negativeBuckets)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExponentialHistogramPointData &&
        other.scale == scale &&
        other.sum == sum &&
        other.count == count &&
        other.zeroCount == zeroCount &&
        other.hasMinMax == hasMinMax &&
        other.min == min &&
        other.max == max &&
        other.positiveBuckets == positiveBuckets &&
        other.negativeBuckets == negativeBuckets &&
        other.startEpochNanos == startEpochNanos &&
        other.epochNanos == epochNanos &&
        other.attributes == attributes;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      scale.hashCode ^
      sum.hashCode ^
      count.hashCode ^
      zeroCount.hashCode ^
      hasMinMax.hashCode ^
      min.hashCode ^
      max.hashCode ^
      positiveBuckets.hashCode ^
      negativeBuckets.hashCode;
}
