// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

// ignore_for_file: comment_references

import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/metrics/data/data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:http/http.dart' as http;

import '../../../proto/opentelemetry/proto/collector/metrics/v1/metrics_service.pb.dart' as pb_metrics_service;
import '../../../proto/opentelemetry/proto/common/v1/common.pb.dart' as pb_common;
import '../../../proto/opentelemetry/proto/resource/v1/resource.pb.dart' as pb_resource;
import '../../../proto/opentelemetry/proto/metrics/v1/metrics.pb.dart' as pb_metrics;

/// {@macro opentelemetry.sdk.metrics.exporters.MetricExporter}
///
/// Exports metrics to Otel Collector mapping [MetricData] to protobufs
class CollectorMetricExporter implements MetricExporter {
  final Logger _log = Logger('opentelemetry.CollectorMetricExporter');

  /// The URI to send metrics to.
  final Uri _uri;

  /// The HTTP client to use to send metrics.
  /// If not provided, a default client will be used.
  final http.Client _client;

  /// Headers to send with each request.
  final Map<String, String> _headers;

  /// Selects the [AggregationTemporality] for the given [InstrumentType].
  /// If not provided, the default will be used [defaultAggregationTemporalitySelector].
  final AggregationTemporalitySelector _temporalitySelector;

  final void Function(List<MetricData> batch)? _failedToExportMetrics;

  /// {@macro opentelemetry.sdk.metrics.exporters.MetricExporter}
  CollectorMetricExporter(
    Uri uri, {
    http.Client? client,
    Map<String, String> headers = const {},
    AggregationTemporalitySelector? temporalitySelector,
    void Function(List<MetricData> batch)? failedToExportMetrics,
  })  : _uri = uri,
        _client = client ?? http.Client(),
        _headers = headers,
        _temporalitySelector = temporalitySelector ?? defaultAggregationTemporalitySelector,
        _failedToExportMetrics = failedToExportMetrics;

  var _isShutdown = false;

  /// {@macro opentelemetry.sdk.metrics.exporters.MetricExporter.export}
  @override
  Future<ExportResult> export({required List<MetricData> batch}) async {
    if (_isShutdown) {
      return ExportResult.failure;
    }

    if (batch.isEmpty) {
      return ExportResult.success;
    }

    return send(batch);
  }

  @protected
  Future<ExportResult> send(List<MetricData> batch) async {
    const maxRetries = 3;
    var retries = 0;
    // Retryable status from the spec: https://opentelemetry.io/docs/specs/otlp/#failures-1
    const valid_retry_codes = [429, 502, 503, 504];

    final resourceMetrics = _resourceMetricsToProtobuf(batch);

    if (resourceMetrics.isEmpty) {
      return ExportResult.success;
    }

    final body = pb_metrics_service.ExportMetricsServiceRequest(
      resourceMetrics: resourceMetrics,
    );

    final headers = {'Content-Type': 'application/x-protobuf'}..addAll(_headers);

    while (retries < maxRetries) {
      try {
        final response = await _client.post(
          _uri,
          body: body.writeToBuffer(),
          headers: headers,
        );
        if (response.statusCode == 200) {
          return ExportResult.success;
        }
        // If the response is not 200, log a warning
        _log.warning('Failed to export ${batch.length} metrics. '
            'HTTP status code: ${response.statusCode}');
        // If the response is not a valid retry code, do not retry
        if (!valid_retry_codes.contains(response.statusCode)) {
          return ExportResult.failure;
        }
      } catch (e) {
        _log.warning('Failed to export ${batch.length} metrics. $e');
        return ExportResult.failure;
      }
      // Exponential backoff with jitter
      final delay = _calculateJitteredDelay(retries++, Duration(milliseconds: 100));
      await Future.delayed(delay);
    }
    _log.severe('Failed to export ${batch.length} metrics after $maxRetries retries');

    // We call this function to inform about a batch of metrics which were not exported to the collector
    _failedToExportMetrics?.call(batch);

    return ExportResult.failure;
  }

  Duration _calculateJitteredDelay(int retries, Duration baseDelay) {
    final delay = baseDelay.inMilliseconds * pow(2, retries);
    final jitter = Random().nextDouble() * delay;
    return Duration(milliseconds: (delay + jitter).toInt());
  }

  /// {@macro opentelemetry.sdk.metrics.exporters.MetricExporter.selectAggregation}
  ///
  /// Uses [defaultAggregationSelector] to select the aggregation.
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
  ///
  /// Also closes the HTTP client.
  @override
  Future<void> shutdown() async {
    _isShutdown = true;
    _client.close();
  }

