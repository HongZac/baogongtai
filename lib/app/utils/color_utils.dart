import 'package:flutter/material.dart';
import 'dart:math';


class ColorUtils {

  static int floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  static int getColorValue(Color color) {
    int value = floatToInt8(color.a) << 24 |
    floatToInt8(color.r) << 16 |
    floatToInt8(color.g) << 8 |
    floatToInt8(color.b) << 0;
    return value;
  }

  static int getColorValueByHex(String hexString){
    final Map<int, String> _hexTable = {
      10: 'A',
      11: 'B',
      12: 'C',
      13: 'D',
      14: 'E',
      15: 'F',
    };
    late final _hexTableReverse = _hexTable.map((k, v) => MapEntry(v, k));

    hexString = hexString.replaceAll('#', '').trim().toUpperCase();

    final bool isNegative = hexString[0] == '-';
    if (isNegative) hexString = hexString.substring(1);

    int decimalVal = 0;
    for (int i = 0; i < hexString.length; i++) {
      if (int.tryParse(hexString[i]) == null &&
          _hexTableReverse.containsKey(hexString[i]) == false) {
        return 0;
        //throw Exception('Non-hex value was passed to the function');
      } else {
        decimalVal += (pow(16, hexString.length - i - 1) *
            (int.tryParse(hexString[i]) != null
                ? int.parse(hexString[i])
                : _hexTableReverse[hexString[i]]!))
            .toInt();
      }
    }
    return isNegative ? -1 * decimalVal : decimalVal;
  }

}