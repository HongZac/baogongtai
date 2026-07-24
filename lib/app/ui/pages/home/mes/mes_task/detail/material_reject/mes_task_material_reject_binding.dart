import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/material_reject/mes_task_material_reject_controller.dart';
import 'package:get/get.dart';


///生产 派工单不良品上报页面
class MesTaskMaterialRejectBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesTaskMaterialRejectController>(MesTaskMaterialRejectController(
      taskModel: Get.rootDelegate.arguments(),
      taskOpenType: int.tryParse(Get.rootDelegate.parameters['taskOpenType'].toString()) ?? 0,
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
    ));
  }

}