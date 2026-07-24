import 'dart:io';

import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';

class RootController extends GetxController {

  ///windows平台下，点击输入框时，是否弹出软键盘
  bool isKeyboardOpenAfterClickTC = ShareStorageUtil.instance?.read(SharedPreferencesKeys.IS_KEYBOARD_OPEN_AFTER_CLICK_TC_KEY) ?? AppConfig.isKeyboardOpenAfterClickTC;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> exitApp() async{
    var confirm = await DialogUtils.showConfirmationDialog(
        Get.overlayContext!,
        msg: '确认退出软件？'
    );
    if (confirm == null || !confirm){
      return;
    }
    exit(0);
  }

  Future<void> openKeyboard() async{
    String executable = 'C:\\WINDOWS\\system32\\osk.exe';
    ///检测程序是否存在
    if(!(await File(executable).exists())){
      ToastNotification(Get.overlayContext!).error("没有发现程序osk.exe!");
      return;
    }
    try {
      await Process.start(executable, [], mode: ProcessStartMode.detached, runInShell: true);
    }
    catch (e){
      ToastNotification(Get.overlayContext!).error(e.toString());
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

}
