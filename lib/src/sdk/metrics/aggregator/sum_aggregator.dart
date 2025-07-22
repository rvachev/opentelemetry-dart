// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/src/api/common/attribute.dart';
import 'package:opentelemetry/src/sdk/common/instrumentation_scope.dart';
import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data_type.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator_handle.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/metric_descriptor.dart';
import 'package:opentelemetry/src/sdk/resource/resource.dart';

final class SumAggregator implements Aggregator<PointData<num>> {
  final bool _isMonotonic;

  SumAggregator({
    required InstrumentDescriptor instrumentDescriptor,
  }) : _isMonotonic = _isMonotonicInstrument(instrumentDescriptor);

  static bool _isMonotonicInstrument(InstrumentDescriptor instrumentDescriptor) {
    final type = instrumentDescriptor.type;
    return type == InstrumentType.histogram ||
        type == InstrumentType.counter ||
        type == InstrumentType.observableCounter;
  }

  @override
  AggregatorHandle<PointData<num>> createHandle() {
    return Handle();
  }

  @override
  PointData<num> diff(PointData<num> previousCumulative, PointData<num> currentCumulative) {
    return PointData(
      value: currentCumulative.value - previousCumulative.value,
      startEpochNanos: currentCumulative.startEpochNanos,
      epochNanos: currentCumulative.epochNanos,
      attributes: currentCumulative.attributes,
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
      type: MetricDataType.sum,
      data: SumData(
        isMonotonic: _isMonotonic,
        temporality: temporality,
        points: points.cast(),
      ),
    );
  }
}

final class Handle implements AggregatorHandle<PointData<num>> {
  num _current = 0;

  @override
  PointData<num> aggregateThenMaybeReset(
      {required Int64 startEpochNanos,
      required Int64 epochNanos,
      List<Attribute> attributes = const [],
      bool reset = true}) {
    final value = _current;
    if (reset) {
      _current = 0;
    }

    return PointData(
      startEpochNanos: startEpochNanos,
      epochNanos: epochNanos,
      attributes: attributes,
      value: value,
    );
  }

  @override
  void record(num value) {
    _current += value;
  }
}
