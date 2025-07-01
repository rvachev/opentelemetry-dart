import 'package:opentelemetry/sdk.dart';

typedef MeterConfigurator = MeterConfig Function(InstrumentationScope meterScope);

final class MeterConfig {
  static const _defaultConfig = MeterConfig(disabled: false);
  static const _disabledConfig = MeterConfig(disabled: true);

  final bool _disabled;

  const MeterConfig({bool disabled = false}) : _disabled = disabled;

  factory MeterConfig.enabled() => _defaultConfig;

  factory MeterConfig.disabled() => _disabledConfig;

  bool get disabled => _disabled;
}
