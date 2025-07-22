// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/metrics/view/predicate.dart';

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
