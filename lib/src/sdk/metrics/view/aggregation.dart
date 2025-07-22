// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/view/base2_exponential_histogram_aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/view/default_aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/view/drop_aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/view/explicit_bucket_histogram_aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/view/last_value_aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/view/sum_aggregation.dart';

abstract interface class Aggregation<T extends BasePointData> {
  static Aggregation<PointData<num>> drop() => DropAggregation.instance;

  static Aggregation<PointData<num>> sum() => SumAggregation.instance;

  static Aggregation defaultAggregation() => DefaultAggregation.instance;

  static Aggregation<PointData<num>> lastValue() => LastValueAggregation.instance;

  static Aggregation<HistogramPointData> explicitBucketHistogram([List<double>? buckerBoundaries]) {
    if (buckerBoundaries == null) {
      return ExplicitBucketHistogramAggregation.getDefault();
    }
    return ExplicitBucketHistogramAggregation.create(buckerBoundaries);
  }

  static Aggregation<ExponentialHistogramPointData> base2ExponentialBucketHistogram([int? maxBuckets, int? maxScale]) {
    if (maxBuckets == null || maxScale == null) {
      return Base2ExponentialHistogramAggregation.getDefault();
    }
    return Base2ExponentialHistogramAggregation.create(maxBuckets, maxScale);
  }

  Aggregator<T> createAggregator(InstrumentDescriptor instrumentDescriptor);

  bool isCompatibleWithInstrument(InstrumentDescriptor instrumentDescriptor);
}
