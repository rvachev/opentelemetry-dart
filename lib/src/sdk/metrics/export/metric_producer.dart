import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/export/metric_filter.dart';

abstract interface class MetricProducer {
  Future<List<MetricData>> produce([MetricFilter? filter]);
}
