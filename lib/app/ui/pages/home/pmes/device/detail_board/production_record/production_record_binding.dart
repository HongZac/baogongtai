
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/production_record/production_record_controller.dart';
import 'package:get/get.dart';

///生产记录 670006
class ProductionRecordBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductionRecordController>(ProductionRecordController(
      deviceId: Get.rootDelegate.parameters['deviceId'] ?? '',
    ));
  }

}