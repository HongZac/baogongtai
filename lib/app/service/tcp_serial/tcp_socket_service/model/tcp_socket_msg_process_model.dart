import 'package:basement/model.dart';

class TcpSocketMsgProcessModel extends ICloneable {

  ///接收对象（例如，扫码枪、电子秤（称重重量）。。。）
  String keyName;

  ///主机号
  dynamic host;
  ///端口号
  int port;

  ///精度值（可接受误差值）
  double accuracy;

  TcpSocketMsgProcessModel({
    required this.keyName,
    required this.host,
    required this.port,
    this.accuracy = 0,
  });

  factory TcpSocketMsgProcessModel.fromJson(Map<String, dynamic> json){
    return TcpSocketMsgProcessModel(
      keyName: json['keyName'] ?? '',
      host: json['host'] ?? '',
      port: json['port'] ?? '',
      accuracy: json['accuracy'] ?? 0,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'keyName': keyName,
      'host': host,
      'port': port,
      'accuracy': accuracy,
    };
  }

}