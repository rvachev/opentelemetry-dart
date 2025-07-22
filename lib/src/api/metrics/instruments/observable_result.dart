// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/api.dart';

abstract interface class ObservableResult {
  void observe({required num number, List<Attribute> attributes = const []});
}

abstract interface class BatchObservableResult {
  void observe({required Observable metric, required num number, List<Attribute> attributes = const []});
}
