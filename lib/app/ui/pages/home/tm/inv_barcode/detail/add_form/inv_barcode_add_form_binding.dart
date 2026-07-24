
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/add_form/inv_barcode_add_form_controller.dart';
import 'package:get/get.dart';


///物料条码新增查看 新增条码页面
class InvBarcodeAddFormBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<InvBarcodeAddFormController>(InvBarcodeAddFormController(
      inventoryModel: Get.rootDelegate.arguments(),
    ));
  }

}