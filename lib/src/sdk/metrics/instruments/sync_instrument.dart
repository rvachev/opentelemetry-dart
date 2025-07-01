import 'package:opentelemetry/api.dart' as api;
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/state/writeable_metric_storage.dart';

base class SyncInstrument {
  final WriteableMetricStorage _storage;
  final InstrumentDescriptor _instrumentDescriptor;

  SyncInstrument({required WriteableMetricStorage storage, required InstrumentDescriptor instrumentDescriptor})
      : _storage = storage,
        _instrumentDescriptor = instrumentDescriptor;

  InstrumentDescriptor get instrumentDescriptor => _instrumentDescriptor;

  void recordMeasurement({required num value, required List<api.Attribute> attributes, required api.Context context}) {
    _storage.record(value: value, attributes: attributes, context: context);
  }
}

final class Counter extends SyncInstrument implements api.Counter {
  Counter({required super.storage, required super.instrumentDescriptor});

  @override
  void add(num value, {List<api.Attribute>? attributes, api.Context? context}) {
    if (value < 0) {
      return;
    }

    recordMeasurement(value: value, attributes: attributes ?? [], context: context ?? api.Context.current);
  }
}

final class Gauge extends SyncInstrument implements api.Gauge {
  Gauge({required super.storage, required super.instrumentDescriptor});

  @override
  void record(num value, {List<api.Attribute>? attributes, api.Context? context}) {
    recordMeasurement(value: value, attributes: attributes ?? [], context: context ?? api.Context.current);
  }
}

final class Histogram extends SyncInstrument implements api.Histogram {
  Histogram({required super.storage, required super.instrumentDescriptor});

  @override
  void record(num value, {List<api.Attribute>? attributes, api.Context? context}) {
    if (value < 0) {
      return;
    }

    recordMeasurement(value: value, attributes: attributes ?? [], context: context ?? api.Context.current);
  }
}

final class UpDownCounter extends SyncInstrument implements api.UpDownCounter {
  UpDownCounter({required super.storage, required super.instrumentDescriptor});

  @override
  void add(num value, {List<api.Attribute>? attributes, api.Context? context}) {
    recordMeasurement(value: value, attributes: attributes ?? [], context: context ?? api.Context.current);
  }
}
