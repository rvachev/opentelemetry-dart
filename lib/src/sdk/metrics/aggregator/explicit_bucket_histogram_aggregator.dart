// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'dart:collection';
import 'dart:math' as math;

import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/src/api/common/attribute.dart';
import 'package:opentelemetry/src/sdk/common/instrumentation_scope.dart';
import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data_type.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator_handle.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/explicit_bucket_histogram_utils.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/metric_descriptor.dart';
import 'package:opentelemetry/src/sdk/resource/resource.dart';

final class ExplicitBucketHistogramAggregator implements Aggregator<HistogramPointData> {
  final List<double> _boundaries;

  ExplicitBucketHistogramAggregator({
    required List<double> boundaries,
  }) : _boundaries = UnmodifiableListView(boundaries);

  @override
  AggregatorHandle<HistogramPointData> createHandle() {
    return Handle(boundaries: _boundaries);
  }

  @override
  HistogramPointData diff(HistogramPointData previousCumulative, HistogramPointData currentCumulative) {
    final diffCounts = <int>[];
    for (var i = 0; i < previousCumulative.counts.length; i++) {
      diffCounts.add(currentCumulative.counts[i] - previousCumulative.counts[i]);
    }

    return HistogramPointData(
      count: currentCumulative.count - previousCumulative.count,
      sum: currentCumulative.sum - previousCumulative.sum,
      hasMinMax: false,
      min: double.maxFinite,
      max: -1,
      boundaries: previousCumulative.boundaries,
      counts: previousCumulative.counts,
      startEpochNanos: previousCumulative.startEpochNanos,
      epochNanos: previousCumulative.epochNanos,
      attributes: previousCumulative.attributes,
    );
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
      type: MetricDataType.histogram,
      data: HistogramData(
        temporality: temporality,
        points: points.cast(),
      ),
    );
  }
}

final class Handle implements AggregatorHandle<HistogramPointData> {
  final List<double> _boundaries;

  Handle({required List<double> boundaries})
      : _boundaries = boundaries,
        _sum = 0,
        _min = double.maxFinite,
        _max = -1,
        _count = 0,
        _counts = List<int>.filled(boundaries.length + 1, 0);

  double _sum;
  double _min;
  double _max;
  int _count;
  List<int> _counts;

  @override
  HistogramPointData aggregateThenMaybeReset({
    required Int64 startEpochNanos,
    required Int64 epochNanos,
    List<Attribute> attributes = const [],
    bool reset = true,
  }) {
    final pointData = HistogramPointData(
      count: _count,
      sum: _sum,
      hasMinMax: _count > 0,
      min: _min,
      max: _max,
      boundaries: _boundaries,
      counts: _counts,
      startEpochNanos: startEpochNanos,
      epochNanos: epochNanos,
      attributes: attributes,
    );

    if (reset) {
      _sum = 0;
      _min = double.maxFinite;
      _max = -1;
      _count = 0;
      _counts = List<int>.filled(_boundaries.length + 1, 0);
    }

    return pointData;
  }

  @override
  void record(num value) {
    final bucketIndex = ExplicitBucketHistogramUtils.findBucketIndex(_boundaries, value.toDouble());

    _sum += value;
    _min = math.min(_min, value.toDouble());
    _max = math.max(_max, value.toDouble());
    _count++;
    _counts[bucketIndex]++;
  }
}
