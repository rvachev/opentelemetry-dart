import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_value_type.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/metric_advice.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/metric_descriptor.dart';

final class InstrumentDescriptor extends MetricDescriptor {
  final InstrumentType type;
  final InstrumentValueType valueType;
  final MetricAdvice? advice;

  InstrumentDescriptor({
    required super.name,
    required super.description,
    required super.unit,
    required this.type,
    required this.valueType,
    this.advice,
  });

  int _hashCode = 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InstrumentDescriptor &&
        other.name.toUpperCase() == name.toUpperCase() &&
        other.description == description &&
        other.unit == unit &&
        other.type == type &&
        other.valueType == valueType &&
        other.advice == advice;
  }

  bool isCompatibleWith(InstrumentDescriptor other) {
    return other.name.toUpperCase() == name.toUpperCase() &&
        other.unit == unit &&
        other.type == type &&
        other.valueType == valueType;
  }

  @override
  int get hashCode {
    var result = _hashCode;
    if (result == 0) {
      result = 1;
      result *= 1000003;
      result ^= name.toLowerCase().hashCode;
      result *= 1000003;
      result ^= description.hashCode;
      result *= 1000003;
      result ^= unit.hashCode;
      result *= 1000003;
      result ^= type.hashCode;
      result *= 1000003;
      result ^= valueType.hashCode;
      if (advice != null) {
        result *= 1000003;
        result ^= advice.hashCode;
      }
      _hashCode = result;
    }

    return result;
  }
}
