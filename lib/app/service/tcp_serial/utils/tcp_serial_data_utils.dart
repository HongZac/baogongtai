import 'package:basement/utils.dart';

class TcpSerialDataUtils {

  static String getFormatValue(String value, {
    bool isNum = true,
  }){
    ///new RegExp(r'[\s\r\n+\-a-zA-Z]')
    value = value.replaceAll(RegExp(r'[^0-9.]'), ''); ///移除非数字或小数点
    if (isNum){
      int point = 0;
      List<String> list = value.split('.');
      if (list.length == 2){
        point = list[1].length;
      }
      //value = NumFormatUtil.qtyFormatConverter(value, decimal: point);
      value = num.tryParse(value)?.toStringAsFixed(point) ?? '';
    }
    return value;
  }

  ///判断指定两个值的差值是否在可接受误差范围内
  ///
  /// [True]：小于可接受误差值（在可接受误差范围内）；
  /// [False]：大于可接受误差值；
  ///
  /// [oldValue]：需要判断的旧值
  ///
  /// [value]：需要判断的新值
  ///
  /// [errorRange]：误差值
  static bool isWithinAcceptableErrorRange({
    required double? oldValue,
    required double value,
    required double errorRange,
  }) {
    if (oldValue == null){
      return false;
    }
    bool boolValue = (oldValue - value).abs() < errorRange;
    if (boolValue){
      PrintUtil.printDebug('小于可接受误差值($errorRange)：old: $oldValue; new: $value');
    }
    return boolValue;
  }

}