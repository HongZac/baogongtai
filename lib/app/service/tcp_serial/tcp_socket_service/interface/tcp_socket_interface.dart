import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/service/tcp_serial/parser/card_reader_a_parser.dart';
import 'package:desktop/app/service/tcp_serial/parser/default_tcp_serial_parser.dart';
import 'package:desktop/app/service/tcp_serial/parser/msg_reverse_order_parser.dart';
import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_enum.dart';
import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_interface.dart';
import 'package:desktop/app/service/tcp_serial/parser/wireless_micro_meter_parser.dart';
import 'package:get/get.dart';


///TCP 连接状态
enum TcpSocketConnectStatus {
  ///已关闭
  closed,

  ///连接中……
  connecting,

  ///已连接
  connected,

  ///等待重连
  waitingReconnect,
}


///TCP 连接状态展示文本
extension TcpSocketConnectStatusText on TcpSocketConnectStatus {
  String get text {
    switch (this) {
      case TcpSocketConnectStatus.closed:
        return '已关闭';
      case TcpSocketConnectStatus.connecting:
        return '连接中';
      case TcpSocketConnectStatus.connected:
        return '已连接';
      case TcpSocketConnectStatus.waitingReconnect:
        return '等待重连';
    }
  }
}


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

  ///Socket 是否已经打开（表示当前是否实际连接成功）
  bool isOpen = false;

  ///是否保持连接（主动打开后为 true，主动关闭后为 false；断线期间仍为 true，等待自动重连）
  bool keepConnected = false;

  ///当前连接状态
  TcpSocketConnectStatus connectStatus = TcpSocketConnectStatus.closed;

  ///连续重连失败次数（用于设置页显示及退避计算）
  int reconnectFailCount = 0;

  ///下次重连的时间（用于设置页显示，未安排重连时为 null）
  DateTime? nextReconnectTime;

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