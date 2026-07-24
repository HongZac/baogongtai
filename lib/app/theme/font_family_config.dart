import 'package:get/get.dart';

abstract class FontFamilyConfig{

  ///文本比例
  static double textScale = 1;

  static String fontFamily = '';

  static Map<String, dynamic> supportFontFamily = {
    'FontFamilyOfSiYuanHeiTi': {'zhName': '思源黑体'.tr, 'enName': 'FontFamilyOfSiYuanHeiTi'},
    'FontFamilyOfSiYuanSongTi': {'zhName': '思源宋体'.tr, 'enName': 'FontFamilyOfSiYuanSongTi'},
  };

}