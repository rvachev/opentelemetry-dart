final class MetricAdvice {
  final List<double> explicitBucketBoundaries;

  const MetricAdvice({required this.explicitBucketBoundaries});

  @override
  int get hashCode => explicitBucketBoundaries.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MetricAdvice && explicitBucketBoundaries == other.explicitBucketBoundaries;

  @override
  String toString() => 'MetricAdvice{explicitBucketBoundaries: $explicitBucketBoundaries}';
}
