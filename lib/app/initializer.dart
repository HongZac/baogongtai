import 'package:basement/base_initializer.dart';
import 'package:desktop/app/service/app_print_service/app_print_service.dart';
import 'package:desktop/app/service/sound_service.dart';
import 'package:desktop/app/service/tts_service.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/theme/app_theme.dart';
import 'package:desktop/app/theme/app_theme_mode.dart';
import 'package:desktop/app/theme/font_family_config.dart';
import 'package:desktop/app/translation/language_config.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:window_manager/window_manager.dart';

import 'service/serial_com_service/serial_com_service.dart';


///在初始化APP系统前，先将GetService处理
///注意：有关引用有关联，执行顺序需要注意
///系统有关的硬件初始化，也在此执行
class Initializer implements Bindings {
  @override
  Future<void> dependencies() async {
    this.printInfo(info:"begin init....");
    try {
      WidgetsFlutterBinding.ensureInitialized();

      //region basement基础框架初始化 包括（dio,modal,repository）初始化ShareStorageUtil
      await BaseInitializer.init('Desktop Files', 'desktop');
      //endregion

      ///提示方式
      TipsUtils.tipsShowTypeStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.TIPS_SHOW_TYPE_KEY) ?? AppConfig.tipsShowTypeStr;

      //region 设置重点色、字体样式、字体大小、主题、语言
      FontFamilyConfig.textScale = ShareStorageUtil.instance?.read(SharedPreferencesKeys.TEXT_SCALE_KEY) ?? AppConfig.textScale;
      FontFamilyConfig.fontFamily = ShareStorageUtil.instance?.read(SharedPreferencesKeys.FONT_FAMILY_KEY) ?? AppConfig.fontFamily;
      AppTheme.buildTheme();
      AppThemeMode().changedThemeByThemeMode(AppTheme.themeMode);
      LanguageConfig.getLanguage(Locale(
        ShareStorageUtil.instance?.read(SharedPreferencesKeys.LOCALE_LANGUAGE_CODE_KEY) ?? AppConfig.defaultLocal.languageCode,
        ShareStorageUtil.instance?.read(SharedPreferencesKeys.LOCALE_COUNTRY_CODE_KEY) ?? AppConfig.defaultLocal.countryCode,
      ));
      //endregion

      //region windowManager 只支持：LINUX、macOs、WINDOWS
      if (!kIsWeb && GetPlatform.isWindows){
        await windowManager.ensureInitialized();
        WindowOptions windowOptions = const WindowOptions(
          size: Size(780, 545),
          center: true,
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.hidden,
        );
        await windowManager.waitUntilReadyToShow(windowOptions, () async {
          await windowManager.setAsFrameless();
          await windowManager.setHasShadow(true);
          await windowManager.show();
          await windowManager.focus();
        });
      }
      //endregion

      ///设置窗体标题.
      if (!kIsWeb && GetPlatform.isWindows){
        await windowManager.setTitle('车间工作台');
      }

      Get.put(AppService());
      Get.put(SoundService());
      Get.put(TtsService());
      Get.put(WeightMsgConnectService());
      Get.put(AppPrintService());
      ///串口通讯服务管理
      Get.put(SerialComService());

      ///安卓平台的的状态栏隐藏
      if (GetPlatform.isAndroid){
        ///是否需要隐藏状态栏和底部导航栏,默认值SystemUiMode.leanBack.
        ///全屏显示，关闭状态栏
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

        /// 固定屏幕竖直内容
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    } catch (err) {
      printInfo(info: "=========Error:$err============");
    }
    printInfo(info:"end init....");
  }

}
