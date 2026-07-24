
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/submit/mes_order_submit_controller.dart';
import 'package:get/get.dart';


///生产 任务单 报工页面
class MesOrderSubmitBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesOrderSubmitController>(MesOrderSubmitController(
      orderModel: Get.rootDelegate.arguments(),
      orderOpenType: int.tryParse(Get.rootDelegate.parameters['orderOpenType'].toString()) ?? 0,
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
    ));
  }

}