// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/src/sdk/common/instrumentation_scope.dart';
import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/empty_metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/state/aggregator_holder.dart';
import 'package:opentelemetry/src/sdk/metrics/state/metric_storage.dart';
import 'package:opentelemetry/src/sdk/metrics/state/writeable_metric_storage.dart';
import 'package:opentelemetry/src/sdk/metrics/view/attribute_processor.dart';
import 'package:opentelemetry/src/sdk/metrics/utils.dart';
import 'package:opentelemetry/src/sdk/resource/resource.dart';

final class AsyncMetricStorage<T extends BasePointData> extends MetricStorage implements WriteableMetricStorage {
  final AggregationTemporality _aggregationTemporality;
  final AttributesProcessor _attributesProcessor;
  final int _aggregationCardinalityLimit;
  final Aggregator<T> _aggregator;

  final AggregatorHolder<T> _aggregatorHolder = {};
  var _lastPoints = <String, T>{};

  AsyncMetricStorage({
    required InstrumentDescriptor instrumentDescriptor,
    required AggregationTemporality aggregationTemporality,
    required AttributesProcessor attributesProcessor,
    required Aggregator<T> aggregator,
    int? aggregationCardinalityLimit,
  })  : _aggregationTemporality = aggregationTemporality,
        _attributesProcessor = attributesProcessor,
        _aggregationCardinalityLimit = aggregationCardinalityLimit ?? MetricStorage.defaultMaxCardinality,
        _aggregator = aggregator,
        super(instrumentDescriptor);

  Int64? _lastCollectedEpochNanos;

  @override
  MetricData collect({
    required Resource resource,
    required InstrumentationScope instrumentationScope,
    required Int64 startEpochNanos,
    required Int64 epochNanos,
  }) {
    final result = _aggregationTemporality == AggregationTemporality.delta
        ? _collectWithDeltaAggregationTemporality(
            startEpochNanos: _lastCollectedEpochNanos ?? startEpochNanos,
            epochNanos: epochNanos,
          )
        : _collectWithCumulativeAggregationTemporality(
            startEpochNanos: startEpochNanos,
            epochNanos: epochNanos,
          );

    if (result.isEmpty) {
      return EmptyMetricData();
    }

    _lastCollectedEpochNanos = epochNanos;

    _aggregatorHolder.clear();

    return _aggregator.toMetricData(
      resource: resource,
      instrumentationScope: instrumentationScope,
      metricDescriptor: instrumentDescriptor,
      points: result,
      temporality: _aggregationTemporality,
    );
  }

  @override
  void record({required num value, required List<Attribute> attributes, Context? context}) {
    final attrs = _validateAndProcessAttributes(attributes, context);
    _aggregatorHolder.putIfAbsent(hashAttributes(attrs), _aggregator.createHandle).record(value);
  }

  List<Attribute> _validateAndProcessAttributes(List<Attribute> attributes, [Context? context]) {
    if (_aggregatorHolder.length >= _aggregationCardinalityLimit) {
      return MetricStorage.cardinalityOverflow;
    }

    final ctx = context ?? Context.current;
    return _attributesProcessor.process(incoming: attributes, context: ctx);
  }

  List<T> _collectWithDeltaAggregationTemporality({
    required Int64 startEpochNanos,
    required Int64 epochNanos,
  }) {
    final currentPoints = <String, T>{};

    for (final MapEntry(key: hashedAttributes, value: handle) in _aggregatorHolder.entries) {
      final point = handle.aggregateThenMaybeReset(
        startEpochNanos: startEpochNanos,
        epochNanos: epochNanos,
        attributes: unhashAttributes(hashedAttributes),
        reset: true,
      );
      currentPoints.putIfAbsent(hashedAttributes, () => point);
    }

    final deltaPoints = <T>[];
    for (final MapEntry(key: attributes, value: currentPoint) in currentPoints.entries) {
      final lastPoint = _lastPoints.remove(attributes);

      T deltaPoint;
      if (lastPoint == null) {
        deltaPoint = currentPoint;
      } else {
        deltaPoint = _aggregator.diff(lastPoint, currentPoint);
      }
      deltaPoints.add(deltaPoint);
    }

    _lastPoints = currentPoints;

    return deltaPoints;
  }

  List<T> _collectWithCumulativeAggregationTemporality({
    required Int64 startEpochNanos,
    required Int64 epochNanos,
  }) {
    return _aggregatorHolder.entries.map((entry) {
      return entry.value.aggregateThenMaybeReset(
        startEpochNanos: startEpochNanos,
        epochNanos: epochNanos,
        attributes: unhashAttributes(entry.key),
        reset: true,
      );
    }).toList();
  }

  @override
  bool get isEnabled => true;
}
