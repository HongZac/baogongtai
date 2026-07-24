
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/detail_tab/mes_order_detail_tab_controller.dart';
import 'package:get/get.dart';


///生产任务单 详情Tab页面
class MesOrderDetailTabBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesOrderDetailTabController>(MesOrderDetailTabController(
      orderModel: Get.rootDelegate.arguments(),
      key: Get.rootDelegate.parameters['key'] ?? '',
      keyName: Get.rootDelegate.parameters['keyName'] ?? '',
      invId: Get.rootDelegate.parameters['invId'] ?? '',
      orderOpenType: int.tryParse(Get.rootDelegate.parameters['orderOpenType'].toString()) ?? 0,
      workCenterId : Get.rootDelegate.parameters['workCenterId'] ?? '',
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
    ));
  }

}