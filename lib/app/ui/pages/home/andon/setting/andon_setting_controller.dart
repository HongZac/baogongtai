import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/ui/pages/home/andon/andon_controller.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/dep_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/ui/widget/prefix_text_field.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///安灯系统 --全场呼叫系统 设置页面
class AndonSettingController
    extends BaseSettingController
    with SignFilterInterface,
        DepFilterInterface,
        DateFilterInterface,
        CommandBarInterface,
        InterfaceUtil {

  @override
  final String title = '全场呼叫-页面设置';

  @override
  final List<ChoiceChipModel> tabValueList = [
    ChoiceChipModel(icon: Icons.bookmarks, title: '状态标签设置', keyName: 'sign'),
    ChoiceChipModel(icon: Icons.store_mall_directory, title: '车间过滤设置', keyName: 'dep'),
    ChoiceChipModel(icon: Icons.category, title: '类型过滤设置', keyName: 'andonClass'),
    ChoiceChipModel(icon: Icons.calendar_month, title: '日期过滤设置', keyName: 'date'),
    ChoiceChipModel(icon: FluentIcons.view_desktop_24_regular, title: '显示设置', keyName: 'ui'),
  ];

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  final AndonController andonController = Get.find<AndonController>();

  ///全场呼叫 状态列表
  List<MoSignModel> get signList => AppConfig.andonSignList;

  List<MoAndonClassModel> andonClassList = [];
  ///是否显示全场呼叫类型选择器
  bool isShowAndonClassPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_IS_SHOW_ANDON_CLASS_PICKER_KEY) ?? AppConfig.isShowAndonClassPicker;
  ///类别筛选 选中的类别
  String andonServiceClassId = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_SERVICE_CLASS_ID_KEY) ?? '';


  ///单页显示记录数
  int pageConfigRows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;


  AndonSettingController({
    super.progId = -1,
    this.noPermission = false,
    this.permissionInfo = '',
  });


  @override
  void onInit() {
    super.onInit();

    //region
    isShowSignFilter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_IS_SHOW_SIGN_FILTER_KEY) ?? AppConfig.isShowSignFilter;
    isSignChipMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_IS_SIGN_CHIP_MULTI_KEY) ?? AppConfig.isSignChipMulti;
    selectedSignBinary = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_SIGN_SELECTED_KEY) ?? AppConfig.binaryForSignSelected;

    isShowDepPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_IS_SHOW_DEP_PICKER_KEY) ?? AppConfig.isShowDepPicker;
    depIds = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_DEP_IDS_KEY) ?? '';

    isShowDatePicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_IS_SHOW_DATE_PICKER_KEY) ?? AppConfig.isShowDatePicker;
    String datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_DATE_PICKER_VALUE_MAP_KEY) ?? '';
    getDatePickerEnumIndex(datePickerValueStr);

    //endregion
  }

  @override
  Future<bool> initializeForm() async {
    await getDepList();
    await getAndonClassList();
    return true;
  }

  Future<void> getAndonClassList() async {
    PageConfig pg = PageConfig(
      page: 1, rows: 999,
      sord:'asc', sidx:'classCode',
      queryData: {}
    );
    var result = await MoAndonClassRepository().getPageList(pg);
    if (!result.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取全场呼叫类型列表时出错：${result.message}');
      return;
    }
    andonClassList.clear();
    andonClassList.addAll(result.rows);
    List<String> selectedIdList = andonServiceClassId.split(',');
    andonClassList.forEach((element) {
      if (selectedIdList.contains(element.id)){
        element.isChoice = true;
      }
      else {
        element.isChoice = false;
      }
    });
  }


  //region OnChanged

  void isShowAndonClassPickerOnChanged(){
    isShowAndonClassPicker = !isShowAndonClassPicker;
    update();
  }

  void andonClassOnChanged(MoAndonClassModel item) {
    item.isChoice = !item.isChoice;
    update();
  }

  void andonClassAllOnChanged({required bool? allChoice}) {
    andonClassList.forEach((element) {
      element.isChoice = allChoice ?? !element.isChoice;
    });
    update();
  }

  ///单页显示记录数 点击变化
  void pageConfigRowsOnChanged(int intValue) {
    pageConfigRows = intValue;
    update();
  }

  //endregion


  //region OnSave

  ///状态标签设置 保存
  Future<void> signSettingSave() async {
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
    if (!isSignChipMulti){
      List<MoSignModel> selectedList = andonController.signList.where(
              (element) => selectedSignBinary & element.sign == element.sign).toList();
      if (selectedList.length > 1){
        ToastNotification(Get.overlayContext!).warn('当前是单选模式，只能选择单个状态标签！');
        isLoading = false;
        return;
      }
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_IS_SHOW_SIGN_FILTER_KEY, isShowSignFilter);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_IS_SIGN_CHIP_MULTI_KEY, isSignChipMulti);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_SIGN_SELECTED_KEY, selectedSignBinary);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '状态标签设置保存成功，正在刷新数据！');

    //region 数据刷新
    andonController.isShowSignFilter = isShowSignFilter;
    andonController.isSignChipMulti = isSignChipMulti;
    if (andonController.selectedSignBinary != selectedSignBinary){
      andonController.selectedSignBinary = selectedSignBinary;
      andonController.signQueryDataOnChanged();
      await andonController.pageChanged(showLoading: false);
    }
    andonController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///车间筛选器设置 保存
  Future<void> depSettingSave() async {
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
    List<DepartmentModel> list = [];
    for (var element in depList) {
      if (element.isChoice){
        list.add(element);
      }
    }
    String depIds = list.map((e) => e.departmentId).join(',');
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_IS_SHOW_DEP_PICKER_KEY, isShowDepPicker);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_DEP_IDS_KEY, depIds);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '车间筛选器设置保存成功，正在刷新数据！');

    //region 数据刷新
    andonController.isShowDepPicker = isShowDepPicker;
    if (andonController.depIds != depIds){
      andonController.depIds = depIds;
      await andonController.depAdapter?.validModelValue(andonController.depIds);
      andonController.depQueryDataOnChanged();
      await andonController.pageChanged(showLoading: false);
    }
    andonController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///全场呼叫类型设置 保存
  Future<void> andonClassSettingSave() async {
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
    List<MoAndonClassModel> list = [];
    for (var element in andonClassList) {
      if (element.isChoice){
        list.add(element);
      }
    }
    String andonClassIds = list.map((e) => e.id).join(',');
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_IS_SHOW_ANDON_CLASS_PICKER_KEY, isShowAndonClassPicker);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_SERVICE_CLASS_ID_KEY, andonClassIds);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '车间筛选器设置保存成功，正在刷新数据！');

    //region 数据刷新
    andonController.isShowAndonClassPicker = isShowAndonClassPicker;
    if (andonController.andonServiceClassId != andonClassIds){
      andonController.andonServiceClassId = andonClassIds;
      await andonController.andonClassAdapter?.validModelValue(andonController.andonServiceClassId);
      andonController.andonClassQueryDataOnChanged();
      await andonController.pageChanged(showLoading: false);
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///日期筛选器设置 保存
  Future<void> dateSettingSave() async {
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
    if (dataPickerValueTC.text.isNotEmpty
        && DatePickerEnum.values[datePickerEnumIndex] == DatePickerEnum.custom){
      bool isFail = false;
      try {
        var dataPickerValueTCJson = jsonDecode(dataPickerValueTC.text);
        if (dataPickerValueTCJson is! Map<String, dynamic>){
          isFail = true;
        }
      } catch(e){
        isFail = true;
      }
      if (isFail){
        ToastNotification(Get.overlayContext!).warn('自定义内容输入有误！');
        isLoading = false;
        return;
      }
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
    Map<String, dynamic> datePickerValueMap = {};
    switch (DatePickerEnum.values[datePickerEnumIndex]){
      //region
      case DatePickerEnum.today:
        datePickerValueMap.addAll({
          'startDate': {'d': {'interval': 0}},
          'endDate': {'d': {'interval': 0}},
        });
        break;
      case DatePickerEnum.lastDay:
        datePickerValueMap.addAll({
          'startDate': {'d': {'interval': -1}},
          'endDate': {'d': {'interval': 0}},
        });
        break;
      case DatePickerEnum.lastSevenDays:
        datePickerValueMap.addAll({
          'startDate': {'d': {'interval': -6}},
          'endDate': {'d': {'interval': 0}},
        });
        break;
      case DatePickerEnum.lastMonth:
        datePickerValueMap.addAll({
          'startDate': {'d': {'interval': -29}},
          'endDate': {'d': {'interval': 0}},
        });
        break;
      case DatePickerEnum.lastThreeMonth:
        datePickerValueMap.addAll({
          'startDate': {'d': {'interval': -89}},
          'endDate': {'d': {'interval': 0}},
        });
        break;
      case DatePickerEnum.custom:
        Map<String, dynamic> dataPickerValueTCJson = dataPickerValueTC.text.isEmpty
            ? {}
            : jsonDecode(dataPickerValueTC.text);
        datePickerValueMap.addAll(dataPickerValueTCJson);
        break;
      //endregion
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_IS_SHOW_DATE_PICKER_KEY, isShowDatePicker);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_DATE_PICKER_VALUE_MAP_KEY, datePickerValueMap.isEmpty ? '' : jsonEncode(datePickerValueMap));
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '日期筛选器设置保存成功，正在刷新数据！');

    //region 数据刷新
    andonController.isShowDatePicker = isShowDatePicker;
    if (jsonEncode(andonController.datePickerValueMap) != jsonEncode(datePickerValueMap)){
      andonController.datePickerValueMap = datePickerValueMap;
      andonController.dateQueryDataOnChanged();
      await andonController.pageChanged(showLoading: false);
    }
    andonController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///显示设置 保存
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_PAGE_CONFIG_ROWS_KEY, pageConfigRows);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (andonController.dataListPageConfig.rows != pageConfigRows){
      andonController.dataListPageConfig.rows = pageConfigRows;
      await andonController.pageChanged(showLoading: false);
    }
    andonController.update();
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