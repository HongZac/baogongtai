import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/material_reject/mes_order_material_reject_controller.dart';
import 'package:get/get.dart';


///生产任务单 不良品上报页面
class MesOrderMaterialRejectBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesOrderMaterialRejectController>(MesOrderMaterialRejectController(
      orderModel: Get.rootDelegate.arguments(),
      orderOpenType: int.tryParse(Get.rootDelegate.parameters['orderOpenType'].toString()) ?? 0,
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
    ));
  }

}