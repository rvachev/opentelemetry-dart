import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/src/api/common/attribute.dart';
import 'package:opentelemetry/src/sdk/common/instrumentation_scope.dart';
import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/exponential_histogram_buckets.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data_type.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/aggregator_handle.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/metric_descriptor.dart';
import 'package:opentelemetry/src/sdk/resource/resource.dart';

final class ExponentialHistogramAggregator implements Aggregator<ExponentialHistogramPointData> {
  @override
  AggregatorHandle<ExponentialHistogramPointData> createHandle() {
    return Handle();
  }

  @override
  ExponentialHistogramPointData diff(
    ExponentialHistogramPointData previousCumulative,
    ExponentialHistogramPointData currentCumulative,
  ) {
    return currentCumulative;
  }

  @override
  MetricData toMetricData({
    required Resource resource,
    required InstrumentationScope instrumentationScope,
    required MetricDescriptor metricDescriptor,
    required List<BasePointData> points,
    required AggregationTemporality temporality,
  }) {
    return MetricData(
      resource: resource,
      instrumentationScope: instrumentationScope,
      name: metricDescriptor.name,
      description: metricDescriptor.description,
      unit: metricDescriptor.unit,
      type: MetricDataType.exponentialHistogram,
      data: ExponentialHistogramData(temporality: temporality, points: points.cast()),
    );
  }
}

final class Handle implements AggregatorHandle<ExponentialHistogramPointData> {
  Handle()
      : _zeroCount = 0,
        _sum = 0.0,
        _min = double.maxFinite,
        _max = -1,
        _count = 0,
        _currentScale = 0;

  int _zeroCount;
  double _sum;
  double _min;
  double _max;
  int _count;
  int _currentScale;
  Base2ExponentialHistogramBuckets? _positiveBuckets;
  Base2ExponentialHistogramBuckets? _negativeBuckets;

  @override
  ExponentialHistogramPointData aggregateThenMaybeReset(
      {required Int64 startEpochNanos,
      required Int64 epochNanos,
      List<Attribute> attributes = const [],
      bool reset = true}) {
    final pointData = ExponentialHistogramPointData(
      scale: _currentScale,
      sum: _sum,
      zeroCount: _zeroCount,
      count: _count,
      hasMinMax: _count > 0,
      min: _min,
      max: _max,
      positiveBuckets: _positiveBuckets ?? Base2ExponentialHistogramBuckets(_currentScale),
      negativeBuckets: _negativeBuckets ?? Base2ExponentialHistogramBuckets(_currentScale),
      startEpochNanos: startEpochNanos,
      epochNanos: epochNanos,
      attributes: attributes,
    );

    if (reset) {
      _sum = 0;
      _min = double.maxFinite;
      _max = -1;
      _count = 0;
      _zeroCount = 0;
      _currentScale = 0;
    }

    return pointData;
  }

  @override
  void record(num value) {
    if (value.isNaN) {
      return;
    }

    _sum += value;

    _min = min(_min, value.toDouble());
    _max = max(_max, value.toDouble());
    _count++;

    final Base2ExponentialHistogramBuckets buckets;
    if (value == 0) {
      _zeroCount++;
      return;
    } else if (value > 0) {
      _positiveBuckets ??= Base2ExponentialHistogramBuckets(_currentScale);
      buckets = _positiveBuckets!;
    } else {
      _negativeBuckets ??= Base2ExponentialHistogramBuckets(_currentScale);
      buckets = _negativeBuckets!;
    }

    if (value == 0.0) {
      throw StateError('Illegal attempted recording of zero at bucket level.');
    }

    final index = buckets.indexer.computeIndex(value.toDouble());
    if (!buckets.incrementBucket(bucketIndex: index, increment: 1)) {
      _downscale(buckets.getScaleReduction(value.toDouble()));
    }
    _count++;
  }

  void _downscale(int by) {
    if (_positiveBuckets != null) {
      _positiveBuckets!.downscale(by);
      _currentScale = _positiveBuckets!.scale;
    }
    if (_negativeBuckets != null) {
      _negativeBuckets!.downscale(by);
      _currentScale = _negativeBuckets!.scale;
    }
  }
}
