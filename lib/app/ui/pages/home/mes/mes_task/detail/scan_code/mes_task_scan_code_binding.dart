import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/scan_code/mes_task_scan_code_controller.dart';
import 'package:get/get.dart';


///报工扫码页面
class MesTaskScanCodeBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<MesTaskScanCodeController>(MesTaskScanCodeController(
      taskModel: Get.rootDelegate.arguments(),
      taskOpenType: int.tryParse(Get.rootDelegate.parameters['taskOpenType'].toString()) ?? 0,
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
    ));
  }

}