import 'package:desktop/app/ui/pages/home/mes/mes_device_order/detail/device_detail/mes_device_order_detail_controller.dart';
import 'package:get/get.dart';


///生产 设备对应生产任务单 设备详情页
class MesDeviceOrderDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesDeviceOrderDetailController>(MesDeviceOrderDetailController(
      deviceId: Get.rootDelegate.parameters['deviceId'] ?? '',
    ));
  }
}