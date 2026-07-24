import 'package:get/get.dart';
import 'device_detail_controller.dart';

class DeviceDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<DeviceDetailController>(DeviceDetailController(
        deviceId: Get.rootDelegate.parameters['deviceId'] ?? '',
    ));
  }
}