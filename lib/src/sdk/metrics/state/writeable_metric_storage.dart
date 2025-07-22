// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/api.dart';

abstract interface class WriteableMetricStorage {
  void record({
    required num value,
    required List<Attribute> attributes,
    Context? context,
  });

  bool get isEnabled;
}
