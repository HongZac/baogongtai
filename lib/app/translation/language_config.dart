import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class LanguageConfig {

  //默认语言
  static final defaultLocale = Locale('en', 'US');

  static List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
    //Locale.fromSubtags(
    //    languageCode: 'zh',
    //    scriptCode: 'Hans',
    //    countryCode: 'CN'),
  ];

  static Map<String, dynamic> supportLanguage = {
    "zh": {"code": "zh", "country_code": "CN", 'enName': 'Chinese', 'zhName': '中文'.tr},
    "en": {"code": "en", "country_code": "US", 'enName': 'English', 'zhName': '英文'.tr}
  };

  static getLanguage(Locale fallbackLocale){
    Get.updateLocale(fallbackLocale);
    return fallbackLocale;
  }

}