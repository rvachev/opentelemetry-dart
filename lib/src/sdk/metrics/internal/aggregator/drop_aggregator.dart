import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/src/api/common/attribute.dart';
import 'package:opentelemetry/src/sdk/common/instrumentation_scope.dart';
import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/exemplar_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/aggregator_handle.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/empty_metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/metric_descriptor.dart';
import 'package:opentelemetry/src/sdk/resource/resource.dart';

final class DropAggregator extends Aggregator<PointData, ExemplarData<num>> {
  static final pointData = PointData(
    value: 0,
    startEpochNanos: Int64(0),
    epochNanos: Int64(0),
    attributes: const [],
  );

  static final _handle = Handle();

  @override
  AggregatorHandle<PointData, ExemplarData<num>> createHandle() {
    return _handle;
  }

  @override
  MetricData toMetricData({
    required Resource resource,
    required InstrumentationScope instrumentationScope,
    required MetricDescriptor metricDescriptor,
    required List<BasePointData> points,
    required AggregationTemporality temporality,
  }) {
    return const EmptyMetricData();
  }
}

final class Handle implements AggregatorHandle<PointData, ExemplarData<num>> {
  @override
  PointData<num> aggregateThenMaybeReset(
      {required Int64 startEpochNanos,
      required Int64 epochNanos,
      List<Attribute> attributes = const [],
      bool reset = true}) {
    return DropAggregator.pointData;
  }

  @override
  void record(num value) {}
}
