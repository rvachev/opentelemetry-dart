import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/metrics/data/data.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data_type.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';

/// Metric data represents the aggregated measurements of an instrument.
class MetricData {
  /// Returns the metric [Resource].
  final Resource resource;

  /// Returns the metric [InstrumentationScope].
  final InstrumentationScope instrumentationScope;

  /// Returns the metric name
  final String name;

  /// Returns the metric description.
  final String description;

  /// Returns the metric unit.
  final String unit;

  /// Returns the type of this metrics.
  final MetricDataType type;

  /// Returns the unconstrained metric data.
  final Data data;

  const MetricData({
    required this.resource,
    required this.instrumentationScope,
    required this.name,
    required this.description,
    required this.unit,
    required this.type,
    required this.data,
  });

  /// Returns `true` if there are no points associated with this metric.
  bool get isEmpty => data.points.isEmpty;
}

extension MetricDataTypeMapper on MetricData {
  GaugeData<PointData<num>> get gaugeData {
    if (type == MetricDataType.gauge) {
      return data as GaugeData<PointData<num>>;
    }
    return GaugeData.empty();
  }

  SumData<PointData<num>> get sumData {
    if (type == MetricDataType.sum) {
      return data as SumData<PointData<num>>;
    }
    return SumData.empty();
  }

  HistogramData get histogramData {
    if (type == MetricDataType.histogram) {
      return data as HistogramData;
    }
    return HistogramData.empty();
  }

  ExponentialHistogramData get exponentialHistogramData {
    if (type == MetricDataType.exponentialHistogram) {
      return data as ExponentialHistogramData;
    }
    return ExponentialHistogramData.empty();
  }

  SummaryData get summaryData {
    if (type == MetricDataType.summary) {
      return data as SummaryData;
    }
    return SummaryData.empty();
  }
}
