import 'package:desktop/app/ui/pages/home/mes/mes_task/mes_task_controller.dart';
import 'package:get/get.dart';

///生产派工单列表页面
class MesTaskBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<MesTaskController>(MesTaskController());
  }

}