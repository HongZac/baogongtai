import 'dart:async';
import 'dart:convert';

import 'package:basement/utils.dart';
import 'package:desktop/app/service/serial_com_service/interface/serial_port_interface.dart';
import 'package:desktop/app/service/serial_com_service/serial_port_data_model.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:flutter_libserialport/flutter_libserialport.dart'
    if (dart.library.io) 'package:flutter_libserialport/flutter_libserialport.dart'
    as lib_serial_port;
import 'package:usb_serial/usb_serial.dart';


class SerialPort extends SerialPortInterface {
  lib_serial_port.SerialPort? _serialPort;
  lib_serial_port.SerialPortReader? _reader;
  StreamSubscription<Uint8List>? _subscription;

  final int _minDataDelayTime = 1000;

  SerialPort(super.portName, {super.parserName, super.config});

  @override
  Future<bool> open() async {
    if (GetPlatform.isWeb) {
      return false;
    }

    isOpen = false;
    _serialPort = lib_serial_port.SerialPort(portName);

    ///打开串口读写
    bool isSuccess = _serialPort!.openReadWrite();
    if (!isSuccess) {
      isOpen = false;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        ToastNotification(Get.overlayContext!).error('打开串口$portName时出错');
      });
      PrintUtil.printDebug('打开串口$portName时出错');
      return false;
    }

    var config = lib_serial_port.SerialPortConfig();
    config.baudRate = serialPortConfig.baudRate; //波特率 115200
    config.bits = serialPortConfig.bits; //数据位
    config.parity = serialPortConfig.parity; //校验位
    config.stopBits = serialPortConfig.stopBits; //停止位
    config.xonXoff = serialPortConfig.xonXoff;
    config.rts = serialPortConfig.rts;
    config.cts = serialPortConfig.cts;
    config.dsr = serialPortConfig.dsr;
    config.dtr = serialPortConfig.dtr;
    _serialPort!.config = config;
    config.dispose();

    ///读串口数据
    _reader = lib_serial_port.SerialPortReader(_serialPort!, timeout: 300);
    _subscription = _reader?.stream.listen((data) async {
      ///这里不要用防抖（Timer），会导致称重数据无法传递（称重消息每 50ms 发送一次，Timer 计时需要 1000ms）
      int currentKeyPressTime = DateTime.now().millisecondsSinceEpoch;
      PrintUtil.printDebug('两次串口消息间隔：${currentKeyPressTime - theLastDataTime}');
      if (theLastDataTime != 0 && currentKeyPressTime - theLastDataTime < _minDataDelayTime) {
        PrintUtil.printDebug('两次串口消息之间的时间间隔小于 $_minDataDelayTime 毫秒，拦截该消息');
      }
      else {
        theLastDataTime = currentKeyPressTime;
        theLastDataList.clear();
        theLastDataList.addAll(data);
        eventBus.fire(SerialPortDataModel(
          com: portName,
          data: jsonEncode({'-2': theLastDataList}),
          isConnectMsg: true,
        ));
        var parsedData = await parser.parse(data.toList());
        if (parsedData != null && parsedData.isNotEmpty) {
          eventBus.fire(SerialPortDataModel(
            com: portName,
            data: parsedData,
          ));
        }
      }
    }, onError: (e) async {
      isOpen = false;
      eventBus.fire(SerialPortDataModel(
        com: portName,
        data: jsonEncode({'-1': '串口$portName出错：${e.toString()}，请检查！'}),
        isConnectMsg: true,
      ));
    }, onDone: () async {
      isOpen = false;
      eventBus.fire(SerialPortDataModel(
        com: portName,
        data: jsonEncode({'-1': '串口$portName关闭！'}),
        isConnectMsg: true,
      ));
    });

    isOpen = true;
    return true;
  }

  @override
  Future<bool> close() async {
    ///停止读串口
    if (_subscription != null) {
      _subscription!.cancel();
    }
    if (_reader != null) {
      _reader!.close();
    }
    if (_serialPort?.isOpen ?? false) {
      _serialPort!.close();
    }
    isOpen = false;
    return true;
  }

  /// Lists the serial ports available on the system.
  static Future<List<String>> availablePorts() async {
    if (!kIsWeb && GetPlatform.isWindows){
      return lib_serial_port.SerialPort.availablePorts;
    }
    else if (!kIsWeb && GetPlatform.isAndroid) {
      //todo 未测试 https://pub.dev/packages/usb_serial
      List<String> list = [];
      List<UsbDevice> usbDeviceList = await UsbSerial.listDevices();
      list.addAll(usbDeviceList.map((e){
        e.port;
        return e.serial ?? '';
      }));
      return list;
    }
    return [];
  }

}
