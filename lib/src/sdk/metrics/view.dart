import 'package:opentelemetry/src/sdk/metrics/internal/view/instrument_selector.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/attribute_processor.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/meter_selector.dart';

final class View {
  final String? name;
  final String? description;
  final Aggregation aggregation;
  final InstrumentSelector instrumentSelector;
  final MeterSelector meterSelector;
  final AttributesProcessor attributesProcessor;
  final int? cardinalityLimit;

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

final class ViewOptions {
  final String? name;
  final String? description;
  final AttributesProcessor? attributeProcessor;
  final Aggregation? aggregation;
  final int? cardinalityLimit;
  final InstrumentType? instrumentType;
  final String? instrumentName;
  final String? instrumentUnit;
  final String? meterName;
  final String? meterVersion;
  final String? meterSchemaUrl;

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
