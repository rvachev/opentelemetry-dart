import 'package:opentelemetry/src/sdk/metrics/internal/view/predicate.dart';

final class MeterSelector {
  final Predicate nameFilter;
  final Predicate versionFilter;
  final Predicate schemaUrlFilter;

  MeterSelector(MeterSelectorCriteria? criteria)
      : nameFilter = ExactPredicate(criteria?.name),
        versionFilter = ExactPredicate(criteria?.version),
        schemaUrlFilter = ExactPredicate(criteria?.schemaUrl);
}

final class MeterSelectorCriteria {
  final String? name;
  final String? version;
  final String? schemaUrl;

  MeterSelectorCriteria({required this.name, required this.version, required this.schemaUrl});
}
