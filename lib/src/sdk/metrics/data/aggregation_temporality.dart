/// Describes the time period over which measurements are aggregated.
enum AggregationTemporality {
  /// Measurements are aggregated since the previous collection.
  delta,

  /// Measurements are aggregated over the lifetime of the instrument.
  cumulative,
}
