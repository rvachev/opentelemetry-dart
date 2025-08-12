// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/api.dart';

/// {@template opentelemetry.api.metrics.MeterProvider}
///
/// A registry for creating named [Meter]s.
///
/// {@endtemplate}
abstract class MeterProvider {
  /// {@template opentelemetry.api.metrics.MeterProvider.get}
  ///
  /// Gets or creates a [Meter] instance.
  ///
  /// The meter is identified by the combination of [name], [version],
  /// [schemaUrl] and [attributes]. The [name] SHOULD uniquely identify the
  /// instrumentation scope, such as the instrumentation library
  /// (e.g. io.opentelemetry.contrib.mongodb), package, module or class name.
  /// The [version] specifies the version of the instrumentation scope if the
  /// scope has a version (e.g. a library version). The [schemaUrl] identifies
  /// the schema this provider adheres to.  The [attributes] specifies
  /// attributes to associate with emitted telemetry.
  ///
  /// {@endtemplate}
  Meter get(
    String name, {
    String version = '',
    String schemaUrl = '',
    List<Attribute> attributes = const [],
  });

  /// {@template opentelemetry.api.metrics.MeterProvider.forceFlush}
  ///
  /// Flushes any remaining data in the [MeterProvider].
  ///
  /// Intended for manual flushes and graceful shutdowns.
  ///
  /// {@endtemplate}
  Future<void> forceFlush();

  /// {@template opentelemetry.api.metrics.MeterProvider.shutdown}
  ///
  /// Shut down the [MeterProvider] and release any held resources and data.
  ///
  /// After this returns, the exporter should reject or ignore further calls to
  /// [get] and [forceFlush]. This method should be idempotent.
  ///
  /// {@endtemplate}
  Future<void> shutdown();
}
