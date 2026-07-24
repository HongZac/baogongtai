import 'dart:async';
import 'package:basement/utils.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/service/serial_com_service/serial_port_data_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:get/get.dart';


///串口接收传递服务
mixin SerialPortGetXListenerMixin<T> on GetxController {
  static List<String> receiverList = [''];

  final String serialPortCacheKey = "serial.port";

  ///是否允许接收条码处理程序
  bool enableSerialPort = true;

  final _appService = Get.find<AppService>();
  late final StreamSubscription<SerialPortDataModel> subscription;

  final WeightMsgConnectService weightMsgConnectService = Get.find<WeightMsgConnectService>();

  ///错误发生时回调函数
  void onError(e) {
    printError(info: e);
  }

  @override
  Future<void> onReady() async{
    super.onReady();

    ///接收串口数组
    subscription = _appService.eventBus.on<SerialPortDataModel>().listen((event) async {
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
    subscription.cancel();
    receiverList.remove(T.toString());
    super.onClose();
  }
}
