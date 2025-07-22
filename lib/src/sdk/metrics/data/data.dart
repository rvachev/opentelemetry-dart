// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/data/point_data.dart';

sealed class Data<T extends BasePointData> {
  final Iterable<T> points;

  const Data({required this.points});
}

final class GaugeData<T extends PointData> extends Data<T> {
  const GaugeData({required Iterable<T> points}) : super(points: points);

  const GaugeData.empty() : super(points: const []);

  GaugeData<T> copyWith({List<T>? points}) {
    return GaugeData<T>(points: points ?? this.points);
  }

  @override
  String toString() {
    return 'GaugeData{points: $points}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GaugeData<T> && other.points == points;
  }

  @override
  int get hashCode => points.hashCode;
}

final class HistogramData extends Data<HistogramPointData> {
  final AggregationTemporality temporality;

  const HistogramData({required this.temporality, required super.points});

  const HistogramData.empty()
      : temporality = AggregationTemporality.delta,
        super(points: const []);

  HistogramData copyWith({AggregationTemporality? temporality, List<HistogramPointData>? points}) {
    return HistogramData(temporality: temporality ?? this.temporality, points: points ?? this.points);
  }

  @override
  String toString() {
    return 'HistogramData{temporality: $temporality, points: $points}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HistogramData && other.temporality == temporality && other.points == points;
  }

  @override
  int get hashCode => temporality.hashCode ^ points.hashCode;
}

final class ExponentialHistogramData extends Data<ExponentialHistogramPointData> {
  final AggregationTemporality temporality;

  const ExponentialHistogramData({required this.temporality, required super.points});

  const ExponentialHistogramData.empty()
      : temporality = AggregationTemporality.delta,
        super(points: const []);

  ExponentialHistogramData copyWith({
    AggregationTemporality? temporality,
    List<ExponentialHistogramPointData>? points,
  }) {
    return ExponentialHistogramData(temporality: temporality ?? this.temporality, points: points ?? this.points);
  }

  @override
  String toString() {
    return 'ExponentialHistogramData{temporality: $temporality, points: $points}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExponentialHistogramData && other.temporality == temporality && other.points == points;
  }

  @override
  int get hashCode => temporality.hashCode ^ points.hashCode;
}

final class SumData<T extends PointData> extends Data<T> {
  final bool isMonotonic;
  final AggregationTemporality temporality;

  const SumData({required this.isMonotonic, required this.temporality, required super.points});

  const SumData.empty()
      : isMonotonic = false,
        temporality = AggregationTemporality.delta,
        super(points: const []);

  SumData<T> copyWith({bool? isMonotonic, AggregationTemporality? temporality, List<T>? points}) {
    return SumData<T>(
      isMonotonic: isMonotonic ?? this.isMonotonic,
      temporality: temporality ?? this.temporality,
      points: points ?? this.points,
    );
  }

  @override
  String toString() {
    return 'SumData{isMonotonic: $isMonotonic, temporality: $temporality, points: $points}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SumData<T> &&
        other.isMonotonic == isMonotonic &&
        other.temporality == temporality &&
        other.points == points;
  }

  @override
  int get hashCode => isMonotonic.hashCode ^ temporality.hashCode ^ points.hashCode;
}

final class SummaryData extends Data<PointData<double>> {
  const SummaryData({required super.points});

  const SummaryData.empty() : super(points: const []);

  SummaryData copyWith({List<PointData<double>>? points}) {
    return SummaryData(points: points ?? this.points);
  }

  @override
  String toString() {
    return 'SummaryData{points: $points}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SummaryData && other.points == points;
  }

  @override
  int get hashCode => points.hashCode;
}
