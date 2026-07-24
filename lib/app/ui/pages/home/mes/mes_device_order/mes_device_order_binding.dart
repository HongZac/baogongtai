
import 'package:desktop/app/ui/pages/home/mes/mes_device_order/mes_device_order_controller.dart';
import 'package:get/get.dart';

///生产 设备对应生产任务单
class MesDeviceOrderBinding implements Bindings {

  @override
  void dependencies() {
    Get.put<MesDeviceOrderController>(MesDeviceOrderController());
  }

}