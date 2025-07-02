import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/exponential_histogram_aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/aggregation.dart';

final class Base2ExponentialHistogramAggregation implements Aggregation<ExponentialHistogramPointData> {
  static const _defaultMaxBuckets = 160;
  static const _defaultMaxScale = 20;

  static final _default = Base2ExponentialHistogramAggregation._(_defaultMaxBuckets, _defaultMaxScale);

  final int maxBuckets;
  final int maxScale;

  const Base2ExponentialHistogramAggregation._(this.maxBuckets, this.maxScale);

  factory Base2ExponentialHistogramAggregation.getDefault() {
    return _default;
  }

  factory Base2ExponentialHistogramAggregation.create(int maxBuckets, int maxScale) {
    return Base2ExponentialHistogramAggregation._(maxBuckets, maxScale);
  }

  @override
  Aggregator<ExponentialHistogramPointData> createAggregator(
    InstrumentDescriptor instrumentDescriptor,
  ) {
    return ExponentialHistogramAggregator(maxBuckets: maxBuckets, maxScale: maxScale);
  }

  @override
  bool isCompatibleWithInstrument(InstrumentDescriptor instrumentDescriptor) {
    return switch (instrumentDescriptor.type) {
      InstrumentType.histogram || InstrumentType.counter => true,
      _ => false,
    };
  }
}
