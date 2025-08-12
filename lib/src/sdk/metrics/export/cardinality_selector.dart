// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/src/sdk/metrics/instrument_type.dart';

/// A function that takes an [InstrumentType] and returns an integer representing the cardinality limit.
typedef CardinalitySelector = int Function(InstrumentType instrumentType);
