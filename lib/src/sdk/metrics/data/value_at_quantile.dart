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
