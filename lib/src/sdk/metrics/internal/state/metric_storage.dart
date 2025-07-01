import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/instrument_descriptor.dart';

abstract class MetricStorage {
  static const defaultMaxCardinality = 2000;
  static final cardinalityOverflow = [Attribute.fromBoolean('otel.metric.overflow', true)];

  InstrumentDescriptor _instrumentDescriptor;

  MetricStorage(this._instrumentDescriptor);

  InstrumentDescriptor get instrumentDescriptor => _instrumentDescriptor;

  MetricData collect({
    required Resource resource,
    required InstrumentationScope instrumentationScope,
    required Int64 startEpochNanos,
    required Int64 epochNanos,
  });

  void updateDescription(String description) {
    _instrumentDescriptor = InstrumentDescriptor(
      name: _instrumentDescriptor.name,
      description: description,
      unit: _instrumentDescriptor.unit,
      type: _instrumentDescriptor.type,
      valueType: _instrumentDescriptor.valueType,
    );
  }
}
