import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/check_record/mes_order_check_record_controller.dart';
import 'package:get/get.dart';


///生产任务单 报次品页面
class MesOrderCheckRecordBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesOrderCheckRecordController>(MesOrderCheckRecordController(
      orderModel: Get.rootDelegate.arguments(),
      orderOpenType: int.tryParse(Get.rootDelegate.parameters['orderOpenType'].toString()) ?? 0,
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
    ));
  }

}