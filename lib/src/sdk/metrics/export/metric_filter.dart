// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';

abstract interface class MetricFilter {
  MetricFilterResult testMetric({
    required InstrumentationScope instrumentationScope,
    required String name,
    required InstrumentType instrumentType,
    required String unit,
  });

  AttributesFilterResult testAttributes({
    required InstrumentationScope instrumentationScope,
    required String name,
    required InstrumentType instrumentType,
    required String unit,
    required List<Attribute> attributes,
  });
}

enum MetricFilterResult {
  accept,
  drop,
  acceptParial,
}

enum AttributesFilterResult {
  accept,
  drop,
}
