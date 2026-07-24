import 'package:desktop/app/ui/pages/home/mes/submit_list/mes_submit_list_controller.dart';
import 'package:get/get.dart';


///工序 报工单列表
class MesSubmitListBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<MesSubmitListController>(MesSubmitListController(
      key: Get.rootDelegate.parameters['key'] ?? '',
      keyName: Get.rootDelegate.parameters['keyName'] ?? '',
      invId: Get.rootDelegate.parameters['invId'] ?? '',
    ));
  }

}