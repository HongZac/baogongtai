
import 'package:desktop/app/service/serial_com_service/interface/serial_port_parser_interface.dart';

///默认串口数据转换器
class DefaultSerialPortDataParser extends SerialPortParserInterface {

  @override
  Future<String?> parse(List<int> dataList) async {
    if (dataList.isEmpty){
      return null;
    }
    dataList.removeWhere((element) => element < 32 || element > 126);
    var data = String.fromCharCodes(dataList);
    return data;
  }


}