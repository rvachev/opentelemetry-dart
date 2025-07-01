// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/src/api/metrics/instruments/instruments.dart';

/// A no-op instance of a [Counter]
final class NoopCounter implements Counter {
  const NoopCounter._();

  static const NoopCounter instance = NoopCounter._();

  @override
  void add(num value, {List<Attribute>? attributes, Context? context}) {}
}

final class NoopGauge implements Gauge {
  const NoopGauge._();

  static const NoopGauge instance = NoopGauge._();

  @override
  void record(num value, {List<Attribute>? attributes, Context? context}) {}
}

final class NoopUpDownCounter implements UpDownCounter {
  const NoopUpDownCounter._();

  static const NoopUpDownCounter instance = NoopUpDownCounter._();

  @override
  void add(num value, {List<Attribute>? attributes, Context? context}) {}
}

final class NoopHistogram implements Histogram {
  const NoopHistogram._();

  static const NoopHistogram instance = NoopHistogram._();

  @override
  void record(num value, {List<Attribute>? attributes, Context? context}) {}
}

final class NoopObservableCounter implements ObservableCounter {
  const NoopObservableCounter._();

  static const NoopObservableCounter instance = NoopObservableCounter._();

  @override
  void addCallback(ObservableCallback callback) {}

  @override
  void removeCallback(ObservableCallback callback) {}
}

final class NoopObservableGauge implements ObservableGauge {
  const NoopObservableGauge._();

  static const NoopObservableGauge instance = NoopObservableGauge._();

  @override
  void addCallback(ObservableCallback callback) {}

  @override
  void removeCallback(ObservableCallback callback) {}
}

final class NoopObservableUpDownCounter implements ObservableUpDownCounter {
  const NoopObservableUpDownCounter._();

  static const NoopObservableUpDownCounter instance = NoopObservableUpDownCounter._();

  @override
  void addCallback(ObservableCallback callback) {}

  @override
  void removeCallback(ObservableCallback callback) {}
}
