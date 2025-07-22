// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/state/metric_storage.dart';

typedef StorageMap = Map<InstrumentDescriptor, MetricStorage>;

final class MetricStorageRegistry {
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

        // TODO: warn
      }

      compatibleStorage = existingStorage as T;
    } else {
      // TODO: warn
    }

    return compatibleStorage;
  }
}
