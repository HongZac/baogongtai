import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:basement/utils.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/interface/tcp_socket_interface.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class TcpSocket extends TcpSocketInterface {

  Socket? sock;

  StreamSubscription<Uint8List>? listen;

  final int _minDataDelayTime = 1000;


  TcpSocket({
    required super.host,
    required super.port,
    super.parserName,
  });


  @override
  Future<bool> open() async {
    isOpen = false;
    errMsg = '';

    try {
      sock = await Socket.connect(host, port);
    } catch (e){
      isOpen = false;
      errMsg = 'TCP $host:$port 连接时出错：${e.toString()}';
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        ToastNotification(Get.overlayContext!).error(errMsg);
      });
      eventBus.fire(TcpSocketDataModel(
        host: host,
        port: port,
        data: jsonEncode({'-1': errMsg}),
        isConnectMsg: true,
      ));
      return false;
    }

    ///监听
    listen = sock?.listen((Uint8List data) async {
      ///这里不要用防抖（Timer），会导致称重数据无法传递（称重消息每 50ms 发送一次，Timer 计时需要 1000ms）
      int currentKeyPressTime = DateTime.now().millisecondsSinceEpoch;
      PrintUtil.printDebug('两次 TCP 消息间隔：${currentKeyPressTime - theLastDataTime}');
      if (theLastDataTime != 0 && currentKeyPressTime - theLastDataTime < _minDataDelayTime) {
        PrintUtil.printDebug('两次 TCP 消息之间的时间间隔小于 $_minDataDelayTime 毫秒，拦截该消息');
      }
      else {
        theLastDataTime = currentKeyPressTime;
        errMsg = '';
        theLastDataList.clear();
        theLastDataList.addAll(data);
        eventBus.fire(TcpSocketDataModel(
          host: host,
          port: port,
          data: jsonEncode({'-2': theLastDataList}),
          isConnectMsg: true,
        ));
        var parsedData = await parser.parse(data.toList());
        if (parsedData != null && parsedData.isNotEmpty) {
          eventBus.fire(TcpSocketDataModel(
            host: host,
            port: port,
            data: parsedData,
          ));
        }
      }
    }, onError: (error) async {
      isOpen = false;
      errMsg = 'TCP $host:$port 连接出错：${error.toString()}，请检查！';
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        ToastNotification(Get.overlayContext!).error(errMsg);
      });
      eventBus.fire(TcpSocketDataModel(
        host: host,
        port: port,
        data: jsonEncode({'-1': errMsg}),
        isConnectMsg: true,
      ));
    }, onDone: () async {
      isOpen = false;
      errMsg = 'TCP $host:$port 连接关闭！';
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        ToastNotification(Get.overlayContext!).error(errMsg);
      });
      eventBus.fire(TcpSocketDataModel(
        host: host,
        port: port,
        data: jsonEncode({'-1': errMsg}),
        isConnectMsg: true,
      ));
    });

    isOpen = true;
    return true;
  }


  @override
  Future<bool> close() async {
    if (listen != null) {
      listen!.cancel();
      listen = null;
    }
    if (sock != null) {
      sock!.destroy();
      sock = null;
    }
    isOpen = false;
    return true;
  }

}