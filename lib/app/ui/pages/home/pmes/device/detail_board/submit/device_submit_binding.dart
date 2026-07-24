import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/submit/device_submit_controller.dart';
import 'package:get/get.dart';

class DeviceSubmitBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<DeviceSubmitController>(DeviceSubmitController(
      deviceId: Get.rootDelegate.parameters['deviceId'] ?? '',
    ));
  }

}