
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/setting/mes_order_detail_setting_controller.dart';
import 'package:get/get.dart';

///生产任务单 详情页 设置页面
class MesOrderDetailSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesOrderDetailSettingController>(MesOrderDetailSettingController(
      type: Get.rootDelegate.parameters['type']!,
      orderOpenType: int.tryParse(Get.rootDelegate.parameters['orderOpenType'].toString()) ?? 0,
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
      permissionInfo: Get.rootDelegate.parameters['permissionInfo'] ?? '',
    ));
  }

}