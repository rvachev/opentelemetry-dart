import 'package:opentelemetry/src/api/metrics/instruments/observable_result.dart';

typedef ObservableCallback<T extends num> = Future<T> Function(ObservableResult<T> observableResult);

typedef BatchObservableCallback<T extends num> = Future<T> Function(BatchObservableResult<T> observableResult);

abstract interface class Observable<T extends num> {
  const Observable();

  void addCallback(ObservableCallback<T> callback);

  void removeCallback(ObservableCallback<T> callback);
}

typedef ObservableCounter<T extends num> = Observable<T>;

typedef ObservableUpDownCounter<T extends num> = Observable<T>;

typedef ObservableGauge<T extends num> = Observable<T>;
