import 'package:desktop/app/ui/pages/home/pmes/device/device_andon/device_andon_controller.dart';
import 'package:get/get.dart';


///工作流程-全场呼叫 主界面
class DeviceAndonBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<DeviceAndonController>(DeviceAndonController(
      deviceId: Get.rootDelegate.parameters['deviceId'] ?? '',
    ));
  }

}