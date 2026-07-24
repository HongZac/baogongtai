import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/inventory_search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/inv_barcode_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///物料条码新增查看 设置页面
class InvBarcodeSettingController
    extends BaseSettingController
    with SearchInterface, InventorySearchInterface,
        InfoFormInterface,
        InterfaceUtil {


  @override
  final String title = '物料条码-页面设置';

  @override
  final List<ChoiceChipModel> tabValueList = [
    ChoiceChipModel(icon: Icons.search, title: '关键字搜索设置', keyName: 'keyWordSearch'),
    ChoiceChipModel(icon: Icons.assignment, title: '物料信息显示设置', keyName: 'infoForm'),
    ChoiceChipModel(icon: FluentIcons.view_desktop_24_regular, title: '显示设置', keyName: 'ui'),
  ];

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  final InvBarcodeController invBarcodeController = Get.find<InvBarcodeController>();

  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> invBarcodeListInfoFormListMap = {};

  int pageConfigRows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;


  InvBarcodeSettingController({
    super.progId = -1,
    this.noPermission = false,
    this.permissionInfo = '',
  });


  @override
  void onInit() {
    super.onInit();

    //region
    isShowSearchInputBox = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_IS_SHOW_SEARCH_INPUT_BOX_KEY) ?? AppConfig.isShowSearchInputBox;
    inventorySearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;

    List<dynamic> invBarcodeListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_INFO_FORM_LIST_KEY) ?? [];
    invBarcodeListInfoFormListMap.clear();
    invBarcodeListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                invBarcodeListInfoFormMapList,
                AppConfig.invBarcodeInvListInfoFormList
            )
        )
    );
    //endregion
  }


  //region onChanged

  ///单页显示记录数 点击变化
  void pageConfigRowsOnChanged(int intValue) {
    pageConfigRows = intValue;
    update();
  }

  //endregion


  //region OnSave

  Future<void> searchSettingSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存数据', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_IS_SHOW_SEARCH_INPUT_BOX_KEY, isShowSearchInputBox);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_SEARCH_TYPE_INDEX_KEY, inventorySearchTypeIndex);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '关键字搜索框设置保存成功，正在刷新数据！');

    //region 数据刷新
    invBarcodeController.isShowSearchInputBox = isShowSearchInputBox;
    invBarcodeController.inventorySearchTypeIndex = inventorySearchTypeIndex;
    if (!invBarcodeController.isShowSearchInputBox){
      invBarcodeController.searchFN.unfocus();
      if (invBarcodeController.searchTC.text.isNotEmpty){
        ///当搜索输入框被隐藏，并且输入框中有内容时，清空输入框内容并重新读取翻页数据
        invBarcodeController.searchTC.text = '';
        invBarcodeController.searchQueryDataOnChanged();
        await invBarcodeController.pageChanged(showLoading: false);
      }
    }
    invBarcodeController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  Future<void> infoFormSettingSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存数据', completedMsg: '数据刷新成功！');

    //region 数据保存
    List<Map<String, dynamic>> mapList = [];
    invBarcodeListInfoFormListMap.forEach((key, value) {
      mapList.addAll(value.map((e) => e.toJson()));
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    invBarcodeController.invBarcodeListInfoFormListMap.clear();
    invBarcodeController.invBarcodeListInfoFormListMap.addAll(invBarcodeListInfoFormListMap);
    invBarcodeController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  Future<void> uiSettingSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存数据', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_PAGE_CONFIG_ROWS_KEY, pageConfigRows);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (invBarcodeController.dataListPageConfig.rows != pageConfigRows){
      invBarcodeController.dataListPageConfig.rows = pageConfigRows;
      await invBarcodeController.pageChanged(showLoading: false);
    }
    invBarcodeController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  //endregion


  @override
  void onClose() {
    super.onClose();
  }

}