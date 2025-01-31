// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/api/metrics/instruments/instruments.dart';

abstract class Meter {
  /// Creates a new [Counter] instrument named [name]. Additional details about
  /// this metric can be captured in [description] and units can be specified in
  /// [unit].
  ///
  /// See https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#instrument-naming-rule
  Counter<T> createCounter<T extends num>(String name, {String description, String unit});

  UpDownCounter<T> createUpDownCounter<T extends num>(String name, {String description, String unit});

  Gauge<T> createGauge<T extends num>(String name, {String description, String unit});

  Histogram<T> createHistogram<T extends num>(String name, {String description, String unit});

  ObservableCounter<T> createObservableCounter<T extends num>(String name, {String description, String unit});

  ObservableGauge<T> createObservableGauge<T extends num>(String name, {String description, String unit});

  ObservableUpDownCounter<T> createObservableUpDownCounter<T extends num>(
    String name, {
    String description,
    String unit,
  });

  void addBatchObservableCallback<T extends num>(BatchObservableCallback<T> callback, List<Observable<T>> observables);

  void removeBatchObservableCallback<T extends num>(
    BatchObservableCallback<T> callback,
    List<Observable<T>> observables,
  );
}
