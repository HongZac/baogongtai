import 'package:desktop/app/ui/pages/home/tm/inv_barcode/setting/inv_barcode_setting_controller.dart';
import 'package:get/get.dart';

///物料条码新增查看 设置页面
class InvBarcodeSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<InvBarcodeSettingController>(InvBarcodeSettingController(
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
      permissionInfo: Get.rootDelegate.parameters['permissionInfo'] ?? '',
    ));
  }
}