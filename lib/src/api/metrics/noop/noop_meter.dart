// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/api/metrics/instruments/gauge.dart';
import 'package:opentelemetry/src/api/metrics/instruments/histogram.dart';
import 'package:opentelemetry/src/api/metrics/instruments/observables.dart';
import 'package:opentelemetry/src/api/metrics/instruments/up_down_counter.dart';
import 'package:opentelemetry/src/api/metrics/noop/noop_counter.dart';
import 'package:opentelemetry/src/experimental_api.dart';

/// A no-op instance of a [Meter]
class NoopMeter implements Meter {
  @override
  Counter<T> createCounter<T extends num>(String name, {String? description, String? unit}) {
    return NoopCounter<T>();
  }

  @override
  void addBatchObservableCallback<T extends num>(BatchObservableCallback<T> callback, List<Observable<T>> observables) {
    // TODO: implement addBatchObservableCallback
  }

  @override
  Gauge<T> createGauge<T extends num>(String name, {String? description, String? unit}) {
    // TODO: implement createGauge
    throw UnimplementedError();
  }

  @override
  Histogram<T> createHistogram<T extends num>(String name, {String? description, String? unit}) {
    // TODO: implement createHistogram
    throw UnimplementedError();
  }

  @override
  ObservableCounter<T> createObservableCounter<T extends num>(String name, {String? description, String? unit}) {
    // TODO: implement createObservableCounter
    throw UnimplementedError();
  }

  @override
  ObservableGauge<T> createObservableGauge<T extends num>(String name, {String? description, String? unit}) {
    // TODO: implement createObservableGauge
    throw UnimplementedError();
  }

  @override
  ObservableUpDownCounter<T> createObservableUpDownCounter<T extends num>(
    String name, {
    String? description,
    String? unit,
  }) {
    // TODO: implement createObservableUpDownCounter
    throw UnimplementedError();
  }

  @override
  UpDownCounter<T> createUpDownCounter<T extends num>(String name, {String? description, String? unit}) {
    // TODO: implement createUpDownCounter
    throw UnimplementedError();
  }

  @override
  void removeBatchObservableCallback<T extends num>(
    BatchObservableCallback<T> callback,
    List<Observable<T>> observables,
  ) {
    // TODO: implement removeBatchObservableCallback
  }
}
