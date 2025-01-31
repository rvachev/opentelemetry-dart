import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/src/api/metrics/instruments/observables.dart';

abstract interface class ObservableResult<T extends num> {
  void observe({T number, List<Attribute> attributes});
}

abstract interface class BatchObservableResult<T extends num> {
  void observe({Observable metric, T number, List<Attribute> attributes});
}
