import 'dart:async';

import 'package:basement/model.dart';
import 'package:desktop/app/service/serial_com_service/interface/serial_port_parser_interface.dart';
import 'package:get/get.dart';

import 'interface/serial_port_config_interface.dart';
import 'interface/serial_port_interface.dart';

import 'implement/serial_port_web.dart'
//if (dart.library.android) 'implement/serial_port_android.dart'
if (dart.library.io) 'implement/serial_port_io.dart'
if (dart.library.html) 'implement/serial_port_web.dart' // Browser
if (dart.library.js) 'implement/serial_port_web.dart'; // Node.JS


///串口处理接口（串口通讯服务对象）
///定义串口：var _serialPort = BaseSerialPort(portName: "COM4", parser: SerialPortParserEnum.defaultParser, config: SerialPortConfigInterface())

///打开串口：_serialPort.open();
///
///关闭串口：_serialPort.close();
class BaseSerialPort extends ICloneable {

  ///默认自动打开串口
  final bool autoOpen;

  ///实际的串口处理程序
  late final SerialPortInterface _serialPort;

  /// [portName]：串口号
  ///
  /// [parser]：接收串口后的数据格式化处理接口
  ///
  /// [config]：串口配置接口
  BaseSerialPort({
    this.autoOpen = false,
    String portName = '',
    SerialPortParserEnum? parser,
    SerialPortConfigInterface? config,
  }) {
    _serialPort = SerialPort(
      portName,
      parserName: parser,
      config: config,
    );
  }

  ///读取串口号
  String get portName => _serialPort.portName;
  ///串口数据处理解析类
  SerialPortParserEnum? get parserName => _serialPort.parserName;
  ///默认的串口参数
  SerialPortConfigInterface get config => _serialPort.serialPortConfig;
  ///当前串口通讯是否打开
  bool get isOpen => _serialPort.isOpen;
  ///该串口最后一次接收到的数据
  List<int> get theLastDataList => _serialPort.theLastDataList;


  Future<bool> open() async {
    return _serialPort.open();
  }

  Future<bool> close() async {
    return _serialPort.close();
  }

  /// Lists the serial ports available on the system.
  static Future<List<String>> availablePorts() async {
    return await SerialPort.availablePorts();
  }

  factory BaseSerialPort.fromJson(Map<String, dynamic> json) {
    var model = BaseSerialPort(
      autoOpen: json['AutoOpen'] ?? false,
      portName: json['PortName'],
      parser: SerialPortParserEnum.values.firstWhereOrNull(
              (element) => element.name == json['ParserName']),
      config: json['Config'] != null
          ? SerialPortConfigInterface.fromJson(json['Config'])
          : null,
    );
    return model;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'AutoOpen': autoOpen,
      'PortName': _serialPort.portName,
      'ParserName': _serialPort.parserName?.name,
      'Config': _serialPort.serialPortConfig.toJson(),
    };
    ///加入串口参数的数据，设置页面需要用到（== map['Config']）
    map.addAll(_serialPort.serialPortConfig.toJson());
    return map;
  }
}