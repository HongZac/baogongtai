import 'package:get/get.dart';

import 'message_main_list_controller.dart';

class MessageMainListBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<MessageMainListController>(MessageMainListController(
      typeId: int.tryParse(Get.rootDelegate.parameters['typeId']!)!,
    ));
  }

}