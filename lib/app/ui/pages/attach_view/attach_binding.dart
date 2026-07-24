import 'package:get/get.dart';

import 'attach_controller.dart';

class AttachBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<AttachController>(AttachController(
      pageTitle: Get.rootDelegate.parameters['pageTitle'] ?? '',
      id: Get.rootDelegate.parameters['id'] ?? '',
      progId: int.tryParse(Get.rootDelegate.parameters['progId'] ?? '')!,
      category: Get.rootDelegate.parameters['category'] ?? '',
    ));
  }

}