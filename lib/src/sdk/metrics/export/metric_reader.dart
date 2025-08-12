// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/export/aggregation_selector.dart';
import 'package:opentelemetry/src/sdk/metrics/export/cardinality_selector.dart';
import 'package:opentelemetry/src/sdk/metrics/export/exporters/metric_exporter.dart';
import 'package:opentelemetry/src/sdk/metrics/export/metric_producer.dart';
import 'package:opentelemetry/src/sdk/metrics/view/aggregation.dart';

abstract final class MetricReader {
  final AggregationSelector _aggregationSelector;
  final AggregationTemporalitySelector _aggregationTemporalitySelector;
  final CardinalitySelector? _cardinalityLimitSelector;
  final List<MetricProducer>? _producers;

  MetricReader({
    AggregationSelector? aggregationSelector,
    AggregationTemporalitySelector? aggregationTemporalitySelector,
    CardinalitySelector? cardinalityLimitSelector,
    List<MetricProducer>? producers,
  })  : _aggregationSelector = aggregationSelector ?? defaultAggregationSelector,
        _aggregationTemporalitySelector = aggregationTemporalitySelector ?? defaultAggregationTemporalitySelector,
        _cardinalityLimitSelector = cardinalityLimitSelector,
        _producers = producers;

  MetricProducer? get metricProducer;

  void setMetricProducer(MetricProducer producer);

  Aggregation selectAggregation(InstrumentType instrumentType) {
    return _aggregationSelector(instrumentType);
  }

  AggregationTemporality selectAggregationTemporality(InstrumentType instrumentType) {
    return _aggregationTemporalitySelector(instrumentType);
  }

  int selectCardinalityLimit(InstrumentType instrumentType) {
    return _cardinalityLimitSelector?.call(instrumentType) ?? 2000;
  }

  Future<List<MetricData>> collect();

  Future<void> shutdown([int? timeoutMillis]);

  Future<void> forceFlush([int? timeoutMillis]);
}

final class PeriodicExportingMetricReader extends MetricReader {
  final _logger = Logger('opentelemetry.sdk.metrics.periodicexportingmetricreader');

  final MetricExporter _exporter;
  final int _exportIntervalMillis;
  final int _exportTimeoutMillis;

  PeriodicExportingMetricReader({
    required MetricExporter exporter,
    super.cardinalityLimitSelector,
    super.producers,
    int exportIntervalMillis = 60000,
    int exportTimeoutMillis = 30000,
  })  : _exporter = exporter,
        _exportIntervalMillis = exportIntervalMillis,
        _exportTimeoutMillis = exportTimeoutMillis,
        super(
          aggregationSelector: exporter.selectAggregation,
          aggregationTemporalitySelector: exporter.selectAggregationTemporality,
        );

  bool _shutdown = false;

  MetricProducer? _metricProducer;

  @override
  MetricProducer? get metricProducer => _metricProducer;

  Timer? _exportTimer;

  @override
  void setMetricProducer(MetricProducer producer) {
    if (_metricProducer != null) {
      throw Exception('MetricReader can not be bound to a MeterProducer again.');
    }

    _metricProducer = producer;

    _exportTimer = Timer.periodic(Duration(milliseconds: _exportIntervalMillis), (_) {
      _runOnce();
    });
  }

  @override
  Future<List<MetricData>> collect() async {
    if (_metricProducer == null) {
      throw Exception('MetricReader is not bound to a MeterProducer.');
    }

    if (_shutdown) {
      throw Exception('MetricReader is shutdown.');
    }

    final results = await Future.wait(
      [
        _metricProducer!.produce(),
        ..._producers?.map((producer) async => producer.produce()).toList() ?? <Future<List<MetricData>>>[],
      ],
    );

    return results.flattened.toList();
  }

  @override
  Future<void> forceFlush([int? timeoutMillis]) async {
    if (_shutdown) {
      return;
    }

    if (timeoutMillis != null) {
      try {
        await callWithTimeout(
          () async {
            await _runOnce();
            await _exporter.forceFlush();
          },
          Duration(milliseconds: timeoutMillis),
        );
      } on TimeoutException catch (e, trace) {
        _logger.warning(e.message, e, trace);
        return;
      } on Object {
        // WARN
        return;
      } finally {
        return;
      }
    }

    await _runOnce();
    await _exporter.forceFlush();
  }

  @override
  Future<void> shutdown([int? timeoutMillis]) async {
    if (_shutdown) {
      return;
    }

    _exportTimer?.cancel();
    _exportTimer = null;

    if (timeoutMillis != null) {
      try {
        await callWithTimeout(() async {
          await _runOnce();
          await _exporter.shutdown();
        }, Duration(milliseconds: _exportTimeoutMillis));
      } on TimeoutException catch (e, trace) {
        _logger.warning(e.message, e, trace);
        return;
      } on Object {
        // WARN
        return;
      }
    } else {
      await _runOnce();
      await _exporter.shutdown();
    }

    _shutdown = true;
  }

  Future<void> _runOnce() async {
    try {
      await callWithTimeout(_doRun, Duration(milliseconds: _exportTimeoutMillis));
    } on TimeoutException catch (e, trace) {
      _logger.warning(e.message, e, trace);
      return;
    } on Object catch (e, trace) {
      _logger.severe(e.toString(), e, trace);
    }
  }

  Future<void> _doRun() async {
    final metrics = await collect();

    if (metrics.isEmpty) {
      return;
    }

    final result = await _exporter.export(batch: metrics);

    if (result == ExportResult.failure) {
      throw Exception('PeriodicExportingMetricReader: metrics export failed');
    }
  }
}

Future<T> callWithTimeout<T>(Future<T> Function() callback, Duration timeout) async {
  return Future.any([
    callback(),
    Future.delayed(timeout, () => throw TimeoutException('Timeout after $timeout.', timeout)),
  ]);
}
