// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator_handle.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/drop_aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/metric_descriptor.dart';

abstract class Aggregator<T extends BasePointData> {
  static Aggregator<PointData> drop() => DropAggregator();

  /// Returns a new [AggregatorHandle]. This MUST by used by the synchronous to aggregate
  /// recorded measurements during the collection cycle.
  ///
  /// @return a new [AggregatorHandle].
  AggregatorHandle<T> createHandle();

  /// Returns a new DELTA point by computing the difference between two cumulative points.
  ///
  /// <p>Aggregators MUST implement diff if it can be used with asynchronous instruments.
  ///
  /// - [previousCumulative] the previously captured point.
  /// - [currentCumulative] the newly captured (cumulative) point.
  ///
  /// returns The resulting delta point.
  T diff(T previousCumulative, T currentCumulative) {
    throw UnimplementedError('This agggregator does not support diff');
  }

  /// Returns the [MetricData] that this [Aggregation] will produce.
  ///
  /// [resource] the resource producing the metric.
  /// [instrumentationScope] the scope that instrumented the metric.
  /// [metricDescriptor] the name, description and unit of the metric.
  /// [points] list of points
  /// [temporality] the temporality of the metric.
  MetricData toMetricData({
    required Resource resource,
    required InstrumentationScope instrumentationScope,
    required MetricDescriptor metricDescriptor,
    required List<BasePointData> points,
    required AggregationTemporality temporality,
  });
}
