// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';

/// {@template opentelemetry.sdk.metrics.export.MetricProducer}
///
/// [MetricProducer] is the interface that is used to make metric data available to the
/// [MetricReader]s
///
/// <p>Alternative [MetricProducer] implementations can be used to bridge aggregated metrics
/// from other frameworks, and are registered with [MeterProvider]. NOTE: When possible, metrics
/// from other frameworks SHOULD be bridged using the metric API, normally with asynchronous
/// instruments which observe the aggregated state of the other framework. However,
/// [MetricProducer] exists to accommodate scenarios where the metric API is insufficient. It should
/// be used with caution as it requires the bridge to take a dependency on Metrics SDK, which is generally not advised.
///
/// {@endtemplate}
abstract interface class MetricProducer {
  Future<List<MetricData>> produce();
}
