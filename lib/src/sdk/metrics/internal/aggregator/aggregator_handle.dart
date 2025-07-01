import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/src/sdk/metrics/data/exemplar_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';

abstract interface class AggregatorHandle<T extends BasePointData, U extends ExemplarData> {
  T aggregateThenMaybeReset({
    required Int64 startEpochNanos,
    required Int64 epochNanos,
    List<Attribute> attributes = const [],
    bool reset = true,
  });

  void record(num value);
}
