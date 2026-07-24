import 'package:desktop/app/ui/pages/home/mes/check_record_list/mes_check_record_list_controller.dart';
import 'package:get/get.dart';


///工序 次品列表
class MesCheckRecordListBinding implements Bindings{
  @override
  void dependencies() {
    Get.put< MesCheckRecordListController>( MesCheckRecordListController(
      key: Get.rootDelegate.parameters['key'] ?? '',
      keyName: Get.rootDelegate.parameters['keyName'] ?? '',
      invId: Get.rootDelegate.parameters['invId'] ?? '',
    ));
  }

}