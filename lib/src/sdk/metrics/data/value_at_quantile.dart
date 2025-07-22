// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

final class ValueAtQuantile {
  final double quantile;
  final double value;

  const ValueAtQuantile({required this.quantile, required this.value});

  ValueAtQuantile copyWith({double? quantile, double? value}) {
    return ValueAtQuantile(
      quantile: quantile ?? this.quantile,
      value: value ?? this.value,
    );
  }

  @override
  String toString() {
    return 'ValueAtQuantile{quantile: $quantile, value: $value}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ValueAtQuantile && other.quantile == quantile && other.value == value;
  }

  @override
  int get hashCode => quantile.hashCode ^ value.hashCode;
}
