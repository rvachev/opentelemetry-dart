import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/aggregator_handle.dart';

typedef AggregatorHolder<T extends BasePointData> = Map<String, AggregatorHandle<T>>;
