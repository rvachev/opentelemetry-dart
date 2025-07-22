// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

enum MetricDataType {
  /// A Gauge represents a measurement of a double value at a moment in time. Generally only one
  /// instance of a given Gauge metric will be reported per reporting interval.
  gauge,

  /// A Sum of values.
  sum,

  /// A Summary of measurements of numeric values, the sum of all measurements and the total number
  /// of measurements recorded, and quantiles describing the distribution of measurements (often
  /// including minimum "0.0" and maximum "1.0" quantiles).
  summary,

  /// A Histogram represents an approximate representation of the distribution of measurements
  /// recorded.
  histogram,

  /// An Exponential Histogram represents an approximate representation of the distribution of
  /// measurements recorded. The bucket boundaries follow a pre-determined exponential formula.
  exponentialHistogram,
}
