
import 'package:desktop/app/ui/pages/home/pmes/device/device_setting/device_setting_controller.dart';
import 'package:get/get.dart';

class DeviceSettingBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<DeviceSettingController>(DeviceSettingController(
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
      permissionInfo: Get.rootDelegate.parameters['permissionInfo'] ?? '',
    ));
  }

}