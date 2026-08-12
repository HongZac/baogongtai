import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_interface.dart';


///串口/网络数据转换器 读卡器 1
class CardReadAParser extends TcpSerialParserInterface {

  @override
  Future<String?> parse(List<int> dataList) async {
    if (dataList.isEmpty) {
      return null;
    }
    dataList.removeWhere((element) => element < 32 || element > 126);
    var data = String.fromCharCodes(dataList);
    return data;
  }
}