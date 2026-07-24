// ignore_for_file: empty_catches, overridden_fields

import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';

///质量巡检首页 设置页面
class QualityInspectionSettingController extends BaseSettingController {

  @override
  String title = '质量巡检-设置页面';

  @override
  final List<ChoiceChipModel> tabValueList = [
    ChoiceChipModel(icon: FluentIcons.view_desktop_24_regular, title: '页面显示设置', keyName: 'interface', isSelected: true),
  ];

  ///质量巡检 前台显示的检验类型列表
  int showCategory = ShareStorageUtil.instance?.read(SharedPreferencesKeys.QUALITY_INSPECTION_SHOW_CATEGORY_LIST_KEY) ?? AppConfig.showCategory;


  QualityInspectionSettingController({
    super.progId = -1,
  });


  void showCategoryOnChanged(bool isSelected, int sign) {
    if (isSelected){
      showCategory += sign;
    }
    else {
      showCategory -= sign;
    }
    update();
  }

  Future<void> interfaceSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 1, msg: '正在保存数据', completedMsg: '数据保存成功！');

    //region 数据保存
    ///清空当前选中的类型状态后，再保存
    ShareStorageUtil.instance?.remove(SharedPreferencesKeys.QUALITY_INSPECTION_CATEGORY_SELECTED_KEY);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.QUALITY_INSPECTION_SHOW_CATEGORY_LIST_KEY, showCategory);
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 1);
  }

}