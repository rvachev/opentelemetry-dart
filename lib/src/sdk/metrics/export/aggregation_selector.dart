// ignore_for_file: prefer_function_declarations_over_variables

import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/aggregation.dart';

typedef AggregationSelector = Aggregation Function(InstrumentType instrumentType);

typedef AggregationTemporalitySelector = AggregationTemporality Function(InstrumentType instrumentType);

final AggregationSelector defaultAggregationSelector = (instrumentType) {
  return Aggregation.defaultAggregation();
};

final AggregationTemporalitySelector defaultAggregationTemporalitySelector = (instrumentType) {
  return AggregationTemporality.cumulative;
};
