import 'package:desktop/app/ui/pages/home/mes/mes_order/mes_order_controller.dart';
import 'package:get/get.dart';


///任务单报工单
class MesOrderBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesOrderController>(MesOrderController());
  }
}