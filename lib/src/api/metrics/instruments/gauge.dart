// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/api.dart';

abstract interface class Gauge {
  /// Records a value with a set of attributes.
  ///
  /// [value] The measurement.
  /// [attributes] A set of attributes to associate with the value.
  /// [context] The explicit context to associate with this measurement.
  void record(num value, {List<Attribute> attributes, Context context});
}
