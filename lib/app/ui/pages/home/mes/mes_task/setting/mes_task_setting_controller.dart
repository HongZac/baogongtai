import 'dart:convert';

import 'package:basement/model.dart';
import 'package:basement/service.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/dep_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/line_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/task_keyword_search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/task_sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/mes_task_controller.dart';
import 'package:desktop/app/ui/widget/prefix_text_field.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///派工单报工-设置页面
class MesTaskSettingController
    extends BaseSettingController
    with SignFilterInterface, TaskSignFilterInterface,
        DepFilterInterface,
        LineFilterInterface,
        DateFilterInterface,
        SearchInterface, TaskKeywordSearchInterface,
        InfoFormInterface,
        CommandBarInterface,
        InterfaceUtil {

  @override
  final String title = '生产派工-页面设置';

  @override
  final List<ChoiceChipModel> tabValueList = [
    ChoiceChipModel(icon: Icons.bookmarks, title: '状态标签设置', keyName: 'sign'),
    ChoiceChipModel(icon: Icons.store_mall_directory, title: '车间过滤设置', keyName: 'dep'),
    ChoiceChipModel(icon: Icons.conveyor_belt, title: '生产产线过滤设置', keyName: 'line'),
    ChoiceChipModel(icon: Icons.calendar_month, title: '日期过滤设置', keyName: 'date'),
    ChoiceChipModel(icon: Icons.search, title: '关键字搜索设置', keyName: 'keyWordSearch'),
    ChoiceChipModel(icon: Icons.assignment, title: '派工信息显示设置', keyName: 'infoForm'),
    ChoiceChipModel(icon: Icons.ads_click, title: '按钮组显示设置', keyName: 'commandBar'),
    ChoiceChipModel(icon: FluentIcons.view_desktop_24_regular, title: '显示设置', keyName: 'ui'),
  ];

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  final MesTaskController mesTaskController = Get.find<MesTaskController>();

  ///列表视图字段显示设置 数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> taskListInfoFormListMap = {};

  ///按钮组设置 派工单列表页面显示的按钮组列表
  final List<CommandBarBtnModel> taskCommandBarList = [];

  ///单页显示记录数
  int pageConfigRows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;


  MesTaskSettingController({
    super.progId = -1,
    this.noPermission = false,
    this.permissionInfo = '',
  });


  @override
  void onInit() {
    super.onInit();

    //region
    isShowSignFilter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_IS_SHOW_TASK_SIGN_FILTER_KEY) ?? AppConfig.isShowSignFilter;
    isSignChipMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_IS_TASK_SIGN_CHIP_MULTI_KEY)?? AppConfig.isSignChipMulti;
    selectedTaskSignBinary = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SIGN_SELECTED_KEY) ?? AppConfig.binaryForSignSelected;

    isShowDepPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_IS_SHOW_DEP_PICKER_KEY) ?? AppConfig.isShowDepPicker;
    depIds = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_DEP_IDS_KEY) ?? '';

    isShowLinePicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_IS_SHOW_LINE_PICKER_KEY) ?? AppConfig.isShowLinePicker;
    lineIds = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_LINE_IDS_KEY) ?? '';

    isShowDatePicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_IS_SHOW_DATE_PICKER_KEY) ?? AppConfig.isShowDatePicker;
    String datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_DATE_PICKER_VALUE_MAP_KEY) ?? '';
    getDatePickerEnumIndex(datePickerValueStr);

    isShowSearchInputBox = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_IS_SHOW_SEARCH_INPUT_BOX_KEY) ?? AppConfig.isShowSearchInputBox;
    taskSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;

    List<dynamic> taskListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_INFO_FORM_LIST_KEY) ?? [];
    taskListInfoFormListMap.clear();
    taskListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                taskListInfoFormMapList,
                AppConfig.mesTaskListInfoFormList
            )
        )
    );

    final List<dynamic> taskCommandBarMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_COMMAND_BAR_LIST_KEY) ?? [];
    taskCommandBarList.clear();
    taskCommandBarList.addAll(
        getCommandBarListByStorage(
            taskCommandBarMapList,
            AppConfig.mesTaskCommandBarList
        )
    );
    //endregion
  }

  @override
  Future<bool> initializeForm() async {
    await getDepList();
    await getLineList();
    return true;
  }


  //region onChanged

  ///单页显示记录数 点击变化
  void pageConfigRowsOnChanged(int intValue) {
    pageConfigRows = intValue;
    update();
  }

  //endregion


  //region onSave

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
      List<MoSignModel> selectedList = mesTaskController.taskSignList.where(
              (element) => selectedTaskSignBinary & element.sign == element.sign).toList();
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_IS_SHOW_TASK_SIGN_FILTER_KEY, isShowSignFilter);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_IS_TASK_SIGN_CHIP_MULTI_KEY, isSignChipMulti);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SIGN_SELECTED_KEY, selectedTaskSignBinary);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '状态标签设置保存成功，正在刷新数据！');

    //region 数据刷新
    mesTaskController.isShowSignFilter = isShowSignFilter;
    mesTaskController.isSignChipMulti = isSignChipMulti;
    if (mesTaskController.selectedTaskSignBinary != selectedTaskSignBinary){
      mesTaskController.selectedTaskSignBinary = selectedTaskSignBinary;
      mesTaskController.signQueryDataOnChanged();
      await mesTaskController.pageChanged(showLoading: false);
    }
    mesTaskController.update();
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_IS_SHOW_DEP_PICKER_KEY, isShowDepPicker);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_DEP_IDS_KEY, depIds);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '车间筛选器设置保存成功，正在刷新数据！');

    //region 数据刷新
    mesTaskController.isShowDepPicker = isShowDepPicker;
    if (mesTaskController.depIds != depIds){
      mesTaskController.depIds = depIds;
      await mesTaskController.depAdapter?.validModelValue(mesTaskController.depIds);
      mesTaskController.depQueryDataOnChanged();
      await mesTaskController.pageChanged(showLoading: false);
    }
    mesTaskController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///生产产线筛选器设置 保存
  Future<void> lineSettingSave() async {
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
    List<MoBeltLineModel> list = [];
    for (var element in lineList) {
      if (element.isChoice){
        list.add(element);
      }
    }
    String lineIds = list.map((e) => e.id).join(',');
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_IS_SHOW_LINE_PICKER_KEY, isShowLinePicker);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_LINE_IDS_KEY, lineIds);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '车间筛选器设置保存成功，正在刷新数据！');

    //region 数据刷新
    mesTaskController.isShowLinePicker = isShowLinePicker;
    if (mesTaskController.lineIds != lineIds){
      mesTaskController.lineIds = lineIds;
      await mesTaskController.lineAdapter?.validModelValue(mesTaskController.lineIds);
      mesTaskController.lineQueryDataOnChanged();
      await mesTaskController.pageChanged(showLoading: false);
    }
    mesTaskController.update();
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_IS_SHOW_DATE_PICKER_KEY, isShowDatePicker);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_DATE_PICKER_VALUE_MAP_KEY, datePickerValueMap.isEmpty ? '' : jsonEncode(datePickerValueMap));
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '日期筛选器设置保存成功，正在刷新数据！');

    //region 数据刷新
    mesTaskController.isShowDatePicker = isShowDatePicker;
    if (jsonEncode(mesTaskController.datePickerValueMap) != jsonEncode(datePickerValueMap)){
      mesTaskController.datePickerValueMap = datePickerValueMap;
      mesTaskController.dateQueryDataOnChanged();
      await mesTaskController.pageChanged(showLoading: false);
    }
    mesTaskController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///关键字搜索框设置 保存
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_IS_SHOW_SEARCH_INPUT_BOX_KEY, isShowSearchInputBox);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SEARCH_TYPE_INDEX_KEY, taskSearchTypeIndex);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '关键字搜索框设置保存成功，正在刷新数据！');

    //region 数据刷新
    mesTaskController.isShowSearchInputBox = isShowSearchInputBox;
    mesTaskController.taskSearchTypeIndex = taskSearchTypeIndex;
    if (!mesTaskController.isShowSearchInputBox){
      mesTaskController.searchFN.unfocus();
      if (mesTaskController.searchTC.text.isNotEmpty){
        ///当搜索输入框被隐藏，并且输入框中有内容时，清空输入框内容并重新读取翻页数据
        mesTaskController.searchTC.text = '';
        mesTaskController.searchQueryDataOnChanged();
        await mesTaskController.pageChanged(showLoading: false);
      }
    }
    mesTaskController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///列表视图字段显示设置 保存
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
    taskListInfoFormListMap.forEach((key, value) {
      mapList.addAll(value.map((e) => e.toJson()));
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    mesTaskController.taskListInfoFormListMap.clear();
    mesTaskController.taskListInfoFormListMap.addAll(taskListInfoFormListMap);
    mesTaskController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///按钮组设置 保存
  Future<void> commandBarSettingSave() async {
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
    taskCommandBarList.forEach((element) {
      mapList.add(element.toJson());
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_COMMAND_BAR_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    mesTaskController.taskCommandBarList.clear();
    mesTaskController.taskCommandBarList.addAll(taskCommandBarList);
    mesTaskController.update();
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_PAGE_CONFIG_ROWS_KEY, pageConfigRows);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (mesTaskController.dataListPageConfig.rows != pageConfigRows){
      mesTaskController.dataListPageConfig.rows = pageConfigRows;
      await mesTaskController.pageChanged(showLoading: false);
    }
    mesTaskController.update();
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