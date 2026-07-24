import 'package:desktop/app/ui/pages/home/tm/submit_barcode/submit_barcode_controller.dart';
import 'package:get/get.dart';


///报工记录的条码列表
class SubmitBarcodeBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<SubmitBarcodeController>(SubmitBarcodeController());
  }

}