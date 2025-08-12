// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/metrics/meter_config.dart';
import 'package:opentelemetry/src/sdk/metrics/state/meter_shared_state.dart';
import 'package:opentelemetry/src/sdk/metrics/view/view_registry.dart';

final class MeterProviderSharedState {
  final Resource resource;
  final Int64 startEpochNanos;
  final MeterConfigurator? meterConfigurator;
  final viewRegistry = ViewRegistry();
  final metricReaders = <MetricReader>[];
  final meterSharedStates = <String, MeterSharedState>{};

  MeterProviderSharedState({
    required this.resource,
    this.meterConfigurator,
    TimeProvider? timeProvider,
  }) : startEpochNanos = (timeProvider ?? DateTimeTimeProvider()).now;

  MeterSharedState getMeterSharedState(InstrumentationScope instrumentationScope) {
    var meterSharedState = meterSharedStates[instrumentationScope.id];

    if (meterSharedState == null) {
      meterSharedState = MeterSharedState(
        meterProviderSharedState: this,
        instrumentationScope: instrumentationScope,
      );
      meterSharedStates[instrumentationScope.id] = meterSharedState;
    }
    return meterSharedState;
  }

  Map<MetricReader, Aggregation> selectAggegations(InstrumentType type) {
    final result = <MetricReader, Aggregation>{};

    for (final metricReader in metricReaders) {
      result[metricReader] = metricReader.selectAggregation(type);
    }

    return result;
  }

  void shutdownMeter(InstrumentationScope instrumentationScope) {
    meterSharedStates.remove(instrumentationScope.id);
  }
}
