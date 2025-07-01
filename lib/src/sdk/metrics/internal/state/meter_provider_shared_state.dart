import 'package:fixnum/fixnum.dart';
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/export/metric_reader.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/meter_config.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/state/meter_shared_state.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/view_registry.dart';

final class MeterProviderSharedState {
  final Resource resource;
  final Int64 startEpochNanos;
  final MeterConfigurator? meterConfigurator;
  final viewRegistry = ViewRegistry();
  final metricReaders = <MetricReader>[];
  final meterSharedStates = <String, MeterSharedState>{};

  MeterProviderSharedState({
    required this.resource,
    this.meterConfigurator,
    TimeProvider? timeProvider,
  }) : startEpochNanos = (timeProvider ?? DateTimeTimeProvider()).now;

  MeterSharedState getMeterSharedState(InstrumentationScope instrumentationScope) {
    var meterSharedState = meterSharedStates[instrumentationScope.id];

    if (meterSharedState == null) {
      meterSharedState = MeterSharedState(
        meterProviderSharedState: this,
        instrumentationScope: instrumentationScope,
      );
      meterSharedStates[instrumentationScope.id] = meterSharedState;
    }
    return meterSharedState;
  }

  Map<MetricReader, Aggregation> selectAggegations(InstrumentType type) {
    final result = <MetricReader, Aggregation>{};

    for (final metricReader in metricReaders) {
      result[metricReader] = metricReader.selectAggregation(type);
    }

    return result;
  }
}
