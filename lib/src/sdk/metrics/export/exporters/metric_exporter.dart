// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/view/aggregation.dart';

enum ExportResult {
  success,
  failure,
}

abstract interface class MetricExporter {
  Future<ExportResult> export({required List<MetricData> batch});

  Future<void> forceFlush();

  AggregationTemporality selectAggregationTemporality(InstrumentType instrumentType);

  Aggregation selectAggregation(InstrumentType instrumentType);

  Future<void> shutdown();
}
