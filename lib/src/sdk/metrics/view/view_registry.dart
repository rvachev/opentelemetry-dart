// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'dart:collection';

import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/state/metric_storage.dart';
import 'package:opentelemetry/src/sdk/metrics/view/aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/view/attribute_processor.dart';
import 'package:opentelemetry/src/sdk/metrics/view/instrument_selector.dart';
import 'package:opentelemetry/src/sdk/metrics/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/view/meter_selector.dart';
import 'package:opentelemetry/src/sdk/metrics/view.dart';

final class ViewRegistry {
  static final defaultView = View(ViewOptions(
    instrumentName: '*',
    attributeProcessor: AttributesProcessor.noop(),
    cardinalityLimit: MetricStorage.defaultMaxCardinality,
  ));

  final List<View> _registeredViews;

  final _instrumentDefaultRegisteredView = <InstrumentType, View>{};

  /// ДОбавить AggregationSelector и CardinalitySelector
  /// Добавить defaultView
  ViewRegistry({
    AggregationSelector? defaultAggregationSelector,
    CardinalitySelector? cardinalitySelector,
    List<View>? registeredViews,
  }) : _registeredViews = registeredViews ?? [] {
    for (final instrumentType in InstrumentType.values) {
      _instrumentDefaultRegisteredView.putIfAbsent(instrumentType, () {
        return View(ViewOptions(
          instrumentName: '*',
          attributeProcessor: AttributesProcessor.noop(),
          aggregation: defaultAggregationSelector?.call(instrumentType) ?? Aggregation.defaultAggregation(),
          cardinalityLimit: cardinalitySelector?.call(instrumentType) ?? MetricStorage.defaultMaxCardinality,
        ));
      });
    }
  }

  void addView(View registeredView) {
    _registeredViews.add(registeredView);
  }

  List<View> findViews({
    required InstrumentDescriptor instrumentDescriptor,
    required InstrumentationScope instrumentationScope,
  }) {
    final views = _registeredViews.where(
      (view) =>
          _matchesInstrument(
            selector: view.instrumentSelector,
            instrumentDescriptor: instrumentDescriptor,
          ) &&
          _matchesMeter(
            selector: view.meterSelector,
            instrumentationScope: instrumentationScope,
          ),
    );

    if (views.isNotEmpty) {
      return UnmodifiableListView(views);
    }

    var instrumentDefaultView = _instrumentDefaultRegisteredView[instrumentDescriptor.type];

    final aggregation = instrumentDefaultView?.aggregation;

    if (aggregation == null || !aggregation.isCompatibleWithInstrument(instrumentDescriptor)) {
      instrumentDefaultView = defaultView;
    }

    return [instrumentDefaultView ?? defaultView];
  }

  bool _matchesInstrument({
    required InstrumentSelector selector,
    required InstrumentDescriptor instrumentDescriptor,
  }) {
    return (selector.type == null || instrumentDescriptor.type == selector.type) &&
        selector.nameFilter.match(instrumentDescriptor.name) &&
        selector.unitFilter.match(instrumentDescriptor.unit);
  }

  bool _matchesMeter({required MeterSelector selector, required InstrumentationScope instrumentationScope}) {
    return selector.nameFilter.match(instrumentationScope.name) &&
        selector.versionFilter.match(instrumentationScope.version) &&
        selector.schemaUrlFilter.match(instrumentationScope.schemaUrl);
  }
}
