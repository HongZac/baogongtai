import 'package:get/get.dart';
import 'device_controller.dart';

class DeviceBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<DeviceController>(DeviceController());
  }
}