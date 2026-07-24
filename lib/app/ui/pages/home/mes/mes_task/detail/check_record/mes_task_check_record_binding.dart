import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/check_record/mes_task_check_record_controller.dart';
import 'package:get/get.dart';


///生产派工单 报次品页面
class MesTaskCheckRecordBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<MesTaskCheckRecordController>(MesTaskCheckRecordController(
      taskModel: Get.rootDelegate.arguments(),
      taskOpenType: int.tryParse(Get.rootDelegate.parameters['taskOpenType'].toString()) ?? 0,
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
    ));
  }
}