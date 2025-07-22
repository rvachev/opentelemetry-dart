// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';

abstract interface class AggregatorHandle<T extends BasePointData> {
  T aggregateThenMaybeReset({
    required Int64 startEpochNanos,
    required Int64 epochNanos,
    List<Attribute> attributes = const [],
    bool reset = true,
  });

  void record(num value);
}
