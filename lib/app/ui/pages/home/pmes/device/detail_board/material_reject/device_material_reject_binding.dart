import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/material_reject/device_material_reject_controller.dart';
import 'package:get/get.dart';

class DeviceMaterialRejectBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<DeviceMaterialRejectController>(DeviceMaterialRejectController(
      deviceId: Get.rootDelegate.parameters['deviceId'] ?? '',
    ));
  }

}