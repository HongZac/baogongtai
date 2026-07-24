import 'package:desktop/app/ui/pages/home/mes/mes_device_task/mes_device_task_controller.dart';
import 'package:get/get.dart';


///生产 设备对应生产派工单
class MesDeviceTaskBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesDeviceTaskController>(MesDeviceTaskController());
  }

}