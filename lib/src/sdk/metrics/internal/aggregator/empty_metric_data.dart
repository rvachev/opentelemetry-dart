import 'package:opentelemetry/src/sdk/common/instrumentation_scope.dart';
import 'package:opentelemetry/src/sdk/metrics/data/data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data_type.dart';
import 'package:opentelemetry/src/sdk/resource/resource.dart';

final class EmptyMetricData implements MetricData {
  const EmptyMetricData();

  @override
  Resource get resource => throw UnimplementedError('EmptyMetricData does not support resource.');

  @override
  InstrumentationScope get instrumentationScope =>
      throw UnimplementedError('EmptyMetricData does not support instrumentationScope.');

  @override
  String get name => throw UnimplementedError('EmptyMetricData does not support name.');

  @override
  String get description => throw UnimplementedError('EmptyMetricData does not support description.');

  @override
  String get unit => throw UnimplementedError('EmptyMetricData does not support unit.');

  @override
  MetricDataType get type => throw UnimplementedError('EmptyMetricData does not support type.');

  @override
  Data get data => throw UnimplementedError('EmptyMetricData does not support data.');

  @override
  bool get isEmpty => true;
}
