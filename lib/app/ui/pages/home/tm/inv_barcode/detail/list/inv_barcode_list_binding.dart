import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/list/inv_barcode_list_controller.dart';
import 'package:get/get.dart';


///物料条码新增查看 条码列表页面 230004
class InvBarcodeListBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<InvBarcodeListController>(InvBarcodeListController(
      inventoryModel: Get.rootDelegate.arguments(),
    ));
  }

}