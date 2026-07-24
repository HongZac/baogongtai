import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/setting/mes_task_detail_setting_controller.dart';
import 'package:get/get.dart';


///生产派工单 详情页 设置页面
class MesTaskDetailSettingBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<MesTaskDetailSettingController>(MesTaskDetailSettingController(
      type: Get.rootDelegate.parameters['type']!,
      taskOpenType: int.tryParse(Get.rootDelegate.parameters['taskOpenType'].toString()) ?? 0,
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
      permissionInfo: Get.rootDelegate.parameters['permissionInfo'] ?? '',
    ));
  }

}