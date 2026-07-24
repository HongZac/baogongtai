import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/setting/inv_barcode_detail_setting_controller.dart';
import 'package:get/get.dart';


///物料条码新增查看 详情页 设置页面
class InvBarcodeDetailSettingBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<InvBarcodeDetailSettingController>(InvBarcodeDetailSettingController(
      type: Get.rootDelegate.parameters['type']!,
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
      permissionInfo: Get.rootDelegate.parameters['permissionInfo'] ?? '',
    ));
  }

}