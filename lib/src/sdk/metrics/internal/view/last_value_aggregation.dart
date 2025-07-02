import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/last_value_aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/aggregation.dart';

final class LastValueAggregation implements Aggregation<PointData<num>> {
  static final LastValueAggregation _instance = LastValueAggregation._();

  static LastValueAggregation get instance {
    return _instance;
  }

  const LastValueAggregation._();

  @override
  Aggregator<PointData<num>> createAggregator(InstrumentDescriptor instrumentDescriptor) {
    return LastValueAggregator();
  }

  @override
  bool isCompatibleWithInstrument(InstrumentDescriptor instrumentDescriptor) {
    return switch (instrumentDescriptor.type) {
      InstrumentType.gauge || InstrumentType.observableGauge => true,
      _ => false,
    };
  }

  @override
  String toString() {
    return 'LastValueAggregation';
  }
}
