import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/src/api/common/attribute.dart';
import 'package:opentelemetry/src/sdk/common/instrumentation_scope.dart';
import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/exemplar_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data_type.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/aggregator.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/aggregator_handle.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/descriptor/metric_descriptor.dart';
import 'package:opentelemetry/src/sdk/resource/resource.dart';

final class LastValueAggregator implements Aggregator<PointData<num>, ExemplarData<num>> {
  @override
  AggregatorHandle<PointData<num>, ExemplarData<num>> createHandle() {
    return Handle();
  }

  @override
  PointData<num> diff(PointData<num> previousCumulative, PointData<num> currentCumulative) {
    return currentCumulative.epochNanos >= previousCumulative.epochNanos ? currentCumulative : previousCumulative;
  }

  @override
  MetricData toMetricData({
    required Resource resource,
    required InstrumentationScope instrumentationScope,
    required MetricDescriptor metricDescriptor,
    required List<BasePointData> points,
    required AggregationTemporality temporality,
  }) {
    return MetricData(
      resource: resource,
      instrumentationScope: instrumentationScope,
      name: metricDescriptor.name,
      description: metricDescriptor.description,
      unit: metricDescriptor.unit,
      type: MetricDataType.gauge,
      data: GaugeData(
        points: points.cast(),
      ),
    );
  }
}

final class Handle implements AggregatorHandle<PointData<num>, ExemplarData<num>> {
  num _current = 0;

  @override
  PointData<num> aggregateThenMaybeReset({
    required Int64 startEpochNanos,
    required Int64 epochNanos,
    List<Attribute> attributes = const [],
    bool reset = true,
  }) {
    final value = _current;
    if (reset) {
      _current = 0;
    }

    return PointData(
      startEpochNanos: startEpochNanos,
      epochNanos: epochNanos,
      attributes: attributes,
      value: value,
    );
  }

  @override
  void record(num value) {
    _current = value;
  }
}
