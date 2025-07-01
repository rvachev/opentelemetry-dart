import 'package:opentelemetry/src/sdk/metrics/data/exemplar_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/explicit_bucket_histogram_aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/explicit_bucket_histogram_utils.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/instrument_descriptor.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/aggregation.dart';

final class ExplicitBucketHistogramAggregation implements Aggregation<HistogramPointData, ExemplarData<num>> {
  static final ExplicitBucketHistogramAggregation _default =
      ExplicitBucketHistogramAggregation._(ExplicitBucketHistogramUtils.defaultHistogramBucketBoundaries);

  final List<double> _boundaries;

  const ExplicitBucketHistogramAggregation._(this._boundaries);

  factory ExplicitBucketHistogramAggregation.create(List<double> boundaries) {
    return ExplicitBucketHistogramAggregation._(boundaries);
  }

  factory ExplicitBucketHistogramAggregation.getDefault() {
    return _default;
  }

  @override
  Aggregator<HistogramPointData, ExemplarData<num>> createAggregator(InstrumentDescriptor instrumentDescriptor) {
    return ExplicitBucketHistogramAggregator(
      boundaries: _boundaries,
    );
  }

  @override
  bool isCompatibleWithInstrument(InstrumentDescriptor instrumentDescriptor) {
    return switch (instrumentDescriptor.type) {
      InstrumentType.counter || InstrumentType.histogram => true,
      _ => false,
    };
  }
}
