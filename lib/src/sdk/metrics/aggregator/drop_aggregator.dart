// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/src/api/common/attribute.dart';
import 'package:opentelemetry/src/sdk/common/instrumentation_scope.dart';
import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator_handle.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/empty_metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/metric_descriptor.dart';
import 'package:opentelemetry/src/sdk/resource/resource.dart';

final class DropAggregator extends Aggregator<PointData> {
  static final pointData = PointData(
    value: 0,
    startEpochNanos: Int64(0),
    epochNanos: Int64(0),
    attributes: const [],
  );

  static final _handle = Handle();

  @override
  AggregatorHandle<PointData> createHandle() {
    return _handle;
  }

  @override
  MetricData toMetricData({
    required Resource resource,
    required InstrumentationScope instrumentationScope,
    required MetricDescriptor metricDescriptor,
    required List<BasePointData> points,
    required AggregationTemporality temporality,
  }) {
    return const EmptyMetricData();
  }
}

final class Handle implements AggregatorHandle<PointData> {
  @override
  PointData<num> aggregateThenMaybeReset({
    required Int64 startEpochNanos,
    required Int64 epochNanos,
    List<Attribute> attributes = const [],
    bool reset = true,
  }) {
    return DropAggregator.pointData;
  }

  @override
  void record(num value) {}
}
