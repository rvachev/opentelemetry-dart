import 'package:opentelemetry/api.dart';

abstract interface class ObservableResult {
  void observe({required num number, List<Attribute> attributes = const []});
}

abstract interface class BatchObservableResult {
  void observe({required Observable metric, required num number, List<Attribute> attributes = const []});
}
