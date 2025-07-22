// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/api/common/attribute.dart';
import 'package:opentelemetry/src/api/metrics/instruments/observable_result.dart' as api;
import 'package:opentelemetry/src/api/metrics/instruments/observables.dart';
import 'package:opentelemetry/src/sdk/metrics/state/attribute_map.dart';
import 'package:opentelemetry/src/sdk/metrics/instruments/observable_instrument.dart';

final class ObservableResult implements api.ObservableResult {
  final AttributeMap<num> _buffer = {};

  AttributeMap<num> get buffer => _buffer;

  @override
  void observe({required num number, List<Attribute> attributes = const []}) {
    _buffer.putIfAbsent(attributes.hashCode, () => (number, attributes));
  }
}

final class BatchObservableResult implements api.BatchObservableResult {
  final Map<ObservableInstrument, AttributeMap<num>> _buffer = {};

  Map<ObservableInstrument, AttributeMap<num>> get buffer => _buffer;

  @override
  void observe({required Observable metric, required num number, List<Attribute> attributes = const []}) {
    if (metric is! ObservableInstrument) {
      return;
    }

    final map = _buffer[metric] ?? {};
    _buffer[metric] = map;

    map.putIfAbsent(attributes.hashCode, () => (number, attributes));
  }
}
