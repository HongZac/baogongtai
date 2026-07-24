import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/pmes_submit_keyword_search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_print_barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/check_record/device_check_record_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/detail/device_detail_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/detail_board_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/submit/device_submit_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';


///注塑 报工单列表
class PMesSubmitListController 
    extends BaseFormWithPageDataController<MoOpSubmitModel> 
    with DateFilterInterface,
        SearchInterface, PMesSubmitKeywordSearchInterface,
        InvClassFrxNameInterface,
        SubmitPrintBarcodeInterface,
        InfoFormInterface,
        CommandBarInterface, 
        InterfaceUtil {

  get dateSearchTypeList => List.unmodifiable(AppConfig.pMesSubmitDateSearchTypeList);
  get dateSearchQueryDataList => List.unmodifiable(dateSearchTypeList.expand((e) => e.content.split(',')).toSet().toList());

  final String key;
  final String keyName;
  final bool showAppBar;

  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> pMesSubmitListInfoFormListMap = {};

  ///报工单列表页面显示的按钮组列表
  final List<CommandBarBtnModel> pMesSubmitListCommandBarList = [];

  ///报工单列表中选中的报工单
  MoOpSubmitModel selectedSubmitModel = MoOpSubmitModel();

  ///报工单删除时间限制
  int? limitTime = AppConfig.limitTime;


  PMesSubmitListController({
    super.progId = 651051,
    required this.key,
    required this.keyName,
    this.showAppBar = true,
  });


  @override
  void onInit() {
    super.onInit();
    
    dataListPageConfig.sidx = 'CreateDate';
    dataListPageConfig.queryData = {
      'Progid': progId,
    };

    dateSearchTypeIndex = AppConfig.dateSearchTypeIndex;
    String datePickerValueStr = '';
    List<dynamic> submitListInfoFormMapList = [];
    String invClassFrxNameMapStr = '';
    switch (keyName){
      //region
      case 'deviceTask': ///设备实时监控
        dateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
        datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_SUBMIT_LIST_DATE_PICKER_VALUE_MAP_KEY)
            ?? jsonEncode(AppConfig.todayDatePickerValueMap);
        submitListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_SUBMIT_LIST_INFO_FORM_LIST_KEY) ?? [];
        frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_TEMPLATE_FILENAME_KEY) ?? AppConfig.deviceSubmitPrintFileName;
        invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        limitTime = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_DELETE_LIMIT_TIME) ?? AppConfig.limitTime;
        dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_SUBMIT_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
        dataListPageConfig.queryData!['DeviceId'] = key;
        isShowSearchInputBox = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_TASK_SUBMIT_LIST_IS_SHOW_SEARCH_INPUT_BOX_KEY) ?? AppConfig.isShowSearchInputBox;
        pMesSubmitSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_TASK_SUBMIT_LIST_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;
        break;
      //endregion
    }
    datePickerValueMap = getDatePickerValueMapByStorage(datePickerValueStr);
    dateQueryDataOnChanged();

    pMesSubmitListInfoFormListMap.clear();
    pMesSubmitListInfoFormListMap.addAll(
      getInfoFormListMap(
        getInfoFormListByStorage(
          submitListInfoFormMapList,
          AppConfig.pMesSubmitListInfoFormList
        )
      )
    );

    pMesSubmitListCommandBarList.clear();
    pMesSubmitListCommandBarList.addAll(
        AppConfig.pMesSubmitListCommandBarList.map(
                (e) => CommandBarBtnModel.fromJson(e.toJson()))
    );

    invClassFrxNameMap.clear();
    invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));
  }


  ///获取报工单列表
  Future<PageResult<MoOpSubmitModel>> getDataList(PageConfig pageConfig) async{
    selectedSubmitModel = MoOpSubmitModel();
    var res = await MoOpSubmitRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取报工单列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }


  //region OnTap

  ///报工单选中变变化
  Future<void> submitOnSelected(MoOpSubmitModel item) async{
    if (selectedSubmitModel.moOpSubmitId == item.moOpSubmitId){
      selectedSubmitModel = MoOpSubmitModel();
    }
    else {
      selectedSubmitModel = item;
    }
    update();
  }

  @override
  Future<void> infoItemOnTap(ICloneable item) async{
    await submitOnSelected(item as MoOpSubmitModel);
  }

  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    item as MoOpSubmitModel;
    switch (keyName){
      case '${AppConfig.pMesSubmitBtn}-${AppConfig.print}':
        await printBarcode(item);
        break;
      case '${AppConfig.pMesSubmitBtn}-${AppConfig.delete}':
        await deleteSubmit(item);
        break;
    }
  }

  ///报工单删除
  Future<void> deleteSubmit(MoOpSubmitModel item) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if ((item.moOpSubmitId ?? '').isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择要删除的报工单！");
      isLoading = false;
      return;
    }
    if (item.createDate != null && limitTime != null
        && item.createDate!.add(Duration(seconds: limitTime!)).isBefore(DateTime.now())){
      ToastNotification(Get.overlayContext!).warn("该报工单的提交时间已超过$limitTime秒，不能删除！");
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认删除报工记录？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在删除报工记录', completedMsg: '数据刷新成功！');
    //region 报工单删除
    var res = await MoOpSubmitRepository().deleteForm(item.moOpSubmitId!);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('删除报工记录时出错：${res.message}！');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '删除成功，正在刷新数据！');
    //endregion
    //region 数据刷新
    dataList.removeWhere((element) => element.moOpSubmitId == item.moOpSubmitId);
    total --;
    switch (keyName){
      case 'deviceTask': ///首页、详情页、报工单页面、报次品页面的报工数、生产数、检验数 + 详情页的列表
        //region 设备实时监控

        //region 首页
        ModelWithGetxController<MoDeviceTaskModel> deviceTaskModelWithGetxController = Get.find<ModelWithGetxController<MoDeviceTaskModel>>(tag: 'PMesDevice-$key');
        if (deviceTaskModelWithGetxController.model.taskId == item.taskId){
          deviceTaskModelWithGetxController.model.submitQty = (deviceTaskModelWithGetxController.model.submitQty ?? 0) - (item.qty ?? 0);
          deviceTaskModelWithGetxController.update();
        }
        //endregion

        DeviceDetailBoardController? deviceDetailBoardController;
        try {
          deviceDetailBoardController = Get.find<DeviceDetailBoardController>();
        } catch (e){}
        if (deviceDetailBoardController != null){

          //region DeviceDetailController 详情页
          DeviceDetailController? deviceDetailController;
          try {
            deviceDetailController = Get.find<DeviceDetailController>();
          } catch (e){}
          if (deviceDetailController != null){
            if (deviceDetailController.taskModel.taskId == item.taskId){
              deviceDetailController.taskModel.submitQty = (deviceDetailController.taskModel.submitQty ?? 0) - (item.qty ?? 0);
              deviceDetailController.taskModel.acceptQty = (deviceDetailController.taskModel.acceptQty ?? 0) - (item.acceptQty ?? 0);
            }
            for (var element in deviceDetailController.taskList) {
              if (element.taskId == item.taskId){
                element.submitQty = (element.submitQty ?? 0) - (item.qty ?? 0);
                element.acceptQty = (element.acceptQty ?? 0) - (item.acceptQty ?? 0);
                break;
              }
            }
            deviceDetailController.update();
          }
          //endregion

          //region SubmitController 报工页
          DeviceSubmitController? deviceSubmitController;
          try {
            deviceSubmitController = Get.find<DeviceSubmitController>();
          } catch (e){}
          if (deviceSubmitController != null){
            if (deviceSubmitController.taskModel.taskId == item.taskId){
              deviceSubmitController.taskModel.submitQty = (deviceSubmitController.taskModel.submitQty ?? 0) - (item.qty ?? 0);
              deviceSubmitController.taskModel.acceptQty = (deviceSubmitController.taskModel.acceptQty ?? 0) - (item.acceptQty ?? 0);
            }
            MoTaskModel? taskAdapterItem = deviceSubmitController.taskAdapter?.dataList.firstWhereOrNull(
                    (element) => element.taskId == item.taskId);
            if (taskAdapterItem != null){
              taskAdapterItem.submitQty = (taskAdapterItem.submitQty ?? 0) - (item.qty ?? 0);
              taskAdapterItem.acceptQty = (taskAdapterItem.acceptQty ?? 0) - (item.acceptQty ?? 0);
            }
            deviceSubmitController.update();
          }
          //endregion

          //region DeviceCheckRecordController 报次品页
          DeviceCheckRecordController? deviceCheckRecordController;
          try {
            deviceCheckRecordController = Get.find<DeviceCheckRecordController>();
          } catch (e){}
          if (deviceCheckRecordController != null){
            if (deviceCheckRecordController.taskModel.taskId == item.taskId){
              deviceCheckRecordController.taskModel.submitQty = (deviceCheckRecordController.taskModel.submitQty ?? 0) - (item.qty ?? 0);
              deviceCheckRecordController.taskModel.acceptQty = (deviceCheckRecordController.taskModel.acceptQty ?? 0) - (item.acceptQty ?? 0);
            }
            MoTaskModel? taskAdapterItem = deviceCheckRecordController.taskAdapter?.dataList.firstWhereOrNull(
                    (element) => element.taskId == item.taskId);
            if (taskAdapterItem != null){
              taskAdapterItem.submitQty = (taskAdapterItem.submitQty ?? 0) - (item.qty ?? 0);
              taskAdapterItem.acceptQty = (taskAdapterItem.acceptQty ?? 0) - (item.acceptQty ?? 0);
            }
            deviceCheckRecordController.update();
          }
          //endregion

        }
        //endregion
        break;
      default:
        ToastNotification(Get.overlayContext!).error('请完善代码');
        ProgressDialogUtil.close();
        isLoading = false;
        return;
    }
    //endregion
    isLoading = false;
    selectedSubmitModel = MoOpSubmitModel();
    update();
    ProgressDialogUtil.update(value: 2);
  }

  ///条码补打
  Future<void> printBarcode(MoOpSubmitModel item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 提交前判断
    if ((item.moOpSubmitId ?? '').isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择要补打的报工单！");
      isLoading = false;
      return;
    }
    String frxName = invClassFrxNameMap[item.invCCode ?? ''] ?? this.frxName;
    if (frxName.isEmpty){
      ToastNotification(Get.overlayContext!).error('打印的模板名称为空，请在设置中修改！');
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
    MoTaskModel? taskModel;
    MoOpOrderModel? orderModel;
    String? barcodeBillCode;
    List<BarcodeMainModel>? barcodeMainList;
    //region 获取条码列表 [barcodeMainList]
    ///查找该报工单的条码列表
    PageConfig barcodeMainPageConfig = PageConfig(
        page: 1,
        rows: 999,
        sidx: 'Numerical',
        sord: 'asc',
        queryData: {
          ///PreProgID 一定是 650041 651051
          'preId': item.moOpSubmitId
        }
    );
    var barCodeRes = await BarcodeMainRepository().getPageList(barcodeMainPageConfig);
    if (!barCodeRes.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取条码列表时出错：${barCodeRes.message}');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    if (barCodeRes.rows.isNotEmpty){
      barcodeMainList = [];
      barcodeMainList.addAll(barCodeRes.rows);
    }
    //endregion
    //region 获取源单数据源 [taskModel]、[orderModel]
    switch (keyName){
      case 'deviceTask':
        if ((item.taskId ?? '').isNotEmpty){
          var taskRes = await MoTaskRepository().getFormData(item.taskId!);
          if (!taskRes.isSuccess){
            ToastNotification(Get.overlayContext!).error('获取派工单数据时出错：${taskRes.message}！');
            ProgressDialogUtil.close();
            isLoading = false;
            return;
          }
          taskModel = taskRes.data;
        }
        if ((item.moOrderId ?? '').isNotEmpty){
          var orderRes = await MoOrderRepository().getFormData(item.moOrderId!);
          if (!orderRes.isSuccess){
            ToastNotification(Get.overlayContext!).error('获取任务单数据时出错：${orderRes.message}！');
            ProgressDialogUtil.close();
            isLoading = false;
            return;
          }
          orderModel = orderRes.data;
        }
        barcodeBillCode = taskModel?.taskCode ?? '';
        break;
      default:
        ToastNotification(Get.overlayContext!).error('请完善代码');
        ProgressDialogUtil.close();
        isLoading = false;
        return;
    }
    //endregion
    Map<bool, String> printRes = await printSubmitBarcode(
      moOpSubmitId: item.moOpSubmitId!, //res.data.data,
      printerUrl: printerUrl,
      printerName: printerName,
      printCopies: printCopies,
      printType: printType,
      taskModel: taskModel,
      orderModel: orderModel,
      billCode: barcodeBillCode,
      barcodeMainList: barcodeMainList,
      submitType: AppConfig.qtySubmit,
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

  ///报工单Item“展开按钮”点击变化
  void submitExpandedOnChanged(MoOpSubmitModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }

  ///附件查看
  Future<void> getAttach(MoOpSubmitModel item) async{
    if (item.moOpSubmitId == null || item.moOpSubmitId!.isEmpty){
      ToastNotification(Get.overlayContext!).warn('错误数据！');
      return;
    }
    else if (item.attach == null || item.attach == 0){
      ToastNotification(Get.overlayContext!).warn('该报工单没有附件！');
      return;
    }
    String page = '';
    switch (keyName){
      //region
      case 'deviceTask': ///设备实时监控
        page = showAppBar ? AppRoutes.PMES_REAL_TIME_MONITOR_SUBMIT_LIST_ATTACH_PAGE : AppRoutes.PMES_REAL_TIME_MONITOR_DETAIL_ATTACH_PAGE;
        break;
      default:
        ToastNotification(Get.overlayContext!).error('请完善代码');
        return;
      //endregion
    }
    Get.rootDelegate.toNamed(
        page,
        parameters: {
          'pageTitle': '报工单附件-${item.billCode ?? ''}',
          'id': item.moOpSubmitId!,
          'progId': progId.toString(),
          'category': 'attach',
        }
    );
  }

  //endregion


  //region OnChanged

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
    switch (keyName){
      //region
      case 'deviceTask': ///设备实时监控
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY, dateSearchTypeIndex);
        break;
      //endregion
    }
    dateQueryDataOnChanged();
    if (startDate != null && endDate != null){
      await pageChanged();
    }
    update();
    isLoading = false;
  }

  @override
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
    if (index == pMesSubmitSearchTypeIndex){
      isLoading = false;
      return;
    }
    pMesSubmitSearchTypeIndex = index;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_TASK_SUBMIT_LIST_SEARCH_TYPE_INDEX_KEY, pMesSubmitSearchTypeIndex);
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
    dataListPageConfig.queryData!.removeWhere((key, value) => pMesSubmitSearchQueryDataList.contains(key));
    if (searchTC.text.isNotEmpty){
      String keyWord = pMesSubmitSearchTypeList[pMesSubmitSearchTypeIndex].content;
      dataListPageConfig.queryData![keyWord] = searchTC.text;
    }
  }

  //endregion


  @override
  void onClose() {
    ///示例
    /*if (showAppBar){
      try {
        MesAssemblyController assemblyController = Get.find<MesAssemblyController>();
        assemblyController.isScanGunCanListen = true;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
          mesTaskController.update();
        });
      } catch (e){}
      try {
        MesTaskController taskController = Get.find<MesTaskController>();
        taskController.isScanGunCanListen = true;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
          mesTaskController.update();
        });
      } catch (e){}
    }*/
    super.onClose();
  }

}