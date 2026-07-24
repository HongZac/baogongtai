import 'package:get/get.dart';
import 'login_setting_controller.dart';

class LoginSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<LoginSettingController>(LoginSettingController());
  }
}