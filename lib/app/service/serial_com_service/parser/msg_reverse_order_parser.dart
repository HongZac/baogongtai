import 'package:desktop/app/service/serial_com_service/interface/serial_port_parser_interface.dart';


///反向接收顺序
class MsgReverseOrderParser extends SerialPortParserInterface {

  @override
  Future<String?> parse(List<int> dataList) async {
    if (dataList.isEmpty) {
      return null;
    }
    dataList.removeWhere((element) => element < 32 || element > 126);
    var data = String.fromCharCodes(dataList);
    data = data.split('').reversed.join('');
    return data;
  }

}