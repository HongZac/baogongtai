import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/submit/mes_task_submit_controller.dart';
import 'package:get/get.dart';


///生产 派工单报工页面
class MesTaskSubmitBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<MesTaskSubmitController>(MesTaskSubmitController(
      taskModel: Get.rootDelegate.arguments(),
      taskOpenType: int.tryParse(Get.rootDelegate.parameters['taskOpenType'].toString()) ?? 0,
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
    ));
  }

}