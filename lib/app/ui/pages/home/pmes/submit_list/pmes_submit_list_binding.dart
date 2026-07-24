import 'package:desktop/app/ui/pages/home/pmes/submit_list/pmes_submit_list_controller.dart';
import 'package:get/get.dart';


///注塑 报工单列表
class PMesSubmitListBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<PMesSubmitListController>(PMesSubmitListController(
      key: Get.rootDelegate.parameters['key'] ?? '',
      keyName: Get.rootDelegate.parameters['keyName'] ?? '',
    ));
  }

}