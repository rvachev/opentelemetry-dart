// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/api/metrics/instruments/instruments.dart';

abstract class Meter {
  /// Creates a new [Counter] instrument named [name]. Additional details about
  /// this metric can be captured in [description] and units can be specified in
  /// [unit].
  ///
  /// See https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#instrument-naming-rule
  Counter createCounter(String name, {String description, String unit});

  UpDownCounter createUpDownCounter(String name, {String description, String unit});

  Gauge createGauge(String name, {String description, String unit});

  Histogram createHistogram(String name, {String description, String unit});

  ObservableCounter createObservableCounter(String name, {String description, String unit});

  ObservableGauge createObservableGauge(String name, {String description, String unit});

  ObservableUpDownCounter createObservableUpDownCounter(
    String name, {
    String description,
    String unit,
  });

  void addBatchObservableCallback(BatchObservableCallback callback, List<Observable> observables);

  void removeBatchObservableCallback(
    BatchObservableCallback callback,
    List<Observable> observables,
  );
}
