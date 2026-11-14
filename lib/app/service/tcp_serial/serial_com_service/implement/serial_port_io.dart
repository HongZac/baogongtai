import 'dart:async';
import 'dart:convert';

import 'package:basement/utils.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/interface/serial_port_interface.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:libserialport_plus/libserialport_plus.dart'
    if (dart.library.io) 'package:libserialport_plus/libserialport_plus.dart'
    as lib_serial_port;
import 'package:usb_serial/usb_serial.dart';


class SerialPort extends SerialPortInterface {
  lib_serial_port.SerialPort? _serialPort;
  lib_serial_port.SerialPortReader? _reader;
  StreamSubscription<Uint8List>? _subscription;
  ///使用 Timer 代替 [_reader]、[_subscription]，
  ///因为 0.6.0 版本的 _reader?.stream.listen 会导致 CPU 占用率过高；
  ///现不再使用 Timer，直接替换包：flutter_libserialport => libserialport_plus
  //Timer? _timer;

  final int _minDataDelayTime = 700;

  SerialPort(super.portName, {super.parserName, super.config});

  @override
  Future<bool> open() async {
    if (GetPlatform.isWeb) {
      return false;
    }

    isOpen = false;
    _serialPort = lib_serial_port.SerialPort(portName);

    ///打开串口读写
    try {
      _serialPort!.open(lib_serial_port.SerialPortMode.read);
      bool isSuccess = _serialPort!.isOpen();
      if (!isSuccess) {
        isOpen = false;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          ToastNotification(Get.overlayContext!).error('打开串口$portName时出错');
        });
        if (_serialPort != null){
          if (_serialPort!.isOpen()) {
            _serialPort!.close();
          }
          _serialPort!.dispose();
          _serialPort = null;
        }
        return false;
      }
    } catch (e){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        ToastNotification(Get.overlayContext!).error('打开串口$portName时出错：$e');
      });
      isOpen = false;
      if (_serialPort != null){
        if (_serialPort!.isOpen()) {
          _serialPort!.close();
        }
        _serialPort!.dispose();
        _serialPort = null;
      }
      return false;
    }

    //region
    lib_serial_port.SerialPortParity? serialPortParity;
    try {
      serialPortParity = lib_serial_port.SerialPortParity.fromValue(serialPortConfig.parity);
    } catch (e){}
    lib_serial_port.SerialPortRts? serialPortRts;
    try {
      serialPortRts = lib_serial_port.SerialPortRts.fromValue(serialPortConfig.rts);
    } catch (e){}
    lib_serial_port.SerialPortCts? serialPortCts;
    try {
      serialPortCts = lib_serial_port.SerialPortCts.fromValue(serialPortConfig.cts);
    } catch (e){}
    lib_serial_port.SerialPortDtr? serialPortDtr;
    try {
      serialPortDtr = lib_serial_port.SerialPortDtr.fromValue(serialPortConfig.dtr);
    } catch (e){}
    lib_serial_port.SerialPortDsr? serialPortDsr;
    try {
      serialPortDsr = lib_serial_port.SerialPortDsr.fromValue(serialPortConfig.dsr);
    } catch (e){}
    lib_serial_port.SerialPortXonXoff? serialPortXonXoff;
    try {
      serialPortXonXoff = lib_serial_port.SerialPortXonXoff.fromValue(serialPortConfig.xonXoff);
    } catch (e){}
    //endregion
    var config = lib_serial_port.SerialPortConfig(
      baudRate: serialPortConfig.baudRate,
      bits: serialPortConfig.bits,
      parity: serialPortParity,
      stopBits: serialPortConfig.stopBits,
      rts: serialPortRts,
      cts: serialPortCts,
      dtr: serialPortDtr,
      dsr: serialPortDsr,
      xonXoff: serialPortXonXoff,
    );
    _serialPort!.setConfig(config);

    /*
    _timer = Timer.periodic(Duration(milliseconds: _minDataDelayTime), (timer) async {
      if (!(_serialPort?.isOpen ?? false)){
        ///串口已关闭
        errMsg = '串口$portName关闭！';
        eventBus.fire(SerialPortDataModel(
          com: portName,
          data: jsonEncode({'-1': errMsg}),
          isConnectMsg: true,
        ));

        if (_timer != null){
          _timer!.cancel();
        }

        try {
          _serialPort?.flush();
          _serialPort?.close();
          _serialPort = null;
        } catch(e){}

        isOpen = false;
        return;
      }

      Uint8List data = _serialPort!.read(1024);
      errMsg = '';
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
    });
    */

    ///读串口数据
    _reader = lib_serial_port.SerialPortReader(_serialPort!);
    _subscription = _reader?.stream.listen((data) async {
      ///这里不要用防抖（Timer），会导致称重数据无法传递（称重消息每 50ms 发送一次，Timer 计时需要 1000ms）
      int currentKeyPressTime = DateTime.now().millisecondsSinceEpoch;
      PrintUtil.printDebug('两次串口消息间隔：${currentKeyPressTime - theLastDataTime}');
      if (theLastDataTime != 0 && currentKeyPressTime - theLastDataTime < _minDataDelayTime) {
        PrintUtil.printDebug('两次串口消息之间的时间间隔小于 $_minDataDelayTime 毫秒，拦截该消息');
      }
      else {
        theLastDataTime = currentKeyPressTime;
        errMsg = '';
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
      errMsg = '串口$portName出错：${e.toString()}，请检查！';
      eventBus.fire(SerialPortDataModel(
        com: portName,
        data: jsonEncode({'-1': errMsg}),
        isConnectMsg: true,
      ));
    }, onDone: () async {
      isOpen = false;
      errMsg = '串口$portName关闭！';
      eventBus.fire(SerialPortDataModel(
        com: portName,
        data: jsonEncode({'-1': errMsg}),
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
      await _subscription!.cancel();
      _subscription = null;
    }
    if (_reader != null) {
      await _reader!.close();
      _reader = null;
    }
    //if (_timer != null){
    //  _timer!.cancel();
    //}
    if (_serialPort != null){
      if (_serialPort!.isOpen()) {
        _serialPort!.close();
      }
      _serialPort!.dispose();
      _serialPort = null;
    }
    isOpen = false;
    return true;
  }

  /// Lists the serial ports available on the system.
  static Future<List<String>> availablePorts() async {
    if (!kIsWeb && GetPlatform.isWindows){
      return lib_serial_port.SerialPort.getAvailablePorts();
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
