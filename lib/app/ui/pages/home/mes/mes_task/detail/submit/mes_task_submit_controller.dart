
import 'dart:async';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/assignment_form_model.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/service/tcp_serial/utils/tcp_serial_data_utils.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/assignment_interface/assignment_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/serial_number_scan_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/mes_submit_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/mes_task_submit_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_print_barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/check_record_list/mes_check_record_list_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/detail/device_detail/mes_device_task_detail_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/check_record/mes_task_check_record_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/detail_tab/mes_task_detail_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/material_reject/mes_task_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/mes_task_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/mes_work_center_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/submit_list/mes_submit_list_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 派工单 报工页面
class MesTaskSubmitController
    extends BaseFormController
    with InfoFormInterface,
        SerialPortGetXListenerMixin<MesTaskSubmitController>, ScanInterface<MesTaskSubmitController>,
        TcpSocketGetxListenerMixin<MesTaskSubmitController>,
        AssignmentInterface,
        InvClassFrxNameInterface,
        SubmitPrintBarcodeInterface,
        SubmitInterface, MesSubmitInterface, MesTaskSubmitInterface,
        SerialNumberScanInterface<MesTaskSubmitController>,
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
    NumPadController(key: NumPadUtil.eBPiece),
    NumPadController(key: NumPadUtil.eBWeight),
    NumPadController(key: NumPadUtil.pieceWeight),
    NumPadController(key: NumPadUtil.num), ///入库箱数（装箱数）(整箱箱数)
    NumPadController(key: NumPadUtil.boxNumOfPallet), ///单托箱数，数值 == 总数量 / 单箱数量，有余数进一位
    NumPadController(key: NumPadUtil.singleBoxQty), ///单箱数量 == 单箱件数（一箱里面装几个）（从数据库中读取，且数据可修改）
    NumPadController(key: NumPadUtil.lastBoxQty), ///尾箱数量 == 尾箱件数（箱子中数量未装满）
    NumPadController(key: NumPadUtil.qty), ///报工总数量 OR 预计总件数
    NumPadController(key: NumPadUtil.weight), ///报工总重(kg)
    NumPadController(key: NumPadUtil.boxWeight), ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重） (kg)
    NumPadController(key: NumPadUtil.pieceWeight, enabled: false), ///实际单重(g) 通过报工总数和报工总重计算
  ];

  @override
  bool get isHavePackingWeightReport => false;

  @override
  bool get isHaveSingleBoxQtyReport => submitType == AppConfig.qtyBoxSubmit
      || submitType == AppConfig.palletSubmit
      || submitType == AppConfig.singleBoxSerialNumberSubmit;
  @override
  final List<AssignmentFormModel> formList = [
    AssignmentFormModel(
      field: 'serialNumberCheckCode',
      title: '序列号校验码',
      sharedKey: SharedPreferencesKeys.MES_TASK_SUBMIT_ASSIGNMENT_SERIAL_NUMBER_CHECK_CODE_KEY,
      dataType: 2,
      formType: 0,
      hintText: '当前允许报工的产品序列号，可以填写多个效验码，用“,”隔开，使用“%”来进行模糊匹配序列号，例如：202507%',
    ),
  ];
  @override
  bool get noPermissionForAssignment => (dataService.isEnableOperatePrivilege && objectItem.buttons?['setAssignment'] == null);
  @override
  String get permissionInfoForAssignment => BaseService.profile.isSystem == true ? '【${objectItem.progid}】【setAssignment】' : '';

  @override
  List<String> get serialNumberCheckCodeList => formList.firstWhereOrNull((element) => element.field == 'serialNumberCheckCode')?.dataList.map((e) => e.toString()).toList() ?? [];

  @override
  bool get serialNumberIsAllConditionMustBeMet => formList.firstWhereOrNull((element) => element.field == 'serialNumberCheckCode')?.isAllConditionMustBeMet ?? AppConfig.isAllConditionMustBeMet;

  final bool showAppBar;

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  //region 总重称重 overlay
  ///是否显示总重称重数据的 overlay
  bool isShowWeightOverlay = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_SHOW_WEIGHT_OVERLAY_KEY) ?? AppConfig.isShowWeightOverlay;
  OverlayEntry? weightOverlayEntry;
  Offset weightOverlayOffset = Offset(
    ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_WEIGHT_OVERLAY_DX_KEY) ?? (MediaQuery.of(Get.context!).size.width - 600) / 2,
    ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_WEIGHT_OVERLAY_DY_KEY) ?? 44,
  );
  StreamController<String> weightOverlayStreamController = StreamController<String>.broadcast();
  Stream<String> get weightOverlayStream => weightOverlayStreamController.stream.asBroadcastStream();
  //endregion


  MesTaskSubmitController({
    super.progId = 650041,
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

    List<dynamic> taskInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_INFO_FORM_LIST_KEY) ?? [];
    taskInfoFormList.clear();
    taskInfoFormList.addAll(
        getInfoFormListByStorage(
            taskInfoFormMapList,
            AppConfig.mesTaskInfoFormList
        )
    );

    submitBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_BTN_INDEX_KEY) ?? AppConfig.submitBtnIndex;
    isShowMakeUpBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
    isShowSelfInspectionBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_SHOW_SELF_INSPECTION_BTN_KEY) ?? AppConfig.isShowSelfInspectionBtn;
    isShowMutualInspectionBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_SHOW_MUTUAL_INSPECTION_BTN_KEY) ?? AppConfig.isShowMutualInspectionBtn;
    isGetBackAfterCommitSuccess = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
    isShowDataReportTypeBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
    submitType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_TYPE_KEY) ?? AppConfig.qtySubmit;
    calcRuleForPalletSubmitType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_CALC_RULE_FOR_PALLET_SUBMIT_TYPE_KEY) ?? AppConfig.calcRuleForPalletSubmitType;
    String formTitleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_FORM_TITLE_MAP_KEY) ?? '';
    formTitleMap.clear();
    formTitleMap.addAll(getFormTitleMapByStorage(formTitleMapStr, AppConfig.mesTaskSubmitFormTitleMap));
    numPadCTList.sort((a, b){
      return numPadCTListSortVoidCallback.call(formTitleMap, a, b);
    });
    String formStyleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_FORM_STYLE_MAP_KEY) ?? '';
    formStyleMap.clear();
    formStyleMap.addAll(getFormStyleMapByStorage(formStyleMapStr, AppConfig.mesTaskSubmitFormStyleMap));
    numPadCTList.forEach((element) {
      element.styleMap.clear();
      if (formStyleMap.containsKey(element.key)){
        element.styleMap.addAll(formStyleMap[element.key]!);
      }
    });
    numPadFocusField = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
    formRowMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_FORM_ROW_MAX_COUNT_LIMIT_KEY) ?? AppConfig.formRowMaxCountLimit;
    depGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
    wcDataReportType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_WC_DATA_REPORT_TYPE_KEY) ?? AppConfig.wcDataReportType;
    isPsnHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
    isPsnMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
    psnGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
    psnDepCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
    psnLineCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
    numMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_NUM_MAX_COUNT_LIMIT_KEY) ?? AppConfig.numMaxCountLimit;
    singleBoxQtyMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_SINGLE_BOX_QTY_MAX_COUNT_LIMIT_KEY) ?? AppConfig.singleBoxQtyMaxCountLimit;
    frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesTaskSubmitPrintFileName;
    String invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMap.clear();
    invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));
    isUsePackingPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_USE_PACKING_PICKER_KEY) ?? AppConfig.isUsePackingPicker;
    isDeviceHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_DEVICE_HAS_ADAPTER_KEY) ?? AppConfig.isDeviceHasAdapter;
    deviceDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_DEVICE_DEP_ID_LIST_KEY) ?? [];
    deviceClassIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_DEVICE_CLASS_ID_LIST_KEY) ?? [];
    isShowInspectFlagBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_SHOW_INSPECT_FLAG_BTN_KEY) ?? AppConfig.isShowInspectFlagBtn;
    isCanClickInspectFlagBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_CAN_CLICK_INSPECT_FLAG_BTN_KEY) ?? AppConfig.isCanClickInspectFlagBtn;
    inspectFlagDefaultValue = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_INSPECT_FLAG_DEFAULT_VALUE_KEY) ?? AppConfig.inspectFlagDefaultValue;
    isShowAutoCommitBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_SHOW_AUTO_COMMIT_BTN_KEY) ?? AppConfig.isShowAutoCommitBtn;
    autoCommitSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_AUTO_COMMIT_FOR_SERIAL_NUMBER_SUBMIT_TYPE_KEY) ?? AppConfig.autoCommitSubmit;
    isSaveTheLastSelectedPsnId = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;
    isSaveTheLastPackingWeightData = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY) ?? AppConfig.isSaveTheLastPackingWeightData;
    isSingleBoxQtyOnlyChangedByContainer = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY) ?? AppConfig.isSingleBoxQtyOnlyChangedByContainer;
    isSaveTheLastQtyData = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_IS_SAVE_THE_LAST_QTY_DATA_KEY) ?? AppConfig.isSaveTheLastQtyData;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
      if (!showAppBar){
        mesTaskDetailTabController = Get.find<MesTaskDetailTabController>();
      }

      weightOverlayStreamController.add(
          NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '0'
      );
      if (isShowWeightOverlay){
        openWeightOverlay();
      }
    });
    numPadCTListSetEnabled();
  }

  @override
  Future<void> onReady() async{
    await super.onReady();

  }

  @override
  Future<bool> initializeForm() async {
    if (taskOpenType == 1){
      ///如果[taskOpenType] == 1，根据[eamDeviceModelWithGetxController?.model.objectId]获取派工单
      await getCurrentTask(deviceId);
    }
    setFormJudgeTypeMap();
    setWeightFormDecimalLengthMap();
    setSubmitDataAndAdapter(
        isInit: true,
        progId: progId,
        deviceId: eamDeviceModelWithGetxController?.model.deviceId,
        deviceCode: eamDeviceModelWithGetxController?.model.deviceCode,
        deviceName: eamDeviceModelWithGetxController?.model.deviceName,
        isNeedSetSingleBoxQty: !isSaveTheLastPackingWeightData || ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY) == null
    );
    getInventoryInfo(taskModel.invId ?? '').then((value) {
      update();
    });
    getTaskAdapter(deviceId: deviceId).then((value){
      update();
    });

    ///写入历史皮重数据
    if (isSaveTheLastPackingWeightData){
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        ///如果使用装箱容器，需要等待 containerWithNoPageAdapter 被赋值后，再写入历史皮重数据
        if (!isUsePackingPicker || containerWithNoPageAdapter != null){
          await setTheLastPackingWeightData(
            theLastContainerSelectedValue: ShareStorageUtil.instance?.read(
                SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY
            ),
            theLastPackingWeightValue: ShareStorageUtil.instance?.read(
                SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY
            ),
            theLastSingleBoxQty: ShareStorageUtil.instance?.read(
                SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY
            ),
          );
          return false;
        }
        return true;
      });
    }

    ///写入历史选中的员工数据
    if (isSaveTheLastSelectedPsnId){
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        ///需要等待 personAdapter 被赋值后，再写入历史员工数据
        if (!isPsnHasAdapter || personAdapter != null){
          await setTheLastSelectedPsnData(
            ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_SELECTED_PSN_LIST_KEY) ?? [],
          );
          return false;
        }
        return true;
      });
    }

    ///写入历史报工总数数据（按序列号报工时，不用写入）
    if (isSaveTheLastQtyData && submitType != AppConfig.serialNumberSubmit && submitType != AppConfig.singleBoxSerialNumberSubmit){
      if (isHaveQtyReport){
        double? qty = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_NUM_PAD_QTY_VALUE_KEY);
        NumPadUtil().setText(NumPadUtil.qty, qty?.toInt().toString() ?? '', numPadCTList);
        calcQty(NumPadUtil.packingWeight);
      }
    }

    return true;
  }

  Map<String, String> setAccItemMap(){
    return {'limit.weight': 'pdm'};
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
  void submitTypeOnChanged(ChoiceChipModel item) {
    if (submitType == item.keyName){ return; }
    super.submitTypeOnChanged(item);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_TYPE_KEY, submitType);
    numPadCTList.forEach((element) {
      element.controller.clear();
    });
    containerWithNoPageAdapter?.clearSelection();

    ///按序列号报工时，不需要填写报工总数（报工总数 = 序列号个数）；
    ///反之，清空序列号相关的数据；
    if (submitType != AppConfig.serialNumberSubmit
        && submitType != AppConfig.singleBoxSerialNumberSubmit){
      orderSNAdapter?.clearSelection();
      serialNumberBarcodeMap.clear();
      submitModel.serialNumber = null;
    }
    else {
      List<MoOrderSNModel> list = orderSNAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
      NumPadUtil().setText(NumPadUtil.qty, list.length.toString(), numPadCTList);
    }

    ///历史皮重数据赋值
    if (isSaveTheLastPackingWeightData){
      setTheLastPackingWeightData(
        theLastContainerSelectedValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY
        ),
        theLastPackingWeightValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY
        ),
        theLastSingleBoxQty: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY
        ),
      );
    }

    ///历史报工总数数据重新赋值
    if (isSaveTheLastQtyData && submitType != AppConfig.serialNumberSubmit && submitType != AppConfig.singleBoxSerialNumberSubmit){
      if (isHaveQtyReport){
        double? qty = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_NUM_PAD_QTY_VALUE_KEY);
        NumPadUtil().setText(NumPadUtil.qty, qty?.toInt().toString() ?? '', numPadCTList);
        calcQty(NumPadUtil.packingWeight);
      }
    }

    update();
  }

  @override
  void containerOnChanged(PickerDataModel model) {
    super.containerOnChanged(model);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY, model.id);
  }

  @override
  Future<void> psnOnChanged(List<PickerDataModel> list) async{
    await super.psnOnChanged(list);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_SELECTED_PSN_LIST_KEY, list.map((e) => e.toJson()).toList());
  }

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
    await setSubmitDataAndAdapter(
        isInit: false,
        deviceId: eamDeviceModelWithGetxController?.model.deviceId,
        deviceCode: eamDeviceModelWithGetxController?.model.deviceCode,
        deviceName: eamDeviceModelWithGetxController?.model.deviceName,
        isNeedSetSingleBoxQty: !isSaveTheLastPackingWeightData || ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY) == null
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

      //region 次品录入页面的派工单数据也改变
      MesTaskCheckRecordController? mesTaskCheckRecordController;
      try {
        mesTaskCheckRecordController = Get.find<MesTaskCheckRecordController>();
      } catch (e){}
      if (mesTaskCheckRecordController != null){
        await mesTaskCheckRecordController.getOtherTask(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel);
        mesTaskCheckRecordController.update();
      }
      //endregion

      //region 不良品上报页面的派工单数据也改变
      MesTaskMaterialRejectController? mesTaskMaterialRejectController;
      try {
        mesTaskMaterialRejectController = Get.find<MesTaskMaterialRejectController>();
      } catch (e){}
      if (mesTaskMaterialRejectController != null){
        await mesTaskMaterialRejectController.getOtherTask(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel);
        mesTaskMaterialRejectController.update();
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
    }
  }

  ///自动提交按钮选中变化（按序列号报工时使用）
  void autoCommitSubmitOnChanged() {
    super.autoCommitSubmitOnChanged();
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_AUTO_COMMIT_FOR_SERIAL_NUMBER_SUBMIT_TYPE_KEY, autoCommitSubmit);
    update();
  }

  //endregion


  //region NumPad SetEnabled + 计算

  ///判断输入框是否可以输入
  void numPadCTListSetEnabled() {
    switch (submitType){
      case AppConfig.qtySubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.pieceWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList); ///入库箱数（装箱数）(整箱)
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, true, numPadCTList); ///报工总重(kg)
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList); ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重）
        break;
      case AppConfig.qtyBoxSubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.pieceWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, true, numPadCTList); ///入库箱数（装箱数）(整箱)
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, true, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, true, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///报工总重(kg)
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList); ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重）
        break;
      case AppConfig.palletSubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.pieceWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList); ///入库箱数（装箱数）(整箱)
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, true, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, true, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, true, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///报工总重(kg)
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, true, numPadCTList); ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重）
        break;
      case AppConfig.serialNumberSubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.pieceWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList); ///入库箱数（装箱数）(整箱)
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///报工总重(kg)
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList); ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重）
        break;
      case AppConfig.singleBoxSerialNumberSubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.pieceWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList); ///入库箱数（装箱数）(整箱)
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, true, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, true, numPadCTList); ///报工总重(kg)
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList); ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重）
        break;
    }
  }

  ///数据填报后的计算
  void calcQty(String keyName){
    numPadDebounce((){
      if (keyName == NumPadUtil.packingWeight){
        ///填写皮重数据时，把填写的数据保存到本地
        double? packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '');
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY, packingWeight);
      }
      else if (keyName == NumPadUtil.singleBoxQty){
        double? singleBoxQty = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '');
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY, singleBoxQty);
      }
      else if (keyName == NumPadUtil.qty){
        ///填写报工总数数据时，把填写的数据保存到本地
        double? qty = double.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '');
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_NUM_PAD_QTY_VALUE_KEY, qty);
      }

      if (submitType == AppConfig.qtySubmit){ ///按数量报工
        switch (keyName){
          case NumPadUtil.weight: ///称重重量(g)
          case NumPadUtil.qty: ///称重件数
            getPieceWeightTC();
            break;
        }
      }
      else if (submitType == AppConfig.qtyBoxSubmit){ ///按数量（多箱）报工
        switch (keyName){
          case NumPadUtil.singleBoxQty:  ///单箱件数
          case NumPadUtil.lastBoxQty: ///尾箱件数
          case NumPadUtil.num: ///入库箱数 (整箱箱数)
            getQtyByQBSubmitType();
            break;
          case NumPadUtil.qty: ///总数量
            getBoxNumByQBSubmitType();
            break;
        }
      }
      else if (submitType == AppConfig.palletSubmit){ ///按托报工
        switch (keyName){
          case NumPadUtil.singleBoxQty: ///单箱数量
            if (calcRuleForPalletSubmitType == 0){
              getBoxNumOfPallet();
            }
            else if (calcRuleForPalletSubmitType == 1){
              getQtyOfPallet();
            }
            break;
          case NumPadUtil.qty: ///报工总数量
            getBoxNumOfPallet();
            break;
          case NumPadUtil.boxNumOfPallet: ///单托箱数
          case NumPadUtil.lastBoxQty: ///尾箱数量
            getQtyOfPallet();
            break;
        }
      }
      else if (submitType == AppConfig.singleBoxSerialNumberSubmit){
        switch (keyName){
          case NumPadUtil.qty:
          case NumPadUtil.weight:
            double weight = (double.tryParse(NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '') ?? 0) * 1000;
            int qty = int.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '') ?? 0;
            String _pieceWeightString;
            if (weight > 0 && qty > 0){
              _pieceWeightString = (weight / qty).toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.pieceWeight]!);
            }
            else {
              _pieceWeightString = '';
            }
            double _pieceWeight = double.tryParse(_pieceWeightString) ?? 0;
            NumPadUtil().setText(NumPadUtil.eBWeight, weight.toString(), numPadCTList);
            NumPadUtil().setText(NumPadUtil.eBPiece, qty.toString(), numPadCTList);
            NumPadUtil().setText(NumPadUtil.pieceWeight, _pieceWeightString, numPadCTList);
            isWeightError = _pieceWeight != 0
                && ((inventoryModel.invWeight ?? 0) / _pieceWeight - 1).abs() > (limitWeightDeviationValue / 100);
            break;
            // case NumPadUtil.singleBoxQty:
            //   int _singleBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') ?? 0;
            //   String _qtyString = _singleBoxQty > 0 ? _singleBoxQty.toString() : '';
            //   NumPadUtil().setText(NumPadUtil.qty, _qtyString, numPadCTList);
            //   break;
        }
      }

      weightOverlayStreamController.add(
          NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '0'
      );

      update();
    });
  }

  ///计算实际单重：报工总重 / 报工总数
  void getPieceWeightTC(){
    double weight = double.tryParse(NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '') ?? 0;
    int qty = int.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '') ?? 0;
    String _pieceWeightString;
    if (weight > 0 && qty > 0){
      _pieceWeightString = (weight * 1000 / qty).toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.pieceWeight]!);
    }
    else {
      _pieceWeightString = '';
    }
    //double _pieceWeight = double.tryParse(_pieceWeightString) ?? 0;
    NumPadUtil().setText(NumPadUtil.pieceWeight, _pieceWeightString, numPadCTList);
  }


  ///按数量（多箱）报工时 计算报工总数量：整箱箱数 * 单箱件数 + 尾箱件数；
  void getQtyByQBSubmitType(){
    ///整箱箱数
    int num = int.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '') ?? 1;
    ///单箱件数
    int singleBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') ?? 0;
    ///尾箱件数
    int lastBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxQty, numPadCTList) ?? '') ?? 0;
    ///报工总数量
    String qtyString = (num * singleBoxQty + lastBoxQty).toStringAsFixed(0);
    NumPadUtil().setText(NumPadUtil.qty, qtyString, numPadCTList);
  }

  ///按数量（多箱）报工时，计算整箱箱数：总件数 / 单箱数量，取整
  ///                    计算尾箱数量：总件数 / 单箱数量，取余数
  void getBoxNumByQBSubmitType() {
    ///报工总数量
    int _qty = int.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '') ?? 0;
    ///单箱数量
    int _singleBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') ?? 0;
    int _num = _qty == 0 || _singleBoxQty == 0 ? 0 : _qty ~/ _singleBoxQty;
    int _lastBoxQty = _qty == 0 || _singleBoxQty == 0 ? 0 : _qty % _singleBoxQty;
    String _numString = _num > 0 ? _num.toString() : '';
    String _lastBoxQtyString = _lastBoxQty > 0 ? _lastBoxQty.toString() : '';
    NumPadUtil().setText(NumPadUtil.num, _numString, numPadCTList);
    NumPadUtil().setText(NumPadUtil.lastBoxQty, _lastBoxQtyString, numPadCTList);
  }

  ///按托报工时，通过“单箱数量”、“报工总数量”计算“单托箱数”、“尾箱数量”
  ///计算单托箱数：总数量 / 单箱数量，取整
  ///计算尾箱数量：总数量 / 单箱数量，取余数
  void getBoxNumOfPallet(){
    int _qty = int.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '') ?? 0;
    int _singleBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') ?? 0;
    int _lastBoxQty = (_qty == 0 || _singleBoxQty == 0) ? 0 : _qty % _singleBoxQty;
    int _boxNumOfPallet = (_qty == 0 || _singleBoxQty == 0) ? 0 : _qty ~/ _singleBoxQty;
    String _lastBoxQtyString = _lastBoxQty > 0 ? _lastBoxQty.toString() : '';
    String _boxNumOfPalletString = _boxNumOfPallet > 0 ? _boxNumOfPallet.toString() : '';
    NumPadUtil().setText(NumPadUtil.lastBoxQty, _lastBoxQtyString, numPadCTList);
    NumPadUtil().setText(NumPadUtil.boxNumOfPallet, _boxNumOfPalletString, numPadCTList);
  }

  ///按托报工时，通过“单箱数量”、“单托箱数”、“尾箱数量”计算“报工总数量”
  ///计算报工总数量：单箱数量 * 单托箱数 + 尾箱数量
  void getQtyOfPallet() {
    int _singleBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') ?? 0;
    int _boxNumOfPallet = int.tryParse(NumPadUtil().getText(NumPadUtil.boxNumOfPallet, numPadCTList) ?? '') ?? 0;
    int _lastBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxQty, numPadCTList) ?? '') ?? 0;
    int _qty = _singleBoxQty * _boxNumOfPallet + _lastBoxQty;
    String _qtyString = _qty > 0 ? _qty.toString() : '';
    NumPadUtil().setText(NumPadUtil.qty, _qtyString, numPadCTList);
  }

  //endregion


  //region 串口、扫码、TCP

 @override
  Future<void> onSerialPortData(SerialPortDataModel serialPortDataModel) async {
    for (var element in serialComService.serialPortMsgProcessList){
      if (element.com == serialPortDataModel.com){
        portMsgOnData(
          element.keyName,
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
    switch (key) {
      case AppConfig.dSWeight:
      //region 报工总重
        if (submitType != AppConfig.qtySubmit && submitType != AppConfig.singleBoxSerialNumberSubmit) { return; }
        String formatValue = TcpSerialDataUtils.getFormatValue(
          data,
        );
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '';
        bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
            oldValue: double.tryParse(_oldString),
            value: double.tryParse(formatValue) ?? 0,
            errorRange: accuracy
        );
        if (isLessThen){ return; }
        //endregion
        NumPadUtil().setText(NumPadUtil.weight, formatValue, numPadCTList, isDataByWeightMsg: true);
        calcQty(NumPadUtil.weight);
        //endregion
        break;
      case AppConfig.scanGun:
      case AppConfig.cardReader:
        onBarcode(data);
        break;
      case AppConfig.serialNumberScan:
        serialNumberScanOnBarcode(
          searchString: data,
          invCCode: taskModel.invCCode,
        );
        break;
    }
  }

  ///扫描接收
  Future<void> onBarcode(String searchString) async{
    if (kDebugMode){
      //searchString = '|F|650011|ac0efdb8-3797-4d9c-b18f-92ca438da5b2';
      //searchString = '|F|650011|86656667-2641-4760-91d8-f97d8bc56bf8';
      //searchString = '|F|650011|f3b4e0e9-2bbf-4482-95d3-9385626db024';
      //searchString = '|G|AS001_008';
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
            if (submitModel.workBillEntryId == list[3]){
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
            if (submitModel.taskId == list[3]){
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
        if ((submitModel.empId ?? '').split(',').contains(psnRes.data.id)){
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
        if ((submitModel.empId ?? '').split(',').contains(psnRes.data.id)){
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
        if (submitModel.deviceId == deviceInfo || submitModel.deviceCode == deviceInfo){
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
        if (wcRes.data.id == submitModel.wcId){
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
      case 'X':
      //region 生产序列号条码
        if (submitType != AppConfig.serialNumberSubmit && submitType != AppConfig.singleBoxSerialNumberSubmit){
          TipsUtils.showTip(
            msg: '当前报工方式不需要选择生产序列号！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        //region 判断装箱情况
        /* if (submitType == AppConfig.singleBoxSerialNumberSubmit){
          String singleBoxQtyString = NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '';
          int? singleBoxQty = int.tryParse(singleBoxQtyString);
          String qtyString = NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '';
          int? qty = int.tryParse(qtyString);
          if (singleBoxQty == null || singleBoxQty < 1){
            TipsUtils.showTip(
              msg: '请输入单箱数量！',
              toastType: ToastType.warn,
            );
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
          if (singleBoxQty == qty){
            TipsUtils.showTip(
              msg: '当前装箱已满，请提交报工！',
              toastType: ToastType.warn,
            );
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
          if (qty != null && singleBoxQty < qty){
            TipsUtils.showTip(
              msg: '当前装箱已超，请检查！',
              toastType: ToastType.warn,
            );
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
        }  */
        //endregion
        String string = list[2];
        void exit({int? errCode = 1, String? msg}) {
          if (errCode != null){
            serialNumberBarcodeMap.addAll({string: errCode});
          }
          // if ((submitType == AppConfig.serialNumberSubmit || submitType == AppConfig.singleBoxSerialNumberSubmit)
          //     && autoCommitSubmit){
          //   setIsAutoCommitSuccess(false);
          // }
          if (msg != null && msg.isNotEmpty){
            TipsUtils.showTip(
              msg: msg,
              toastType: ToastType.error,
            );
          }
          update();
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        MoOrderSNModel? orderSNModel;
        if (!isBMoSN){
          //region 报废序列号判断
          var scrapCheckRes = await scrapCheck(string);
          if (!scrapCheckRes){
            return exit(errCode: 7);
          }
          //endregion
          var snRes = await MoOrderSNRepository().getModel(string);
          if (!snRes.isSuccess){
            return exit(errCode: 2, msg: '获取序列号数据时出错：${snRes.message}！');
          }
          if (snRes.data.id.isEmpty){
            return exit(errCode: 3, msg: '查询不到该序列号！');
          }
          if ((snRes.data.moOrderId ?? '').isEmpty){
            return exit(errCode: 4, msg: '该序列号还未被分配任务单！');
          }
          if (snRes.data.enableMark != 1){
            return exit(errCode: 7, msg: '该序列号已失效！');
          }
          orderSNModel = snRes.data;
        }
        if (serialNumberCheckCodeList.isNotEmpty){ ///序列号校验码判断 todo 先暂时这样处理
          bool isEligibility(String cc){
            if (cc.startsWith('%') || cc.endsWith('%')){
              String serialNumberCheckCode = cc.replaceAll('%', '');
              if (serialNumberCheckCode.isNotEmpty){
                if (cc.startsWith('%') && cc.endsWith('%') && string.contains(serialNumberCheckCode)){
                  return true;
                }
                else if (cc.startsWith('%') && string.endsWith(serialNumberCheckCode)){
                  return true;
                }
                else if (cc.endsWith('%') && string.startsWith(serialNumberCheckCode)){
                  return true;
                }
                else if (!cc.startsWith('%') && !cc.endsWith('%') && string == serialNumberCheckCode){
                  return true;
                }
                return false;
              }
              return false;
            }
            else {
              ///判断正则表达式
              RegExp pattern = RegExp(cc);
              return pattern.hasMatch(string);
              return string.contains(pattern);
            }
            return false;
          }
          String? sCCRes = serialNumberCheckCodeList.firstWhereOrNull((cc){
            return serialNumberIsAllConditionMustBeMet ? !isEligibility(cc) : isEligibility(cc);
          });
          if (serialNumberIsAllConditionMustBeMet ? sCCRes != null : sCCRes == null){
            return exit(errCode: 8, msg: '该序列号与校验码不一致！\n当前效验码：${serialNumberCheckCodeList.join(', ')}');
          }
        }
        //region 判断该序列号是否已选中，已选中，则退出
        List<MoOrderSNModel> selectedList = orderSNAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
        List<String> serialNumberList = selectedList.map((e) => e.id).toList();
        if (serialNumberList.contains(string)){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        //endregion
        ///任务单不一致，提示并退出
        if (!isBMoSN && orderSNModel != null && orderSNModel.moOrderId != null
            && orderSNModel.moOrderId != submitModel.moOrderId){
          return exit(errCode: 8, msg: '该序列号已被分配到其他任务单');
        }
        ///按单箱序列号报工，暂时可以不用没有工序
        ///这里两种报工方式分开判断
        if (submitType == AppConfig.serialNumberSubmit){
          ///有选中的工序，且只选中一条
          if ((submitModel.opId ?? '').isNotEmpty && submitModel.opId!.split(',').length == 1){
            ///写入序列号前，需要先判断序列号的报工情况：
            ///未通过，退出；
            ///通过，（如果是自动报工，且按序列号报工，则需要先提交前检查）选中扫描的序列号，写入报工数量（如果是自动报工，则执行报工前检查并报工，最后退出）；
            bool isCanContinue = await checkOpSerialNumber(string);
            if (!isCanContinue){
              ///[checkOpSerialNumber()] 中已写入 [serialNumberBarcodeMap]，也执行了 msg
              return exit(errCode: null);
            }
            if (autoCommitSubmit){
              Map<bool, String> checkMap = submitCheck(
                isPrint: false,
                invCCode: taskModel.invCCode,
                needCheckQty: false,
                needCheckOp: false,
                needCheckSN: false,
              );
              if (checkMap.containsKey(false)){
                return exit(msg: checkMap[false]!);
              }
            }
            await orderSNAdapter?.validViewValue([orderSNModel ?? MoOrderSNModel(id: string, code: string)]);
            submitSNOnChanged([orderSNModel ?? MoOrderSNModel(id: string, code: string)]);

            if (autoCommitSubmit){
              ///此时所有报工数据都已填写完成，符合自动报工的条件，直接提交报工记录
              isLoading = false;
              update();
              ProgressDialogUtil.close();
              serialNumberBarcodeMap.addAll({string: 200});
              await saveSubmit(false, byAutoSubmit: true);
              return;
            }

            serialNumberBarcodeMap.addAll({string: 200});
          }
          ///没有选中工序，或者选中多条
          else {
            ///清空选中的工序列表，并提示
            submitModel.workBillEntryId = null;
            submitModel.opId = null;
            submitModel.opName = null;
            submitModel.inspectFlag = null;
            submitModel.pieceRate = null;
            processAdapter?.clearSelection();
            return exit(msg: '当前没有选中工序，或选中多条，请重新选择工序后再次扫描序列号条码！');
          }
        }
        else if (submitType == AppConfig.singleBoxSerialNumberSubmit){
          List<MoOrderSNModel> list = orderSNAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
          list.add(orderSNModel ?? MoOrderSNModel(id: string, code: string));
          await orderSNAdapter?.validViewValue(list);
          submitSNOnChanged(list);
          if (singleBoxSerialNumberSubmitAutoCommit){
            ///数量符合，可以执行自动提交
            ///报工提交前检查，未通过则退出
            Map<bool, String> checkMap = submitCheck(
              isPrint: true,
              invCCode: taskModel.invCCode,
              needCheckQty: true,
              needCheckOp: true,
              needCheckSN: true,
            );
            if (checkMap.containsKey(false)){
              return exit(msg: checkMap[false]!);
            }
            ///符合自动报工的条件，直接提交报工记录
            isLoading = false;
            update();
            ProgressDialogUtil.close();
            serialNumberBarcodeMap.addAll({string: 200});
            await saveSubmit(true, byAutoSubmit: true);
            return;
          }
          serialNumberBarcodeMap.addAll({string: 200});
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

  @override
  Future<void> onTcpSocketData(TcpSocketDataModel tcpSocketDataModel) async {
    for (var element in tcpSocketService.tcpSocketMsgProcessList){
      if (element.host == tcpSocketDataModel.host && element.port == tcpSocketDataModel.port){
        portMsgOnData(
          element.keyName,
          data: tcpSocketDataModel.data,
          accuracy: element.accuracy,
        );
      }
    }
  }

  //endregion


  @override
  Future<void> saveSubmit(bool isPrint, {bool byAutoSubmit = false}) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;

    // late final MesTaskScanCodeController mesTaskScanCodeController;

    // try{
    //   mesTaskScanCodeController = Get.find<MesTaskScanCodeController>();
    // } catch (e){
    //   ToastNotification(Get.overlayContext!).warn('请先报工扫码!');
    //   isLoading = false;
    //   return;
    // }


    List<String> remainingCodeList = [];

    if ((submitType == AppConfig.serialNumberSubmit || submitType == AppConfig.singleBoxSerialNumberSubmit)){
      String singleBoxQtyString = NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '';
      int? singleBoxQty = int.tryParse(singleBoxQtyString);
      if (singleBoxQty == null || singleBoxQty < 1){
        // TipsUtils.showTip(
        //   msg: '请输入单箱数量！',
        //   toastType: ToastType.warn,
        // );
        ToastNotification(Get.overlayContext!).error('请输入单箱数量！');
        isLoading = false;
        ProgressDialogUtil.close();
        return;
      }

      String serialNumber = '';
      // String code = snCodeStr;
      List<String> codeList = snCodeStr.split(',');

      if(codeList.length >= singleBoxQty ) {
        List<String> firstList = codeList.take(singleBoxQty).toList();
        List<String> reList = codeList.skip(singleBoxQty).toList();
        serialNumber = firstList.join(',');
        remainingCodeList.addAll(reList);

      }else {
        serialNumber = codeList.join(',');
        remainingCodeList.addAll([]);

      }

      submitModel.serialNumber = serialNumber;
    }

    if (!byAutoSubmit){
      ///报工提交前检查
      Map<bool, String> checkMap = submitCheck(
        isPrint: isPrint,
        invCCode: taskModel.invCCode,
      );
      if (checkMap.containsKey(false)){
        ToastNotification(Get.overlayContext!).error(checkMap[false]!);
        isLoading = false;
        return;
      }
      ///超量报工判断 派工单
      bool overSubmitCheckRes = await overSubmitCheck(
        qty: taskModel.assignQty ?? 0,
        submitQty: taskModel.submitQty ?? 0,
      );
      if (!overSubmitCheckRes){
        isLoading = false;
        return;
      }
      if (!isBMoSN){
        //region 报废序列号判断
        if ((submitModel.serialNumber ?? '').isNotEmpty){
          ProgressDialogUtil.showProgressDialog(
            msg: '正在判断序列号是否报废',
            completedMsg: '判断成功！',
          );
          var scrapCheckRes = await scrapCheck(submitModel.serialNumber ?? '');
          if (!scrapCheckRes){
            ProgressDialogUtil.close();
            isLoading = false;
            return;
          }
          ///序列号未报废也要 close，而不是 update，为了不让加载弹窗妨碍到报工
          ProgressDialogUtil.close();
        }
        //endregion
      }
    }

    var dialogRes = await submitSaveConfirmationDialog(isPrint, byAutoSubmit: byAutoSubmit);
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
      max: 2,
      //max: 2 + (isPrint ? 1 : 0) + (isPrint && isNeedCreateStock ? 1 : 0),
      msg: '正在提交报工记录',
      completedMsg: '刷新成功！',
      //completedMsg: isPrint && isNeedCreateStock
      //    ? '生产入库单生成成功'
      //    : isPrint
      //    ? '打印成功'
      //    : '刷新成功！',
    );
    //region 提交报工记录
    setSubmitDataBeforeSave();
    var res = await MoOpSubmitRepository().submitFormData(submitModel, bMoSN: isBMoSN);

    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).warn('报工记录提交失败！${res.message}！');
      // TipsUtils.showTip(
      //   msg: '报工记录提交失败！${res.message}！',
      //   toastType: ToastType.error,
      // );
      ProgressDialogUtil.close();
      isLoading = false;


      return;
    }

    List<MoOrderSNModel> modelList = [];
    for(var e in remainingCodeList){
      modelList.add(MoOrderSNModel(id: e, code: e));
    }
    await orderSNAdapter?.validViewValue(modelList);
    submitSNOnChanged(modelList);

    List<String> submitResDataList = (res.data.data?.toString() ?? '').isEmpty
        ? []
        : res.data.data!.toString().split(',');
    List<String> serialNumberList = (submitModel.serialNumber ?? '').isEmpty
        ? []
        : submitModel.serialNumber!.split(',');
    if (submitType == AppConfig.serialNumberSubmit
        && serialNumberList.isNotEmpty && submitResDataList.length != serialNumberList.length){
      setIsAutoCommitSuccess(false);
      TipsUtils.showTip(
        msg: '报工记录部分提交失败！${res.message}！',
        toastType: ToastType.error,
      );
      ProgressDialogUtil.update(value: 1, msg: '报工记录部分提交成功，正在刷新数据！');
    }
    else {
      setIsAutoCommitSuccess(true);
      ProgressDialogUtil.update(value: 1, msg: '报工记录提交成功，正在刷新数据！');
    }
    //endregion

    //region 刷新页面
    var taskRes = await MoTaskRepository().getFormData(submitModel.taskId!);
    if (!taskRes.isSuccess){
      ToastNotification(Get.overlayContext!).warn("派工单数据刷新失败！");
    }
    else {
      taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
    }
    MoTaskModel? taskAdapterItem = taskAdapter?.dataList.firstWhereOrNull(
            (element) => element.taskId == submitModel.taskId);
    if (taskAdapterItem != null){
      taskAdapterItem.submitQty = taskModel.submitQty;
      taskAdapterItem.acceptQty = taskModel.acceptQty;
    }
    //region 首页：当前报工的派工单
    if (taskOpenType == 0){
      try {
        MesTaskController mesTaskController = Get.find<MesTaskController>();
        MoTaskModel? task = mesTaskController.dataList.firstWhereOrNull((element) => element.taskId == submitModel.taskId);
        if (task != null){
          bool isExpanded = task.isExpanded;
          task.fromJson(taskModel.toJson());
          task.isExpanded = isExpanded;
        }
        mesTaskController.update();
      } catch (e){}
    }
    else if (taskOpenType == 1){
      if (eamDeviceModelWithGetxController?.model.currentTask?.taskId == submitModel.taskId){
        eamDeviceModelWithGetxController?.model.currentTask!.fromJson(taskModel.toJson());
        eamDeviceModelWithGetxController?.update();
      }
    }
    else if (taskOpenType == 2){
      try {
        MesWorkCenterController mesWorkCenterController = Get.find<MesWorkCenterController>();
        MoTaskModel? task = mesWorkCenterController.taskList.firstWhereOrNull((element) => element.taskId == submitModel.taskId);
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
      if (mesDeviceTaskDetailController.taskModel.taskId == submitModel.taskId){
        mesDeviceTaskDetailController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
      }
      MoTaskModel? _taskModel = mesDeviceTaskDetailController.taskList.firstWhereOrNull((element) => element.taskId == submitModel.taskId);
      if (_taskModel != null){
        _taskModel.submitQty = taskModel.submitQty;
        _taskModel.acceptQty = taskModel.acceptQty;
      }
      mesDeviceTaskDetailController.update();
    }
    //endregion
    //region 报工单列表页面：刷新
    MesSubmitListController? submitListController;
    try {
      submitListController = Get.find<MesSubmitListController>();
    } catch (e){}
    if (submitListController != null){
      await submitListController.pageChanged(showLoading: false);
      submitListController.update();
    }
    //endregion

    //region 报次品页面：当前派工单刷新
    MesTaskCheckRecordController? taskCheckRecordController;
    try {
      taskCheckRecordController = Get.find<MesTaskCheckRecordController>();
    } catch (e){}
    if (taskCheckRecordController != null){
      if (taskCheckRecordController.checkRecordModel.taskId == submitModel.taskId){
        taskCheckRecordController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
      }
      MoTaskModel? taskAdapterItem = taskCheckRecordController.taskAdapter?.dataList.firstWhereOrNull(
              (element) => element.taskId == submitModel.taskId);
      if (taskAdapterItem != null){
        taskAdapterItem.submitQty = taskModel.submitQty;
        taskAdapterItem.acceptQty = taskModel.acceptQty;
      }
      taskCheckRecordController.update();
    }
    //endregion

    //region 不良品上报页面：当前派工单刷新
    MesTaskMaterialRejectController? mesTaskMaterialRejectController;
    try {
      mesTaskMaterialRejectController = Get.find<MesTaskMaterialRejectController>();
    } catch (e){}
    if (mesTaskMaterialRejectController != null){
      if (mesTaskMaterialRejectController.checkRecordModel.taskId == submitModel.taskId){
        mesTaskMaterialRejectController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
      }
      MoTaskModel? taskAdapterItem = mesTaskMaterialRejectController.taskAdapter?.dataList.firstWhereOrNull(
              (element) => element.taskId == submitModel.taskId);
      if (taskAdapterItem != null){
        taskAdapterItem.submitQty = taskModel.submitQty;
        taskAdapterItem.acceptQty = taskModel.acceptQty;
      }
      mesTaskMaterialRejectController.update();
    }
    //endregion
    ///刷新报工填报区域的数据
    if(submitType == AppConfig.singleBoxSerialNumberSubmit){

    }else {
      await resetSubmitDataAfterSave();
    }
    ///历史皮重数据赋值
    if (isSaveTheLastPackingWeightData){
      await setTheLastPackingWeightData(
        theLastContainerSelectedValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY
        ),
        theLastPackingWeightValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY
        ),
        theLastSingleBoxQty: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY
        ),
      );
    }
    ///历史报工总数数据赋值
    if (isSaveTheLastQtyData && submitType != AppConfig.serialNumberSubmit && submitType != AppConfig.singleBoxSerialNumberSubmit){
      if (isHaveQtyReport){
        double? qty = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SUBMIT_THE_LAST_NUM_PAD_QTY_VALUE_KEY);
        NumPadUtil().setText(NumPadUtil.qty, qty?.toInt().toString() ?? '', numPadCTList);
        calcQty(NumPadUtil.packingWeight);
      }
    }
    update();
    ProgressDialogUtil.update(value: 2, msg: '${isPrint ? '数据刷新成功，正在打印！' : null}');
    //endregion
    //region 打印 + 生成生产入库单
    ///todo 以后的版本，所有地方都改成异步执行
    if (isPrint) {
      Future.sync(() async {
        EAMDeviceModel? eamDeviceModel;
        if ((submitModel.deviceId ?? '').isNotEmpty){
          var deviceRes = await EAMDeviceRepository().getModel(submitModel.deviceId!);
          if (!deviceRes.isSuccess){
            ToastNotification(Get.overlayContext!).error("设备数据获取失败：${deviceRes.message}！");
            //ProgressDialogUtil.close();
            //isLoading = false;
            return;
          }
          eamDeviceModel = deviceRes.data;
        }
        MoOpOrderModel? orderModel;
        if ((taskRes.data.moOrderId ?? '').isNotEmpty){
          var orderRes = await MoOrderRepository().getFormData(taskRes.data.moOrderId!);
          if (!orderRes.isSuccess){
            ToastNotification(Get.overlayContext!).error("任务单数据获取失败：${taskRes.message}！");
          }
          else {
            orderModel = MoOpOrderModel.fromJson(orderRes.data.toJson());
          }
        }
        Map<bool, String> printRes = await printSubmitBarcode(
          moOpSubmitId: res.data.data,
          printerUrl: printerUrl,
          printerName: printerName,
          printCopies: printCopies,
          printType: printType,
          taskModel: taskModel,
          orderModel: orderModel,
          billCode: taskModel.taskCode ?? '',
          submitType: submitType,
          deviceAddCode: eamDeviceModel?.deviceAddCode ?? '',
          invMnemCode: inventoryModel.invMnemCode ?? '',
        );
        if (printRes.containsKey(true)) {
          ToastNotification(Get.overlayContext!).info(printRes[true]!);
        }
        else {
          TipsUtils.showTip(
            msg: printRes[false] ?? '',
            toastType: ToastType.error,
          );

          return;
        }
      });
      //region 生成生产入库单（执行到这一步的时候报工单和条码一定生成成功）
      if (isPrint && isNeedCreateStock && !res.data.data.toString().contains(',')){
        Map<bool, String> stockRes = await createStock(res.data.data);
        if (stockRes.containsKey(true)) {
          //ProgressDialogUtil.update(value: 4);
        }
        else {
          TipsUtils.showTip(
            msg: stockRes[false] ?? '',
            toastType: ToastType.error,
          );
          //ProgressDialogUtil.close();
          //isLoading = false;
          return;
        }
      }
      //endregion
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
  Widget dataReportAreaWidget(BuildContext context) {
    List<Widget> itemWidgetList = [];
    Map<String, Widget> itemAreaWidgetMap = {};
    itemAreaWidgetMap.addAll({
      if (isMakeUp)
        AppConfig.billDateForm: billDateReportItem(context),
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
      if (submitType == AppConfig.serialNumberSubmit)
        AppConfig.orderSNForm: orderSNReportItem(context),

      if (submitType == AppConfig.qtySubmit)
        ...{
          NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
          NumPadUtil.weight: numPadReportItem(context, NumPadUtil.weight, hintText: '选填'),
        }
      else if (submitType == AppConfig.qtyBoxSubmit)
        ...{
          NumPadUtil.num: numPadReportItem(context, NumPadUtil.num),
          NumPadUtil.singleBoxQty: singleBoxQtyReportItem(context),
          NumPadUtil.lastBoxQty: numPadReportItem(context, NumPadUtil.lastBoxQty),
          NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
        }
      else if (submitType == AppConfig.palletSubmit)
          ...{
            NumPadUtil.singleBoxQty: singleBoxQtyReportItem(context),
            NumPadUtil.lastBoxQty: numPadReportItem(context, NumPadUtil.lastBoxQty),
            NumPadUtil.boxNumOfPallet: numPadReportItem(context, NumPadUtil.boxNumOfPallet),
            NumPadUtil.boxWeight: numPadReportItem(context, NumPadUtil.boxWeight),
            NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
          }
        else if (submitType == AppConfig.serialNumberSubmit)
            ...{
              NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
            }
          else if (submitType == AppConfig.singleBoxSerialNumberSubmit)
              ...{
                NumPadUtil.pieceWeight: numPadReportItem(context, NumPadUtil.pieceWeight),
                NumPadUtil.singleBoxQty: singleBoxQtyReportItem(context),
                NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
                NumPadUtil.weight: numPadReportItem(context, NumPadUtil.weight, hintText: '选填'),
              }
    });
    formTitleMap.forEach((key, value) {
      if (itemAreaWidgetMap.containsKey(key)){
        itemWidgetList.add(itemAreaWidgetMap[key]!);
      }
    });

    double _itemHeight = 72;
    double _needHeight = _itemHeight * itemWidgetList.length;
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        interactive: false,
        thumbVisibility: WidgetStateProperty.all(false),
        trackVisibility: WidgetStateProperty.all(false),
        thumbColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          int? _count;
          if (formRowMaxCountLimit != null){
            _count = formRowMaxCountLimit! > itemWidgetList.length
                ? null
                : formRowMaxCountLimit!;
          }
          else if (constraints.maxHeight < _needHeight){
            _count = constraints.maxHeight ~/ _itemHeight;
          }

          if (_count != null){
            return SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: itemWidgetList.sublist(0, _count),
                    ),
                  ),
                  const SizedBox(width: 4,),
                  Expanded(
                    child: Column(
                      children: itemWidgetList.sublist(_count),
                    ),
                  ),
                ],
              ),
            );
          }
          else {
            return SingleChildScrollView(
              child: Column(
                children: itemWidgetList,
              ),
            );
          }
        },
      ),
    );
  }

  Widget numPadAreaWidget(BuildContext context){
    if (submitType == AppConfig.singleBoxSerialNumberSubmit){
      return GestureDetector(
        onDoubleTap: () async {
          await DialogUtils.showCustomDialog(
              context,
              isNeedConfirmBtn: false,
              title: '条码列表',
              onCancelName: '关闭',
              contentPadding: const EdgeInsets.all(2),
              initialWidth: 800,
              initialHeight: 600,
              content: snScanCodeViewWidget(context),
          );

        },
        child: snViewWidget(context),
      );
    }
    return super.numPadAreaWidget(context);
  }


  //region 总重称重 overlay

  void openWeightOverlay() {
    weightOverlayEntry = _buildWeightOverlayEntry();
    Overlay.of(Get.context!).insert(weightOverlayEntry!);
  }

  void closeWeightOverlay() {
    weightOverlayEntry?.remove(); ///收起下拉框
    weightOverlayEntry = null;
  }

  OverlayEntry _buildWeightOverlayEntry() {
    return OverlayEntry(
        builder: (BuildContext context){
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
            bool resetWeightOverlayOffset = false;
            if (weightOverlayOffset.dx > Get.width){
              resetWeightOverlayOffset = true;
            }
            else if (weightOverlayOffset.dy > Get.height){
              resetWeightOverlayOffset = true;
            }
            if (resetWeightOverlayOffset){
              weightOverlayOffset = Offset(
                  (Get.width - 600) / 2,
                  44
              );
              ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_WEIGHT_OVERLAY_DX_KEY, weightOverlayOffset.dx);
              ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_WEIGHT_OVERLAY_DY_KEY, weightOverlayOffset.dy);
              update();
            }
          });
          return StreamBuilder<String>(
            stream: weightOverlayStream,
            initialData: NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '0',
            builder: (BuildContext context, AsyncSnapshot<String>snapshot){
              return Stack(
                children: [
                  Positioned(
                    top: weightOverlayOffset.dy,
                    left: weightOverlayOffset.dx,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surface,
                      child: SizedBox(
                        height: 150, width: 300,
                        child: Draggable(
                          feedback: Container(
                            alignment: Alignment.center,
                            height: 150, width: 300,
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox.shrink(),
                          ),
                          onDraggableCanceled: (Velocity velocity, Offset offset) {
                            weightOverlayOffset = offset;
                            ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_WEIGHT_OVERLAY_DX_KEY, weightOverlayOffset.dx);
                            ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SUBMIT_WEIGHT_OVERLAY_DY_KEY, weightOverlayOffset.dy);
                            update();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: '报工总重 (kg)：\n',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data}',
                                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                      color: AppColors.errorColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          );
        }
    );
  }

  //endregion


  @override
  void onClose() {
    numPadDebounce.dispose();
    numPadCTList.forEach((element) {
      element.dispose();
    });

    if (weightOverlayEntry != null) {
      closeWeightOverlay();
    }

    super.onClose();
  }

}