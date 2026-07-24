import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/setting/detail_setting_controller.dart';
import 'package:get/get.dart';


///注塑 设备实时监控 设备详情、报工、报次品 设置页面
class DeviceDetailSettingBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<DeviceDetailSettingController>(DeviceDetailSettingController(
      type: Get.rootDelegate.parameters['type']!,
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
      permissionInfo: Get.rootDelegate.parameters['permissionInfo'] ?? '',
    ));
  }

}