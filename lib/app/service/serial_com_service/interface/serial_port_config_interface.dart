import 'package:basement/model.dart';

///串口通讯配置接口
class SerialPortConfigInterface extends ICloneable {
  //region 参数变量定义
  ///波特率
  int baudRate;

  ///数据位
  int bits;

  ///校验位
  int parity;

  /// 停止位
  int stopBits;

  /// Gets the RTS pin behaviour from the port configuration.
  int rts;

  /// Gets the CTS pin behaviour from the port configuration.
  int cts;

  /// Gets the DTR pin behaviour from the port configuration.
  int dtr;

  /// Gets the DSR pin behaviour from the port configuration.
  int dsr;

  /// Gets the XON/XOFF configuration from the port configuration.
  int xonXoff;
  //endregion

  SerialPortConfigInterface({
    this.baudRate = 9600,
    this.bits = 8,
    this.parity = 0,
    this.stopBits = 1,
    this.xonXoff = 0,
    this.rts = 1,
    this.cts = 0,
    this.dsr = 0,
    this.dtr = 1,
  });

  @override
  void fromJson(Map<String, dynamic> json) {
    baudRate = json['BaudRate'] ?? 9600;
    bits = json['Bits'] ?? 8;
    parity = json['Parity'] ?? 0;
    stopBits = json['StopBits'] ?? 1;
    rts = json['Rts'] ?? 1;
    cts = json['Cts'] ?? 0;
    dtr = json['Dtr'] ?? 1;
    dsr = json['Dsr'] ?? 0;
    xonXoff = json['XonXOff'] ?? 0;
  }

  factory SerialPortConfigInterface.fromJson(Map<String, dynamic> json) {
    var config = SerialPortConfigInterface();
    config.fromJson(json);
    return config;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'BaudRate': baudRate,
      'Bits': bits,
      'Parity': parity,
      'StopBits': stopBits,
      'Rts': rts,
      'Cts': cts,
      'Dtr': dtr,
      'Dsr': dsr,
      'XonXOff': xonXoff,
    };
    return map;
  }
}