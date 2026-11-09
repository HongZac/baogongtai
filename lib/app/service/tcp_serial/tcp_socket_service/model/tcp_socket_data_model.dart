import 'package:desktop/app/service/tcp_serial/tcp_socket_service/interface/tcp_socket_interface.dart';


///TCP 数据传递
class TcpSocketDataModel {

  ///主机号
  final dynamic host;
  ///端口号
  final int port;

  final String data;
  final bool isConnectMsg;

  ///连接状态（用于通知设置页刷新连接状态，非连接状态事件时为 null）
  final TcpSocketConnectStatus? connectStatus;

  ///是否保持连接（用于设置页开关状态，不涉及开关变化时为 null）
  final bool? keepConnected;

  TcpSocketDataModel({
    required this.host,
    required this.port,
    required this.data,
    this.isConnectMsg = false,
    this.connectStatus,
    this.keepConnected,
  });

}