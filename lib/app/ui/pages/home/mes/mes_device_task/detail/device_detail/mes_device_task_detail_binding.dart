import 'package:desktop/app/ui/pages/home/mes/mes_device_task/detail/device_detail/mes_device_task_detail_controller.dart';
import 'package:get/get.dart';


///生产 设备对应生产派工单 详情
class MesDeviceTaskDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesDeviceTaskDetailController>(MesDeviceTaskDetailController(
      deviceId: Get.rootDelegate.parameters['deviceId'] ?? '',
    ));
  }
}