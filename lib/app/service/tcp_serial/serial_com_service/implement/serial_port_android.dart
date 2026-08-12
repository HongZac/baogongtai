
import 'package:desktop/app/service/tcp_serial/serial_com_service/interface/serial_port_interface.dart';
import 'package:usb_serial/usb_serial.dart';


class SerialPort extends SerialPortInterface {
  SerialPort(super.portName, {super.parserName, super.config,});

  /// Lists the serial ports available on the system.
  static Future<List<String>> availablePorts() async {
    List<String> list = [];
    List<UsbDevice> usbDeviceList = await UsbSerial.listDevices();
    list.addAll(usbDeviceList.map((e){
      e.port;
      return e.serial ?? '';
    }));
    return list;
  }

}
