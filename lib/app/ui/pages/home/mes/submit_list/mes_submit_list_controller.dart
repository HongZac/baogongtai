

import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
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
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/process_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/mes_submit_keyword_search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_print_barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/check_record/mes_order_check_record_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/material_reject/mes_order_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/submit/mes_order_submit_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/mes_order_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/check_record/mes_task_check_record_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/material_reject/mes_task_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/submit/mes_task_submit_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/mes_task_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';


///工序 报工单列表
class MesSubmitListController
    extends BaseFormWithPageDataController<MoOpSubmitModel>
    with ProcessFilterInterface,
        DateFilterInterface,
        SearchInterface, MesSubmitKeywordSearchInterface,
        InvClassFrxNameInterface,
        SubmitPrintBarcodeInterface,
        InfoFormInterface,
        CommandBarInterface,
        InterfaceUtil {

  get dateSearchTypeList => List.unmodifiable(AppConfig.mesSubmitDateSearchTypeList);
  get dateSearchQueryDataList => List.unmodifiable(dateSearchTypeList.expand((e) => e.content.split(',')).toSet().toList());

  final String key;
  final String keyName;
  final String invId;
  final bool showAppBar;

  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> submitListInfoFormListMap = {};

  ///报工单列表页面显示的按钮组列表
  final List<CommandBarBtnModel> submitListCommandBarList = [];

  ///报工单列表中选中的报工单
  MoOpSubmitModel selectedSubmitModel = MoOpSubmitModel();

  ///报工单删除时间限制
  int? limitTime;


  MesSubmitListController({
    super.progId = 650041,
    required this.key,
    required this.keyName,
    this.invId = '',
    this.showAppBar = true,
  });


  @override
  void onInit() async {
    super.onInit();

    isShowProcessPicker = (keyName == 'order');

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
      case 'task':
        dateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
        datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_DATE_PICKER_VALUE_MAP_KEY)
            ?? jsonEncode(AppConfig.todayDatePickerValueMap);
        submitListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_INFO_FORM_LIST_KEY) ?? [];
        frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesTaskSubmitPrintFileName;
        invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        limitTime = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
        dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
        dataListPageConfig.queryData!['TaskId'] = key;
        isShowSearchInputBox = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_IS_SHOW_SEARCH_INPUT_BOX_KEY) ?? AppConfig.isShowSearchInputBox;
        mesSubmitSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;
        break;
      case 'order':
        dateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
        datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_DATE_PICKER_VALUE_MAP_KEY)
            ?? jsonEncode(AppConfig.todayDatePickerValueMap);
        submitListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_INFO_FORM_LIST_KEY) ?? [];
        frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesOrderSubmitPrintFileName;
        invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        limitTime = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
        dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
        dataListPageConfig.queryData!['MoOrderId'] = key;
        isShowSearchInputBox = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_IS_SHOW_SEARCH_INPUT_BOX_KEY) ?? AppConfig.isShowSearchInputBox;
        mesSubmitSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;
        break;
      case 'deviceTask': ///设备派工
        dateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
        datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_DATE_PICKER_VALUE_MAP_KEY)
            ?? jsonEncode(AppConfig.todayDatePickerValueMap);
        submitListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_INFO_FORM_LIST_KEY) ?? [];
        frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesTaskSubmitPrintFileName;
        invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        limitTime = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
        dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
        dataListPageConfig.queryData!['DeviceId'] = key;
        isShowSearchInputBox = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_IS_SHOW_SEARCH_INPUT_BOX_KEY) ?? AppConfig.isShowSearchInputBox;
        mesSubmitSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;
        break;
      case 'deviceOrder':
        dateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
        datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_DATE_PICKER_VALUE_MAP_KEY)
            ?? jsonEncode(AppConfig.todayDatePickerValueMap);
        submitListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_INFO_FORM_LIST_KEY) ?? [];
        frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesTaskSubmitPrintFileName;
        invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        limitTime = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
        dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
        dataListPageConfig.queryData!['DeviceId'] = key;
        isShowSearchInputBox = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_IS_SHOW_SEARCH_INPUT_BOX_KEY) ?? AppConfig.isShowSearchInputBox;
        mesSubmitSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;
        break;
      //endregion
    }
    datePickerValueMap = getDatePickerValueMapByStorage(datePickerValueStr);
    dateQueryDataOnChanged();

    submitListInfoFormListMap.clear();
    submitListInfoFormListMap.addAll(
      getInfoFormListMap(
        getInfoFormListByStorage(
          submitListInfoFormMapList,
          AppConfig.mesSubmitListInfoFormList
        )
      )
    );

    submitListCommandBarList.clear();
    submitListCommandBarList.addAll(
       AppConfig.mesSubmitListCommandBarList.map(
               (e) => CommandBarBtnModel.fromJson(e.toJson()))
    );

    invClassFrxNameMap.clear();
    invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));
  }


  @override
  Future<bool> initializeForm() async {
    await super.initializeForm();
    if (keyName == 'order'){
      await getProcessAdapter(moOrderId: key, invId: invId);
    }
    return true;
  }

  
  @override
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
  void submitOnSelected(MoOpSubmitModel item) {
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
    submitOnSelected(item as MoOpSubmitModel);
  }

  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    item as MoOpSubmitModel;
    switch (keyName){
      case '${AppConfig.mesSubmitBtn}-${AppConfig.print}':
        await printBarcode(item);
        break;
      case '${AppConfig.mesSubmitBtn}-${AppConfig.check}':
        await checkSubmit(item);
        break;
      case '${AppConfig.mesSubmitBtn}-${AppConfig.delete}':
        await deleteSubmit(item);
        break;
    }
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
      case 'task': ///生产派工单
      case 'deviceTask': ///设备生产派工单
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
      case 'order': ///生产任务单
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
        barcodeBillCode = orderModel?.billCode ?? '';
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

  ///检验
  Future<void> checkSubmit(MoOpSubmitModel item) async {
    ToastNotification(Get.overlayContext!).warn('功能未完成！');
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
      case 'task': ///首页、报工单页面、报次品页面的报工数、生产数、检验数
        //region 生产派工单
        if ((item.taskId ?? '').isNotEmpty){
          var taskRes = await MoTaskRepository().getFormData(item.taskId!);
          if (!taskRes.isSuccess){
            ToastNotification(Get.overlayContext!).error('获取派工单信息时出错：${taskRes.message}');
            ProgressDialogUtil.close();
            isLoading = false;
            update();
            return;
          }

          //region 首页
          MesTaskController taskController = Get.find<MesTaskController>();
          MoTaskModel? task = taskController.dataList.firstWhereOrNull((element) => element.taskId == item.taskId);
          if (task != null){
            bool isExpanded = task.isExpanded;
            task.fromJson(taskRes.data.toJson());
            task.isExpanded = isExpanded;
          }
          taskController.update();
          //endregion

          //region 报工页
          MesTaskSubmitController? taskSubmitController;
          try {
            taskSubmitController = Get.find<MesTaskSubmitController>();
          } catch (e){}
          if (taskSubmitController != null){
            if (taskSubmitController.taskModel.taskId == item.taskId){
              taskSubmitController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
            }
            taskSubmitController.update();
          }
          //endregion

          //region 报次品页
          MesTaskCheckRecordController? taskCheckRecordController;
          try {
            taskCheckRecordController = Get.find<MesTaskCheckRecordController>();
          } catch (e){}
          if (taskCheckRecordController != null){
            if (taskCheckRecordController.taskModel.taskId == item.taskId){
              taskCheckRecordController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
            }
            taskCheckRecordController.update();
          }
          //endregion

          //region 不良品上报页
          MesTaskMaterialRejectController? taskMaterialRejectController;
          try {
            taskMaterialRejectController = Get.find<MesTaskMaterialRejectController>();
          } catch (e){}
          if (taskMaterialRejectController != null){
            if (taskMaterialRejectController.taskModel.taskId == item.taskId){
              taskMaterialRejectController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
            }
            taskMaterialRejectController.update();
          }
          //endregion
        }
        //endregion
        break;
      case 'order': ///首页、报工单页面、报次品页面的报工数、生产数、检验数 + 报工单页面、报次品页面的工序列表的检验数
        //region 任务单页面
        if ((item.moOrderId ?? '').isNotEmpty) {
          var orderRes = await MoOrderRepository().getFormData(item.moOrderId!);
          if (!orderRes.isSuccess){
            ToastNotification(Get.overlayContext!).error('获取任务单信息时出错：${orderRes.message}');
            ProgressDialogUtil.close();
            isLoading = false;
            update();
            return;
          }

          //region 首页
          MesOrderController orderController = Get.find<MesOrderController>();
          MoOpOrderModel? order = orderController.dataList.firstWhereOrNull((element) => element.moOrderId == item.moOrderId);
          if (order != null){
            bool isExpanded = order.isExpanded;
            order.fromJson(orderRes.data.toJson());
            order.isExpanded = isExpanded;
          }
          orderController.update();
          //endregion

          var refreshProcessAdapter = await AdapterHelper.getAsyncAdapter(
            'process',
            queryData: {
              'wbId': orderRes.data.wbId,
              'invId': orderRes.data.productId,
            },
            isNeedLoadData: true,
          ) as ProcessAdapter;

          //region 报工页
          MesOrderSubmitController? orderSubmitController;
          try {
            orderSubmitController = Get.find<MesOrderSubmitController>();
          } catch (e){}
          if (orderSubmitController != null){
            if (orderSubmitController.orderModel.moOrderId == item.moOrderId){
              await orderSubmitController.processAdapter?.resetData(
                noFilterDataList: refreshProcessAdapter.noFilterDataList,
                postIdList: orderSubmitController.postIdList,
              );
              ///刷新本页面的任务单数据
              orderSubmitController.orderModel = MoOpOrderModel.fromJson(orderRes.data.toJson());
            }
            await orderSubmitController.getOpTGSubmitQty();
            orderSubmitController.update();
          }
          //endregion

          //region 报次品页
          MesOrderCheckRecordController? orderCheckRecordController;
          try {
            orderCheckRecordController = Get.find<MesOrderCheckRecordController>();
          } catch (e){}
          if (orderCheckRecordController != null){
            if (orderCheckRecordController.orderModel.moOrderId == item.moOrderId){
              await orderCheckRecordController.processAdapter?.resetData(
                noFilterDataList: refreshProcessAdapter.noFilterDataList,
                postIdList: orderCheckRecordController.postIdList,
              );
              ///刷新本页面的任务单数据
              orderCheckRecordController.orderModel = MoOpOrderModel.fromJson(orderRes.data.toJson());
            }
            orderCheckRecordController.update();
          }
          //endregion

          //region 不良品上报页
          MesOrderMaterialRejectController? orderMaterialRejectController;
          try {
            orderMaterialRejectController = Get.find<MesOrderMaterialRejectController>();
          } catch (e){}
          if (orderMaterialRejectController != null){
            if (orderMaterialRejectController.orderModel.moOrderId == item.moOrderId){
              await orderMaterialRejectController.processAdapter?.resetData(
                noFilterDataList: refreshProcessAdapter.noFilterDataList,
                postIdList: orderMaterialRejectController.postIdList,
              );
              ///刷新本页面的任务单数据
              orderMaterialRejectController.orderModel = MoOpOrderModel.fromJson(orderRes.data.toJson());
            }
            orderMaterialRejectController.update();
          }
          //endregion
        }
        //endregion
        break;
      case 'deviceTask':
        //region 设备生产派工页面
        if ((item.taskId ?? '').isNotEmpty){
          var taskRes = await MoTaskRepository().getFormData(item.taskId!);
          if (!taskRes.isSuccess){
            ToastNotification(Get.overlayContext!).error('获取派工单信息时出错：${taskRes.message}');
            ProgressDialogUtil.close();
            isLoading = false;
            update();
            return;
          }

          //region 首页
          try {
            ModelWithGetxController<EAMDeviceModel> eamDeviceModelWithGetxController = Get.find<ModelWithGetxController<EAMDeviceModel>>(tag: 'MesDeviceTask-$key');
            if (eamDeviceModelWithGetxController.model.currentTask?.taskId == taskRes.data.taskId){
              eamDeviceModelWithGetxController.model.currentTask!.fromJson(taskRes.data.toJson());
            }
            eamDeviceModelWithGetxController.update();
          } catch (e){}
          //endregion

          //region 报工页
          MesTaskSubmitController? taskSubmitController;
          try {
            taskSubmitController = Get.find<MesTaskSubmitController>();
          } catch (e){}
          if (taskSubmitController != null){
            if (taskSubmitController.taskModel.taskId == item.taskId){
              taskSubmitController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
            }
            taskSubmitController.update();
          }
          //endregion

          //region 报次品页
          MesTaskCheckRecordController? taskCheckRecordController;
          try {
            taskCheckRecordController = Get.find<MesTaskCheckRecordController>();
          } catch (e){}
          if (taskCheckRecordController != null){
            if (taskCheckRecordController.taskModel.taskId == item.taskId){
              taskCheckRecordController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
            }
            taskCheckRecordController.update();
          }
          //endregion

          //region 不良品上报页
          MesTaskMaterialRejectController? taskMaterialRejectController;
          try {
            taskMaterialRejectController = Get.find<MesTaskMaterialRejectController>();
          } catch (e){}
          if (taskMaterialRejectController != null){
            if (taskMaterialRejectController.taskModel.taskId == item.taskId){
              taskMaterialRejectController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
            }
            taskMaterialRejectController.update();
          }
          //endregion
        }
        //endregion
        break;
      case 'deviceOrder':
        //todo
        break;
    }
    //endregion
    isLoading = false;
    selectedSubmitModel = MoOpSubmitModel();
    update();
    ProgressDialogUtil.update(value: 2);
  }

  ///报工单Item“展开按钮”点击变化
  void submitExpandedOnChanged(MoOpSubmitModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }

  //endregion


  //region OnChanged

  @override
  Future<void> processOnChanged(List<PickerDataModel> list) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    String oldProcessId = processId;
    await super.processOnChanged(list);
    if (oldProcessId == processId){
      isLoading = false;
      return;
    }
    processQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void processQueryDataOnChanged() {
    dataListPageConfig.queryData!['WorkBillEntryId'] = processId;
  }

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
      case 'task':
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY, dateSearchTypeIndex);
        break;
      case 'order':
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY, dateSearchTypeIndex);
        break;
      case 'deviceTask': ///设备派工
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY, dateSearchTypeIndex);
        break;
      case 'deviceOrder':
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY, dateSearchTypeIndex);
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
    if (index == mesSubmitSearchTypeIndex){
      isLoading = false;
      return;
    }
    mesSubmitSearchTypeIndex = index;
    switch (keyName){
      //region
      case 'task':
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_SEARCH_TYPE_INDEX_KEY, mesSubmitSearchTypeIndex);
        break;
      case 'order':
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_SEARCH_TYPE_INDEX_KEY, mesSubmitSearchTypeIndex);
        break;
      case 'deviceTask': ///设备派工
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_LIST_SEARCH_TYPE_INDEX_KEY, mesSubmitSearchTypeIndex);
        break;
      //endregion
    }
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
    dataListPageConfig.queryData!.removeWhere((key, value) => mesSubmitSearchQueryDataList.contains(key));
    if (searchTC.text.isNotEmpty){
      String keyWord = mesSubmitSearchTypeList[mesSubmitSearchTypeIndex].content;
      dataListPageConfig.queryData![keyWord] = searchTC.text;
    }
  }

  //endregion


  @override
  void onClose() {
    super.onClose();
  }

}