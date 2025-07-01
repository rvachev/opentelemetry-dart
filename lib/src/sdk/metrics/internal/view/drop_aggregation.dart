import 'package:opentelemetry/src/sdk/metrics/data/exemplar_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/aggregation.dart';

final class DropAggregation implements Aggregation<PointData, ExemplarData<num>> {
  static final DropAggregation _instance = DropAggregation._();

  static DropAggregation get instance {
    return _instance;
  }

  const DropAggregation._();

  @override
  Aggregator<PointData, ExemplarData<num>> createAggregator(InstrumentDescriptor instrumentDescriptor) {
    return Aggregator.drop();
  }

  @override
  bool isCompatibleWithInstrument(InstrumentDescriptor instrumentDescriptor) {
    return true;
  }

  @override
  String toString() {
    return 'DropAggregation';
  }
}
