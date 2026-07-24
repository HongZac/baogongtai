import 'package:desktop/app/ui/pages/home/tm/inv_barcode/inv_barcode_controller.dart';
import 'package:get/get.dart';


///物料条码新增查看 首页
class InvBarcodeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<InvBarcodeController>(InvBarcodeController());
  }
}