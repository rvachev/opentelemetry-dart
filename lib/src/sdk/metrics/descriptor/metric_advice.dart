// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

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
