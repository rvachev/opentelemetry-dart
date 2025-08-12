// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/api/metrics/instruments/instruments.dart';
import 'package:opentelemetry/src/api/metrics/metric_advice.dart';

/// {@template opentelemetry.api.metrics.Meter}
///
/// Provides instruments used to record measurements which are aggregated to metrics.
///
/// See https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#instrument-naming-rule
///
/// {@endtemplate}
abstract class Meter {
  /// {@template opentelemetry.api.metrics.Meter.createCounter}
  ///
  /// Creates a new [Counter] instrument named [name]. Additional details about
  /// this metric can be captured in [description] and units can be specified in
  /// [unit].
  ///
  /// {@endtemplate}
  Counter createCounter(String name, {String description, String unit});

  /// {@template opentelemetry.api.metrics.Meter.createUpDownCounter}
  ///
  /// Creates a new [UpDownCounter] instrument named [name]. Additional details about
  /// this metric can be captured in [description] and units can be specified in
  /// [unit].
  ///
  /// {@endtemplate}
  UpDownCounter createUpDownCounter(String name, {String description, String unit});

  /// {@template opentelemetry.api.metrics.Meter.createGauge}
  ///
  /// Creates a new [Gauge] instrument named [name]. Additional details about
  /// this metric can be captured in [description] and units can be specified in
  /// [unit].
  ///
  /// {@endtemplate}
  Gauge createGauge(String name, {String description, String unit});

  /// {@template opentelemetry.api.metrics.Meter.createHistogram}
  ///
  /// Creates a new [Histogram] instrument named [name]. Additional details about
  /// this metric can be captured in [description] and units can be specified in
  /// [unit].
  ///
  /// In case if you want to configure the histrogram buckets provide [advice] with array of boundaries.
  ///
  /// {@endtemplate}
  Histogram createHistogram(String name, {String description, String unit, MetricAdvice advice});

  /// {@template opentelemetry.api.metrics.Meter.createObservableCounter}
  ///
  /// Creates a new [ObservableCounter] instrument named [name]. Additional details about
  /// this metric can be captured in [description] and units can be specified in
  /// [unit].
  ///
  /// {@endtemplate}
  ObservableCounter createObservableCounter(String name, {String description, String unit});

  /// {@template opentelemetry.api.metrics.Meter.createObservableGauge}
  ///
  /// Creates a new [ObservableGauge] instrument named [name]. Additional details about
  /// this metric can be captured in [description] and units can be specified in
  /// [unit].
  ///
  /// {@endtemplate}
  ObservableGauge createObservableGauge(String name, {String description, String unit});

  /// {@template opentelemetry.api.metrics.Meter.createObservableUpDownCounter}
  ///
  /// Creates a new [ObservableUpDownCounter] instrument named [name]. Additional details about
  /// this metric can be captured in [description] and units can be specified in
  /// [unit].
  ///
  /// {@endtemplate}
  ObservableUpDownCounter createObservableUpDownCounter(
    String name, {
    String description,
    String unit,
  });

  /// {@template opentelemetry.api.metrics.Meter.addBatchObservableCallback}
  ///
  /// Adds a callback to be called when a batch of [Observable] instruments are recorded.
  ///
  /// {@endtemplate}
  void addBatchObservableCallback(BatchObservableCallback callback, List<Observable> observables);

  /// {@template opentelemetry.api.metrics.Meter.removeBatchObservableCallback}
  ///
  /// Removes a callback from being called when a batch of [Observable] instruments are recorded.
  ///
  /// {@endtemplate}
  void removeBatchObservableCallback(
    BatchObservableCallback callback,
    List<Observable> observables,
  );

  /// {@template opentelemetry.api.metrics.Meter.shutdown}
  ///
  /// Shuts down the meter and releases any held resources.
  ///
  /// {@endtemplate}
  void shutdown();
}
