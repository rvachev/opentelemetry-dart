// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/view/aggregation.dart';

final class DropAggregation implements Aggregation<PointData> {
  static final DropAggregation _instance = DropAggregation._();

  static DropAggregation get instance {
    return _instance;
  }

  const DropAggregation._();

  @override
  Aggregator<PointData> createAggregator(InstrumentDescriptor instrumentDescriptor) {
    return Aggregator.drop();
  }

  @override
  bool isCompatibleWithInstrument(InstrumentDescriptor instrumentDescriptor) {
    return true;
  }

  @override
  String toString() {
    return 'DropAggregation';
  }
}
