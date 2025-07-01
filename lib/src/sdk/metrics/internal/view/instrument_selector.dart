import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/predicate.dart';

final class InstrumentSelector {
  final Predicate nameFilter;
  final InstrumentType? type;
  final Predicate unitFilter;

  InstrumentSelector(InstrumentSelectorCriteria? criteria)
      : nameFilter = PatternPredicate(criteria?.name ?? '*'),
        type = criteria?.type,
        unitFilter = ExactPredicate(criteria?.unit);
}

final class InstrumentSelectorCriteria {
  final String? name;
  final String? unit;
  final InstrumentType? type;

  InstrumentSelectorCriteria({required this.name, required this.unit, required this.type});
}
