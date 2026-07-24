
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/detail_tab/inv_barcode_detail_tab_controller.dart';
import 'package:get/get.dart';


///物料条码新增查看 详情Tab页面
class InvBarcodeDetailTabBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<InvBarcodeDetailTabController>(InvBarcodeDetailTabController(
      inventoryModel: Get.rootDelegate.arguments(),
      key: Get.rootDelegate.parameters['key'] ?? '',
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
    ));
  }

}