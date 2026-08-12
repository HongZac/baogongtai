import 'package:basement/model.dart';


///串口消息接收配置
class SerialPortMsgProcessModel extends ICloneable {

  ///接收对象（例如，扫码枪、电子秤（称重重量）。。。）
  String keyName;

  ///串口号
  String com;

  ///精度值（可接受误差值）
  double accuracy;

  SerialPortMsgProcessModel({
    required this.keyName,
    required this.com,
    this.accuracy = 0,
  });

  factory SerialPortMsgProcessModel.fromJson(Map<String, dynamic> json){
    return SerialPortMsgProcessModel(
      keyName: json['keyName'] ?? '',
      com: json['com'] ?? '',
      accuracy: json['accuracy'] ?? 0,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'keyName': keyName,
      'com': com,
      'accuracy': accuracy,
    };
  }

}