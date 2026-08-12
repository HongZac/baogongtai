import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/service/tcp_serial/parser/card_reader_a_parser.dart';
import 'package:desktop/app/service/tcp_serial/parser/default_tcp_serial_parser.dart';
import 'package:desktop/app/service/tcp_serial/parser/msg_reverse_order_parser.dart';
import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_enum.dart';
import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_interface.dart';
import 'package:desktop/app/service/tcp_serial/parser/wireless_micro_meter_parser.dart';
import 'package:get/get.dart';


///TCP客户端套接字（Socket）通讯的应用接口
abstract class TcpSocketInterface {

  ///主机号
  final dynamic host;
  ///端口号
  final int port;

  ///Socket 数据处理解析类名称
  final TcpSerialParserEnum? parserName;
  ///串口/网络数据转换器（实际的 Socket 数据处理程序）
  late final TcpSerialParserInterface parser;

  ///Socket 是否已经打开
  bool isOpen = false;

  ///该 Socket 最后一次接收到的数据
  final List<int> theLastDataList = [];
  ///该 Socket 最后一次接收到数据的时间
  int theLastDataTime = 0;

  ///Socket 连接的错误信息
  String errMsg = '';

  ///数据触发，发送方
  final eventBus = Get.find<AppService>().eventBus;


  TcpSocketInterface({
    required this.host,
    required this.port,
    this.parserName,
  }){
    switch (parserName) {
      case TcpSerialParserEnum.wirelessMicroMeter: ///无线卡尺 1
        parser = WirelessMicroMeterParser();
        break;
      case TcpSerialParserEnum.msgReverseOrder: ///反向接收顺序
        parser = MsgReverseOrderParser();
        break;
      case TcpSerialParserEnum.cardReadA: ///读卡器 1
        parser = CardReadAParser();
        break;
      default:
        parser = DefaultTcpSerialParser();
        break;
    }
  }

  Future<bool> open() async {
    return false;
  }

  Future<bool> close() async {
    return true;
  }

}