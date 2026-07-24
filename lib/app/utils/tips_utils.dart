

import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';

enum TipsShowType {
  dialog,
  toast,
}


class TipsUtils {

  /// 提示方式
  ///
  /// dialog
  ///
  /// toast
  static String _tipsShowTypeStr = 'dialog';
  static String get tipsShowTypeStr => _tipsShowTypeStr;
  static set tipsShowTypeStr(String str){
    ChoiceChipModel? item = AppConfig.tipsShowTypeList.firstWhereOrNull((element) => element.keyName == str);
    if (item != null){
      switch (item.keyName){
        case 'dialog':
          _tipsShowType = TipsShowType.dialog;
          break;
        case 'toast':
          _tipsShowType = TipsShowType.toast;
          break;
      }
      _tipsShowTypeStr = str;
    }
  }
  static TipsShowType _tipsShowType = TipsShowType.dialog;



  static void showTip({
    required String msg,
    required ToastType toastType, // = ToastType.warn,
  }){
    switch (_tipsShowType){
      case TipsShowType.dialog:
        //region
        //ProgressDialogUtil.close();
        DialogUtils.showTipsDialog(
          Get.context!,
          msg: msg,
          toastType: toastType,
          onConfirm: () async {  }
        );
        //endregion
        break;
      case TipsShowType.toast:
        //region
        switch (toastType){
          case ToastType.info:
            ToastNotification(Get.overlayContext!).info(msg);
            break;
          case ToastType.error:
            ToastNotification(Get.overlayContext!).error(msg);
            break;
          case ToastType.success:
            ToastNotification(Get.overlayContext!).success(msg);
            break;
          case ToastType.warn:
            ToastNotification(Get.overlayContext!).warn(msg);
            break;
        }
        //endregion
        break;
    }
  }

}