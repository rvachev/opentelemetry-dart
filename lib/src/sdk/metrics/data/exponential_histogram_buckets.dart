import 'dart:math';

import 'package:collection/collection.dart';
import 'package:opentelemetry/src/sdk/metrics/internal/aggregator/base2_exponential_histogram_indexer.dart';

final class Base2ExponentialHistogramBuckets {
  final Base2ExponentialHistogramIndexer _indexer;
  final int _scale;
  final BucketsBacking backing;
  int _indexBase;
  int _indexStart;
  int _indexEnd;

  Base2ExponentialHistogramBuckets(int scale)
      : _scale = scale,
        _indexer = Base2ExponentialHistogramIndexer.get(scale),
        backing = BucketsBacking([]),
        _indexEnd = 0,
        _indexBase = 0,
        _indexStart = 0;

  Base2ExponentialHistogramBuckets._({
    required this.backing,
    required Base2ExponentialHistogramIndexer indexer,
    required int scale,
    int indexBase = 0,
    int indexStart = 0,
    int indexEnd = 0,
  })  : _indexBase = indexBase,
        _indexStart = indexStart,
        _indexEnd = indexEnd,
        _indexer = indexer,
        _scale = scale;

  Base2ExponentialHistogramIndexer get indexer => _indexer;

  int get offset => _indexStart;

  int get scale => _scale;

  int get length {
    if (backing.isEmpty) {
      return 0;
    }

    if (_indexEnd == _indexStart && at(0) == 0) {
      return 0;
    }

    return _indexEnd - _indexStart + 1;
  }

  List<int> get counts => List.generate(length, at);

  int getScaleReduction(double value) {
    final index = _indexer.computeIndex(value);
    final newStart = min(index, _indexStart);
    final newEnd = max(index, _indexEnd);
    return getScaleReductionInRange(newStart, newEnd);
  }

  int getScaleReductionInRange(int newStart, int newEnd) {
    var scaleReduction = 0;

    while (newEnd - newStart + 1 > backing.length) {
      newStart >>= 1;
      newEnd >>= 1;
      scaleReduction++;
    }
    return scaleReduction;
  }

  int at(int index) {
    final bias = _indexBase - _indexStart;
    if (index < bias) {
      index += backing.length;
    }

    index -= bias;
    return backing.countAt(index);
  }

  bool incrementBucket({required int bucketIndex, required int increment}) {
    if (_indexBase == 0) {
      _indexStart = bucketIndex;
      _indexEnd = bucketIndex;
      _indexBase = bucketIndex;
      backing.increment(bucketIndex: 0, increment: increment);
      return true;
    }

    if (bucketIndex > _indexEnd) {
      if (bucketIndex - _indexStart + 1 > backing.length) {
        return false;
      }
      _indexEnd = bucketIndex;
    } else if (bucketIndex < _indexStart) {
      if (_indexEnd - bucketIndex + 1 > backing.length) {
        return false;
      }
      _indexStart = bucketIndex;
    }

    var realIndex = bucketIndex - _indexBase;
    if (realIndex >= backing.length) {
      realIndex -= backing.length;
    } else if (realIndex < 0) {
      realIndex += backing.length;
    }

    backing.increment(bucketIndex: realIndex, increment: increment);
    return true;
  }

  void decrementBucket({required int bucketIndex, required int decrement}) {
    backing.decrement(bucketIndex: bucketIndex, decrement: decrement);
  }

  void trim() {
    for (var i = 0; i < length; i++) {
      if (at(i) != 0) {
        _indexStart += i;
        break;
      } else if (i == length - 1) {
        _indexStart = _indexEnd = _indexBase = 0;
        return;
      }
    }

    for (var i = length - 1; i >= 0; i--) {
      if (at(i) != 0) {
        _indexEnd -= length - i - 1;
        break;
      }
    }

    _rotate();
  }

  void downscale(int by) {
    _rotate();

    final size = 1 + _indexEnd - _indexStart;
    final each = 1 << by;
    var inpos = 0;
    var outpos = 0;

    for (var pos = _indexStart; pos <= _indexEnd;) {
      var mod = pos % each;
      if (mod < 0) {
        mod += each;
      }
      for (var i = 0; i < each && inpos < size; i++) {
        _relocateBucket(outpos, inpos);
        inpos++;
        pos++;
      }
      outpos++;
    }

    _indexStart >>= by;
    _indexEnd >>= by;
    _indexBase = _indexStart;
  }

  Base2ExponentialHistogramBuckets clone() {
    return Base2ExponentialHistogramBuckets._(
      scale: _scale,
      indexer: _indexer,
      backing: backing.clone(),
      indexBase: _indexBase,
      indexStart: _indexStart,
      indexEnd: _indexEnd,
    );
  }

  void _rotate() {
    final bias = _indexBase - _indexStart;

    if (bias == 0) {
      return;
    } else if (bias > 0) {
      backing
        ..reverse(from: 0, limit: backing.length)
        ..reverse(from: 0, limit: bias)
        ..reverse(from: bias, limit: backing.length);
    } else {
      backing
        ..reverse(from: 0, limit: backing.length)
        ..reverse(from: 0, limit: backing.length + bias);
    }
    _indexBase = _indexStart;
  }

  void _relocateBucket(int dest, int src) {
    if (dest == src) {
      return;
    }

    incrementBucket(bucketIndex: dest, increment: backing.emptyBucket(src));
  }
}

final class BucketsBacking {
  BucketsBacking(List<int> counts) : _counts = counts;

  List<int> _counts;

  int get length => _counts.length;

  bool get isEmpty => _counts.isEmpty;

  int countAt(int index) => _counts[index];

  void growTo({
    required int newSize,
    required int oldPositiveLimit,
    required int newPositiveLimit,
  }) {
    _counts = List<int>.filled(newSize, 0)
      ..splice(
        start: newPositiveLimit,
        deleteCount: _counts.length - oldPositiveLimit,
        newItems: _counts.slice(oldPositiveLimit),
      )
      ..splice(start: 0, deleteCount: oldPositiveLimit, newItems: _counts.slice(0, oldPositiveLimit));
  }

  void reverse({required int from, required int limit}) {
    final num = ((from + limit) / 2).floor() - from;
    for (var i = 0; i < num; i++) {
      final tmp = _counts[from + i];
      _counts[from + i] = _counts[limit - i - 1];
      _counts[limit - i - 1] = tmp;
    }
  }

  int emptyBucket(int bucketIndex) {
    final tmp = _counts[bucketIndex];
    _counts[bucketIndex] = 0;
    return tmp;
  }

  void increment({required int bucketIndex, required int increment}) {
    _counts[bucketIndex] += increment;
  }

  void decrement({required int bucketIndex, required int decrement}) {
    _counts[bucketIndex] = max(0, _counts[bucketIndex] - decrement);
  }

  BucketsBacking clone() {
    return BucketsBacking(List.of(_counts));
  }
}

extension on List {
  void splice<T>({
    required int start,
    int? deleteCount,
    List<T> newItems = const [],
  }) {
    final actualStart = start < 0 ? length + start : start;

    final actualDeleteCount = deleteCount ?? length - actualStart;

    if (actualStart > length) {
      return;
    }

    replaceRange(
      actualStart,
      actualStart + actualDeleteCount > length ? length : actualStart + actualDeleteCount,
      newItems,
    );
  }
}
