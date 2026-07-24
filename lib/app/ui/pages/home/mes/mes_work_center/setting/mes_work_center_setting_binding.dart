import 'package:desktop/app/ui/pages/home/mes/mes_work_center/setting/mes_work_center_setting_controller.dart';
import 'package:get/get.dart';


///生产 加工中心（可选择派工单报工 OR 任务单报工） - 参数设置
class MesWorkCenterSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesWorkCenterSettingController>(MesWorkCenterSettingController(
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
      permissionInfo: Get.rootDelegate.parameters['permissionInfo'] ?? '',
    ));
  }

}