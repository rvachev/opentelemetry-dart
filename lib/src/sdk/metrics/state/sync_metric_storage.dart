// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/api/common/attribute.dart';
import 'package:opentelemetry/src/api/context/context.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator_handle.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/empty_metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/state/aggregator_holder.dart';
import 'package:opentelemetry/src/sdk/metrics/state/metric_storage.dart';
import 'package:opentelemetry/src/sdk/metrics/state/writeable_metric_storage.dart';
import 'package:opentelemetry/src/sdk/metrics/utils.dart';

final class SyncMetricStorage extends MetricStorage implements WriteableMetricStorage {
  final AggregationTemporality _aggregationTemporality;
  final AttributesProcessor _attributesProcessor;
  final int _aggregationCardinalityLimit;
  final Aggregator _aggregator;

  AggregatorHolder _aggregatorHolder = {};

  SyncMetricStorage({
    required InstrumentDescriptor instrumentDescriptor,
    required AggregationTemporality aggregationTemporality,
    required AttributesProcessor attributesProcessor,
    required Aggregator aggregator,
    int? aggregationCardinalityLimit,
  })  : _aggregationTemporality = aggregationTemporality,
        _attributesProcessor = attributesProcessor,
        _aggregationCardinalityLimit = aggregationCardinalityLimit ?? MetricStorage.defaultMaxCardinality,
        _aggregator = aggregator,
        super(instrumentDescriptor);

  Int64? _lastCollectedEpochNanos;

  @override
  void record({
    required num value,
    required List<Attribute> attributes,
    Context? context,
  }) {
    final attrs = _attributesProcessor.process(incoming: attributes, context: context ?? Context.current);

    _getAggregatorHandle(_aggregatorHolder, attrs).record(value);
  }

  @override
  bool get isEnabled => true;

  @override
  MetricData collect({
    required Resource resource,
    required InstrumentationScope instrumentationScope,
    required Int64 startEpochNanos,
    required Int64 epochNanos,
  }) {
    // Rework this to provide right method to determine if we need to reset the aggregator holder
    // ignore: prefer_const_declarations
    final reset = true;

    final start = _aggregationTemporality == AggregationTemporality.delta ? _lastCollectedEpochNanos : startEpochNanos;

    final aggregatorHandles = _aggregatorHolder;

    if (aggregatorHandles.isEmpty) {
      return EmptyMetricData();
    }

    if (reset) {
      _aggregatorHolder = {};
    }

    final points = <BasePointData>[];

    for (final MapEntry(key: String hashedAttributes, value: AggregatorHandle handle) in aggregatorHandles.entries) {
      final attributes = unhashAttributes(hashedAttributes);
      final point = handle.aggregateThenMaybeReset(
        startEpochNanos: start ?? startEpochNanos,
        epochNanos: epochNanos,
        attributes: attributes,
        reset: reset,
      );

      points.add(point);
    }

    _lastCollectedEpochNanos = epochNanos;

    return points.isEmpty
        ? EmptyMetricData()
        : _aggregator.toMetricData(
            resource: resource,
            instrumentationScope: instrumentationScope,
            metricDescriptor: instrumentDescriptor,
            points: points,
            temporality: _aggregationTemporality,
          );
  }

  AggregatorHandle _getAggregatorHandle(
    Map<String, AggregatorHandle> aggregatorHandles,
    List<Attribute> attributes,
  ) {
    final hashedAttributes = hashAttributes(attributes);

    final handle = aggregatorHandles[hashedAttributes];

    if (handle != null) {
      return handle;
    }

    if (aggregatorHandles.length >= _aggregationCardinalityLimit) {
      final handle = aggregatorHandles[MetricStorage.cardinalityOverflow];
      if (handle != null) {
        return handle;
      }
    }

    final newHandle = _aggregator.createHandle();

    return aggregatorHandles.putIfAbsent(hashedAttributes, () => newHandle);
  }
}
