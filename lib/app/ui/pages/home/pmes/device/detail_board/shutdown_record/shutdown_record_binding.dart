import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/shutdown_record/shutdown_record_controller.dart';
import 'package:get/get.dart';

///停机记录 670003
class ShutdownRecordBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ShutdownRecordController>(ShutdownRecordController(
      deviceId: Get.rootDelegate.parameters['deviceId'] ?? '',
    ));
  }

}