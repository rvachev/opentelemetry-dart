import 'package:opentelemetry/src/api/common/attribute.dart';
import 'package:opentelemetry/src/api/context/context.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/state/writeable_metric_storage.dart';

final class MultiMetricStorage implements WriteableMetricStorage {
  final List<WriteableMetricStorage> _storages;

  MultiMetricStorage(this._storages);

  @override
  void record({
    required num value,
    required List<Attribute> attributes,
    Context? context,
  }) {
    for (final storage in _storages) {
      storage.record(value: value, attributes: attributes, context: context);
    }
  }

  @override
  bool get isEnabled => true;
}
