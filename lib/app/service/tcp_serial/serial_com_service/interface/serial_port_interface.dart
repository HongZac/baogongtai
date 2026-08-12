import 'package:desktop/app/service/tcp_serial/parser/card_reader_a_parser.dart';
import 'package:desktop/app/service/tcp_serial/parser/default_tcp_serial_parser.dart';
import 'package:desktop/app/service/tcp_serial/parser/msg_reverse_order_parser.dart';
import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_interface.dart';
import 'package:desktop/app/service/tcp_serial/parser/wireless_micro_meter_parser.dart';
import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_enum.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:get/get.dart';

import 'serial_port_config_interface.dart';

///串口通讯的应用接口
abstract class SerialPortInterface {
  ///串口名称，示例"COM4"
  final String portName;
  ///默认的串口参数
  late final SerialPortConfigInterface serialPortConfig;
  ///串口数据处理解析类名称
  final TcpSerialParserEnum? parserName;
  ///串口/网络数据转换器（实际的串口数据处理程序）
  late final TcpSerialParserInterface parser;

  ///串口是否已经打开
  bool isOpen = false;

  ///该串口最后一次接收到的数据
  final List<int> theLastDataList = [];
  ///该串口最后一次接收到数据的时间
  int theLastDataTime = 0;

  ///串口连接的错误信息
  String errMsg = '';

  ///数据触发，发送方
  final eventBus = Get.find<AppService>().eventBus;


  SerialPortInterface(this.portName, {
    this.parserName,
    SerialPortConfigInterface? config,
  }){
    serialPortConfig = config ?? SerialPortConfigInterface();
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
