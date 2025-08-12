// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:meta/meta.dart';
import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/src/api/metrics/metric_advice.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_value_type.dart';
import 'package:opentelemetry/src/sdk/metrics/instruments/instruments.dart' as sdk;
import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/state/meter_shared_state.dart';

/// {@macro opentelemetry.api.metrics.Meter}
class Meter implements api.Meter {
  final MeterSharedState _meterSharedState;

  /// {@macro opentelemetry.api.metrics.Meter}
  @protected
  Meter(this._meterSharedState);

  /// {@macro opentelemetry.api.metrics.Meter.createCounter}
  @override
  api.Counter createCounter(String name, {String? description, String? unit}) {
    final descriptor = InstrumentDescriptor(
      name: name,
      description: description ?? '',
      unit: unit ?? '',
      type: InstrumentType.counter,
      valueType: InstrumentValueType.long,
    );

    final storage = _meterSharedState.registerMetricStorage(descriptor);

    return sdk.Counter(storage: storage, instrumentDescriptor: descriptor);
  }

  /// {@macro opentelemetry.api.metrics.Meter.createGauge}
  @override
  api.Gauge createGauge(String name, {String? description, String? unit}) {
    final descriptor = InstrumentDescriptor(
      name: name,
      description: description ?? '',
      unit: unit ?? '',
      type: InstrumentType.gauge,
      valueType: InstrumentValueType.double,
    );

    final storage = _meterSharedState.registerMetricStorage(descriptor);

    return sdk.Gauge(storage: storage, instrumentDescriptor: descriptor);
  }

  /// {@macro opentelemetry.api.metrics.Meter.createHistogram}
  @override
  api.Histogram createHistogram(String name, {String? description, String? unit, MetricAdvice? advice}) {
    final descriptor = InstrumentDescriptor(
      name: name,
      description: description ?? '',
      unit: unit ?? '',
      type: InstrumentType.histogram,
      valueType: InstrumentValueType.double,
      advice: advice,
    );

    final storage = _meterSharedState.registerMetricStorage(descriptor);

    return sdk.Histogram(storage: storage, instrumentDescriptor: descriptor);
  }

  /// {@macro opentelemetry.api.metrics.Meter.createUpDownCounter}
  @override
  api.UpDownCounter createUpDownCounter(String name, {String? description, String? unit}) {
    final descriptor = InstrumentDescriptor(
      name: name,
      description: description ?? '',
      unit: unit ?? '',
      type: InstrumentType.upDownCounter,
      valueType: InstrumentValueType.double,
    );

    final storage = _meterSharedState.registerMetricStorage(descriptor);

    return sdk.UpDownCounter(storage: storage, instrumentDescriptor: descriptor);
  }

  /// {@macro opentelemetry.api.metrics.Meter.createObservableCounter}
  @override
  api.ObservableCounter createObservableCounter(String name, {String? description, String? unit}) {
    final descriptor = InstrumentDescriptor(
      name: name,
      description: description ?? '',
      unit: unit ?? '',
      type: InstrumentType.observableCounter,
      valueType: InstrumentValueType.double,
    );

    final storages = _meterSharedState.registerAsyncMetricStorage(descriptor);

    return sdk.ObservableCounter(
      storages: storages,
      instrumentDescriptor: descriptor,
      observableRegistry: _meterSharedState.observableRegistry,
    );
  }

  /// {@macro opentelemetry.api.metrics.Meter.createObservableGauge}
  @override
  api.ObservableGauge createObservableGauge(String name, {String? description, String? unit}) {
    final descriptor = InstrumentDescriptor(
      name: name,
      description: description ?? '',
      unit: unit ?? '',
      type: InstrumentType.observableGauge,
      valueType: InstrumentValueType.double,
    );

    final storages = _meterSharedState.registerAsyncMetricStorage(descriptor);

    return sdk.ObservableGauge(
      storages: storages,
      instrumentDescriptor: descriptor,
      observableRegistry: _meterSharedState.observableRegistry,
    );
  }

  /// {@macro opentelemetry.api.metrics.Meter.createObservableUpDownCounter}
  @override
  api.ObservableUpDownCounter createObservableUpDownCounter(String name, {String? description, String? unit}) {
    final descriptor = InstrumentDescriptor(
      name: name,
      description: description ?? '',
      unit: unit ?? '',
      type: InstrumentType.observableUpDownCounter,
      valueType: InstrumentValueType.double,
    );

    final storages = _meterSharedState.registerAsyncMetricStorage(descriptor);

    return sdk.ObservableUpDownCounter(
      storages: storages,
      instrumentDescriptor: descriptor,
      observableRegistry: _meterSharedState.observableRegistry,
    );
  }

  /// {@macro opentelemetry.api.metrics.Meter.addBatchObservableCallback}
  @override
  void addBatchObservableCallback(api.BatchObservableCallback callback, List<api.Observable> observables) {
    _meterSharedState.observableRegistry.addBatchCallback(callback: callback, instruments: observables);
  }

  /// {@macro opentelemetry.api.metrics.Meter.removeBatchObservableCallback}
  @override
  void removeBatchObservableCallback(api.BatchObservableCallback callback, List<api.Observable> observables) {
    _meterSharedState.observableRegistry.removeBatchCallback(callback: callback, instruments: observables);
  }

  /// {@macro opentelemetry.api.metrics.Meter.shutdown}
  @override
  void shutdown() {
    _meterSharedState.shutdown();
  }
}
