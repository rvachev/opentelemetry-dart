import 'package:opentelemetry/api.dart';

abstract class Gauge<T extends num> {
  /// Records a value with a set of attributes.
  ///
  /// [value] The measurement.
  /// [attributes] A set of attributes to associate with the value.
  /// [context] The explicit context to associate with this measurement.
  void record(T value, {List<Attribute> attributes, Context context});
}
