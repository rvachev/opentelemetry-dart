// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/metric_advice.dart';
import 'package:opentelemetry/src/sdk/metrics/view/aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/view/drop_aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/view/explicit_bucket_histogram_aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/view/last_value_aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/view/sum_aggregation.dart';

final class DefaultAggregation implements Aggregation {
  static final DefaultAggregation _instance = DefaultAggregation._();

  static DefaultAggregation get instance {
    return _instance;
  }

  const DefaultAggregation._();

  Aggregation _resolve(InstrumentDescriptor instrumentDescriptor) {
    if (instrumentDescriptor.type
        case InstrumentType.counter ||
            InstrumentType.upDownCounter ||
            InstrumentType.observableCounter ||
            InstrumentType.observableUpDownCounter) {
      return SumAggregation.instance;
    }
    if (instrumentDescriptor.type case InstrumentType.histogram) {
      if (instrumentDescriptor.advice case final MetricAdvice advice) {
        return ExplicitBucketHistogramAggregation.create(advice.explicitBucketBoundaries);
      }
      return ExplicitBucketHistogramAggregation.getDefault();
    }
    if (instrumentDescriptor.type case InstrumentType.observableGauge || InstrumentType.gauge) {
      return LastValueAggregation.instance;
    }

    return DropAggregation.instance;
  }

  @override
  Aggregator<BasePointData> createAggregator(InstrumentDescriptor instrumentDescriptor) {
    return _resolve(instrumentDescriptor).createAggregator(instrumentDescriptor);
  }

  @override
  bool isCompatibleWithInstrument(InstrumentDescriptor instrumentDescriptor) {
    return _resolve(instrumentDescriptor).isCompatibleWithInstrument(instrumentDescriptor);
  }
}
