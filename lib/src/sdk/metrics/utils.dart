// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'dart:convert';

import 'package:opentelemetry/api.dart';

String hashAttributes(List<Attribute> attributes) {
  final attributeMap = {
    for (final attribute in attributes) attribute.key: attribute.value,
  };

  final keys = attributeMap.keys.toList();

  if (keys.isEmpty) return '';

  keys.sort();

  return jsonEncode({
    for (final key in keys) key: attributeMap[key],
  });
}

List<Attribute> unhashAttributes(String hashedAttributes) {
  if (hashedAttributes.isEmpty) return [];

  final attributeMap = jsonDecode(hashedAttributes) as Map<String, dynamic>;

  return [
    for (final entry in attributeMap.entries) Attribute(entry.key, entry.value),
  ];
}
