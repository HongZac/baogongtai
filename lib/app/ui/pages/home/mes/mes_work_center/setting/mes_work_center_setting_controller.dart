import 'dart:convert';

import 'package:basement/service.dart';
import 'package:basement/utils.dart';
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
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/order_keyword_search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/task_keyword_search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/order_sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/task_sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/work_center_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/mes_work_center_controller.dart';
import 'package:desktop/app/ui/widget/prefix_text_field.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 加工中心（可选择派工单报工 OR 任务单报工） - 参数设置
class MesWorkCenterSettingController
    extends BaseSettingController
    with DepFilterInterface,
        WorkCenterFilterInterface,
        SignFilterInterface, TaskSignFilterInterface, OrderSignFilterInterface,
        DateFilterInterface,
        SearchInterface, TaskKeywordSearchInterface, OrderKeywordSearchInterface,
        InfoFormInterface,
        CommandBarInterface,
        InterfaceUtil {

  final String title = '加工中心-页面设置';

  @override
  final List<ChoiceChipModel> tabValueList = [
    ChoiceChipModel(icon: Icons.filter_alt_sharp, title: '加工中心-车间筛选', keyName: 'dep'),
    ChoiceChipModel(icon: Icons.filter_alt_sharp, title: '加工中心-加工中心筛选', keyName: 'workCenter'),
    ChoiceChipModel(icon: Icons.category, title: '单据类型设置', keyName: 'sign'),
    ChoiceChipModel(icon: Icons.bookmarks, title: '状态标签设置', keyName: 'sign'),
    ChoiceChipModel(icon: Icons.calendar_month, title: '日期过滤设置', keyName: 'date'),
    ChoiceChipModel(icon: Icons.search, title: '关键字搜索设置', keyName: 'orderKeyWordSearch'),
    ChoiceChipModel(icon: Icons.assignment, title: '任务单-任务信息显示设置', keyName: 'orderInfoForm'),
    ChoiceChipModel(icon: Icons.assignment, title: '派工单-任务信息显示设置', keyName: 'taskInfoForm'),
    ChoiceChipModel(icon: Icons.ads_click, title: '任务单-按钮组显示设置', keyName: 'orderCommandBar'),
    ChoiceChipModel(icon: Icons.ads_click, title: '派工单-按钮组显示设置', keyName: 'taskCommandBar'),
    ChoiceChipModel(icon: FluentIcons.view_desktop_24_regular, title: '显示设置', keyName: 'ui'),
  ];

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  final MesWorkCenterController mesWorkCenterController = Get.find<MesWorkCenterController>();

  ///是否显示单据类型选择标签
  bool isShowCategory = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_IS_SHOW_CATEGORY_KEY) ?? AppConfig.isShowCategory;
  ///单据类型列表选中项的 Sign（任务单 610001 OR 派工单 650011）
  int selectedCategorySign = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_CATEGORY_SELECTED_KEY) ?? AppConfig.workCenterCategorySelectedIndex;

  ///列表视图字段显示设置 数据字段列表（已分组） 任务单
  final Map<int, List<InfoFormModel>> orderListInfoFormListMap = {};
  ///列表视图字段显示设置 数据字段列表（已分组） 派工单
  final Map<int, List<InfoFormModel>> taskListInfoFormListMap = {};

  ///按钮组设置 按钮组列表 任务单
  final List<CommandBarBtnModel> orderCommandBarList = [];
  ///按钮组设置 按钮组列表 派工单
  final List<CommandBarBtnModel> taskCommandBarList = [];

  ///单页显示记录数
  int pageConfigRows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;


  MesWorkCenterSettingController({
    super.progId = -1,
    this.noPermission = false,
    this.permissionInfo = '',
  });

  
  @override
  void onInit() {
    super.onInit();

    //region
    List<dynamic> unVisibleDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_DEP_ID_DISPLAY_KEY) ?? [];
    depIds = unVisibleDepIdList.join(',');

    List<dynamic> unVisibleWorkCenterList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_WORK_CENTER_ID_DISPLAY_KEY) ?? [];
    workCenterIds = unVisibleWorkCenterList.join(',');

    isShowSignFilter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_IS_SHOW_SIGN_FILTER_KEY) ?? AppConfig.isShowSignFilter;
    isSignChipMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_IS_SIGN_CHIP_MULTI_KEY) ?? AppConfig.isSignChipMulti;
    selectedTaskSignBinary = selectedOrderSignBinary = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_SIGN_SELECTED_KEY) ?? AppConfig.binaryForSignSelected;

    isShowDatePicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_IS_SHOW_DATE_PICKER_KEY) ?? AppConfig.isShowDatePicker;
    String datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_DATE_PICKER_VALUE_MAP_KEY) ?? '';
    getDatePickerEnumIndex(datePickerValueStr);

    isShowSearchInputBox = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_IS_SHOW_SEARCH_INPUT_BOX_KEY) ?? AppConfig.isShowSearchInputBox;
    orderSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_ORDER_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;
    taskSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_TASK_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;

    final List<dynamic> orderListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_INFO_FORM_LIST_KEY) ?? [];
    orderListInfoFormListMap.clear();
    orderListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                orderListInfoFormMapList,
                AppConfig.mesOrderListInfoFormList
            )
        )
    );

    final List<dynamic> taskListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_INFO_FORM_LIST_KEY) ?? [];
    taskListInfoFormListMap.clear();
    taskListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                taskListInfoFormMapList,
                AppConfig.mesTaskListInfoFormList
            )
        )
    );

    final List<dynamic> orderCommandBarMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_COMMAND_BAR_LIST_KEY) ?? [];
    orderCommandBarList.clear();
    orderCommandBarList.addAll(
        getCommandBarListByStorage(
            orderCommandBarMapList,
            AppConfig.mesOrderCommandBarList
        )
    );

    final List<dynamic> taskCommandBarMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_COMMAND_BAR_LIST_KEY) ?? [];
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
    await getDepList(isUnVisible: true);
    await getWorkCenterList(isUnVisible: true);
    return true;
  }


  //region OnChanged

  void isShowCategoryOnChanged() {
    isShowCategory = !isShowCategory;
    update();
  }

  void selectedCategorySignOnChanged(int index) {
    selectedCategorySign = index;
    update();
  }

  ///单页显示记录数 点击变化
  void pageConfigRowsOnChanged(int intValue) {
    pageConfigRows = intValue;
    update();
  }

  //endregion


  //region OnSave

  ///车间筛选保存
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
      Get.context!, msg: '确认保存车间筛选数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存数据', completedMsg: '数据刷新成功！');

    //region 数据保存
    List<String> list = [];
    for (var element in depList) {
      if (!element.isChoice){
        list.add(element.departmentId);
      }
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_DEP_ID_DISPLAY_KEY, list);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '车间筛选数据保存成功，正在刷新数据！');

    //region 数据刷新
    mesWorkCenterController.getFilterOfWorkCenterList();
    mesWorkCenterController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///加工中心筛选保存
  Future<void> workCenterSettingSave() async{
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
      Get.context!, msg: '确认保存加工中心筛选数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存数据', completedMsg: '数据刷新成功！');

    //region 数据保存
    List<String> list = [];
    for (var element in workCenterList) {
      if (!element.isChoice){
        list.add(element.id);
      }
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_WORK_CENTER_ID_DISPLAY_KEY, list);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '加工中心筛选数据保存成功，正在刷新数据！');

    //region 数据刷新
    mesWorkCenterController.getFilterOfWorkCenterList();
    mesWorkCenterController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  Future<void> categorySettingSave() async {
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_IS_SHOW_CATEGORY_KEY, isShowCategory);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_CATEGORY_SELECTED_KEY, selectedCategorySign);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '单据类型设置保存成功，正在刷新数据！');

    //region 数据刷新
    mesWorkCenterController.isShowCategory = isShowCategory;
    if (mesWorkCenterController.selectedCategorySign != selectedCategorySign){
      mesWorkCenterController.selectedCategorySign = selectedCategorySign;
      await mesWorkCenterController.categorySaveOnChanged();
      await mesWorkCenterController.pageChanged(showLoading: false);
    }
    mesWorkCenterController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

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
      ///这里只需要判断一个 signList
      List<MoSignModel> selectedList = mesWorkCenterController.orderSignList.where(
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_IS_SHOW_SIGN_FILTER_KEY, isShowSignFilter);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_IS_SIGN_CHIP_MULTI_KEY, isSignChipMulti);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_SIGN_SELECTED_KEY, selectedSignBinary);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '状态标签设置保存成功，正在刷新数据！');

    //region 数据刷新
    mesWorkCenterController.isShowSignFilter = isShowSignFilter;
    mesWorkCenterController.isSignChipMulti = isSignChipMulti;
    if (mesWorkCenterController.selectedSignBinary != selectedSignBinary){
      mesWorkCenterController.selectedTaskSignBinary = mesWorkCenterController.selectedOrderSignBinary = selectedSignBinary;
      mesWorkCenterController.signQueryDataOnChanged();
      await mesWorkCenterController.pageChanged(showLoading: false);
    }
    mesWorkCenterController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_IS_SHOW_DATE_PICKER_KEY, isShowDatePicker);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_DATE_PICKER_VALUE_MAP_KEY, datePickerValueMap.isEmpty ? '' : jsonEncode(datePickerValueMap));
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '日期筛选器设置保存成功，正在刷新数据！');
    
    //region 数据刷新
    mesWorkCenterController.isShowDatePicker = isShowDatePicker;
    if (jsonEncode(mesWorkCenterController.datePickerValueMap) != jsonEncode(datePickerValueMap)){
      mesWorkCenterController.datePickerValueMap = datePickerValueMap;
      mesWorkCenterController.dateQueryDataOnChanged();
      await mesWorkCenterController.pageChanged(showLoading: false);
    }
    mesWorkCenterController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_IS_SHOW_SEARCH_INPUT_BOX_KEY, isShowSearchInputBox);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_ORDER_SEARCH_TYPE_INDEX_KEY, orderSearchTypeIndex);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_TASK_SEARCH_TYPE_INDEX_KEY, taskSearchTypeIndex);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '关键字搜索框设置保存成功，正在刷新数据！');

    //region 数据刷新
    mesWorkCenterController.isShowSearchInputBox = isShowSearchInputBox;
    mesWorkCenterController.orderSearchTypeIndex = orderSearchTypeIndex;
    mesWorkCenterController.taskSearchTypeIndex = taskSearchTypeIndex;
    if (!mesWorkCenterController.isShowSearchInputBox){
      mesWorkCenterController.searchFN.unfocus();
      if (mesWorkCenterController.searchTC.text.isNotEmpty){
        ///当搜索输入框被隐藏，并且输入框中有内容时，清空输入框内容并重新读取翻页数据
        mesWorkCenterController.searchTC.text = '';
        mesWorkCenterController.searchQueryDataOnChanged();
        await mesWorkCenterController.pageChanged(showLoading: false);
      }
    }
    mesWorkCenterController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///任务单列表视图字段显示设置 保存
  Future<void> orderInfoFormSettingSave() async {
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
    orderListInfoFormListMap.forEach((key, value) {
      mapList.addAll(value.map((e) => e.toJson()));
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    mesWorkCenterController.orderListInfoFormListMap.clear();
    mesWorkCenterController.orderListInfoFormListMap.addAll(orderListInfoFormListMap);
    mesWorkCenterController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///派工单列表视图字段显示设置 保存
  Future<void> taskInfoFormSettingSave() async {
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
    mesWorkCenterController.taskListInfoFormListMap.clear();
    mesWorkCenterController.taskListInfoFormListMap.addAll(taskListInfoFormListMap);
    mesWorkCenterController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///任务单按钮组设置 保存
  Future<void> orderCommandBarSettingSave() async {
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
    orderCommandBarList.forEach((element) {
      mapList.add(element.toJson());
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_COMMAND_BAR_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    mesWorkCenterController.orderCommandBarList.clear();
    mesWorkCenterController.orderCommandBarList.addAll(orderCommandBarList);
    mesWorkCenterController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///派工单按钮组设置 保存
  Future<void> taskCommandBarSettingSave() async {
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
    mesWorkCenterController.taskCommandBarList.clear();
    mesWorkCenterController.taskCommandBarList.addAll(taskCommandBarList);
    mesWorkCenterController.update();
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_PAGE_CONFIG_ROWS_KEY, pageConfigRows);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (mesWorkCenterController.orderPageConfig.rows != pageConfigRows){
      mesWorkCenterController.orderPageConfig.rows = pageConfigRows;
      mesWorkCenterController.taskPageConfig.rows = pageConfigRows;
      await mesWorkCenterController.pageChanged(showLoading: false);
    }
    mesWorkCenterController.update();
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