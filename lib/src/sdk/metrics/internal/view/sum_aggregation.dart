import 'package:opentelemetry/src/sdk/metrics/data/exemplar_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/sum_aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/aggregation.dart';

final class SumAggregation implements Aggregation<PointData<num>, ExemplarData<num>> {
  static final SumAggregation _instance = SumAggregation._();

  static SumAggregation get instance {
    return _instance;
  }

  const SumAggregation._();

  @override
  Aggregator<PointData<num>, ExemplarData<num>> createAggregator(InstrumentDescriptor instrumentDescriptor) {
    return SumAggregator(instrumentDescriptor: instrumentDescriptor);
  }

  @override
  bool isCompatibleWithInstrument(InstrumentDescriptor instrumentDescriptor) {
    return switch (instrumentDescriptor.type) {
      InstrumentType.counter ||
      InstrumentType.observableCounter ||
      InstrumentType.upDownCounter ||
      InstrumentType.observableUpDownCounter ||
      InstrumentType.histogram =>
        true,
      _ => false,
    };
  }

  @override
  String toString() {
    return 'SumAggregation';
  }
}
