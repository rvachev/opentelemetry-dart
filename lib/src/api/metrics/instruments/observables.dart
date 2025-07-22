// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/api/metrics/instruments/observable_result.dart';

typedef ObservableCallback = void Function(ObservableResult observableResult);

typedef BatchObservableCallback = void Function(BatchObservableResult observableResult);

abstract interface class Observable {
  const Observable();

  void addCallback(ObservableCallback callback);

  void removeCallback(ObservableCallback callback);
}

typedef ObservableCounter = Observable;

typedef ObservableUpDownCounter = Observable;

typedef ObservableGauge = Observable;
