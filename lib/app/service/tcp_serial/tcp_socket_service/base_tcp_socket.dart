import 'package:basement/model.dart';
import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_enum.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/implement/tcp_socket.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/interface/tcp_socket_interface.dart';
import 'package:get/get.dart';


///TCP 套接字通讯服务对象
class BaseTcpSocket extends ICloneable {

  ///默认自动打开
  final bool autoOpen;

  ///实际的 TCP 处理程序
  late final TcpSocketInterface _tcpSocket;

  BaseTcpSocket({
    this.autoOpen = false,
    required dynamic host,
    required int port,
    TcpSerialParserEnum? parser,
  }){
    _tcpSocket = TcpSocket(
      host: host,
      port: port,
      parserName: parser,
    );
  }



  ///主机号
  dynamic get host => _tcpSocket.host;
  ///端口号
  int get port => _tcpSocket.port;
  ///TCP 数据处理解析类
  TcpSerialParserEnum? get parserName => _tcpSocket.parserName;
  ///当前 TCP 通讯是否打开
  bool get isOpen => _tcpSocket.isOpen;
  ///该 TCP 口最后一次接收到的数据
  List<int> get theLastDataList => _tcpSocket.theLastDataList;
  ///TCP 连接的错误信息
  String get errMsg => _tcpSocket.errMsg;


  Future<bool> open() async {
    return _tcpSocket.open();
  }

  Future<bool> close() async {
    return _tcpSocket.close();
  }


  factory BaseTcpSocket.fromJson(Map<String, dynamic> json){
    return BaseTcpSocket(
      autoOpen: json['AutoOpen'] ?? false,
      host: json['Host'] ?? '',
      port: json['Port'] ?? 0,
      parser: TcpSerialParserEnum.values.firstWhereOrNull(
              (element) => element.toString() == json['ParserName']),
    );
  }

  Map<String, dynamic> toJson(){
    Map<String, dynamic> map = {
      'AutoOpen': autoOpen,
      'Host': _tcpSocket.host,
      'Port': _tcpSocket.port,
      'ParserName': _tcpSocket.parserName?.toString(),
    };
    return map;
  }

}