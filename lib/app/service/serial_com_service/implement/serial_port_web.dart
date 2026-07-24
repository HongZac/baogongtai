
import 'package:desktop/app/service/serial_com_service/interface/serial_port_interface.dart';

class SerialPort extends SerialPortInterface {
  SerialPort(super.portName, {super.parserName, super.config,});

  /// Lists the serial ports available on the system.
  static Future<List<String>> availablePorts() async {
    return [];
  }

}
