import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/service/app_print_service/app_print_service.dart';
import 'package:desktop/app/service/data_service.dart';
import 'package:desktop/app/service/network_connection_service.dart';
import 'package:desktop/app/ui/pages/root/root_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:window_manager/window_manager.dart';



/// 登录页
class LoginController extends GetxController {

  final rootCtl = Get.find<RootController>();

  ///是否保存密码（记住密码）
  bool _reservePassword = ShareStorageUtil.instance?.read(SharedPreferencesKeys.RESERVEPWD_KEY) ?? AppConfig.isReservePW;
  ///不显示密码明文
  bool _obscureTextLogin = true;

  final TextEditingController userController = TextEditingController(
    text: ShareStorageUtil.instance?.read(SharedPreferencesKeys.USER_NAME_KEY) ?? (kDebugMode ? AppConfig.userName : ''),
  );
  late final TextEditingController pwController = TextEditingController(
    text: (_reservePassword || kDebugMode ? ShareStorageUtil.instance?.read(SharedPreferencesKeys.PW_KEY) : null) ?? (kDebugMode ? AppConfig.password : '')
  );

  final FocusNode uNFocusNode = FocusNode();
  final FocusNode pWFocusNode = FocusNode();
  int lastKeyPressTime = 0;

  bool isLoading = false;


  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();

    bool isNeedTimedRestart = ShareStorageUtil.instance?.read(SharedPreferencesKeys.IS_NEED_TIMED_RESTART_KEY) ?? AppConfig.isNeedTimedRestart;
    if (isNeedTimedRestart){
      bool isOpenByRestart = ShareStorageUtil.instance?.read(SharedPreferencesKeys.IS_OPEN_BY_RESTART_KEY) ?? AppConfig.isOpenByRestart;
      if (isOpenByRestart){
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          ShareStorageUtil.instance?.write(SharedPreferencesKeys.IS_OPEN_BY_RESTART_KEY, false);
          if (pwController.text.isEmpty){
            pwController.text = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PW_KEY) ?? '';
          }
          await signIn();
        });
      }
    }

  }

  bool get reservePassword => _reservePassword;
  set reservePassword(value) {
      if(value != _reservePassword) {
        _reservePassword = value;
        update();
      }
  }
  bool get obscureTextLogin => _obscureTextLogin;
  set obscureTextLogin(value) {
    _obscureTextLogin = value;
    update();
  }

  ///校验登录APP方法
  Future<void> signIn() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;


    if (userController.text.isEmpty) {
      ToastNotification(Get.overlayContext!).warn("login.erroruser".tr);
      isLoading = false;
      return;
    }
    if (pwController.text.isEmpty) {
      ToastNotification(Get.overlayContext!).warn("login.errorpassword".tr);
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(msg: 'login.modifying'.tr, completedMsg: 'login.success'.tr);
    IAuthenticationService authenticationService = Get.find<IAuthenticationService>();
    var res = await authenticationService.signInWithPassword(
      userController.text.trim(),
      pwController.text.trim(),
    );
    ///如果登录不成功，返回登录错误提示信息
    if(!res.isSuccess || !authenticationService.isLogon){
       ToastNotification(Get.overlayContext!).error(res.data.runtimeType == String ? res.data : '登录失败！');
       ProgressDialogUtil.close();
       isLoading = false;
       return;
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.USER_NAME_KEY, userController.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PW_KEY, pwController.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.RESERVEPWD_KEY, _reservePassword);

    ProgressDialogUtil.update(value: 1, msg: '登录成功！');

    ///登录后初始化数据工作
    try {
      Get.delete<DataService>(force: true);
    } catch (e){}
    Get.put(DataService());

    try {
      Get.delete<NetworkConnectionService>(force: true);
    } catch (e){}
    Get.put(NetworkConnectionService());

    final appPrintService = Get.find<AppPrintService>();
    if (appPrintService.printServiceList.isNotEmpty){
      appPrintService.register(appPrintService.printServiceList);
    }

    if (!kIsWeb && GetPlatform.isWindows){
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1280, 960),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async{
        if(GetPlatform.isWindows && !kIsWeb){
          await windowManager.hide();
        }
        await Future.delayed(const Duration(seconds: 1));
        Get.rootDelegate.offNamed(AppRoutes.HOME_PAGE);
        await windowManager.maximize();
        await windowManager.show();
        await windowManager.focus();
      });
    }
    else {
      await Future.delayed(const Duration(seconds: 1));
      Get.rootDelegate.offNamed(AppRoutes.HOME_PAGE);
    }
    isLoading = false;
  }

  @override
  void onClose() {
    uNFocusNode.dispose();
    pWFocusNode.dispose();
    super.onClose();
  }
}