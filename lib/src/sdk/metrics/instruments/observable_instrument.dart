import 'package:opentelemetry/src/api/metrics/instruments/observables.dart' as api;
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/state/async_metric_storage.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/state/observable_registry.dart';

base class ObservableInstrument implements api.Observable {
  final List<AsyncMetricStorage> _storages;
  final InstrumentDescriptor _instrumentDescriptor;
  final ObservableRegistry _observableRegistry;

  const ObservableInstrument({
    required List<AsyncMetricStorage> storages,
    required InstrumentDescriptor instrumentDescriptor,
    required ObservableRegistry observableRegistry,
  })  : _storages = storages,
        _instrumentDescriptor = instrumentDescriptor,
        _observableRegistry = observableRegistry;

  List<AsyncMetricStorage> get storages => _storages;

  InstrumentDescriptor get instrumentDescriptor => _instrumentDescriptor;

  @override
  void addCallback(api.ObservableCallback callback) {
    _observableRegistry.addCallback(callback: callback, instrument: this);
  }

  @override
  void removeCallback(api.ObservableCallback callback) {
    _observableRegistry.removeCallback(callback: callback, instrument: this);
  }
}

final class ObservableCounter extends ObservableInstrument implements api.ObservableCounter {
  const ObservableCounter({
    required super.storages,
    required super.instrumentDescriptor,
    required super.observableRegistry,
  });
}

final class ObservableUpDownCounter extends ObservableInstrument implements api.ObservableUpDownCounter {
  const ObservableUpDownCounter({
    required super.storages,
    required super.instrumentDescriptor,
    required super.observableRegistry,
  });
}

final class ObservableGauge extends ObservableInstrument implements api.ObservableGauge {
  const ObservableGauge({
    required super.storages,
    required super.instrumentDescriptor,
    required super.observableRegistry,
  });
}
