// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/src/api/metrics/meter.dart';
import 'package:opentelemetry/src/api/metrics/meter_provider.dart';
import 'package:opentelemetry/src/api/metrics/noop/noop_meter.dart';

/// A noop registry for creating named [Meter]s.
class NoopMeterProvider implements MeterProvider {
  @override
  Meter get(
    String name, {
    String version = '',
    String schemaUrl = '',
    List<Attribute> attributes = const [],
  }) {
    return NoopMeter.instance;
  }
}
