
import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/serial_com_service/mixin/serial_port_getx_listener.dart';
import 'package:desktop/app/service/serial_com_service/serial_port_data_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_print_barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/mes_check_record_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/mes_task_check_record_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/check_record_list/mes_check_record_list_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/detail/device_detail/mes_device_task_detail_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/detail_tab/mes_task_detail_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/material_reject/mes_task_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/submit/mes_task_submit_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/mes_task_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/mes_work_center_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/submit_list/mes_submit_list_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产派工单 报次品页面
class MesTaskCheckRecordController
    extends BaseFormController
    with InfoFormInterface,
        SerialPortGetXListenerMixin<MesTaskCheckRecordController>, ScanInterface<MesTaskCheckRecordController>,
        InvClassFrxNameInterface,
        CheckRecordPrintBarcodeInterface,
        CheckRecordInterface, MesCheckRecordInterface, MesTaskCheckRecordInterface,
        InterfaceUtil {

  late final MesTaskDetailTabController mesTaskDetailTabController;

  ///0：生产派工； 1：设备派工； 2：加工中心派工
  ///
  /// == 1 时，不能选择设备
  final int taskOpenType;
  ///上一个页面选中的加工中心（设备派工）
  final String deviceId;
  ///上一个页面选中的加工中心（加工中心派工）
  final String workCenterId;
  ///设备对应生产派工单的对应机台数据
  late final ModelWithGetxController<EAMDeviceModel>? eamDeviceModelWithGetxController = deviceId.isNotEmpty
      ? Get.find<ModelWithGetxController<EAMDeviceModel>>(tag: 'MesDeviceTask-$deviceId')
      : null;

  ///派工单表单页面-数据字段列表
  final List<InfoFormModel> taskInfoFormList = [];

  @override
  final List<NumPadController> numPadCTList = [
    NumPadController(key: NumPadUtil.qty),
  ];

  final bool showAppBar;

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;


  MesTaskCheckRecordController({
    super.progId = 811010,
    super.isShowProgressDialogInOnReady = true,
    required MoTaskModel taskModel,
    this.taskOpenType = 0,
    this.deviceId = '',
    this.workCenterId = '',
    this.showAppBar = true,
    this.noPermission = false,
    this.permissionInfo = '',
  }){
    this.taskModel = taskModel;
  }


  @override
  void onInit() {
    super.onInit();

    if (this is! MesTaskMaterialRejectController){
      List<dynamic> taskInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_INFO_FORM_LIST_KEY) ?? [];
      taskInfoFormList.clear();
      taskInfoFormList.addAll(
          getInfoFormListByStorage(
              taskInfoFormMapList,
              AppConfig.mesTaskInfoFormList
          )
      );

      checkRecordBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_BTN_INDEX_KEY) ?? AppConfig.checkRecordBtnIndex;
      isShowMakeUpBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
      isGetBackAfterCommitSuccess = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
      isShowDataReportTypeBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
      checkRecordType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_TYPE_KEY) ?? AppConfig.qtyCheckRecord;
      String formTitleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_FORM_TITLE_MAP_KEY) ?? '';
      formTitleMap.clear();
      formTitleMap.addAll(getFormTitleMapByStorage(formTitleMapStr, AppConfig.mesTaskCheckRecordFormTitleMap));
      numPadCTList.sort((a, b){
        return numPadCTListSortVoidCallback.call(formTitleMap, a, b);
      });
      String formStyleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_FORM_STYLE_MAP_KEY) ?? '';
      formStyleMap.clear();
      formStyleMap.addAll(getFormStyleMapByStorage(formStyleMapStr, AppConfig.mesTaskCheckRecordFormStyleMap));
      numPadCTList.forEach((element) {
        element.styleMap.clear();
        if (formStyleMap.containsKey(element.key)){
          element.styleMap.addAll(formStyleMap[element.key]!);
        }
      });
      numPadFocusField = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
      formRowMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_FORM_ROW_MAX_COUNT_LIMIT_KEY) ?? AppConfig.formRowMaxCountLimit;
      depGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
      wcDataReportType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_WC_DATA_REPORT_TYPE_KEY) ?? AppConfig.wcDataReportType;
      isPsnHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
      isPsnMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
      psnGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
      psnDepCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
      psnLineCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
      frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesTaskCheckRecordPrintFileName;
      String invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
      invClassFrxNameMap.clear();
      invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));
      isDeviceHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_IS_DEVICE_HAS_ADAPTER_KEY) ?? AppConfig.isDeviceHasAdapter;
      deviceDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_DEVICE_DEP_ID_LIST_KEY) ?? [];
      deviceClassIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_DEVICE_CLASS_ID_LIST_KEY) ?? [];
      isSaveTheLastSelectedPsnId = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_CHECK_RECORD_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
        if (!showAppBar){
          mesTaskDetailTabController = Get.find<MesTaskDetailTabController>();
        }
      });
      numPadCTListSetEnabled();
    }
  }

  @override
  Future<bool> initializeForm() async {
    if (taskOpenType == 1){
      ///如果[taskOpenType] == 1，根据[eamDeviceModel.objectId]获取任务单
      await getCurrentTask(deviceId);
    }
    setFormJudgeTypeMap();
    setWeightFormDecimalLengthMap();
    setCheckRecordDataAndAdapter(
      isInit: true,
      progId: progId,
      deviceId: eamDeviceModelWithGetxController?.model.deviceId,
      deviceCode: eamDeviceModelWithGetxController?.model.deviceCode,
      deviceName: eamDeviceModelWithGetxController?.model.deviceName,
    );
    getInventoryInfo(taskModel.invId ?? '').then((value) {
      update();
    });
    getTaskAdapter(deviceId: deviceId).then((value){
      update();
    });

    ///写入历史选中的员工数据
    if (isSaveTheLastSelectedPsnId){
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        ///需要等待 personAdapter 被赋值后，再写入历史员工数据
        if (!isPsnHasAdapter || personAdapter != null){
          await setTheLastSelectedPsnData(
            ShareStorageUtil.instance?.read(
                this is! MesTaskMaterialRejectController
                    ? SharedPreferencesKeys.MES_TASK_CHECK_RECORD_THE_LAST_SELECTED_PSN_LIST_KEY
                    : SharedPreferencesKeys.MES_TASK_MATERIAL_REJECT_THE_LAST_SELECTED_PSN_LIST_KEY
            ) ?? []
          );
          return false;
        }
        return true;
      });
    }

    return true;
  }

  ///获取当前设备正在生产的派工单
  Future<bool> getCurrentTask(String deviceId) async {
    if (deviceId.isNotEmpty){
      PageConfig pageConfig = PageConfig(
          page: 1, rows: 1,
          queryData: {
            'progid': 650011,
            'DeviceId': deviceId,
            'GESign': MoTaskSign.scz.sign,
            'LTSign': MoTaskSign.ysc.sign,
          }
      );
      var res = await MoTaskRepository().getPageList(pageConfig);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取当前设备正在生产的派工单时出错：${res.message}！');
        return false;
      }
      if (res.rows.isNotEmpty){
        taskModel = res.rows[0];
      }
      return true;
    }
    ToastNotification(Get.overlayContext!).error('获取当前设备正在生产的派工单时出错：找不到设备信息！');
    return false;
  }


  //region OnTap

  ///查看工序图纸
  Future<void> getOpSop(MoTaskModel item) async{
    ProgressDialogUtil.showProgressDialog(msg: '正在获取工序数据', completedMsg: '工序数据获取成功！',);
    ///产品id对应的工艺路线列表
    final List<MoRoutingEntryModel> routingByInvIdList = [];
    var res = await MoRoutingRepository().getRoutingByInvId(item.invId ?? '');
    if (res.isSuccess && res.data.entryList.isNotEmpty){
      routingByInvIdList.addAll(res.data.entryList);
    }
    MoRoutingEntryModel? routingEntryModel = routingByInvIdList.firstWhereOrNull((element) => element.opId == item.opId);
    if (routingEntryModel == null || routingEntryModel.routingDId.isEmpty){
      ToastNotification(Get.overlayContext!).warn('无法获取工序图纸！');
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update();
    await ProgressDialogUtil.awaitCompletionDelay();

    Get.rootDelegate.toNamed(
        taskOpenType == 0
            ? AppRoutes.MES_TASK_DETAIL_ATTACH_PAGE
            : taskOpenType == 1
            ? AppRoutes.MES_DEVICE_TASK_DETAIL_ATTACH_PAGE
            : taskOpenType == 2
            ? AppRoutes.MES_WORK_CENTER_TASK_DETAIL_ATTACH_PAGE
            : '',
        parameters: {
          'pageTitle': '工序图纸-${item.opName}',
          'id': routingEntryModel.routingDId,
          'progId': '660011',
          'category': 'sop',
        }
    );
  }

  ///查看产品附件
  Future<void> itemInvAttach(MoTaskModel item) async{
    if (item.invId == null || item.invId!.isEmpty){
      ToastNotification(Get.overlayContext!).error('该派工单没有产品！');
      return;
    }
    Get.rootDelegate.toNamed(
        taskOpenType == 0
            ? AppRoutes.MES_TASK_DETAIL_ATTACH_PAGE
            : taskOpenType == 1
            ? AppRoutes.MES_DEVICE_TASK_DETAIL_ATTACH_PAGE
            : taskOpenType == 2
            ? AppRoutes.MES_WORK_CENTER_TASK_DETAIL_ATTACH_PAGE
            : '',
        parameters: {
          'pageTitle': '产品附件-${item.invName}',
          'id': item.invId!,
          'progId': '200025',
          'category': 'attach',
        }
    );
  }

  //endregion


  //region OnChanged

  @override
  void checkRecordTypeOnChanged(ChoiceChipModel item) {
    if (checkRecordType == item.keyName){ return; }
    super.checkRecordTypeOnChanged(item);
    ShareStorageUtil.instance?.write(
        this is! MesTaskMaterialRejectController
            ? SharedPreferencesKeys.MES_TASK_CHECK_RECORD_TYPE_KEY
            : SharedPreferencesKeys.MES_TASK_MATERIAL_REJECT_TYPE_KEY,
        checkRecordType
    );
    update();
  }

  @override
  Future<void> psnOnChanged(List<PickerDataModel> list) async{
    await super.psnOnChanged(list);
    ShareStorageUtil.instance?.write(
        this is! MesTaskMaterialRejectController
            ? SharedPreferencesKeys.MES_TASK_CHECK_RECORD_THE_LAST_SELECTED_PSN_LIST_KEY
            : SharedPreferencesKeys.MES_TASK_MATERIAL_REJECT_THE_LAST_SELECTED_PSN_LIST_KEY,
        list.map((e) => e.toJson()).toList()
    );
  }

  @override
  Future<void> taskOnChanged(PickerDataModel model) async {
    MoTaskModel item = MoTaskModel.fromJson(model.toJson());
    await getOtherTask(item);
    update();
  }

  ///切换当派工单（通过扫码、其他页面切换）
  Future<void> getOtherTask(MoTaskModel item, {bool isOtherPageNeedChanged = true, InventoryModel? inventoryModel}) async{
    assert((isOtherPageNeedChanged && inventoryModel == null) || ((!isOtherPageNeedChanged && inventoryModel != null)));
    if (taskModel.taskId == item.taskId){
      return;
    }
    taskModel = item;
    await setCheckRecordDataAndAdapter(
      isInit: false,
      deviceId: eamDeviceModelWithGetxController?.model.deviceId,
      deviceCode: eamDeviceModelWithGetxController?.model.deviceCode,
      deviceName: eamDeviceModelWithGetxController?.model.deviceName,
    );
    if (inventoryModel == null){
      await getInventoryInfo(taskModel.invId ?? '');
    }
    else {
      this.inventoryModel = inventoryModel;
    }
    if (isOtherPageNeedChanged){
      if (!showAppBar){
        mesTaskDetailTabController.taskModel = MoTaskModel.fromJson(taskModel.toJson());
        mesTaskDetailTabController.key = taskModel.taskId;
      }

      //region 不良品上报页面/次品页面的派工单数据也改变
      if (this is! MesTaskMaterialRejectController){
        MesTaskMaterialRejectController? materialRejectController;
        try{
          materialRejectController = Get.find<MesTaskMaterialRejectController>();
        } catch (e){}
        if (materialRejectController != null){
          await materialRejectController.getOtherTask(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel);
          materialRejectController.update();
        }
      }
      else {
        MesTaskCheckRecordController? mesTaskCheckRecordController;
        try{
          mesTaskCheckRecordController = Get.find<MesTaskCheckRecordController>();
        } catch (e){}
        if (mesTaskCheckRecordController != null){
          await mesTaskCheckRecordController.getOtherTask(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel);
          mesTaskCheckRecordController.update();
        }
      }
      //endregion

      //region 刷新次品记录列表的数据
      MesCheckRecordListController? checkRecordListController;
      try {
        checkRecordListController = Get.find<MesCheckRecordListController>();
      } catch (e){}
      if (checkRecordListController != null){
        checkRecordListController.dataListPageConfig.queryData!['TaskId'] = item.taskId;
        await checkRecordListController.pageChanged(showLoading: false);
        checkRecordListController.update();
      }
      //endregion

      //region 报工页面的派工单数据也改变
      MesTaskSubmitController? taskSubmitController;
      try {
        taskSubmitController = Get.find<MesTaskSubmitController>();
      } catch (e){}
      if (taskSubmitController != null){
        await taskSubmitController.getOtherTask(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel);
        taskSubmitController.update();
      }
      //endregion

      //region 刷新报工单列表的数据
      MesSubmitListController? submitListController;
      try {
        submitListController = Get.find<MesSubmitListController>();
      } catch (e){}
      if (submitListController != null){
        submitListController.dataListPageConfig.queryData!['TaskId'] = item.taskId;
        await submitListController.pageChanged(showLoading: false);
        submitListController.update();
      }
      //endregion
    }
  }

  //endregion


  //region NumPad SetEnabled

  @override
  void numPadCTListSetEnabled() {  }

  @override
  void calcQty(String keyName) {  }

  //endregion


  //region 串口、扫码

  @override
  Future<void> onSerialPortData(SerialPortDataModel serialPortDataModel) async {
    for (var element in weightMsgConnectService.connectList){
      if (element.com == serialPortDataModel.com){
        portMsgOnData(
          element.key,
          data: serialPortDataModel.data,
          accuracy: element.accuracy,
        );
      }
    }
  }

  void portMsgOnData(String key, {
    required dynamic data,
    bool isWeightMsgReverseOrder = false,
    double accuracy = 0,
  }){
    switch (key){
      case WeightMsgConnectService.scanGun:
      case WeightMsgConnectService.cardReader:
        onBarcode(data);
        break;
    }
  }

  @override
  Future<void> onBarcode(String searchString) async{
    if (kDebugMode){
      //searchString = '|F|650011|86656667-2641-4760-91d8-f97d8bc56bf8';
      //searchString = '|F|650011|f3b4e0e9-2bbf-4482-95d3-9385626db024';
    }
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (searchString.isEmpty){
      ToastNotification(Get.overlayContext!).warn('条码为空！');
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(msg: '正在返回扫描结果');

    searchString = getBarCodePrefix(searchString, objectItem.attributeList);
    List<String> list = searchString.split('|');
    if (list.length < 3){
      TipsUtils.showTip(
        msg: '条码错误，请检查设置的默认条码格式！',
        toastType: ToastType.warn,
      );
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    switch (list[1]){
      case 'T':
        //region 工序条码 610001
        if (list.length == 4){
          if (list[2] == '610001'){
            if (taskModel.moOpId == list[3]){
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            ///获取指定工序明细ID的派工单
            var taskRes = await MoTaskRepository().getPageList(PageConfig(
              page: 1, rows: 1,
              queryData: {
                'progid': 650011,
                'ExtOpFlag': 0, ///ExtOpFlag=0 去除委外
                'MoOpId': list[3],
              }
            ));
            if (!taskRes.isSuccess){
              TipsUtils.showTip(
                msg: '获取生产派工单时出错：${taskRes.message}',
                toastType: ToastType.error,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (taskRes.rows.isEmpty){
              TipsUtils.showTip(
                msg: '未查询到派工单！',
                toastType: ToastType.error,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (taskOpenType == 1 && taskRes.rows[0].deviceId != deviceId){
              TipsUtils.showTip(
                msg: '该派工单未派工到指定设备！',
                toastType: ToastType.error,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            await getOtherTask(taskRes.rows[0]);
          }
          else {
            TipsUtils.showTip(
              msg: '条码错误！',
              toastType: ToastType.warn,
            );
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
        }
        else {
          TipsUtils.showTip(
            msg: '条码错误！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        //endregion
        break;
      case 'F':
        //region 生产派工单条码 650011
        if (list.length == 4){
          if (list[2] == '650011'){
            if (taskModel.taskId == list[3]){
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            var taskRes = await MoTaskRepository().getFormData(list[3]);
            if (!taskRes.isSuccess){
              TipsUtils.showTip(
                msg: '获取生产派工单时出错：${taskRes.message}',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (taskRes.data.taskId.isEmpty){
              TipsUtils.showTip(
                msg: '未查询到派工单信息！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (taskOpenType == 1 && taskRes.data.deviceId != deviceId){
              TipsUtils.showTip(
                msg: '该派工单未派工到指定设备！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            await getOtherTask(taskRes.data);
          }
          else {
            TipsUtils.showTip(
              msg: '条码错误！',
              toastType: ToastType.warn,
            );
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
        }
        else {
          TipsUtils.showTip(
            msg: '条码错误！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        //endregion
        break;
      case 'IP':
        //region 员工卡号
        if (wcDataReportType == 2){
          TipsUtils.showTip(
            msg: '当前报工方式不需要选择员工！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        String idCode = list[2];
        var psnRes = await PersonRepository().getFormData('', '', {'IdCode': idCode}, 0);
        if (!psnRes.isSuccess){
          TipsUtils.showTip(
            msg: '获取员工数据时出错：${psnRes.message}！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (psnRes.data.id.isEmpty){
          TipsUtils.showTip(
            msg: '查询不到该员工！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if ((checkRecordModel.empId ?? '').split(',').contains(psnRes.data.id)){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (isPsnHasAdapter){
          List<PersonModel> list = [];
          if (isPsnMulti){
            list = personAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
          }
          list.add(psnRes.data);
          await personAdapter?.validViewValue(list);
          await psnOnChanged(list);
        }
        else {
          if (!isPsnMulti){
            personList.clear();
          }
          personList.add(psnRes.data);
          await psnOnChanged(personList);
        }
        //endregion
        break;
      case 'G':
        //region 员工条码
        if (wcDataReportType == 2){
          TipsUtils.showTip(
            msg: '当前报工方式不需要选择员工！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        String psnNum = list[2];
        var psnRes = await PersonRepository().getFormData('', '', {'PsnNum': psnNum}, 0);
        if (!psnRes.isSuccess){
          TipsUtils.showTip(
            msg: '获取员工数据时出错：${psnRes.message}！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (psnRes.data.id.isEmpty){
          TipsUtils.showTip(
            msg: '查询不到该员工！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if ((checkRecordModel.empId ?? '').split(',').contains(psnRes.data.id)){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (isPsnHasAdapter){
          List<PersonModel> list = [];
          if (isPsnMulti){
            list = personAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
          }
          list.add(psnRes.data);
          await personAdapter?.validViewValue(list);
          await psnOnChanged(list);
        }
        else {
          if (!isPsnMulti){
            personList.clear();
          }
          personList.add(psnRes.data);
          await psnOnChanged(personList);
        }
        //endregion
        break;
      case 'E':
        //region 设备条码
        if (this is MesTaskMaterialRejectController){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (taskOpenType == 1){
          TipsUtils.showTip(
            msg: '当前报工方式不能选择设备！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (wcDataReportType == 0){
          TipsUtils.showTip(
            msg: '当前报工方式不需要选择设备！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        String deviceInfo = list[2]; ///该值可能是 code，也可能是 id
        if (checkRecordModel.deviceId == deviceInfo || checkRecordModel.deviceCode == deviceInfo){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        EAMDeviceModel eamDeviceModel = EAMDeviceModel();
        var deviceCodeRes = await EAMDeviceRepository().getList({'DeviceCode': deviceInfo});
        if (!deviceCodeRes.isSuccess){
          TipsUtils.showTip(
            msg: '获取设备数据时出错：${deviceCodeRes.message}！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (deviceCodeRes.data.isEmpty){
          var deviceIdRes = await EAMDeviceRepository().getModel(deviceInfo);
          if (!deviceIdRes.isSuccess){
            TipsUtils.showTip(
              msg: '获取设备数据时出错：${deviceIdRes.message}！',
              toastType: ToastType.warn,
            );
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
          if (deviceIdRes.data.id.isEmpty){
            TipsUtils.showTip(
              msg: '查询不到该设备！',
              toastType: ToastType.warn,
            );
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
          eamDeviceModel = deviceIdRes.data;
        }
        else {
          eamDeviceModel = deviceCodeRes.data[0];
        }
        if (isDeviceHasAdapter){
          await deviceAdapter?.validViewValue([eamDeviceModel]);
        }
        else {
          deviceModel = eamDeviceModel;
        }
        deviceOnChanged(eamDeviceModel);
        //endregion
        break;
      case 'L':
        //region 产线、加工中心、班组
        if (this is MesTaskMaterialRejectController){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        String lineCode = list[2];
        var wcRes = await MoBeltLineRepository().getFormData('', '', {'LineCode': lineCode}, 0);
        if (!wcRes.isSuccess){
          TipsUtils.showTip(
            msg: '获取生产产线数据时出错：${wcRes.message}！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (wcRes.data.id.isEmpty){
          TipsUtils.showTip(
            msg: '查询不到该生产产线！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (wcRes.data.lineClass != wcDataReportType){
          TipsUtils.showTip(
            msg: '产线类型错误！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (wcRes.data.id == checkRecordModel.wcId){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        switch (wcDataReportType){
          //region
          case 0: ///产线
            MoBeltLineModel model = MoBeltLineModel.fromJson(wcRes.data.toJson());
            await lineAdapter?.validViewValue([model]);
            await lineOnChanged(model);
            break;
          case 1: ///加工中心
            MoWorkCenterModel model = MoWorkCenterModel.fromJson(wcRes.data.toJson());
            await workCenterAdapter?.validViewValue([model]);
            await workCenterOnChanged(model);
            break;
          case 2: ///生产班组
            MoBeltLineModel model = MoBeltLineModel.fromJson(wcRes.data.toJson());
            await teamGroupAdapter?.validViewValue([model]);
            await teamGroupOnChanged(model);
            break;
          //endregion
        }
        //endregion
        break;
      default:
        TipsUtils.showTip(
          msg: '条码错误！',
          toastType: ToastType.warn,
        );
        isLoading = false;
        ProgressDialogUtil.close();
        return;
    }

    isLoading = false;
    update();
    ProgressDialogUtil.update(value: 1);
  }

  //endregion


  @override
  Future<void> saveCheckRecord(bool isPrint) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    Map<bool, String> checkMap = checkRecordCheck(
      isPrint: isPrint,
      invCCode: taskModel.invCCode,
    );
    if (checkMap.containsKey(false)){
      ToastNotification(Get.overlayContext!).error(checkMap[false]!);
      isLoading = false;
      return;
    }
    var dialogRes = await checkRecordSaveConfirmationDialog(isPrint);
    if (!dialogRes){
      isLoading = false;
      return;
    }
    String printerUrl = ''; ///打印机Url
    String printerName = ''; ///打印机Name
    int printCopies = 0; ///打印份数
    String printType = ''; ///打印方式
    if (isPrint){
      Map<String, dynamic> printInfoMap = await getPrintInfo();
      printerUrl = printInfoMap['printerUrl']!;
      printerName = printInfoMap['printerName']!;
      printCopies = printInfoMap['printCopies']!;
      printType = printInfoMap['printType']!;
    }
    ProgressDialogUtil.showProgressDialog(
      max: isPrint ? 3 : 2,
      msg: '正在提交次品记录',
      completedMsg: isPrint ? '打印成功！' : '数据刷新成功！',
    );
    //region 提交次品记录
    setCheckRecordDataBeforeSave();
    var res = await MoCheckRecordRepository().saveVoucher('', checkRecordModel);
    if (!res.isSuccess){
      TipsUtils.showTip(
        msg: '报工记录提交失败！${res.message}！',
        toastType: ToastType.error,
      );
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '次品记录提交成功，正在刷新数据！');
    //endregion
    //region 刷新页面 首页、本页面、报次品页面的报工数、检验数 + 报工单列表 + 重置submitModel的人员、数量、原因 + 重置原因列表
    var taskRes = await MoTaskRepository().getFormData(checkRecordModel.taskId!);
    if (!taskRes.isSuccess){
      ToastNotification(Get.overlayContext!).warn("派工单数据刷新失败！");
    }
    else {
      taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
    }
    MoTaskModel? taskAdapterItem = taskAdapter?.dataList.firstWhereOrNull(
            (element) => element.taskId == checkRecordModel.taskId);
    if (taskAdapterItem != null){
      taskAdapterItem.disabledQty = taskRes.data.disabledQty;
    }
    //region 首页
    if (taskOpenType == 0){
      try {
        MesTaskController taskController = Get.find<MesTaskController>();
        MoTaskModel? task = taskController.dataList.firstWhereOrNull((element) => element.taskId == checkRecordModel.taskId);
        if (task != null){
          bool isExpanded = task.isExpanded;
          task.fromJson(taskModel.toJson());
          task.isExpanded = isExpanded;
        }
        taskController.update();
      } catch (e){}
    }
    else if (taskOpenType == 1){
      if (eamDeviceModelWithGetxController?.model.currentTask?.taskId == checkRecordModel.taskId){
        eamDeviceModelWithGetxController?.model.currentTask!.fromJson(taskModel.toJson());
        eamDeviceModelWithGetxController?.update();
      }
    }
    else if (taskOpenType == 2){
      try {
        MesWorkCenterController mesWorkCenterController = Get.find<MesWorkCenterController>();
        MoTaskModel? task = mesWorkCenterController.taskList.firstWhereOrNull((element) => element.taskId == checkRecordModel.taskId);
        if (task != null){
          bool isExpanded = task.isExpanded;
          task.fromJson(taskModel.toJson());
          task.isExpanded = isExpanded;
        }
        mesWorkCenterController.update();
      } catch (e){}
    }
    //endregion
    //region 详情页
    if (taskOpenType == 1){
      MesDeviceTaskDetailController mesDeviceTaskDetailController = Get.find<MesDeviceTaskDetailController>();
      if (mesDeviceTaskDetailController.taskModel.taskId == checkRecordModel.taskId){
        mesDeviceTaskDetailController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
      }
      MoTaskModel? _taskModel = mesDeviceTaskDetailController.taskList.firstWhereOrNull((element) => element.taskId == checkRecordModel.taskId);
      if (_taskModel != null){
        _taskModel.disabledQty = taskRes.data.disabledQty;
      }
      mesDeviceTaskDetailController.update();
    }
    //endregion
    //region 报工页面
    MesTaskSubmitController? taskSubmitController;
    try {
      taskSubmitController = Get.find<MesTaskSubmitController>();
    } catch (e){}
    if (taskSubmitController != null){
      if (taskSubmitController.taskModel.taskId == checkRecordModel.taskId){
        taskSubmitController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
      }
      MoTaskModel? taskAdapterItem = taskSubmitController.taskAdapter?.dataList.firstWhereOrNull(
              (element) => element.taskId == checkRecordModel.taskId);
      if (taskAdapterItem != null){
        taskAdapterItem.disabledQty = taskRes.data.disabledQty;
      }
      taskSubmitController.update();
    }
    //endregion
    //region 不良品上报/次品页面
    if (this is! MesTaskMaterialRejectController) {
      MesTaskMaterialRejectController? mesTaskMaterialRejectController;
      try {
        mesTaskMaterialRejectController = Get.find<MesTaskMaterialRejectController>();
      } catch (e){}
      if (mesTaskMaterialRejectController != null){
        if (mesTaskMaterialRejectController.taskModel.taskId == checkRecordModel.taskId){
          mesTaskMaterialRejectController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
        }
        MoTaskModel? taskAdapterItem = mesTaskMaterialRejectController.taskAdapter?.dataList.firstWhereOrNull(
                (element) => element.taskId == checkRecordModel.taskId);
        if (taskAdapterItem != null){
          taskAdapterItem.disabledQty = taskRes.data.disabledQty;
        }
        mesTaskMaterialRejectController.update();
      }
    }
    else {
      MesTaskCheckRecordController? mesTaskCheckRecordController;
      try {
        mesTaskCheckRecordController = Get.find<MesTaskCheckRecordController>();
      } catch (e){}
      if (mesTaskCheckRecordController != null){
        if (mesTaskCheckRecordController.taskModel.taskId == checkRecordModel.taskId){
          mesTaskCheckRecordController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
        }
        MoTaskModel? taskAdapterItem = mesTaskCheckRecordController.taskAdapter?.dataList.firstWhereOrNull(
                (element) => element.taskId == checkRecordModel.taskId);
        if (taskAdapterItem != null){
          taskAdapterItem.disabledQty = taskRes.data.disabledQty;
        }
        mesTaskCheckRecordController.update();
      }
    }
    //endregion
    //region 次品列表
    MesCheckRecordListController? checkRecordListController;
    try {
      checkRecordListController = Get.find<MesCheckRecordListController>();
    } catch (e){}
    if (checkRecordListController != null){
      await checkRecordListController.pageChanged(showLoading: false);
      checkRecordListController.update();
    }
    //endregion
    ///刷新报次品填报区域的数据
    await resetCheckRecordDataAfterSave();
    update();
    ProgressDialogUtil.update(value: 2, msg: '${isPrint ? '数据刷新成功，正在打印！' : null}');
    //endregion
    //region 打印
    if (isPrint){
      EAMDeviceModel? eamDeviceModel;
      if ((checkRecordModel.deviceId ?? '').isNotEmpty){
        var deviceRes = await EAMDeviceRepository().getModel(checkRecordModel.deviceId!);
        if (!deviceRes.isSuccess){
          ToastNotification(Get.overlayContext!).error("设备数据获取失败：${deviceRes.message}！");
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        eamDeviceModel = deviceRes.data;
      }
      MoOpOrderModel? orderModel;
      if ((taskRes.data.moOrderId ?? '').isNotEmpty){
        var orderRes = await MoOrderRepository().getFormData(taskRes.data.moOrderId!);
        if (!orderRes.isSuccess){
          ToastNotification(Get.overlayContext!).warn("任务单数据刷新失败！");
        }
        else {
          orderModel = MoOpOrderModel.fromJson(orderRes.data.toJson());
        }
      }
      Map<bool, String> printRes = await printCheckRecordBarcode(
        moRecordId: res.data.data,
        printerUrl: printerUrl,
        printerName: printerName,
        printCopies: printCopies,
        printType: printType,
        taskModel: taskModel,
        orderModel: orderModel,
        billCode: taskModel.taskCode ?? '',
        deviceAddCode: eamDeviceModel?.deviceAddCode ?? '',
        invMnemCode: inventoryModel.invMnemCode ?? '',
      );
      if (printRes.containsKey(true)) {
        ProgressDialogUtil.update(value: 3);
        ToastNotification(Get.overlayContext!).info(printRes[true]!);
      }
      else {
        TipsUtils.showTip(
          msg: printRes[false] ?? '',
          toastType: ToastType.error,
        );
        ProgressDialogUtil.close();
        isLoading = false;
        return;
      }
    }
    //endregion
    //region 如果提交成功，直接返回到首页
    if (res.isSuccess && isGetBackAfterCommitSuccess){
      await ProgressDialogUtil.awaitCompletionDelay();
      await Future.doWhile(() async{
        await Get.rootDelegate.popRoute();
        var page = Get.rootDelegate.history.last;
        if (page.currentPage?.binding == null){
          return true;
        }
        return false;
      });
    }
    //endregion
    isLoading = false;
  }


  @override
  Widget dataReportAreaWidget(BuildContext context){
    List<Widget> itemWidgetList = [];
    Map<String, Widget> itemAreaWidgetMap = {};
    itemAreaWidgetMap.addAll({
      if (isMakeUp)
        AppConfig.productDateForm: productDateReportItem(context),
      AppConfig.depForm: depReportItem(context),
      AppConfig.teamForm: teamReportItem(context),
      if (wcDataReportType == 0)
        AppConfig.lineForm: lineReportItem(context)
      else if (wcDataReportType == 1)
        AppConfig.workCenterForm: workCenterReportItem(context)
      else if (wcDataReportType == 2)
        AppConfig.teamGroupForm: teamGroupReportItem(context),
      if (wcDataReportType != 0 && taskOpenType != 1)
        AppConfig.deviceForm: deviceReportItem(context),
      if (wcDataReportType != 2)
        AppConfig.personForm: personReportItem(context),
      if (checkRecordModel.disposeFlow == 7)
        AppConfig.reProcessForm: reProcessReportItem(context),

      NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
    });
    formTitleMap.forEach((key, value) {
      if (itemAreaWidgetMap.containsKey(key)){
        itemWidgetList.add(itemAreaWidgetMap[key]!);
      }
    });
    int space = (itemWidgetList.length / 2).ceil();

    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: 420,
          ),
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: itemWidgetList.sublist(0, space),
                  ),
                ),
                const SizedBox(width: 4,),
                Expanded(
                  child: Column(
                    children: itemWidgetList.sublist(space),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: comDefectViewWidget(context),
        )
      ],
    );
  }


  @override
  void onClose() {
    numPadDebounce.dispose();
    numPadCTList.forEach((element) {
      element.dispose();
    });
    super.onClose();
  }
}