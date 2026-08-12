

///TCP 数据传递
class TcpSocketDataModel {

  ///主机号
  final dynamic host;
  ///端口号
  final int port;

  final String data;
  final bool isConnectMsg;

  TcpSocketDataModel({
    required this.host,
    required this.port,
    required this.data,
    this.isConnectMsg = false,
  });

}