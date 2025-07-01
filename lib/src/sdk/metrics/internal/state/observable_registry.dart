import 'package:opentelemetry/src/api/metrics/instruments/instruments.dart' as api;
import 'package:opentelemetry/src/sdk/metrics/instruments/observable_instrument.dart';
import 'package:opentelemetry/src/sdk/metrics/observable_result.dart';

typedef ObservableCallbackRecord = ({
  api.ObservableCallback callback,
  ObservableInstrument instrument,
});

typedef BatchObservableCallbackRecord = ({
  api.BatchObservableCallback callback,
  Set<ObservableInstrument> instruments,
});

final class ObservableRegistry {
  final _callbacks = <ObservableCallbackRecord>[];
  final _batchCallbacks = <BatchObservableCallbackRecord>[];

  void addCallback({required api.ObservableCallback callback, required ObservableInstrument instrument}) {
    final index = _findCallback(callback: callback, instrument: instrument);

    if (index != -1) {
      return;
    }

    _callbacks.add((callback: callback, instrument: instrument));
  }

  void removeCallback({required api.ObservableCallback callback, required ObservableInstrument instrument}) {
    final index = _findCallback(callback: callback, instrument: instrument);

    if (index == -1) {
      return;
    }

    _callbacks.removeAt(index);
  }

  void addBatchCallback({
    required api.BatchObservableCallback callback,
    required List<api.Observable> instruments,
  }) {
    final observableInstruments = Set.of(instruments.whereType<ObservableInstrument>());

    if (observableInstruments.isEmpty) return;

    final index = _findBatchCallback(callback: callback, instruments: observableInstruments);
    if (index != -1) {
      return;
    }

    _batchCallbacks.add((callback: callback, instruments: observableInstruments));
  }

  void removeBatchCallback({
    required api.BatchObservableCallback callback,
    required List<api.Observable> instruments,
  }) {
    final observableInstruments = Set.of(instruments.whereType<ObservableInstrument>());

    if (observableInstruments.isEmpty) return;

    final index = _findBatchCallback(callback: callback, instruments: observableInstruments);
    if (index == -1) {
      return;
    }

    _batchCallbacks.removeAt(index);
  }

  Future<void> observe() async {
    final callbackFutures = _observeCallbacks();
    final batchCallbackFutures = _observeBatchCallbacks();

    await Future.wait([...callbackFutures, ...batchCallbackFutures]);
  }

  Iterable<Future<void>> _observeCallbacks() {
    return _callbacks.map((e) async {
      final result = ObservableResult();

      await Future(() => e.callback(result));

      for (final storage in e.instrument.storages) {
        for (final MapEntry(key: _, value: metric) in result.buffer.entries) {
          storage.record(value: metric.$1, attributes: metric.$2);
        }
      }
    });
  }

  Iterable<Future<void>> _observeBatchCallbacks() {
    return _batchCallbacks.map((e) async {
      final result = BatchObservableResult();

      await Future(() => e.callback(result));

      for (final instrument in e.instruments) {
        final buffer = result.buffer[instrument];
        if (buffer == null) {
          continue;
        }

        for (final storage in instrument.storages) {
          for (final MapEntry(key: _, value: metric) in buffer.entries) {
            storage.record(value: metric.$1, attributes: metric.$2);
          }
        }
      }
    });
  }

  int _findCallback({required api.ObservableCallback callback, required ObservableInstrument instrument}) {
    return _callbacks.indexWhere(
      (element) => element.callback == callback && element.instrument == instrument,
    );
  }

  int _findBatchCallback({
    required api.BatchObservableCallback callback,
    required Set<ObservableInstrument> instruments,
  }) {
    return _batchCallbacks.indexWhere(
      (element) => element.callback == callback && element.instruments == instruments,
    );
  }
}
