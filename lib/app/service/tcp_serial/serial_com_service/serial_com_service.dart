import 'package:basement/utils.dart';
import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_enum.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/base_serial_port.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/interface/serial_port_config_interface.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_msg_process_model.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:get/get.dart';


///串口通讯服务管理，主要功能包括 串口注册与取消
class SerialComService extends GetxService {

  ///已经注册了的串口通讯服务列表
  final List<BaseSerialPort> serialPortList = [];

  ///串口消息接收配置列表
  final List<SerialPortMsgProcessModel> serialPortMsgProcessList = [];


  @override
  void onInit() {
    super.onInit();

    serialPortList.clear();
    var list = ShareStorageUtil.instance?.read(SharedPreferencesKeys.SERIAL_COM_SERVICE_SERIAL_PORT_LIST_KEY) ?? [];
    if (list.isNotEmpty){
      list.forEach((element){
        BaseSerialPort model = BaseSerialPort.fromJson(element);
        serialPortList.add(model);
      });
    }

    serialPortMsgProcessList.clear();
    var list2 = ShareStorageUtil.instance?.read(SharedPreferencesKeys.SERIAL_COM_SERVICE_SERIAL_PORT_MSG_PROCESS_LIST_KEY) ?? [];
    if (list2.isNotEmpty){
      list2.forEach((element){
        SerialPortMsgProcessModel model = SerialPortMsgProcessModel.fromJson(element);
        serialPortMsgProcessList.add(model);
      });
    }

    ///自动打开串口通讯
    for (var element in serialPortList) {
      if (element.autoOpen) {
        element.open();
      }
    }

  }


  ///注册串口，并且保存至本地配置中
  ///
  /// [portName]：串口号
  ///
  /// [autoOpen]：启动程序后，默认自动打开串口通讯
  ///
  /// [parserName]：解析类型 [TcpSerialParserEnum]
  ///
  /// [baudRate]：波特率，9600
  ///
  /// [bits]：数据位，8
  ///
  /// [parity]：校验位，null
  ///
  /// [stopBits]：结束位，1
  Future<void> register({
    required String portName,
    bool? autoOpen,
    TcpSerialParserEnum? parserName,
    int baudRate = 9600,
    int bits = 8,
    int parity = 0,
    int stopBits = 1,
  }) async {
    var serialPort = serialPortList.firstWhereOrNull((e) => e.portName == portName);
    ///如果已存在，则直接退出
    if (serialPort != null){
      return;
    }

    ///未进行数据正确性校验
    serialPort = BaseSerialPort(
      autoOpen: autoOpen ?? false,
      portName: portName,
      parser: parserName,
      config: SerialPortConfigInterface(
        baudRate: baudRate,
        bits: bits,
        parity: parity,
        stopBits: stopBits,
      ),
    );
    serialPortList.add(serialPort);

    ///保存至本地配置文件中
    List<Map<String, dynamic>> mapList = serialPortList.map((e) => e.toJson()).toList();
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.SERIAL_COM_SERVICE_SERIAL_PORT_LIST_KEY, mapList);

    if (serialPort.autoOpen) {
      ///自动打开串口通讯
      await serialPort.open();
    }
  }

  ///删除串口
  Future<void> removeSerialPort(String portName) async {
    BaseSerialPort? item = serialPortList.firstWhereOrNull((element) => element.portName == portName);
    if (item != null){
      if (item.isOpen) {
        await item.close();
      }
      serialPortList.removeWhere((element) => element.portName == item.portName);

      ///保存至本地配置文件中
      List<Map<String, dynamic>> mapList = serialPortList.map((e) => e.toJson()).toList();
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.SERIAL_COM_SERVICE_SERIAL_PORT_LIST_KEY, mapList);
    }
  }

  ///枚举系统上所有的COM口列表
  Future<List<String>> getAvailablePorts() async {
    return await BaseSerialPort.availablePorts();
  }


  @override
  void onClose() {
    ///将所有打开的串口关闭
    for (var serialPort in serialPortList) {
      serialPort.close();
    }
    super.onClose();
  }

}