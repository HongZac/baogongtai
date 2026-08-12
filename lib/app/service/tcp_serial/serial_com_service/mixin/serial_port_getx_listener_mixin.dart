import 'dart:async';
import 'package:basement/utils.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/serial_com_service.dart';
import 'package:get/get.dart';


///串口消息接收接口
mixin SerialPortGetXListenerMixin<T> on GetxController {

  final SerialComService serialComService = Get.find<SerialComService>();

  static List<String> receiverList = [''];

  ///是否允许接收条码处理程序
  bool enableSerialPort = true;

  final _appService = Get.find<AppService>();
  late final StreamSubscription<SerialPortDataModel> _subscription;


  @override
  Future<void> onReady() async{
    super.onReady();

    ///接收串口数组
    _subscription = _appService.eventBus.on<SerialPortDataModel>().listen((event) async {
      if (enableSerialPort && !event.isConnectMsg) {
        PrintUtil.printDebug('串口消息：${event.data}');
        onSerialPortData(event);
      }
    });
    receiverList.add(T.toString());
  }

  ///接收到的串口数据处理，需要继承类里处理实际功能
  Future<void> onSerialPortData(SerialPortDataModel serialPortDataModel);

  @override
  void onClose() {
    _subscription.cancel();
    receiverList.remove(T.toString());
    super.onClose();
  }
}