  Iterable<pb_metrics.ResourceMetrics> _resourceMetricsToProtobuf(List<MetricData> batch) {
    final resourceToMetrics = <Resource, Map<InstrumentationScope, List<pb_metrics.Metric>>>{};

    for (final data in batch) {
      if (data.isEmpty) {
        continue;
      }
      final scopeToMetrics = resourceToMetrics[data.resource] ?? <InstrumentationScope, List<pb_metrics.Metric>>{};
      scopeToMetrics[data.instrumentationScope] = (scopeToMetrics[data.instrumentationScope] ?? <pb_metrics.Metric>[])
        ..add(_metricToProtobuf(data));
      resourceToMetrics[data.resource] = scopeToMetrics;
    }

    final resourceMetrics = <pb_metrics.ResourceMetrics>[];
    for (final MapEntry(
          key: Resource resource,
          value: Map<InstrumentationScope, List<pb_metrics.Metric>> scopeToMetrics
        ) in resourceToMetrics.entries) {
      final attrs = <pb_common.KeyValue>[];
      for (final attr in resource.attributes.entries) {
        attrs.add(pb_common.KeyValue(
          key: attr.key,
          value: _attributeValueToProtobuf(attr.value),
        ));
      }

      final resourceMetric = pb_metrics.ResourceMetrics(
        resource: pb_resource.Resource(attributes: attrs),
        scopeMetrics: [],
      );

      for (final MapEntry(key: InstrumentationScope scope, value: List<pb_metrics.Metric> metrics)
          in scopeToMetrics.entries) {
        resourceMetric.scopeMetrics.add(pb_metrics.ScopeMetrics(
          scope: pb_common.InstrumentationScope(
            name: scope.name,
            version: scope.version,
            attributes: [
              for (final attr in scope.attributes)
                pb_common.KeyValue(key: attr.key, value: _attributeValueToProtobuf(attr.value)),
            ],
          ),
          metrics: metrics,
        ));
      }
      resourceMetrics.add(resourceMetric);
    }

    return resourceMetrics;
  }

  pb_metrics.Metric _metricToProtobuf(MetricData metricData) {
    return pb_metrics.Metric(
      name: metricData.name,
      description: metricData.description,
      unit: metricData.unit,
      sum: metricData.sumData != null ? _sumToProtobuf(metricData.sumData!) : null,
      gauge: metricData.gaugeData != null ? _gaugeToProtobuf(metricData.gaugeData!) : null,
      histogram: metricData.histogramData != null ? _histogramToProtobuf(metricData.histogramData!) : null,
      exponentialHistogram: metricData.exponentialHistogramData != null
          ? _exponentialHistogramToProtobuf(metricData.exponentialHistogramData!)
          : null,
    );
  }

  pb_metrics.Sum _sumToProtobuf(SumData<PointData<num>> sumData) {
    return pb_metrics.Sum(
      aggregationTemporality: _temporalityToProtobuf(sumData.temporality),
      isMonotonic: sumData.isMonotonic,
      dataPoints: sumData.points.map(_numberDataPointToProtobuf),
    );
  }

  pb_metrics.Gauge _gaugeToProtobuf(GaugeData<PointData<num>> gaugeData) {
    return pb_metrics.Gauge(
      dataPoints: gaugeData.points.map(_numberDataPointToProtobuf),
    );
  }

  pb_metrics.Histogram _histogramToProtobuf(HistogramData histogramData) {
    return pb_metrics.Histogram(
      aggregationTemporality: _temporalityToProtobuf(histogramData.temporality),
      dataPoints: histogramData.points.map(_histogramDataPointToProtobuf),
    );
  }

  pb_metrics.ExponentialHistogram _exponentialHistogramToProtobuf(ExponentialHistogramData exponentialHistogramData) {
    return pb_metrics.ExponentialHistogram(
      aggregationTemporality: _temporalityToProtobuf(exponentialHistogramData.temporality),
      dataPoints: exponentialHistogramData.points.map(_exponentialHistogramDataPointToProtobuf),
    );
  }

  pb_metrics.AggregationTemporality _temporalityToProtobuf(AggregationTemporality temporality) {
    switch (temporality) {
      case AggregationTemporality.delta:
        return pb_metrics.AggregationTemporality.AGGREGATION_TEMPORALITY_DELTA;
      case AggregationTemporality.cumulative:
        return pb_metrics.AggregationTemporality.AGGREGATION_TEMPORALITY_CUMULATIVE;
    }
  }

