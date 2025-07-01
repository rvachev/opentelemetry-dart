import 'package:collection/collection.dart';
import 'package:fixnum/fixnum.dart';

import 'package:opentelemetry/api.dart';

class ExemplarData<T extends num> {
  final T value;
  final List<Attribute> filteredAttributes;
  final Int64 epochNanos;
  final SpanId? spanId;
  final TraceId? traceId;

  const ExemplarData({
    required this.value,
    required this.filteredAttributes,
    required this.epochNanos,
    this.spanId,
    this.traceId,
  });

  ExemplarData<T> copyWith({
    T? value,
    List<Attribute>? filteredAttributes,
    Int64? epochNanos,
    SpanId? spanId,
    TraceId? traceId,
  }) {
    return ExemplarData<T>(
      value: value ?? this.value,
      filteredAttributes: filteredAttributes ?? this.filteredAttributes,
      epochNanos: epochNanos ?? this.epochNanos,
      spanId: spanId ?? this.spanId,
      traceId: traceId ?? this.traceId,
    );
  }

  @override
  String toString() {
    return 'ExemplarData(value: $value, filteredAttributes: $filteredAttributes, epochNanos: $epochNanos, spanId: $spanId, traceId: $traceId)';
  }

  @override
  bool operator ==(covariant ExemplarData<T> other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.value == value &&
        listEquals(other.filteredAttributes, filteredAttributes) &&
        other.epochNanos == epochNanos &&
        other.spanId == spanId &&
        other.traceId == traceId;
  }

  @override
  int get hashCode {
    return value.hashCode ^ filteredAttributes.hashCode ^ epochNanos.hashCode ^ spanId.hashCode ^ traceId.hashCode;
  }
}
