import 'package:desktop/app/ui/pages/home/mes/mes_order/setting/mes_order_setting_controller.dart';
import 'package:get/get.dart';

///生产任务单 主页面 设置页面
class MesOrderSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesOrderSettingController>(MesOrderSettingController(
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
      permissionInfo: Get.rootDelegate.parameters['permissionInfo'] ?? '',
    ));
  }

}