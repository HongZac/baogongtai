import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/detail_tab/mes_task_detail_tab_controller.dart';
import 'package:get/get.dart';


///生产派工单 详情Tab页面
class MesTaskDetailTabBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<MesTaskDetailTabController>(MesTaskDetailTabController(
      taskModel: Get.rootDelegate.arguments(),
      key: Get.rootDelegate.parameters['key'] ?? '',
      keyName: Get.rootDelegate.parameters['keyName'] ?? '',
      taskOpenType: int.tryParse(Get.rootDelegate.parameters['taskOpenType'].toString()) ?? 0,
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
    ));
  }

}