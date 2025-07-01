import 'dart:math';
import 'dart:typed_data';

final class Base2ExponentialHistogramIndexer {
  static const _exponentMask = 0x7ff00000;
  static const _significandMask = 0xfffff;
  static const _exponentBias = 1023;
  static const _significandWidth = 52;
  static const _exponentWidth = 11;

  static final _cache = <int, Base2ExponentialHistogramIndexer>{};

  final int _scale;
  final double _scaleFactor;

  Base2ExponentialHistogramIndexer._(int scale)
      : _scale = scale,
        _scaleFactor = _computeScaleFactor(scale);

  factory Base2ExponentialHistogramIndexer.get(int scale) {
    return _cache.putIfAbsent(scale, () => Base2ExponentialHistogramIndexer._(scale));
  }

  int computeIndex(double value) {
    final absValue = value.abs();

    if (_scale > 0) {
      return _getIndexByLogarithm(absValue);
    }

    if (_scale == 0) {
      return _mapToIndexScaleZero(absValue);
    }

    return _mapToIndexScaleZero(value) >> -_scale;
  }

  int _getIndexByLogarithm(double value) {
    return (log(value) * _scaleFactor).ceil() - 1;
  }

  static int _mapToIndexScaleZero(double value) {
    final data = ByteData(8)..setFloat64(0, value);
    final bits = data.getUint32(0);
    final expBits = (bits & _exponentMask) >> 20;
    final rawBits = expBits - _exponentBias;

    var rawExponent = (rawBits & _exponentMask) >> _significandWidth;
    final rawSignificand = rawBits & _significandMask;
    if (rawExponent == 0) {
      rawExponent -= _numberOfLeadingZeros(rawSignificand - 1) - _exponentWidth - 1;
    }
    final ieeeExponent = rawExponent - _exponentBias;
    if (rawSignificand == 0) {
      return ieeeExponent - 1;
    }
    return ieeeExponent;
  }

  static double _computeScaleFactor(int scale) {
    return log2e * pow(2, scale);
  }
}

int _numberOfLeadingZeros(int i) {
  int _bitCount(int i) {
    i -= (i >> 1) & 0x55555555;
    i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
    i = (i + (i >> 4)) & 0xF0F0F0F;
    i += i >> 8;
    i += i >> 16;
    return i & 0x0000003F;
  }

  i |= i >> 1;
  i |= i >> 2;
  i |= i >> 4;
  i |= i >> 8;
  i |= i >> 16;
  return _bitCount(~i);
}
