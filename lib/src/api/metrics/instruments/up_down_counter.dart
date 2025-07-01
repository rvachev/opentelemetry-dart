import 'package:opentelemetry/api.dart';

abstract interface class UpDownCounter {
  /// Records a value with a set of attributes.
  ///
  /// [value] The increment amount. MUST be non-negative.
  /// [attributes] A set of attributes to associate with the value.
  /// [context] The explicit context to associate with this measurement.
  void add(num value, {List<Attribute> attributes, Context context});
}
