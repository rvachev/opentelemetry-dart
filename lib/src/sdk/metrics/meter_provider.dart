// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:logging/logging.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/api/metrics/noop/noop_meter.dart';
import 'package:opentelemetry/src/sdk/metrics/export/metric_collector.dart';
import 'package:opentelemetry/src/sdk/metrics/export/metric_reader.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/meter_config.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/state/meter_provider_shared_state.dart';
import 'package:opentelemetry/src/sdk/metrics/view.dart';

import '../../../api.dart' as api;
import '../../experimental_sdk.dart' as sdk;

class MeterProvider implements api.MeterProvider {
  final _logger = Logger('opentelemetry.sdk.metrics.meterprovider');

  final MeterProviderSharedState _meterProviderSharedState;

  MeterProvider({
    required sdk.Resource resource,
    required List<MetricReader> metricReaders,
    TimeProvider? timeProvider,
    List<View> views = const [],
    MeterConfigurator? meterConfigurator,
  }) : _meterProviderSharedState = MeterProviderSharedState(
          resource: resource,
          meterConfigurator: meterConfigurator,
          timeProvider: timeProvider,
        ) {
    for (final view in views) {
      _meterProviderSharedState.viewRegistry.addView(view);
    }

    for (final metricReader in metricReaders) {
      metricReader.setMetricProducer(MetricCollector(
        timeProvider: timeProvider,
        meterProviderSharedState: _meterProviderSharedState,
      ));
      _meterProviderSharedState.metricReaders.add(metricReader);
    }
  }

  @override
  api.Meter get(
    String name, {
    String version = '',
    String schemaUrl = '',
    List<api.Attribute> attributes = const [],
  }) {
    if (name.isEmpty) {
      _logger.warning('Invalid Meter Name', '', StackTrace.current);
      return NoopMeter.instance;
    }

    return _meterProviderSharedState
        .getMeterSharedState(
          InstrumentationScope(
            name,
            version,
            schemaUrl,
            attributes,
          ),
        )
        .meter;
  }
}
