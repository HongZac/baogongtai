

import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect.dart';

///称重消息接收主机端口Model
@Deprecated('计划换个命名')
class WeightMsgConnectModel {
  String key;
  dynamic host;
  ///端口号
  int port;
  ///串口号
  String com;
  ///可接受误差值
  double accuracy;
  ///消息顺序是否是反向的
  ///
  ///重量数据均为最低位在前，高位和符号位在最后。负数符号位发送为“-”，正数时符号位发送 0；
  ///
  ///例如当前仪表显示的重量为 -500.00 kg，则串行输出数据为：=00.005-；
  ///
  ///当前仪表显示的重量为 500.00 kg，则串行输出数据为：=00.0050；
  bool isWeightMsgReverseOrder;
  WeightMsgConnect? weightMsgConnectService;

  WeightMsgConnectModel({
    required this.key,
    required this.host,
    required this.port,
    required this.com,
    this.accuracy = 0,
    this.isWeightMsgReverseOrder = false,
    this.weightMsgConnectService,
  });

  factory WeightMsgConnectModel.fromJson(Map<String, dynamic> json){
    return WeightMsgConnectModel(
      key: json['key'] ?? '',
      host: json['host'] ?? '',
      port: json['port'] ?? 0,
      com: json['com'] ?? '',
      accuracy: json['accuracy'] ?? 0,
      isWeightMsgReverseOrder: json['isWeightMsgReverseOrder'] ?? false,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'key': key,
      'host': host,
      'port': port,
      'com': com,
      'accuracy': accuracy,
      'isWeightMsgReverseOrder': isWeightMsgReverseOrder,
    };
  }

}