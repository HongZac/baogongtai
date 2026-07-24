import 'package:desktop/app/ui/pages/home/mes/mes_task/setting/mes_task_setting_controller.dart';
import 'package:get/get.dart';


///生产派工单 设置页面
class MesTaskSettingBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<MesTaskSettingController>(MesTaskSettingController(
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
      permissionInfo: Get.rootDelegate.parameters['permissionInfo'] ?? '',
    ));
  }

}