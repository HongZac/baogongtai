import 'package:desktop/app/ui/pages/home/pmes/check_record_list/pmes_check_record_list_controller.dart';
import 'package:get/get.dart';


///注塑 次品记录列表页面
class PMesCheckRecordListBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<PMesCheckRecordListController>(PMesCheckRecordListController(
      key: Get.rootDelegate.parameters['key'] ?? '',
      keyName: Get.rootDelegate.parameters['keyName'] ?? '',
    ));
  }

}