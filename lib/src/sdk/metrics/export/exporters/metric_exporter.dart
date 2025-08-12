// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/view/aggregation.dart';

/// Describes the outcome of an [MetricExporter.export] operation.
enum ExportResult {
  /// The exporter accepted the batch and no retry is required.
  success,

  /// The exporter failed to process the batch; the caller may retry according
  /// to its own policy (for example, with backoff).
  failure,
}

/// {@template opentelemetry.sdk.metrics.exporters.MetricExporter}
///
/// A Metric Exporter is a push based interface for exporting [MetricData] out of [MeterProvider].
///
/// <p>To use, associate an exporter with a [PeriodicExportingMetricReader], and pass as an argument to metricReaders in [MeterProvider].</p>
///
/// {@endtemplate}
abstract interface class MetricExporter {
  /// {@template opentelemetry.sdk.metrics.exporters.MetricExporter.export}
  /// Export a batch of aggregated [MetricData] records.
  ///
  /// - [batch] - The metrics to send.
  ///
  /// Returns a [Future] that completes with an [ExportResult] indicating whether
  /// the data was successfuly exported.
  /// {@endtemplate}
  Future<ExportResult> export({required List<MetricData> batch});

  /// {@template opentelemetry.sdk.metrics.exporters.MetricExporter.selectAggregationTemporality}
  ///
  /// Return the [AggregationTemporality] for the given [InstrumentType].
  ///
  /// {@endtemplate}
  AggregationTemporality selectAggregationTemporality(InstrumentType instrumentType);

  /// {@template opentelemetry.sdk.metrics.exporters.MetricExporter.selectAggregation}
  ///
  /// Return the [Aggregation] for the given [InstrumentType].
  ///
  /// {@endtemplate}
  Aggregation selectAggregation(InstrumentType instrumentType);

  /// {@template opentelemetry.sdk.metrics.exporters.MetricExporter.forceFlush}
  ///
  /// Flushes any remaining data in the exporter.
  ///
  /// Intended for manual flushes and graceful shutdowns.
  ///
  /// {@endtemplate}
  Future<void> forceFlush();

  /// {@template opentelemetry.sdk.metrics.exporters.MetricExporter.shutdown}
  ///
  /// Shut down the exporter and release any held resources and data.
  ///
  /// After this returns, the exporter should reject or ignore further calls to
  /// [export] and [forceFlush]. This method should be idempotent.
  ///
  /// {@endtemplate}
  Future<void> shutdown();
}
