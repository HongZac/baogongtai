import 'package:get/get.dart';
import 'andon_controller.dart';


class AndonBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AndonController>(AndonController());
  }
}