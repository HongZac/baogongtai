import 'package:get/get.dart';
import 'message_controller.dart';

///工序报工单
class MessageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MessageController>(MessageController());
  }
}