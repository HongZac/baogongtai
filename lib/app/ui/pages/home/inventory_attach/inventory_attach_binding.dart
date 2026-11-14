import 'package:desktop/app/ui/pages/home/inventory_attach/inventory_attach_controller.dart';
import 'package:get/get.dart';

///产品图纸查询 首页
class InventoryAttachBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<InventoryAttachController>(InventoryAttachController());
  }

}