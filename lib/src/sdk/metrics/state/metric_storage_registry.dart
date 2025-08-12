// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:logging/logging.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/state/metric_storage.dart';

typedef StorageMap = Map<InstrumentDescriptor, MetricStorage>;

final class MetricStorageRegistry {
  final _logger = Logger('opentelemetry.sdk.metrics.periodicexportingmetricreader');

  final StorageMap _sharedRegistry = {};

  List<MetricStorage> getStorages() {
    return _sharedRegistry.values.toList();
  }

  void register(MetricStorage storage) {
    _registerStorage(storage, _sharedRegistry);
  }

  T? findOrUpdateCompatibleStorage<T extends MetricStorage>(InstrumentDescriptor expectedDescriptor) {
    final storages = _sharedRegistry[expectedDescriptor.name];
    if (storages == null) {
      return null;
    }

    return _findOrUpdateCompatibleStorage<T>(expectedDescriptor, storages);
  }

  void _registerStorage(MetricStorage storage, StorageMap storageMap) {
    final descriptor = storage.instrumentDescriptor;
    final existedStorage = storageMap[descriptor.name];

    if (existedStorage == null) {
      storageMap[descriptor] = storage;
      return;
    }
  }

  T? _findOrUpdateCompatibleStorage<T extends MetricStorage>(
    InstrumentDescriptor expectedDescriptor,
    MetricStorage existingStorage,
  ) {
    T? compatibleStorage;

    final existingDescriptor = existingStorage.instrumentDescriptor;

    if (existingDescriptor.isCompatibleWith(expectedDescriptor)) {
      if (existingDescriptor.description != expectedDescriptor.description) {
        if (expectedDescriptor.description.length > existingDescriptor.description.length) {
          existingStorage.updateDescription(expectedDescriptor.description);
        }

        _logger.warning('A view or instrument with the name ${expectedDescriptor.name}'
            ' has already been registered, but has a different description and is incompatible with another registered view');
      }

      compatibleStorage = existingStorage as T;
    } else {
      _logger.warning('A view or instrument with the name ${expectedDescriptor.name}'
          ' has already been registered and is incompatible with another registered view');
    }

    return compatibleStorage;
  }
}
