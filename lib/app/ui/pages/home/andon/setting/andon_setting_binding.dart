import 'package:desktop/app/ui/pages/home/andon/setting/andon_setting_controller.dart';
import 'package:get/get.dart';


///安灯系统 --全场呼叫系统 设置页面
class AndonSettingBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<AndonSettingController>(AndonSettingController(
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
      permissionInfo: Get.rootDelegate.parameters['permissionInfo'] ?? '',
    ));
  }

}