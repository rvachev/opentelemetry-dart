// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/explicit_bucket_histogram_aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/explicit_bucket_histogram_utils.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/view/aggregation.dart';

final class ExplicitBucketHistogramAggregation implements Aggregation<HistogramPointData> {
  static final ExplicitBucketHistogramAggregation _default =
      ExplicitBucketHistogramAggregation._(ExplicitBucketHistogramUtils.defaultHistogramBucketBoundaries);

  final List<double> _boundaries;

  const ExplicitBucketHistogramAggregation._(this._boundaries);

  factory ExplicitBucketHistogramAggregation.create(List<double> boundaries) {
    return ExplicitBucketHistogramAggregation._(boundaries);
  }

  factory ExplicitBucketHistogramAggregation.getDefault() {
    return _default;
  }

  @override
  Aggregator<HistogramPointData> createAggregator(InstrumentDescriptor instrumentDescriptor) {
    return ExplicitBucketHistogramAggregator(
      boundaries: _boundaries,
    );
  }

  @override
  bool isCompatibleWithInstrument(InstrumentDescriptor instrumentDescriptor) {
    return switch (instrumentDescriptor.type) {
      InstrumentType.counter || InstrumentType.histogram => true,
      _ => false,
    };
  }
}
