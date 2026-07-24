
import 'package:desktop/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class AppThemeMode{

  static Map<String, dynamic> themeList = {
    'system': {'title': '跟随系统', 'themeMode': ThemeMode.system},
    'light': {'title': '浅色', 'themeMode': ThemeMode.light},
    'dark': {'title': '深色', 'themeMode': ThemeMode.dark},
  };

  ThemeMode getThemeMode(String key){
    switch (key){
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  void changedThemeByThemeMode(ThemeMode mode){
    switch (mode){
      //region
      case ThemeMode.system:
        if (SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.light){
          Get.changeTheme(AppTheme.lightThemeData);
        }
        else {
          Get.changeTheme(AppTheme.darkThemeData);
        }
        Get.changeThemeMode(ThemeMode.system);
        break;
      case ThemeMode.dark:
        Get.changeTheme(AppTheme.darkThemeData);
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.light:
        Get.changeTheme(AppTheme.lightThemeData);
        Get.changeThemeMode(ThemeMode.light);
        break;
      //endregion
    }
  }

  void changedThemeByString(String mode){
    switch (mode){
      //region
      case 'system':
        if (SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.light){
          Get.changeTheme(AppTheme.lightThemeData);
        }
        else {
          Get.changeTheme(AppTheme.darkThemeData);
        }
        break;
      case 'dark':
        Get.changeTheme(AppTheme.darkThemeData);
        break;
      case 'light':
        Get.changeTheme(AppTheme.lightThemeData);
        break;
      //endregion
    }
  }

}