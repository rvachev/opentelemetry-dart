// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/export/metric_collector.dart';
import 'package:opentelemetry/src/sdk/metrics/state/async_metric_storage.dart';
import 'package:opentelemetry/src/sdk/metrics/state/meter_provider_shared_state.dart';
import 'package:opentelemetry/src/sdk/metrics/state/metric_storage_registry.dart';
import 'package:opentelemetry/src/sdk/metrics/state/multu_metric_storage.dart';
import 'package:opentelemetry/src/sdk/metrics/state/observable_registry.dart';
import 'package:opentelemetry/src/sdk/metrics/state/sync_metric_storage.dart';
import 'package:opentelemetry/src/sdk/metrics/state/writeable_metric_storage.dart';
import 'package:opentelemetry/src/sdk/metrics/meter.dart';

final class MeterSharedState {
  late final Meter meter;
  final MeterProviderSharedState _meterProviderSharedState;
  final InstrumentationScope _instrumentationScope;
  final bool isDisabled;
  final observableRegistry = ObservableRegistry();
  final _metricStorageRegistry = MetricStorageRegistry();

  MeterSharedState({
    required MeterProviderSharedState meterProviderSharedState,
    required InstrumentationScope instrumentationScope,
  })  : _meterProviderSharedState = meterProviderSharedState,
        _instrumentationScope = instrumentationScope,
        isDisabled = meterProviderSharedState.meterConfigurator?.call(instrumentationScope).disabled ?? false {
    meter = Meter(this);
  }

  WriteableMetricStorage registerMetricStorage(InstrumentDescriptor descriptor) {
    final storages = _registerSyncMetricStorage(descriptor);

    if (storages.length == 1) {
      return storages.first;
    }

    return MultiMetricStorage(storages);
  }

  List<AsyncMetricStorage> registerAsyncMetricStorage(InstrumentDescriptor descriptor) =>
      _registerAsyncMetricStorage(descriptor);

  Future<List<MetricData>?> collect({required MetricCollector collector, required Int64 collectionTime}) async {
    if (isDisabled) {
      return null;
    }
    await observableRegistry.observe();
    final storages = _metricStorageRegistry.getStorages();

    if (storages.isEmpty) {
      return null;
    }

    final metricDataList = storages
        .map(
          (metricStorage) => metricStorage.collect(
            resource: _meterProviderSharedState.resource,
            instrumentationScope: _instrumentationScope,
            startEpochNanos: _meterProviderSharedState.startEpochNanos,
            epochNanos: collectionTime,
          ),
        )
        .toList();

    if (metricDataList.isEmpty) {
      return null;
    }

    return metricDataList;
  }

  List<SyncMetricStorage> _registerSyncMetricStorage(InstrumentDescriptor descriptor) {
    final views = _meterProviderSharedState.viewRegistry
        .findViews(instrumentDescriptor: descriptor, instrumentationScope: _instrumentationScope);

    final storages = <SyncMetricStorage>[];

    final perCollectorAggregations = _meterProviderSharedState.selectAggegations(descriptor.type);

    for (final MapEntry(key: reader, value: _) in perCollectorAggregations.entries) {
      for (final view in views) {
        final viewDescriptor = InstrumentDescriptor(
          name: view.name ?? descriptor.name,
          description: view.description ?? descriptor.description,
          unit: descriptor.unit,
          type: descriptor.type,
          valueType: descriptor.valueType,
        );
        final compatibleStorage =
            _metricStorageRegistry.findOrUpdateCompatibleStorage<SyncMetricStorage>(viewDescriptor);
        if (compatibleStorage != null) {
          storages.add(compatibleStorage);
          continue;
        }

        final aggregator = view.aggregation.createAggregator(viewDescriptor);

        final storage = SyncMetricStorage(
          instrumentDescriptor: viewDescriptor,
          aggregationTemporality: reader.selectAggregationTemporality(viewDescriptor.type),
          aggregator: aggregator,
          attributesProcessor: view.attributesProcessor,
          aggregationCardinalityLimit: reader.selectCardinalityLimit(viewDescriptor.type),
        );
        _metricStorageRegistry.register(storage);
        storages.add(storage);
      }
    }

    return storages;
  }

  List<AsyncMetricStorage> _registerAsyncMetricStorage(InstrumentDescriptor descriptor) {
    final views = _meterProviderSharedState.viewRegistry
        .findViews(instrumentDescriptor: descriptor, instrumentationScope: _instrumentationScope);

    final storages = <AsyncMetricStorage>[];

    final perCollectorAggregations = _meterProviderSharedState.selectAggegations(descriptor.type);

    for (final MapEntry(key: reader, value: aggregation) in perCollectorAggregations.entries) {
      for (final view in views) {
        final viewDescriptor = InstrumentDescriptor(
          name: view.name ?? descriptor.name,
          description: view.description ?? descriptor.description,
          unit: descriptor.unit,
          type: descriptor.type,
          valueType: descriptor.valueType,
        );
        final compatibleStorage =
            _metricStorageRegistry.findOrUpdateCompatibleStorage<AsyncMetricStorage>(viewDescriptor);
        if (compatibleStorage != null) {
          storages.add(compatibleStorage);
          continue;
        }

        final aggregator = aggregation.createAggregator(viewDescriptor);

        final storage = AsyncMetricStorage(
          instrumentDescriptor: viewDescriptor,
          aggregationTemporality: reader.selectAggregationTemporality(viewDescriptor.type),
          aggregator: aggregator,
          attributesProcessor: view.attributesProcessor,
          aggregationCardinalityLimit: reader.selectCardinalityLimit(viewDescriptor.type),
        );
        _metricStorageRegistry.register(storage);
        storages.add(storage);
      }
    }

    return storages;
  }
}
