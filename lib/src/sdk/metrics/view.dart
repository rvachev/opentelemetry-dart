// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/metrics/view/instrument_selector.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/view/aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/view/attribute_processor.dart';
import 'package:opentelemetry/src/sdk/metrics/view/meter_selector.dart';

/// {@template opentelemetry.sdk.metrics.view.View}
///
/// A view configures how measurements are aggregated and exported as metrics.
///
/// <p>Views are registered with the [MeterProvider] as argument [MeterProvider.views].
///
/// {@endtemplate}
final class View {
  /// The name of the view.
  final String? name;

  /// The description of the view.
  final String? description;

  /// The aggregation to use for the view.
  ///
  /// Note that if you pass incompatible aggregation for matched instriment you will be fallbacked to the default aggregation.
  final Aggregation aggregation;

  /// The instrument selector to use for the view.
  ///
  /// It tries to match instrument by name, type and unit.
  final InstrumentSelector instrumentSelector;

  /// The meter selector to use for the view.
  ///
  /// It tries to match meter by name, version and schemaUrl.
  final MeterSelector meterSelector;

  /// The attributes processor to use for the view.
  ///
  /// It describes how attributes are processed and transformed before they are exported.
  final AttributesProcessor attributesProcessor;

  /// The cardinality limit to use for the view.
  final int? cardinalityLimit;

  /// {@macro opentelemetry.sdk.metrics.view.View}
  View(ViewOptions options)
      : name = options.name,
        description = options.description,
        aggregation = options.aggregation ?? Aggregation.defaultAggregation(),
        instrumentSelector = InstrumentSelector(
          InstrumentSelectorCriteria(
            name: options.instrumentName,
            unit: options.instrumentUnit,
            type: options.instrumentType,
          ),
        ),
        meterSelector = MeterSelector(
          MeterSelectorCriteria(
            name: options.meterName,
            version: options.meterVersion,
            schemaUrl: options.meterSchemaUrl,
          ),
        ),
        cardinalityLimit = options.cardinalityLimit,
        attributesProcessor = options.attributeProcessor ?? AttributesProcessor.noop();

  @override
  String toString() {
    return '''View(name: $name, 
    description: $description, 
    aggregation: $aggregation, 
    attributesProcessor: $attributesProcessor, 
    cardinalityLimit: $cardinalityLimit)''';
  }
}

/// {@template opentelemetry.sdk.metrics.view.ViewOptions}
///
/// Options for creating a [View].
///
/// {@endtemplate}
final class ViewOptions {
  /// The name of the view.
  final String? name;

  /// The description of the view.
  final String? description;

  /// The attributes processor to use for the view.
  ///
  /// It describes how attributes are processed and transformed before they are exported.
  final AttributesProcessor? attributeProcessor;

  /// The aggregation to use for the view.
  ///
  /// Note that if you pass incompatible aggregation for matched instriment you will be fallbacked to the default aggregation.
  final Aggregation? aggregation;

  /// The cardinality limit to use for the view.
  final int? cardinalityLimit;

  /// The instrument type to be matched for the instrument.
  final InstrumentType? instrumentType;

  /// The instrument name to be matched for the instrument.
  final String? instrumentName;

  /// The instrument unit to be matched for the instrument.
  final String? instrumentUnit;

  /// The meter name to be matched for the meter.
  final String? meterName;

  /// The meter version to be matched for the meter.
  final String? meterVersion;

  /// The meter schemaUrl to be matched for the meter.
  final String? meterSchemaUrl;

  /// {@macro opentelemetry.sdk.metrics.view.ViewOptions}
  ViewOptions({
    this.name,
    this.description,
    this.attributeProcessor,
    this.aggregation,
    this.cardinalityLimit,
    this.instrumentType,
    this.instrumentName,
    this.instrumentUnit,
    this.meterName,
    this.meterVersion,
    this.meterSchemaUrl,
  });
}
