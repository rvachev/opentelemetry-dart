// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

// ignore_for_file: prefer_function_declarations_over_variables

import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/view/aggregation.dart';

/// A function that takes an [InstrumentType] and returns an [Aggregation].
typedef AggregationSelector = Aggregation Function(InstrumentType instrumentType);

/// A function that takes an [InstrumentType] and returns an [AggregationTemporality].
typedef AggregationTemporalitySelector = AggregationTemporality Function(InstrumentType instrumentType);

/// The default [AggregationSelector].
///
/// Returns [Aggregation.defaultAggregation]
final AggregationSelector defaultAggregationSelector = (instrumentType) {
  return Aggregation.defaultAggregation();
};

/// The default [AggregationTemporalitySelector].
///
/// Always returns [AggregationTemporality.cumulative]
final AggregationTemporalitySelector defaultAggregationTemporalitySelector = (instrumentType) {
  return AggregationTemporality.cumulative;
};
