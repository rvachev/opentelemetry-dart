// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

/// Describes the time period over which measurements are aggregated.
enum AggregationTemporality {
  /// Measurements are aggregated since the previous collection.
  delta,

  /// Measurements are aggregated over the lifetime of the instrument.
  cumulative,
}
