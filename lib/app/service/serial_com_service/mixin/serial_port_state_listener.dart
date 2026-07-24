import 'dart:async';

import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/service/serial_com_service/serial_port_data_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin SerialPortStateListenerMixin<T extends StatefulWidget> on State<T> {
  static List<String> receiverList = [''];

  final String serialPortCacheKey = "serial.port";

  ///是否允许接收条码处理程序
  bool enableSerialPort = true;

  final appService = Get.find<AppService>();
  late StreamSubscription<SerialPortDataModel> subscription;

  ///错误发生时回调函数
  void onError(e) {
    printError(info: e);
  }

  @override
  void initState() {
    super.initState();

    subscription = appService.eventBus.on<SerialPortDataModel>().listen((event) async {});
    receiverList.add(T.toString());
  }

  @override
  void dispose() {
    subscription.cancel();
    receiverList.remove(T.toString());
    super.dispose();
  }
}
