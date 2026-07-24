import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_barcode_interface/inv_barcode_print_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///物料条码新增查看 条码列表页面 230004
class InvBarcodeListController
    extends BaseFormWithPageDataController<BarcodeMainModel>
    with DateFilterInterface,
        SearchInterface,
        InvClassFrxNameInterface,
        InvBarcodePrintInterface,
        InfoFormInterface,
        CommandBarInterface,
        InterfaceUtil {

  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> invBarcodeListInfoFormListMap = {};

  ///按钮组列表
  final List<CommandBarBtnModel> invBarcodeListCommandBarList = [
    CommandBarBtnModel(
      title: '全选',
      keyName: '${AppConfig.invBarcodeListBtn}-${AppConfig.invBarcodeListBtn}',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: null,
    ),
    CommandBarBtnModel(
      title: '全不选',
      keyName: '${AppConfig.invBarcodeListBtn}-${AppConfig.deSelectAll}',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: null,
    ),
    CommandBarBtnModel(
      title: '条码打印',
      icon: Icons.local_print_shop_rounded,
      keyName: '${AppConfig.invBarcodeListBtn}-${AppConfig.print}',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'print',
    ),
    CommandBarBtnModel(
      title: '删除',
      icon: FluentIcons.delete_24_filled,
      keyName: '${AppConfig.invBarcodeListBtn}-${AppConfig.delete}',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btndelete',
    ),
  ];

  get searchTypeList => List.unmodifiable(AppConfig.invBarcodeSearchTypeList);
  get searchQueryDataList => List.unmodifiable(searchTypeList.map((e) => e.content).toSet().toList());

  get dateSearchTypeList => List.unmodifiable(AppConfig.invBarcodeDateSearchTypeList);
  get dateSearchQueryDataList => List.unmodifiable(dateSearchTypeList.expand((e) => e.content.split(',')).toSet().toList());

  ///要查看条码记录的产品信息 初始值：上一个页面选中的派工单
  InventoryModel inventoryModel = InventoryModel();

  ///可删除时间限制
  int? limitTime = AppConfig.limitTime;

  final bool showAppBar;


  InvBarcodeListController({
    super.progId = 230004,
    required InventoryModel inventoryModel,
    this.showAppBar = true,
  }){
    this.inventoryModel = inventoryModel;
  }


  @override
  void onInit() {
    super.onInit();

    dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
    dataListPageConfig.sidx = 'Numerical';
    dataListPageConfig.sord = 'asc';
    dataListPageConfig.queryData = {
      'Progid': progId,
      'InvID': inventoryModel.invID,
    };

    //region
    dateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_LIST_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
    String datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_LIST_DATE_PICKER_VALUE_MAP_KEY)
        ?? jsonEncode(AppConfig.todayDatePickerValueMap);
    datePickerValueMap = getDatePickerValueMapByStorage(datePickerValueStr);
    dataListPageConfig.queryData!['StartTime'] = '${DateUtil.getDateStrByDateTime(startDate,
        format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
    dataListPageConfig.queryData!['EndTime'] = '${DateUtil.getDateStrByDateTime(endDate,
        format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 23:59:59';


    List<dynamic> invBarcodeListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_LIST_INFO_FORM_LIST_KEY) ?? [];
    invBarcodeListInfoFormListMap.clear();
    invBarcodeListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                invBarcodeListInfoFormMapList,
                AppConfig.invBarcodeListInfoFormList
            )
        )
    );

    frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_TEMPLATE_FILENAME_KEY) ?? AppConfig.invBarcodePrintFileName;
    String invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMap.clear();
    invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));
    limitTime = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
    //endregion

    dateQueryDataOnChanged();
  }


  @override
  Future<PageResult<BarcodeMainModel>> getDataList(PageConfig pageConfig) async{
    var res = await BarcodeMainRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取条码列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }


  //region date

  @override
  Future<void> dateSearchTypeOnChanged(ChoiceChipModel item, int index) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (index == dateSearchTypeIndex){
      isLoading = false;
      return;
    }
    dateSearchTypeIndex = index;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_LIST_DATE_SEARCH_TYPE_INDEX_KEY, dateSearchTypeIndex);
    dateQueryDataOnChanged();
    if (startDate != null && endDate != null){
      await pageChanged();
    }
    update();
    isLoading = false;
  }

  Future<void> dateOnChanged(String string) async {
    DateTime? oldStartDate = startDate;
    DateTime? oldEndDate = endDate;
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    await super.dateOnChanged(string);
    if (oldStartDate == startDate && oldEndDate == endDate){
      isLoading = false;
      return;
    }
    dateQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void dateQueryDataOnChanged() {
    dataListPageConfig.queryData!.removeWhere((key, value) => dateSearchQueryDataList.contains(key));
    if (startDate != null && endDate != null){
      String keyWord = dateSearchTypeList[dateSearchTypeIndex].content;
      List<String> keywordList = keyWord.split(',');
      if (keywordList.length == 2){
        dataListPageConfig.queryData![keywordList[0]] = startDateStrWithNoTime;
        dataListPageConfig.queryData![keywordList[1]] = endDateStrWithNoTime;
      }
    }
  }

  //endregion

  
  //region 搜索

  @override
  Future<void> searchTypeOnChanged(ChoiceChipModel item, int index) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (index == searchTypeIndex){
      isLoading = false;
      return;
    }
    searchTypeIndex = index;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_LIST_SEARCH_TYPE_INDEX_KEY, searchTypeIndex);
    searchQueryDataOnChanged();
    if (searchTC.text.isNotEmpty){
      await pageChanged();
    }
    update();
    isLoading = false;
  }

  @override
  void searchTCOnChanged() {
    searchQueryDataOnChanged();
    update();
  }

  @override
  Future<void> onSearch() async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchFN.unfocus();
    searchQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }

  @override
  Future<void> searchTCOnClear() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchFN.unfocus();
    searchTC.text = '';
    searchQueryDataOnChanged();
    await pageChanged();
    isSearchWidgetOpen = false;
    update();
    isLoading = false;
  }

  void searchQueryDataOnChanged() {
    dataListPageConfig.queryData!.removeWhere((key, value) => searchQueryDataList.contains(key));
    if (searchTC.text.isNotEmpty){
      String keyWord = searchTypeList[searchTypeIndex].content;
      dataListPageConfig.queryData![keyWord] = searchTC.text;
    }
  }

  //endregion


  void itemChanged(BarcodeMainModel item) async{
    item.isChoice = !item.isChoice;
    update();
  }

  @override
  Future<void> infoItemOnTap(ICloneable item) async{
    item as BarcodeMainModel;
    itemChanged(item);
  }

  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    switch (keyName){
      case '${AppConfig.invBarcodeListBtn}-${AppConfig.selectAll}':
        dataList.forEach((element) {
          element.isChoice = true;
        });
        update();
        break;
      case '${AppConfig.invBarcodeListBtn}-${AppConfig.deSelectAll}':
        dataList.forEach((element) {
          element.isChoice = false;
        });
        update();
        break;
      case '${AppConfig.invBarcodeListBtn}-${AppConfig.print}':
        await printBarcode();
        break;
    }
  }

  ///条码打印
  Future<void> printBarcode() async{
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 提交前判断
    List<BarcodeMainModel> selectDataList = dataList.where((element) => element.isChoice).toList();
    if (selectDataList.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择要补打的条码！");
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认补打条码？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    Map<String, dynamic> printInfoMap = await getPrintInfo();
    String printerUrl = printInfoMap['printerUrl']!; ///打印机Url
    String printerName = printInfoMap['printerName']!; ///打印机Name
    int printCopies = printInfoMap['printCopies']!; ///打印份数
    String printType = printInfoMap['printType']!; ///打印方式
    ProgressDialogUtil.showProgressDialog(msg: '正在打印', completedMsg: '打印成功！');
    Map<bool, String> printRes = await printInvBarcode(
      printerUrl: printerUrl,
      printerName: printerName,
      printCopies: printCopies,
      printType: printType,
      barcodeMainList: selectDataList,
      invCCode: inventoryModel.invCCode ?? '',
    );
    if (printRes.containsKey(true)) {
      ProgressDialogUtil.update();
      ToastNotification(Get.overlayContext!).info(printRes[true]!);
    }
    else {
      ToastNotification(Get.overlayContext!).error(printRes[false] ?? '');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }

    isLoading = false;
  }


  @override
  void onClose() {
    super.onClose();
  }


}