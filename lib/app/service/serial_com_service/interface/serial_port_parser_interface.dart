import 'package:basement/picker.dart';

///现有的解析器定义
enum SerialPortParserEnum {
  defaultParser,
  ///无线卡尺 1
  wirelessMicroMeter,
  ///反向接收顺序
  msgReverseOrder,
  ///读卡器 1
  cardReadA,
}

final List<PickerDataModel> serialPortParserList = [
  PickerDataModel(id: SerialPortParserEnum.defaultParser.name, name: '默认'),
  PickerDataModel(id: SerialPortParserEnum.wirelessMicroMeter.name, name: '无线卡尺 1'),
  PickerDataModel(id: SerialPortParserEnum.msgReverseOrder.name, name: '反向接收顺序'),
  PickerDataModel(id: SerialPortParserEnum.cardReadA.name, name: '读卡器 1'),
];


///将串口数据解析,返回字符串型
class SerialPortParserInterface {
  Future<String?> parse(List<int> dataList) async {
    return null;
  }
}
