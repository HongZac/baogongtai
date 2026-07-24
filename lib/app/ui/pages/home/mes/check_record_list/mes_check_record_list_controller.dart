import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/item_model.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_document_type_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_print_barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/process_filter_interface.dart';
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


///工序 次品列表
class MesCheckRecordListController
    extends BaseFormWithPageDataController<MoCheckRecordModel>
    with ProcessFilterInterface,
        DateFilterInterface,
        InvClassFrxNameInterface,
        CheckRecordPrintBarcodeInterface,
        InfoFormInterface,
        CommandBarInterface,
        CheckRecordDocumentTypeFilterInterface,
        InterfaceUtil {

  get dateSearchTypeList => List.unmodifiable(AppConfig.mesCheckRecordDateSearchTypeList);
  get dateSearchQueryDataList => List.unmodifiable(dateSearchTypeList.expand((e) => e.content.split(',')).toSet().toList());

  final String key;
  final String keyName;
  final String invId;
  final bool showAppBar;

  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> checkRecordListInfoFormListMap = {};

  ///派工单列表页面显示的按钮组列表
  final List<CommandBarBtnModel> checkRecordListCommandBarList = [];

  ///次品单列表中选中的次品记录
  MoCheckRecordModel selectedCheckRecordModel = MoCheckRecordModel();

  ///报工单删除时间限制
  int? limitTime;

  ///不良品上报 系统对象
  EditFormItem materialRejectObjectItem = EditFormItem();

  @override
  EditFormItem get objectItem => checkRecordDocumentTypeIndex == 0
      ? super.objectItem
      : checkRecordDocumentTypeIndex == 1
      ? materialRejectObjectItem
      : EditFormItem();


  MesCheckRecordListController({
     super.progId = 811010,
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
    dataListPageConfig.queryData = {};
    dateSearchTypeIndex = AppConfig.dateSearchTypeIndex;
    String datePickerValueStr = '';
    List<dynamic> checkRecordListInfoFormMapList = [];
    String invClassFrxNameMapStr = '';
    String invClassFrxNameMapMRStr = '';
    switch (keyName){
      //region
      case 'task':
        dateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
        datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_DATE_PICKER_VALUE_MAP_KEY)
            ?? jsonEncode(AppConfig.todayDatePickerValueMap);
        checkRecordListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_INFO_FORM_LIST_KEY) ?? [];
        frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesTaskCheckRecordPrintFileName;
        frxNameMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_MATERIAL_REJECT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesTaskMaterialRejectPrintFileName;
        invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        invClassFrxNameMapMRStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_MATERIAL_REJECT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        limitTime = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
        dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
        dataListPageConfig.queryData?['TaskId'] = key;
        checkRecordDocumentTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_CR_DOCUMENT_TYPE_INDEX_KEY) ?? AppConfig.checkRecordDocumentTypeIndex;
        break;
      case 'order':
        dateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
        datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_DATE_PICKER_VALUE_MAP_KEY)
            ?? jsonEncode(AppConfig.todayDatePickerValueMap);
        checkRecordListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_INFO_FORM_LIST_KEY) ?? [];
        frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesOrderCheckRecordPrintFileName;
        frxNameMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesOrderMaterialRejectPrintFileName;
        invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        invClassFrxNameMapMRStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        limitTime = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
        dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
        dataListPageConfig.queryData?['MoOrderId'] = key;
        checkRecordDocumentTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_CR_DOCUMENT_TYPE_INDEX_KEY) ?? AppConfig.checkRecordDocumentTypeIndex;
        break;
      case 'deviceTask':
        dateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
        datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_DATE_PICKER_VALUE_MAP_KEY)
            ?? jsonEncode(AppConfig.todayDatePickerValueMap);
        checkRecordListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_INFO_FORM_LIST_KEY) ?? [];
        frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesTaskCheckRecordPrintFileName;
        frxNameMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_MATERIAL_REJECT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesTaskMaterialRejectPrintFileName;
        invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        invClassFrxNameMapMRStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_MATERIAL_REJECT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        limitTime = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
        dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
        dataListPageConfig.queryData?['DeviceId'] = key;
        checkRecordDocumentTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_CR_DOCUMENT_TYPE_INDEX_KEY) ?? AppConfig.checkRecordDocumentTypeIndex;
        break;
      case 'deviceOrder':
        dateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
        datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_DATE_PICKER_VALUE_MAP_KEY)
            ?? jsonEncode(AppConfig.todayDatePickerValueMap);
        checkRecordListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_INFO_FORM_LIST_KEY) ?? [];
        frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesTaskCheckRecordPrintFileName;
        frxNameMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesOrderMaterialRejectPrintFileName;
        invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        invClassFrxNameMapMRStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
        limitTime = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
        dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
        dataListPageConfig.queryData?['DeviceId'] = key;
        checkRecordDocumentTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_CR_DOCUMENT_TYPE_INDEX_KEY) ?? AppConfig.checkRecordDocumentTypeIndex;
        break;
      //endregion
    }
    datePickerValueMap = getDatePickerValueMapByStorage(datePickerValueStr);
    dateQueryDataOnChanged();

    checkRecordListInfoFormListMap.clear();
    checkRecordListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                checkRecordListInfoFormMapList,
                AppConfig.mesCheckRecordListInfoFormList
            )
        )
    );

    checkRecordListCommandBarList.clear();
    checkRecordListCommandBarList.addAll(
        AppConfig.mesCheckRecordListCommandBarList.map(
                (e) => CommandBarBtnModel.fromJson(e.toJson()))
    );

    invClassFrxNameMap.clear();
    invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));

    invClassFrxNameMapMR.clear();
    invClassFrxNameMapMR.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapMRStr));
  }

  @override
  Future<bool> initializeForm() async {
    await getMaterialRejectObjectItem();
    dataListPageConfig.queryData!.addAll({
      'progid': objectItem.progid ?? progId,
    });
    await super.initializeForm();
    if (keyName == 'order'){
      await getProcessAdapter(moOrderId: key, invId: invId);
    }
    return true;
  }

  ///获取系统对象
  Future<void> getMaterialRejectObjectItem() async {
    var orderRes = await FormRepository().getFormSystem(811013);
    if (!orderRes.isSuccess) {
      ToastNotification(Get.overlayContext!).error('获取 811013 系统对象时出错：${orderRes.message}');
      return;
    }
    materialRejectObjectItem = orderRes.data;
  }


  Future<PageResult<MoCheckRecordModel>> getDataList(PageConfig pageConfig) async{
    selectedCheckRecordModel = MoCheckRecordModel();
    PageConfig pg = PageConfig.fromJson(pageConfig.toJson());
    if (pg.queryData!['progid'] == 811013){
      ///查询材料不良记录时，不需要筛选设备
      pg.queryData!.remove('DeviceId');
    }
    var res = await MoCheckRecordRepository().getPageList(pg);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取次品记录单列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }

  
  //region OnTap

  ///次品记录选中变变化
  Future<void> checkRecordOnSelected(MoCheckRecordModel item) async{
    if (selectedCheckRecordModel.moRecordId == item.moRecordId){
      selectedCheckRecordModel = MoCheckRecordModel();
    }
    else {
      selectedCheckRecordModel = item;
    }
    update();
  }

  @override
  Future<void> infoItemOnTap(ICloneable item) async{
    await checkRecordOnSelected(item as MoCheckRecordModel);
  }

  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    item as MoCheckRecordModel;
    switch (keyName){
      case '${AppConfig.mesCheckRecordBtn}-${AppConfig.print}':
        await printBarcode(item);
        break;
      case '${AppConfig.mesCheckRecordBtn}-${AppConfig.delete}':
        await deleteCheckRecord(item);
        break;
    }
  }

  ///删除次记录
  Future<void> deleteCheckRecord(MoCheckRecordModel item) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (item.moRecordId.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择要删除的次品记录！");
      isLoading = false;
      return;
    }
    if (item.createDate != null && limitTime != null
        && item.createDate!.add(Duration(seconds: limitTime!)).isBefore(DateTime.now())){
      ToastNotification(Get.overlayContext!).warn("该次品记录的提交时间已超过$limitTime秒，不能删除！");
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认删除次品记录？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在删除报工单', completedMsg: '数据刷新成功！');
    //region 次品记录删除
    var res = await MoCheckRecordRepository().deleteForm(item.moRecordId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('删除失败！${res.message}！');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '删除成功，正在刷新数据！');
    //endregion
    //region 数据刷新
    dataList.removeWhere((element) => element.moRecordId == item.moRecordId);
    total --;
    switch (keyName){
      case 'task': ///首页、报工单页面、报次品页面的次品数
        //region 生产派工单
        if ((item.taskId ?? '').isNotEmpty){
          var taskRes = await MoTaskRepository().getFormData(item.taskId!);
          if (!taskRes.isSuccess){
            ToastNotification(Get.overlayContext!).error('获取派工单信息失败！${taskRes.message}');
            ProgressDialogUtil.close();
            isLoading = false;
            update();
            return;
          }
          MoTaskModel taskModel = taskRes.data;

          //region 首页
          MesTaskController taskController = Get.find<MesTaskController>();
          MoTaskModel? task = taskController.dataList.firstWhereOrNull((element) => element.taskId == item.taskId);
          if (task != null){
            task.disabledQty = taskModel.disabledQty;
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
              taskSubmitController.taskModel.disabledQty = taskModel.disabledQty;
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
              taskCheckRecordController.taskModel.disabledQty = taskModel.disabledQty;
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
              taskMaterialRejectController.taskModel.disabledQty = taskModel.disabledQty;
            }
            taskMaterialRejectController.update();
          }
          //endregion
        }
        //endregion
        break;
      case 'order': ///首页、报工单页面、报次品页面的次品数  报工单页面、报次品页面的工序列表的次品数
        //region 任务单页面
        if ((item.moOrderId ?? '').isNotEmpty){
          var orderRes = await MoOrderRepository().getFormData(item.moOrderId!);
          if (!orderRes.isSuccess){
            ToastNotification(Get.overlayContext!).error('获取任务单信息失败！${orderRes.message}');
            ProgressDialogUtil.close();
            isLoading = false;
            update();
            return;
          }
          MoOpOrderModel orderModel = orderRes.data;

          //region 首页
          MesOrderController? orderController = Get.find<MesOrderController>();
          MoOpOrderModel? order = orderController.dataList.firstWhereOrNull((element) => element.moOrderId == item.moOrderId);
          if (order != null){
            bool isExpanded = order.isExpanded;
            order.fromJson(orderModel.toJson());
            order.isExpanded = isExpanded;
          }
          orderController.update();
          //endregion

          var refreshProcessAdapter = await AdapterHelper.getAsyncAdapter(
            'process',
            queryData: {
              'wbId': orderModel.wbId,
              'invId': orderModel.productId,
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
              orderSubmitController.orderModel = orderModel;
            }
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
              orderCheckRecordController.orderModel = orderModel;
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
              orderMaterialRejectController.orderModel = orderModel;
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
            ToastNotification(Get.overlayContext!).error('获取派工单信息失败！${taskRes.message}');
            ProgressDialogUtil.close();
            isLoading = false;
            update();
            return;
          }
          MoTaskModel taskModel = taskRes.data;

          //region 首页
          ModelWithGetxController<EAMDeviceModel> eamDeviceModelWithGetxController = Get.find<ModelWithGetxController<EAMDeviceModel>>(tag: 'MesDeviceTask-$key');
          if (eamDeviceModelWithGetxController.model.currentTask?.taskId == taskRes.data.taskId){
            eamDeviceModelWithGetxController.model.currentTask!.fromJson(taskRes.data.toJson());
          }
          eamDeviceModelWithGetxController.update();
          //endregion

          //region 报工页
          MesTaskSubmitController? taskSubmitController;
          try {
            taskSubmitController = Get.find<MesTaskSubmitController>();
          } catch (e){}
          if (taskSubmitController != null){
            if (taskSubmitController.taskModel.taskId == item.taskId){
              taskSubmitController.taskModel.disabledQty = taskModel.disabledQty;
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
              taskCheckRecordController.taskModel.disabledQty = taskModel.disabledQty;
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
              taskMaterialRejectController.taskModel.disabledQty = taskModel.disabledQty;
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
    selectedCheckRecordModel = MoCheckRecordModel();
    update();
    ProgressDialogUtil.update(value: 2);
  }

  ///条码补打
  Future<void> printBarcode(MoCheckRecordModel item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 权限权限
    if (dataService.isEnableOperatePrivilege && objectItem.buttons?['print'] == null){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? '【${objectItem.progid}】【print】' : ''}！');
      isLoading = false;
      return;
    }
    //endregion
    //region 提交前判断
    if (item.moRecordId.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择要补打的次品记录！");
      isLoading = false;
      return;
    }

    String frxName = '';
    Map<String, String> invClassFrxNameMap = {};
    if (item.progID == 811010){
      frxName = this.frxName;
      invClassFrxNameMap = this.invClassFrxNameMap;
    }
    else if (item.progID == 811013){
      frxName = this.frxNameMR;
      invClassFrxNameMap = this.invClassFrxNameMapMR;
    }

    frxName = this.frxName; //todo 次品记录中没有产品类别编码
    //frxName = invClassFrxNameMap[item.invCCode ?? ''] ?? this.frxName;
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
    ///查找该次品记录的条码列表
    PageConfig barcodeMainPageConfig = PageConfig(
        page: 1,
        rows: 999,
        sidx: 'Numerical',
        sord: 'asc',
        queryData: {
          ///PreProgID 一定是 650041 651051
          'preId': item.moRecordId
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
    Map<bool, String> printRes = await printCheckRecordBarcode(
      moRecordId: item.moRecordId,
      printerUrl: printerUrl,
      printerName: printerName,
      printCopies: printCopies,
      printType: printType,
      taskModel: taskModel,
      orderModel: orderModel,
      billCode: barcodeBillCode,
      barcodeMainList: barcodeMainList,
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


  ///次品记录Item“展开按钮”点击变化
  void checkRecordExpandedOnChanged(MoCheckRecordModel item){
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
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_DATE_SEARCH_TYPE_INDEX_KEY, dateSearchTypeIndex);
        break;
      case 'order':
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_DATE_SEARCH_TYPE_INDEX_KEY, dateSearchTypeIndex);
        break;
      case 'deviceTask':
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_DATE_SEARCH_TYPE_INDEX_KEY, dateSearchTypeIndex);
        break;
      case 'deviceOrder':
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_DATE_SEARCH_TYPE_INDEX_KEY, dateSearchTypeIndex);
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

  Future<void> checkRecordDocumentTypeIndexOnChanged(int index) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (checkRecordDocumentTypeIndex == index){
      isLoading = false;
      return;
    }
    checkRecordDocumentTypeIndex = index;
    switch (keyName){
      //region
      case 'task':
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_CR_DOCUMENT_TYPE_INDEX_KEY, checkRecordDocumentTypeIndex);
        break;
      case 'order':
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_CR_DOCUMENT_TYPE_INDEX_KEY, checkRecordDocumentTypeIndex);
        break;
      case 'deviceTask':
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_LIST_CR_DOCUMENT_TYPE_INDEX_KEY, checkRecordDocumentTypeIndex);
        break;
      case 'deviceOrder':
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_CR_DOCUMENT_TYPE_INDEX_KEY, checkRecordDocumentTypeIndex);
        break;
      //endregion
    }
    cRDocumentTypeQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void cRDocumentTypeQueryDataOnChanged() {
    dataListPageConfig.queryData!['progid'] = objectItem.progid;
  }


  //endregion


  @override
  void onClose() {
    super.onClose();
  }

}