const _escape = r'/[\^$\\.+?()[\]{}|]/g';

sealed class Predicate {
  bool match(String str);
}

final class PatternPredicate extends Predicate {
  final bool _matchAll;
  final RegExp _regexp;

  PatternPredicate(String pattern)
      : _matchAll = pattern == '*',
        _regexp = pattern == '*' ? RegExp(r'/.*/') : RegExp(escapePattern(pattern));

  @override
  bool match(String str) {
    if (_matchAll) {
      return true;
    }

    return _regexp.hasMatch(str);
  }

  static String escapePattern(String pattern) {
    final escaped = pattern.replaceAll(_escape, r'\\$&').replaceAll('*', '.*');
    return '^$escaped\$';
  }

  static bool hasWildcard(String pattern) {
    return pattern.contains('*');
  }
}

final class ExactPredicate extends Predicate {
  final bool _matchAll;
  final String? _pattern;

  ExactPredicate(String? pattern)
      : _matchAll = pattern == null,
        _pattern = pattern;

  @override
  bool match(String str) {
    if (_matchAll) {
      return true;
    }

    return str == _pattern;
  }
}
