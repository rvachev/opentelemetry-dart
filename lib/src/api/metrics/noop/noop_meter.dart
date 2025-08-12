// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/api/metrics/instruments/instruments.dart';
import 'package:opentelemetry/src/api/metrics/meter.dart';
import 'package:opentelemetry/src/api/metrics/metric_advice.dart';
import 'package:opentelemetry/src/api/metrics/noop/noop_instruments.dart';

/// A no-op instance of a [Meter]
class NoopMeter implements Meter {
  const NoopMeter._();

  static const NoopMeter instance = NoopMeter._();

  @override
  Counter createCounter(String name, {String? description, String? unit}) {
    return NoopCounter.instance;
  }

  @override
  Gauge createGauge(String name, {String? description, String? unit}) {
    return NoopGauge.instance;
  }

  @override
  UpDownCounter createUpDownCounter(String name, {String? description, String? unit}) {
    return NoopUpDownCounter.instance;
  }

  @override
  Histogram createHistogram(String name, {String? description, String? unit, MetricAdvice? advice}) {
    return NoopHistogram.instance;
  }

  @override
  ObservableCounter createObservableCounter(String name, {String? description, String? unit}) {
    return NoopObservableCounter.instance;
  }

  @override
  ObservableGauge createObservableGauge(String name, {String? description, String? unit}) {
    return NoopObservableGauge.instance;
  }

  @override
  ObservableUpDownCounter createObservableUpDownCounter(
    String name, {
    String? description,
    String? unit,
  }) {
    return NoopObservableUpDownCounter.instance;
  }

  @override
  void addBatchObservableCallback(BatchObservableCallback callback, List<Observable> observables) {}

  @override
  void removeBatchObservableCallback(
    BatchObservableCallback callback,
    List<Observable> observables,
  ) {}

  @override
  void shutdown() {}
}
