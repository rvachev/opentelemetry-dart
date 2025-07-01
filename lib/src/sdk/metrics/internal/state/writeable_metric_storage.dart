import 'package:opentelemetry/api.dart';

abstract interface class WriteableMetricStorage {
  void record({
    required num value,
    required List<Attribute> attributes,
    Context? context,
  });

  bool get isEnabled;
}
