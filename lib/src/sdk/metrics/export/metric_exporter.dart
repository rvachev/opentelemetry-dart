import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/export/aggregation_selector.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/aggregation.dart';

enum ExportResult {
  success,
  failure,
}

abstract interface class MetricExporter {
  Future<ExportResult> export({required List<MetricData> batch});

  Future<void> forceFlush();

  AggregationTemporality selectAggregationTemporality(InstrumentType instrumentType);

  Aggregation selectAggregation(InstrumentType instrumentType);

  Future<void> shutdown();
}

final class ConsoleMetricExporter implements MetricExporter {
  final AggregationTemporalitySelector _temporalitySelector;

  ConsoleMetricExporter({AggregationTemporalitySelector? temporalitySelector})
      : _temporalitySelector = temporalitySelector ?? defaultAggregationTemporalitySelector;

  bool _shutdown = false;

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
      print(_toResourceJson(entry.key));
      for (final scopeToMetrics in entry.value.entries) {
        print(_toScopeJson(scopeToMetrics.key));
        for (final metricData in scopeToMetrics.value) {
          print(_metricDataToJson(metricData));
        }
      }
    }

    return ExportResult.success;
  }

  Map<String, dynamic> _toResourceJson(Resource resource) {
    return {
      'attributes': [
        for (final entry in resource.attributes.entries)
          {
            'key': entry.key,
            'value': {
              'stringValue': entry.value.toString(),
            },
          }
      ]
    };
  }

  Map<String, dynamic> _toScopeJson(InstrumentationScope scope) {
    return {
      'name': scope.name,
      'version': scope.version,
      'attributes': [
        for (final entry in scope.attributes)
          {
            'key': entry.key,
            'value': {
              'stringValue': entry.value.toString(),
            },
          }
      ]
    };
  }

  Map<String, dynamic> _metricDataToJson(MetricData metricData) {
    return {
      'name': metricData.name,
      'description': metricData.description,
      'unit': metricData.unit,
      '${metricData.type.name}': {
        'dataPoints': metricData.data,
      }
    };
  }

  @override
  Future<void> forceFlush() {
    return Future.value();
  }

  @override
  Aggregation selectAggregation(InstrumentType instrumentType) {
    return defaultAggregationSelector.call(instrumentType);
  }

  @override
  AggregationTemporality selectAggregationTemporality(InstrumentType instrumentType) {
    return _temporalitySelector.call(instrumentType);
  }

  @override
  Future<void> shutdown() {
    _shutdown = true;
    return Future.value();
  }
}
