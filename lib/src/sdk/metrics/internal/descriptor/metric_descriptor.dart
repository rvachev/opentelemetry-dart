class MetricDescriptor {
  final String name;
  final String description;
  final String unit;
  // final InstrumentDescriptor sourceInstrument;

  MetricDescriptor({required this.name, required this.description, required this.unit});

  int _hashCode = 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MetricDescriptor && other.name == name && other.description == description && other.unit == unit;
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
      _hashCode = result;
    }
    return result;
  }
}
