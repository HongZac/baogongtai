
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///颜色
abstract class AppColors {

  ///提示框中信息显示颜色
  static const Color successBgColor = Color.fromRGBO(202, 237, 220, 1);
  static const Color successTextColor = Color.fromRGBO(6, 95, 70, 1);

  static const Color errorBgColor = Color.fromRGBO(254, 242, 242, 1);
  static const Color errorTextColor = Color.fromRGBO(156, 34, 34, 1);

  static const Color infoBgColor = Color.fromRGBO(239, 246, 255, 1);
  static const Color infoTextColor = Color.fromRGBO(88, 145, 255, 1);

  static const Color warnBgColor = Color.fromRGBO(255, 251, 235, 1);
  static const Color warnTextColor = Color.fromRGBO(180, 83, 9, 1);

  static const Color warnIconColor = Color(0xFFFFAA25);

  static const Color totalColor = Color(0xFF006EF3); //0xFF1088FF
  static const Color runColor = Color(0xFF32A971);
  static const Color standByColor = Color(0xFFFAAD14);
  static const Color stopColor = Color(0xFFF5222D);
  static const Color notConnectedColor = Colors.grey;

  static const Color progressBkgColor = Color(0xFFBDBDBD);
  static const Color progressActiveBkgColor = Color(0xFF2196F3);
  static const Color progressWarnBkgColor = Color(0xFFFCC422); //Color(0xFFE65100);
  static const Color progressErrBkgColor = Color(0xFFB71C1C);

  static const Color successColor = Color(0xFF249344);
  static const Color warnColor = Color(0xFFE65100);

  static final errorColor = Theme.of(Get.context!).colorScheme.error;
  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = Color(0xFF444444);
  static final Color greyColor = Colors.grey[400]!;
  static const Color transparentColor = Colors.transparent;
  static const Color starColor = Color(0xFFFFCD5D);

  static const Color dioGetColor = Colors.green;
  static final Color dioPostColor = Colors.yellow[700]!;
  static const Color dioPutColor = Colors.blue;
  static const Color dioPatchColor = Colors.deepPurple;
  static const Color dioDeleteColor = Colors.deepOrangeAccent;
  static const Color dioHeadColor = Colors.greenAccent;
  static const Color dioOptionsColor = Colors.pink;

  ///主颜色
  static const List<Color> mainColorList = [
    Color.fromRGBO(41, 77, 255, 1),
    Color.fromRGBO(253, 157, 28, 1),
    Color.fromRGBO(146, 204, 30, 1),
    Color.fromRGBO(47, 126, 249, 1),
    Color.fromRGBO(98, 45, 251, 1),
    Color.fromRGBO(243, 30, 88, 1),
    Color.fromRGBO(20, 194, 195, 1),
    Color.fromRGBO(236, 47, 150, 1),
    Color.fromRGBO(222, 143, 115, 1),
    Color.fromRGBO(71, 200, 118, 1),
  ];

  ///背景色
  static const List<Color> bkgdColorList = [
    Color.fromRGBO(41, 77, 255, 0.13),
    Color.fromRGBO(253, 157, 28, 0.13),
    Color.fromRGBO(146, 204, 30, 0.13),
    Color.fromRGBO(47, 126, 249, 0.13),
    Color.fromRGBO(98, 45, 251, 0.13),
    Color.fromRGBO(243, 30, 88, 0.13),
    Color.fromRGBO(20, 194, 195, 0.13),
    Color.fromRGBO(236, 47, 150, 0.13),
    Color.fromRGBO(222, 143, 115, 0.13),
    Color.fromRGBO(71, 200, 118, 0.13),
  ];

}