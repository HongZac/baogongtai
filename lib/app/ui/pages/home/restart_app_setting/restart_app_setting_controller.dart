import 'dart:async';

import 'package:basement/utils.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///定时重启设置页面
class RestartAppSettingController extends BaseDialogController {

  ///应用程序是否需要定时重启
  bool isNeedTimedRestart = ShareStorageUtil.instance?.read(SharedPreferencesKeys.IS_NEED_TIMED_RESTART_KEY) ?? AppConfig.isNeedTimedRestart;

  ///应用程序定时重启的天数
  int? dayOfAppRestart = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DAY_OF_APP_RESTART_KEY) ?? AppConfig.dayOfAppRestart;

  ///应用程序定时重启的时间
  final DateTime? dateTimeOfAppRestart = DateTime.tryParse(
    ShareStorageUtil.instance?.read(SharedPreferencesKeys.DATE_TIME_OF_APP_RESTART_KEY) ?? AppConfig.dateTimeOfAppRestart ?? ''
  );
  ///应用程序定时重启的时间
  late TimeOfDay? timeOfDayOfAppRestart = dateTimeOfAppRestart == null
      ? null
      : TimeOfDay.fromDateTime(dateTimeOfAppRestart!);

  ///下次重启时间
  String get nextRestartTime {
    final nowDateTime = DateTime.now();
    DateTime dateTime = nowDateTime.copyWith(
      day: nowDateTime.day + (dayOfAppRestart ?? 0),
      hour: timeOfDayOfAppRestart?.hour ?? 0,
      minute: timeOfDayOfAppRestart?.minute ?? 0,
      second: 0,
      millisecond: 0,
    );
    if (dateTime.isBefore(nowDateTime)){
      dateTime = dateTime.add(Duration(days: 1));
    }
    return '（下次重启时间：${DateUtil.getDateStrByDateTime(dateTime, format: DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE)}）';
  }


  void isNeedTimedRestartOnChanged() {
    isNeedTimedRestart = !isNeedTimedRestart;
    update();
  }


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async {
    if (actionName == DialogButtonActionEnum.confirm) {
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.IS_NEED_TIMED_RESTART_KEY, isNeedTimedRestart);
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.DAY_OF_APP_RESTART_KEY, dayOfAppRestart);
      ShareStorageUtil.instance?.write(
        SharedPreferencesKeys.DATE_TIME_OF_APP_RESTART_KEY,
        timeOfDayOfAppRestart == null
            ? null
            : DateTime.now().copyWith(hour: timeOfDayOfAppRestart!.hour, minute: timeOfDayOfAppRestart!.minute).toString()
      );
      ToastNotification(Get.overlayContext!).info('重新打开工作台后，该设置才会生效！');
      return DialogReturnDataModel(isCanCloseDialog: true, data: true);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

}