  pb_metrics.NumberDataPoint _numberDataPointToProtobuf(PointData<num> pointData) {
    return pb_metrics.NumberDataPoint(
      asDouble: pointData.value.toDouble(),
      startTimeUnixNano: pointData.startEpochNanos,
      timeUnixNano: pointData.epochNanos,
      attributes: [
        for (final attr in pointData.attributes)
          pb_common.KeyValue(key: attr.key, value: _attributeValueToProtobuf(attr.value)),
      ],
    );
  }

  pb_metrics.HistogramDataPoint _histogramDataPointToProtobuf(HistogramPointData histrogramPointData) {
    return pb_metrics.HistogramDataPoint(
      count: Int64(histrogramPointData.count),
      sum: histrogramPointData.sum,
      min: histrogramPointData.min,
      max: histrogramPointData.max,
      bucketCounts: histrogramPointData.counts.map(Int64.new).toList(),
      explicitBounds: histrogramPointData.boundaries,
      startTimeUnixNano: histrogramPointData.startEpochNanos,
      timeUnixNano: histrogramPointData.epochNanos,
      attributes: [
        for (final attr in histrogramPointData.attributes)
          pb_common.KeyValue(key: attr.key, value: _attributeValueToProtobuf(attr.value)),
      ],
    );
  }

  pb_metrics.ExponentialHistogramDataPoint _exponentialHistogramDataPointToProtobuf(
    ExponentialHistogramPointData exponentialHistogramPointData,
  ) {
    return pb_metrics.ExponentialHistogramDataPoint(
      startTimeUnixNano: exponentialHistogramPointData.startEpochNanos,
      timeUnixNano: exponentialHistogramPointData.epochNanos,
      attributes: [
        for (final attr in exponentialHistogramPointData.attributes)
          pb_common.KeyValue(key: attr.key, value: _attributeValueToProtobuf(attr.value)),
      ],
      scale: exponentialHistogramPointData.scale,
      zeroCount: Int64(exponentialHistogramPointData.zeroCount),
      positive: pb_metrics.ExponentialHistogramDataPoint_Buckets(
        offset: exponentialHistogramPointData.positiveBuckets.offset,
        bucketCounts: exponentialHistogramPointData.positiveBuckets.counts.map(Int64.new).toList(),
      ),
      negative: pb_metrics.ExponentialHistogramDataPoint_Buckets(
        offset: exponentialHistogramPointData.negativeBuckets.offset,
        bucketCounts: exponentialHistogramPointData.negativeBuckets.counts.map(Int64.new).toList(),
      ),
      count: Int64(exponentialHistogramPointData.count),
      sum: exponentialHistogramPointData.sum,
      min: exponentialHistogramPointData.min,
      max: exponentialHistogramPointData.max,
    );
  }

  pb_common.AnyValue _attributeValueToProtobuf(Object value) {
    switch (value.runtimeType) {
      case String:
        return pb_common.AnyValue(stringValue: value as String);
      case bool:
        return pb_common.AnyValue(boolValue: value as bool);
      case double:
        return pb_common.AnyValue(doubleValue: value as double);
      case int:
        return pb_common.AnyValue(intValue: Int64(value as int));
      case List:
        final list = value as List;
        if (list.isNotEmpty) {
          switch (list[0].runtimeType) {
            case String:
              final values = [] as List<pb_common.AnyValue>;
              for (final str in list) {
                values.add(pb_common.AnyValue(stringValue: str));
              }
              return pb_common.AnyValue(arrayValue: pb_common.ArrayValue(values: values));
            case bool:
              final values = [] as List<pb_common.AnyValue>;
              for (final b in list) {
                values.add(pb_common.AnyValue(boolValue: b));
              }
              return pb_common.AnyValue(arrayValue: pb_common.ArrayValue(values: values));
            case double:
              final values = [] as List<pb_common.AnyValue>;
              for (final d in list) {
                values.add(pb_common.AnyValue(doubleValue: d));
              }
              return pb_common.AnyValue(arrayValue: pb_common.ArrayValue(values: values));
            case int:
              final values = [] as List<pb_common.AnyValue>;
              for (final i in list) {
                values.add(pb_common.AnyValue(intValue: i));
              }
              return pb_common.AnyValue(arrayValue: pb_common.ArrayValue(values: values));
          }
        }
    }
    return pb_common.AnyValue();
  }
}
