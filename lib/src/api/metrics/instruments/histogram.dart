import 'package:opentelemetry/api.dart';

abstract interface class Histogram {
  /// Records a value with a set of attributes.
  ///
  /// [value] The measurement. MUST be non-negative.
  /// [attributes] A set of attributes to associate with the value.
  /// [context] The explicit context to associate with this measurement.
  void record(num value, {List<Attribute> attributes, Context context});
}
