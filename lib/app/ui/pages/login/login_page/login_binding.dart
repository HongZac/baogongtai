import 'package:get/get.dart';

import 'login_controller.dart';

/// 登录页
class LoginPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<LoginController>(LoginController());
  }
}