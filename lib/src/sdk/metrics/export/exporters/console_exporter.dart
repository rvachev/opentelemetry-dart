// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/common/instrumentation_scope.dart';
import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/export/aggregation_selector.dart';
import 'package:opentelemetry/src/sdk/metrics/export/exporters/metric_exporter.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/view/aggregation.dart';
import 'package:opentelemetry/src/sdk/resource/resource.dart';

/// {@macro opentelemetry.sdk.metrics.exporters.MetricExporter}
///
/// Exports data to console. Might be useful for testing and debugging metrics.
final class ConsoleMetricExporter implements MetricExporter {
  final AggregationTemporalitySelector _temporalitySelector;

  /// {@macro opentelemetry.sdk.metrics.exporters.MetricExporter}
  ///
  /// Exports data to console. Might be useful for testing and debugging metrics.
  ConsoleMetricExporter({AggregationTemporalitySelector? temporalitySelector})
      : _temporalitySelector = temporalitySelector ?? defaultAggregationTemporalitySelector;

  bool _shutdown = false;

  /// {@macro opentelemetry.sdk.metrics.exporters.MetricExporter.export}
  @override
  Future<ExportResult> export({required List<MetricData> batch}) async {
    if (_shutdown) return ExportResult.failure;

    final rsm = <Resource, Map<InstrumentationScope, List<MetricData>>>{};

    for (final data in batch) {
      if (data.isEmpty) {
        continue;
      }
      final scopeToMetrics = rsm[data.resource] ?? <InstrumentationScope, List<MetricData>>{};
      scopeToMetrics[data.instrumentationScope] = (scopeToMetrics[data.instrumentationScope] ?? <MetricData>[])
        ..add(data);
      rsm[data.resource] = scopeToMetrics;
    }

    for (final entry in rsm.entries) {
      print('resource: ${_toResourceJson(entry.key)}');
      for (final scopeToMetrics in entry.value.entries) {
        print('scope: ${_toScopeJson(scopeToMetrics.key)}');
        for (final metricData in scopeToMetrics.value) {
          print('metrics: ${_metricDataToJson(metricData)}');
        }
      }
    }

    return ExportResult.success;
  }

  String _toResourceJson(Resource resource) {
    return '''{
  'attributes': ${[
      for (final entry in resource.attributes.entries)
        {
          'key': entry.key,
          'value': {
            'stringValue': entry.value.toString(),
          },
        }
    ]}
}''';
  }

  String _toScopeJson(InstrumentationScope scope) {
    return '''{
  'name': ${scope.name},
  'version': ${scope.version},
  'attributes': ${[
      for (final entry in scope.attributes)
        {
          'key': entry.key,
          'value': {
            'stringValue': entry.value.toString(),
          },
        }
    ]}
}''';
  }

  String _metricDataToJson(MetricData metricData) {
    return '''{
  'name': ${metricData.name},
  'description': ${metricData.description},
  'unit': ${metricData.unit},
  '${metricData.type.name}': {
    'dataPoints': ${metricData.data},
  }
}''';
  }

  /// {@macro opentelemetry.sdk.metrics.exporters.MetricExporter.selectAggregation}
  @override
  Aggregation selectAggregation(InstrumentType instrumentType) {
    return defaultAggregationSelector.call(instrumentType);
  }

  /// {@macro opentelemetry.sdk.metrics.exporters.MetricExporter.selectAggregationTemporality}
  @override
  AggregationTemporality selectAggregationTemporality(InstrumentType instrumentType) {
    return _temporalitySelector.call(instrumentType);
  }

  /// {@macro opentelemetry.sdk.metrics.exporters.MetricExporter.forceFlush}
  @override
  Future<void> forceFlush() {
    return Future.value();
  }

  /// {@macro opentelemetry.sdk.metrics.exporters.MetricExporter.shutdown}
  @override
  Future<void> shutdown() {
    _shutdown = true;
    return Future.value();
  }
}
