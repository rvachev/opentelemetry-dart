// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'package:opentelemetry/api.dart';

typedef KeyPredicate = bool Function(String key);

sealed class AttributesProcessor {
  const AttributesProcessor();

  const factory AttributesProcessor.allowByKey(KeyPredicate keyFilter) = _AllowByKeyProcessor;

  const factory AttributesProcessor.denyByKey(KeyPredicate keyFilter) = _DenyByKeyProcessor;

  const factory AttributesProcessor.append(List<Attribute> aditionalAttributes) = _AppendingAttributeProcessor;

  factory AttributesProcessor.noop() => NoopAttributeProcessor.noop;

  List<Attribute> process({required List<Attribute> incoming, required Context context});

  bool get usesContext;

  AttributesProcessor then(AttributesProcessor other) {
    if (other.isNoop) {
      return this;
    }
    if (isNoop) {
      return other;
    }

    if (other case final _JoinedAttributesProccessor joinedAttribtesProccessor) {
      return joinedAttribtesProccessor.prepend(other);
    }

    return _JoinedAttributesProccessor([this, other]);
  }

  bool get isNoop => switch (this) {
        NoopAttributeProcessor _ => true,
        _ => false,
      };
}

final class NoopAttributeProcessor extends AttributesProcessor {
  static const NoopAttributeProcessor noop = NoopAttributeProcessor._();

  const NoopAttributeProcessor._();

  @override
  List<Attribute> process({required List<Attribute> incoming, required Context context}) {
    return incoming;
  }

  @override
  bool get usesContext {
    return false;
  }
}

final class _AllowByKeyProcessor extends AttributesProcessor {
  final KeyPredicate _keyFilter;

  const _AllowByKeyProcessor(this._keyFilter);

  @override
  List<Attribute> process({required List<Attribute> incoming, required Context context}) {
    return incoming.where((e) => _keyFilter(e.key)).toList();
  }

  @override
  bool get usesContext {
    return false;
  }

  @override
  String toString() {
    return 'AttributeKeyFilteringProcessor(nameFilter: $_keyFilter)';
  }
}

final class _DenyByKeyProcessor extends AttributesProcessor {
  final KeyPredicate _keyFilter;

  const _DenyByKeyProcessor(this._keyFilter);

  @override
  List<Attribute> process({required List<Attribute> incoming, required Context context}) {
    return (incoming..removeWhere((e) => _keyFilter(e.key))).toList();
  }

  @override
  bool get usesContext {
    return false;
  }

  @override
  String toString() {
    return 'AttributeKeyFilteringProcessor(nameFilter: $_keyFilter)';
  }
}

final class _AppendingAttributeProcessor extends AttributesProcessor {
  final List<Attribute> _aditionalAttributes;

  const _AppendingAttributeProcessor(this._aditionalAttributes);

  @override
  List<Attribute> process({required List<Attribute> incoming, required Context context}) {
    return incoming + _aditionalAttributes;
  }

  @override
  bool get usesContext {
    return false;
  }

  @override
  String toString() {
    return 'AppendingAttributeProcessor(aditionalAttributes: $_aditionalAttributes)';
  }
}

final class _JoinedAttributesProccessor extends AttributesProcessor {
  final List<AttributesProcessor> _processors;
  final bool _usesContextCache;

  _JoinedAttributesProccessor(List<AttributesProcessor> processors)
      : _processors = processors,
        _usesContextCache = processors.map((e) => e.usesContext).reduce((l, r) => l || r);

  @override
  List<Attribute> process({required List<Attribute> incoming, required Context context}) {
    var result = incoming;
    for (final processor in _processors) {
      result = processor.process(incoming: result, context: context);
    }
    return result;
  }

  @override
  bool get usesContext {
    return _usesContextCache;
  }

  @override
  AttributesProcessor then(AttributesProcessor other) {
    final newList = List.of(_processors);

    if (other case final _JoinedAttributesProccessor joinedAttribtesProccessor) {
      newList.addAll(joinedAttribtesProccessor._processors);
    } else {
      newList.add(other);
    }
    return _JoinedAttributesProccessor(newList);
  }

  AttributesProcessor prepend(AttributesProcessor other) {
    return _JoinedAttributesProccessor([other, ..._processors]);
  }

  @override
  String toString() {
    return 'JoinedAttributesProccessor(processors: $_processors)';
  }
}
