import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'en_us/en_us_translations.dart';
import 'zh_cn/zh_cn_translations.dart';


class TranslationService extends Translations {

  //Get.deviceLocale==直接读取ui.window.locale;
  static Locale? get locale => Get.deviceLocale;

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': en_US,
    'zh_CN': zh_CN,
  };
}