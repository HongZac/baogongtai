import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_interface.dart';


///默认串口/网络数据转换器
class DefaultTcpSerialParser extends TcpSerialParserInterface {

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