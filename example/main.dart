// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'dart:async';
import 'dart:math';

import 'package:opentelemetry/api.dart' hide MeterProvider;
import 'package:opentelemetry/sdk.dart';
import 'package:opentelemetry/src/sdk/metrics/data/aggregation_temporality.dart';
import 'package:opentelemetry/src/sdk/metrics/export/metric_exporter.dart';
import 'package:opentelemetry/src/sdk/metrics/export/metric_reader.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/aggregation.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/view/attribute_processor.dart';
import 'package:opentelemetry/src/sdk/metrics/meter_provider.dart';
import 'package:opentelemetry/src/sdk/metrics/view.dart';

/// Applications use a tracer to create sets of spans that constitute a trace.
/// There are several components needed to get a tracer:

/// An exporter is needed to send ended spans to a backend such as the dev
/// console.
final exporter = ConsoleExporter();

/// A processor is needed to handle starting and ending spans. The
/// [SimpleSpanProcessor] doesn't do any processing and immediately forwards
/// ended spans to the exporter. This is in contrast to the [BatchSpanProcessor]
/// which will batch spans together before forwarding them to the exporter.
final processor = SimpleSpanProcessor(exporter);

/// Finally, a [TracerProvider] is configured with any number of processors.
/// [TracerProviderBase] is suitable for applications run in the VM whereas
/// a WebTracerProvider is suited for applications transpiled to JavaScript to
/// run in a browser.
final provider = TracerProviderBase(processors: [processor]);

// The [TracerProvider] is the mechanism used to get a [Tracer].
final tracer = provider.getTracer('instrumentation-name');

/// Demonstrates creating a trace with a parent and child span.
void main() async {
  // The current active context is available via a static getter.
  var context = Context.current;

  // A trace starts with a root span which has no parent.
  final parentSpan = tracer.startSpan('parent-span');

  // A new context can be created in order to propagate context manually.
  context = contextWithSpan(context, parentSpan);

  // The [traceContext] and [traceContextSync] functions will automatically
  // propagate context, capture errors, and end the span.
  await traceContext('child-span', (_) {
    tracer.startSpan('grandchild-span').end();
    return Future.delayed(Duration(milliseconds: 100));
  }, context: context, tracer: tracer);

  // Spans must be ended or they will not be exported.
  parentSpan.end();

  final meterProvider = MeterProvider(
    resource: Resource([
      Attribute.fromString('appVersion', '1.13.0'),
      Attribute.fromString('userId', '123'),
    ]),
    metricReaders: [
      PeriodicExportingMetricReader(
        exporter: ConsoleMetricExporter(
          temporalitySelector: (instrumentType) {
            return AggregationTemporality.delta;
          },
        ),
        exportIntervalMillis: 2000,
      ),
    ],
    views: [
      View(
        ViewOptions(
          name: 'my.test.view.counter',
          instrumentName: 'view.counter',
          meterName: 'my.test.view.meter',
          attributeProcessor: AttributesProcessor.allowByKey(
            (key) {
              return key == 'CPU';
            },
          ),
        ),
      ),
      View(
        ViewOptions(
          name: 'histogram.custom.aggregation',
          instrumentName: 'my.test.meter.histogram',
          aggregation: Aggregation.explicitBucketHistogram([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        ),
      ),
    ],
  );

  final meter = meterProvider.get(
    'my.test.meter',
    version: '1.13.0',
    attributes: [
      Attribute.fromString('featureName', 'files'),
    ],
  );

  // meter.createCounter('counter', unit: '1').add(5);

  // final viewMeter = meterProvider.get('my.test.view.meter', version: '1.13.0', attributes: [
  //   Attribute.fromString('source', 'view'),
  // ]);

  // viewMeter.createCounter('view.counter', unit: '1')
  //   ..add(5, attributes: [Attribute.fromString('OS', 'iOS'), Attribute.fromString('CPU', 'ARM')])
  //   ..add(7, attributes: [Attribute.fromString('OS', 'iOS'), Attribute.fromString('CPU', 'ARM')]);

  // final counter = meter.createCounter('my.test.meter.counter')
  //   ..add(1)
  //   ..add(1, attributes: [Attribute.fromString('another.attribute', '2')]);
  // final gauge = meter.createGauge('my.test.meter.gauge')
  //   ..record(2)
  //   ..record(3);
  // final histogram = meter.createHistogram('my.test.meter.histogram')
  //   ..record(1)
  //   ..record(6);
  // final upDownCounter = meter.createUpDownCounter('my.test.meter.upDownCounter')
  //   ..add(3)
  //   ..add(-5);
  final observableCounter = meter.createObservableCounter('my.test.meter.observableCounter',
      description: 'Counter for current time', unit: 'ms')
    ..addCallback(
      (observableResult) {
        observableResult
            .observe(number: observeValue(), attributes: [Attribute.fromString('counter', 'DateTime.now()')]);
      },
    );
  final observableUpDownCounter = meter.createObservableUpDownCounter('my.test.meter.observableUpDownCounter')
    ..addCallback(
      (observableResult) {
        observableResult.observe(number: observeRandomValue());
      },
    );

  // await Future.delayed(Duration(seconds: 5), () {
  // counter.add(4);
  // gauge.record(6);
  // histogram.record(3);
  // upDownCounter.add(3);
  // });
}

int observeValue() {
  return DateTime.now().millisecondsSinceEpoch;
}

final random = Random();

int observeRandomValue() {
  return random.nextInt(20) - 10;
}
