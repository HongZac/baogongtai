

///串口数据传递
class SerialPortDataModel {

  final String com;
  final String data;
  final bool isConnectMsg;

  SerialPortDataModel({
    required this.com,
    required this.data,
    this.isConnectMsg = false,
  });

}