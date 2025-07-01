import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/metrics/data/metric_data.dart';
import 'package:opentelemetry/src/sdk/metrics/export/metric_filter.dart';
import 'package:opentelemetry/src/sdk/metrics/export/metric_producer.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/state/meter_provider_shared_state.dart';

final class MetricCollector implements MetricProducer {
  final TimeProvider _timeProvider;
  final MeterProviderSharedState _meterProviderSharedState;

  MetricCollector({
    required MeterProviderSharedState meterProviderSharedState,
    TimeProvider? timeProvider,
  })  : _timeProvider = timeProvider ?? DateTimeTimeProvider(),
        _meterProviderSharedState = meterProviderSharedState;

  @override
  Future<List<MetricData>> produce([MetricFilter? filter]) async {
    final result = <MetricData>[];

    for (final meterSharedState in _meterProviderSharedState.meterSharedStates.values) {
      final current = await meterSharedState.collect(
        collector: this,
        collectionTime: _timeProvider.now,
      );

      if (current != null) {
        result.addAll(current);
      }
    }

    return result;
  }
}
