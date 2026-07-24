
import 'package:get/get.dart';
import 'overall_setting_controller.dart';

class OverallSettingBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<OverallSettingController>(OverallSettingController());
  }

}