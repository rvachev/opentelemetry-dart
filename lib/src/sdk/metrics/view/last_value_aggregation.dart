// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/last_value_aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/view/aggregation.dart';

final class LastValueAggregation implements Aggregation<PointData<num>> {
  static final LastValueAggregation _instance = LastValueAggregation._();

  static LastValueAggregation get instance {
    return _instance;
  }

  const LastValueAggregation._();

  @override
  Aggregator<PointData<num>> createAggregator(InstrumentDescriptor instrumentDescriptor) {
    return LastValueAggregator();
  }

  @override
  bool isCompatibleWithInstrument(InstrumentDescriptor instrumentDescriptor) {
    return switch (instrumentDescriptor.type) {
      InstrumentType.gauge || InstrumentType.observableGauge => true,
      _ => false,
    };
  }

  @override
  String toString() {
    return 'LastValueAggregation';
  }
}
