
import 'dart:async';

import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/assignment_form_model.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/serial_com_service/mixin/serial_port_getx_listener.dart';
import 'package:desktop/app/service/serial_com_service/serial_port_data_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/assignment_interface/assignment_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/mes_submit_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/order_submit_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_print_barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/check_record_list/mes_check_record_list_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/check_record/mes_order_check_record_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/detail_tab/mes_order_detail_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/material_reject/mes_order_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/mes_order_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/mes_work_center_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/submit_list/mes_submit_list_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 任务单 报工页面
class MesOrderSubmitController
    extends BaseFormController
    with InfoFormInterface,
        SerialPortGetXListenerMixin<MesOrderSubmitController>, ScanInterface<MesOrderSubmitController>,
        AssignmentInterface,
        InvClassFrxNameInterface,
        SubmitPrintBarcodeInterface,
        SubmitInterface, MesSubmitInterface, OrderSubmitInterface,
        InterfaceUtil {

  late final MesOrderDetailTabController mesOrderDetailTabController;
  ///0：生产任务单； 1：设备任务单； 2：加工中心任务单
  final int orderOpenType;
  ///上一个页面选中的加工中心（加工中心任务单）
  final String workCenterId;
  ///上一个页面选中的设备（设备任务单）
  final String deviceId;
  ///工序计划单明细 + 设备实时生产数据（设备对应生产任务单）
  late final ModelWithGetxController<MoDeviceWorkBillList>? deviceWBModelWithGetxController = deviceId.isNotEmpty
      ? Get.find<ModelWithGetxController<MoDeviceWorkBillList>>(tag: 'MesDeviceOrder-$deviceId')
      : null;

  ///任务单表单页面-数据字段列表
  final List<InfoFormModel> orderInfoFormList = [];

  @override
  final List<NumPadController> numPadCTList = [
    NumPadController(key: NumPadUtil.packingWeight), ///单箱皮重
    NumPadController(key: NumPadUtil.num), ///入库箱数（装箱数）(整箱箱数)
    NumPadController(key: NumPadUtil.boxNumOfPallet), ///单托箱数，数值 == 总数量 / 单箱数量，有余数进一位
    NumPadController(key: NumPadUtil.singleBoxQty), ///单箱数量 == 单箱件数（一箱里面装几个）（从数据库中读取，且数据可修改）
    NumPadController(key: NumPadUtil.lastBoxQty), ///尾箱数量 == 尾箱件数（箱子中数量未装满）
    NumPadController(key: NumPadUtil.singleBoxWeight), ///单箱重量
    NumPadController(key: NumPadUtil.lastBoxWeight), ///尾箱重量
    NumPadController(key: NumPadUtil.qty), ///报工总数量 OR 预计总件数
    NumPadController(key: NumPadUtil.weight), ///报工总重
    NumPadController(key: NumPadUtil.boxWeight), ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重） (kg)
  ];

  @override
  bool get isHavePackingWeightReport => submitType == AppConfig.mesWeightSubmit
      || submitType == AppConfig.mesWeightBoxSubmit;

  @override
  bool get isHaveSingleBoxQtyReport => submitType == AppConfig.qtyBoxSubmit
      || submitType == AppConfig.palletSubmit
      || submitType == AppConfig.singleBoxSerialNumberSubmit;

  @override
  final List<AssignmentFormModel> formList = [
    AssignmentFormModel(
      field: 'serialNumberCheckCode',
      title: '序列号校验码',
      sharedKey: SharedPreferencesKeys.MES_ORDER_SUBMIT_ASSIGNMENT_SERIAL_NUMBER_CHECK_CODE_KEY,
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
  bool isShowWeightOverlay = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_WEIGHT_OVERLAY_KEY) ?? AppConfig.isShowWeightOverlay;
  OverlayEntry? weightOverlayEntry;
  Offset weightOverlayOffset = Offset(
    ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_WEIGHT_OVERLAY_DX_KEY) ?? (MediaQuery.of(Get.context!).size.width - 600) / 2,
    ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_WEIGHT_OVERLAY_DY_KEY) ?? 44,
  );
  StreamController<String> weightOverlayStreamController = StreamController<String>.broadcast();
  Stream<String> get weightOverlayStream => weightOverlayStreamController.stream.asBroadcastStream();
  //endregion


  MesOrderSubmitController({
    super.progId = 650041,
    super.isShowProgressDialogInOnReady = true,
    required MoOpOrderModel orderModel,
    this.orderOpenType = 0,
    this.workCenterId = '',
    this.deviceId = '',
    this.showAppBar = true,
    this.noPermission = false,
    this.permissionInfo = '',
  }){
    this.orderModel = orderModel;
  }


  @override
  void onInit() {
    super.onInit();

    List<dynamic> orderInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_INFO_FORM_LIST_KEY) ?? [];
    orderInfoFormList.clear();
    orderInfoFormList.addAll(
      getInfoFormListByStorage(
        orderInfoFormMapList,
        AppConfig.mesOrderInfoFormList
      )
    );

    submitBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_BTN_INDEX_KEY) ?? AppConfig.submitBtnIndex;
    isShowMakeUpBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
    isShowSelfInspectionBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_SELF_INSPECTION_BTN_KEY) ?? AppConfig.isShowSelfInspectionBtn;
    isShowMutualInspectionBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_MUTUAL_INSPECTION_BTN_KEY) ?? AppConfig.isShowMutualInspectionBtn;
    isGetBackAfterCommitSuccess = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
    isShowOpTgSubmitQty = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_OP_TG_SUBMIT_QTY_KEY) ?? AppConfig.isShowOpTgSubmitQty;
    isShowDataReportTypeBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
    submitType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_TYPE_KEY) ?? AppConfig.qtySubmit;
    calcRuleForPalletSubmitType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_CALC_RULE_FOR_PALLET_SUBMIT_TYPE_KEY) ?? AppConfig.calcRuleForPalletSubmitType;
    String formTitleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_FORM_TITLE_MAP_KEY) ?? '';
    formTitleMap.clear();
    formTitleMap.addAll(getFormTitleMapByStorage(formTitleMapStr, AppConfig.mesOrderSubmitFormTitleMap));
    numPadCTList.sort((a, b){
      return numPadCTListSortVoidCallback.call(formTitleMap, a, b);
    });
    String formStyleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_FORM_STYLE_MAP_KEY) ?? '';
    formStyleMap.clear();
    formStyleMap.addAll(getFormStyleMapByStorage(formStyleMapStr, AppConfig.mesOrderSubmitFormStyleMap));
    numPadCTList.forEach((element) {
      element.styleMap.clear();
      if (formStyleMap.containsKey(element.key)){
        element.styleMap.addAll(formStyleMap[element.key]!);
      }
    });
    numPadFocusField = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
    formRowMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_FORM_ROW_MAX_COUNT_LIMIT_KEY) ?? AppConfig.formRowMaxCountLimit;
    depGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
    wcDataReportType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_WC_DATA_REPORT_TYPE_KEY) ?? AppConfig.wcDataReportType;
    isPsnHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
    isPsnMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
    psnGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
    psnDepCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
    psnLineCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
    numMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_NUM_MAX_COUNT_LIMIT_KEY) ?? AppConfig.numMaxCountLimit;
    singleBoxQtyMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_SINGLE_BOX_QTY_MAX_COUNT_LIMIT_KEY) ?? AppConfig.singleBoxQtyMaxCountLimit;
    frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesOrderSubmitPrintFileName;
    String invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMap.clear();
    invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));
    isDeviceHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_DEVICE_HAS_ADAPTER_KEY) ?? AppConfig.isDeviceHasAdapter;
    deviceDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_DEVICE_DEP_ID_LIST_KEY) ?? [];
    deviceClassIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_DEVICE_CLASS_ID_LIST_KEY) ?? [];
    isShowInspectFlagBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_INSPECT_FLAG_BTN_KEY) ?? AppConfig.isShowInspectFlagBtn;
    isCanClickInspectFlagBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_CAN_CLICK_INSPECT_FLAG_BTN_KEY) ?? AppConfig.isCanClickInspectFlagBtn;
    inspectFlagDefaultValue = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_INSPECT_FLAG_DEFAULT_VALUE_KEY) ?? AppConfig.inspectFlagDefaultValue;
    isShowAutoCommitBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_AUTO_COMMIT_BTN_KEY) ?? AppConfig.isShowAutoCommitBtn;
    autoCommitSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_AUTO_COMMIT_FOR_SERIAL_NUMBER_SUBMIT_TYPE_KEY) ?? AppConfig.autoCommitSubmit;
    isShowOpDescription = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_OP_DESCRIPTION_KEY) ?? AppConfig.isShowOpDescription;
    isUsePackingPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_USE_PACKING_PICKER_KEY) ?? AppConfig.isUsePackingPicker;
    isSaveTheLastSelectedPsnId = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;
    isSaveTheLastPackingWeightData = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY) ?? AppConfig.isSaveTheLastPackingWeightData;
    isSingleBoxQtyOnlyChangedByContainer = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY) ?? AppConfig.isSingleBoxQtyOnlyChangedByContainer;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
      if (!showAppBar){
        mesOrderDetailTabController = Get.find<MesOrderDetailTabController>();
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
  Future<void> onReady() async {
    await super.onReady();

    connectList.forEach((element) {
      element.weightMsgConnectService = WeightMsgConnect(connectModel: element, onFire: (data) { ///数据处理
        if (element.weightMsgConnectService == null){ return; }
        portMsgOnData(
          element.key,
          data: data,
          isWeightMsgReverseOrder: element.isWeightMsgReverseOrder,
          accuracy: element.accuracy,
        );
        return null;
      });
      element.weightMsgConnectService!.onInit();
    });
  }

  @override
  Future<bool> initializeForm() async {
    if (orderOpenType == 1){
      //todo 如果[orderOpenType] == 1，根据[deviceWB.objectId]获取任务单
      //次品页面也一样
    }
    setFormJudgeTypeMap();
    setWeightFormDecimalLengthMap();
    setSubmitDataAndAdapter(
      isInit: true,
      progId: progId,
      workCenterId: workCenterId,
      deviceId: deviceWBModelWithGetxController?.model.deviceId,
      deviceCode: deviceWBModelWithGetxController?.model.deviceCode,
      deviceName: deviceWBModelWithGetxController?.model.deviceName,
      opId: deviceWBModelWithGetxController?.model.opId,
      opName: deviceWBModelWithGetxController?.model.opName,
      workBillEntryId: deviceWBModelWithGetxController?.model.wbMxId,
      inspectFlag: deviceWBModelWithGetxController?.model.inspectOpFlag,
      pieceRate: deviceWBModelWithGetxController?.model.pieceRate,
    );
    getInventoryInfo(orderModel.productId ?? '').then((value) {
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
                SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY
            ),
            theLastPackingWeightValue: ShareStorageUtil.instance?.read(
                SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY
            ),
            theLastSingleBoxQty: ShareStorageUtil.instance?.read(
                SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY
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
            ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_SELECTED_PSN_LIST_KEY) ?? [],
          );
          return false;
        }
        return true;
      });
    }

    return true;
  }



  //region OnChanged

  @override
  void submitTypeOnChanged(ChoiceChipModel item) {
    if (submitType == item.keyName){ return; }
    super.submitTypeOnChanged(item);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_TYPE_KEY, submitType);
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
            SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY
        ),
        theLastPackingWeightValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY
        ),
        theLastSingleBoxQty: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY
        ),
      );
    }

    update();
  }

  @override
  void containerOnChanged(PickerDataModel model) {
    super.containerOnChanged(model);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY, model.id);
  }

  @override
  Future<void> psnOnChanged(List<PickerDataModel> list, {bool isPostNeedChanged = true}) async{
    await super.psnOnChanged(list, isPostNeedChanged: orderOpenType != 1);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_SELECTED_PSN_LIST_KEY, list.map((e) => e.toJson()).toList());
  }

  ///切换当任务单（通过扫码、其他页面切换）
  Future<void> getOtherOrder(MoOpOrderModel item, {bool isOtherPageNeedChanged = true, InventoryModel? inventoryModel, MoWorkBillEntryModel? workBillEntryModel}) async{
    assert((isOtherPageNeedChanged && inventoryModel == null) || ((!isOtherPageNeedChanged && inventoryModel != null)));
    if (orderModel.moOrderId == item.moOrderId){
      return;
    }
    orderModel = item;
    await setSubmitDataAndAdapter(
      isInit: false,
      deviceId: deviceWBModelWithGetxController?.model.deviceId,
      deviceCode: deviceWBModelWithGetxController?.model.deviceCode,
      deviceName: deviceWBModelWithGetxController?.model.deviceName,
      opId: workBillEntryModel?.opId,
      opName: workBillEntryModel?.opName,
      workBillEntryId: workBillEntryModel?.wbMxId,
      inspectFlag: workBillEntryModel?.inspectOpFlag,
      pieceRate: workBillEntryModel?.pieceRate,
    );
    if (inventoryModel == null){
      await getInventoryInfo(orderModel.productId ?? '');
    }
    else {
      this.inventoryModel = inventoryModel;
    }
    if (isOtherPageNeedChanged){
      if (!showAppBar){
        mesOrderDetailTabController.orderModel = MoOpOrderModel.fromJson(orderModel.toJson());
        mesOrderDetailTabController.key = orderModel.moOrderId;
        mesOrderDetailTabController.invId = orderModel.productId ?? '';
      }

      //region 刷新报工单列表的数据
      MesSubmitListController? submitListController;
      try {
        submitListController = Get.find<MesSubmitListController>();
      } catch (e){}
      if (submitListController != null){
        submitListController.dataListPageConfig.queryData!['MoOrderId'] = item.moOrderId;
        submitListController.processAdapter = await AdapterHelper.getAsyncAdapter(
          'process',
          multipleSelection: false,
          isNeedLoadData: false,
          queryData: {
            'wbId': item.wbId,
            'invId': item.productId,
          },
          selectedItems: []
        ) as ProcessAdapter;
        await submitListController.pageChanged(showLoading: false);
        submitListController.update();
      }
      //endregion

      //region 次品录入页面的任务单数据也改变
      MesOrderCheckRecordController? mesOrderCheckRecordController;
      try {
        mesOrderCheckRecordController = Get.find<MesOrderCheckRecordController>();
      } catch (e){}
      if (mesOrderCheckRecordController != null){
        await mesOrderCheckRecordController.getOtherOrder(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel, workBillEntryModel: workBillEntryModel);
        mesOrderCheckRecordController.update();
      }
      //endregion

      //region 不良品上报页面页面的任务单数据也改变
      MesOrderMaterialRejectController? mesOrderMaterialRejectController;
      try {
        mesOrderMaterialRejectController = Get.find<MesOrderMaterialRejectController>();
      } catch (e){}
      if (mesOrderMaterialRejectController != null){
        await mesOrderMaterialRejectController.getOtherOrder(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel, workBillEntryModel: workBillEntryModel);
        mesOrderMaterialRejectController.update();
      }
      //endregion

      //region 刷新次品记录列表的数据
      MesCheckRecordListController? checkRecordListController;
      try {
        checkRecordListController = Get.find<MesCheckRecordListController>();
      } catch (e){}
      if (checkRecordListController != null){
        checkRecordListController.dataListPageConfig.queryData!['MoOrderId'] = item.moOrderId;
        checkRecordListController.processAdapter = await AdapterHelper.getAsyncAdapter(
            'process',
            multipleSelection: false,
            isNeedLoadData: false,
            queryData: {
              'wbId': item.wbId,
              'invId': item.productId,
            },
            selectedItems: []
        ) as ProcessAdapter;
        await checkRecordListController.pageChanged(showLoading: false);
        checkRecordListController.update();
      }
      //endregion
    }
  }

  ///自动提交按钮选中变化（按序列号报工时使用）
  void autoCommitSubmitOnChanged() {
    super.autoCommitSubmitOnChanged();
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_AUTO_COMMIT_FOR_SERIAL_NUMBER_SUBMIT_TYPE_KEY, autoCommitSubmit);
    update();
  }

  //endregion


  //region NumPad SetEnabled + 计算

  void numPadCTListSetEnabled() {
    switch (submitType){
      case AppConfig.qtySubmit:
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, false, numPadCTList); ///单箱皮重
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList); ///入库箱数（装箱数）(整箱)
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList); ///单箱重量
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList); ///尾箱重量
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///报工总重
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList); ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重）
        break;
      case AppConfig.qtyBoxSubmit:
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, false, numPadCTList); ///单箱皮重
        NumPadUtil().setEnabled(NumPadUtil.num, true, numPadCTList); ///入库箱数（装箱数）(整箱)
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, !isUsePackingPicker || !isSingleBoxQtyOnlyChangedByContainer, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, true, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList); ///单箱重量
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList); ///尾箱重量
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///报工总重
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList); ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重）
        break;
      case AppConfig.mesWeightSubmit:
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, !isUsePackingPicker, numPadCTList); ///单箱皮重
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList); ///入库箱数（装箱数）(整箱)
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList); ///单箱重量
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList); ///尾箱重量
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, true, numPadCTList); ///报工总重
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList); ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重）
        break;
      case AppConfig.mesWeightBoxSubmit:
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, !isUsePackingPicker, numPadCTList); ///单箱皮重
        NumPadUtil().setEnabled(NumPadUtil.num, true, numPadCTList); ///入库箱数（装箱数）(整箱)
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, true, numPadCTList); ///单箱重量
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, true, numPadCTList); ///尾箱重量
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, true, numPadCTList); ///报工总重
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList); ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重）
        break;
      case AppConfig.palletSubmit:
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, false, numPadCTList); ///单箱皮重
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList); ///入库箱数（装箱数）(整箱)
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, true, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, true, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, true, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList); ///单箱重量
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList); ///尾箱重量
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///报工总重
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, true, numPadCTList); ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重）
        break;
      case AppConfig.serialNumberSubmit:
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, false, numPadCTList); ///单箱皮重
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList); ///入库箱数（装箱数）(整箱)
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList); ///单箱重量
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList); ///尾箱重量
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///报工总重
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList); ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重）
        break;
      case AppConfig.singleBoxSerialNumberSubmit:
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, false, numPadCTList); ///单箱皮重
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList); ///入库箱数（装箱数）(整箱)
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, true, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList); ///单箱重量
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList); ///尾箱重量
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///报工总重
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList); ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重）
        break;
    }
  }

  ///数据填报后的计算
  void calcQty(String keyName) {
    numPadDebounce((){
      if (keyName == NumPadUtil.packingWeight){
        ///填写皮重数据时，把填写的数据保存到本地
        double? packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '');
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY, packingWeight);
      }
      else if (keyName == NumPadUtil.singleBoxQty){
        double? singleBoxQty = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '');
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY, singleBoxQty);
      }

      if (submitType == AppConfig.qtyBoxSubmit){ ///按数量（多箱）报工
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
      else if (submitType == AppConfig.mesWeightBoxSubmit){ ///按重量（多箱）报工
        switch (keyName){
          case NumPadUtil.singleBoxWeight:  ///单箱重量
          case NumPadUtil.lastBoxWeight: ///尾箱重量
          case NumPadUtil.num: ///入库箱数 (整箱箱数)
            ///计算总重量
            getWeightByWBSubmitType();
            break;
          case NumPadUtil.weight: ///总重量
            getBoxNumByWBSubmitType();
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

      weightOverlayStreamController.add(
        NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '0'
      );

     update();
    });
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

  ///按重量（多箱）报工时 计算报工总重量：整箱箱数 * 单箱重量 + 尾箱重量
  void getWeightByWBSubmitType(){
    ///整箱箱数
    int num = int.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '') ?? 1;
    ///单箱重量
    double singleBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '') ?? 0;
    ///尾箱重量
    double lastBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxWeight, numPadCTList) ?? '') ?? 0;
    ///报工总重
    String weightString = (num * singleBoxWeight + lastBoxWeight).toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.weight]!);
    NumPadUtil().setText(NumPadUtil.weight, weightString, numPadCTList);
  }

  ///按重量（多箱）报工时，计算整箱箱数：总重量 / 单箱重量，取整
  ///                    计算尾箱重量：总重量 / 单箱重量，取余数
  void getBoxNumByWBSubmitType() {
    ///报工总重量
    double _weight = double.tryParse(NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '') ?? 0;
    ///单箱重量
    double _singleBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '') ?? 0;
    int _num = _weight == 0 || _singleBoxWeight == 0 ? 0 : _weight ~/ _singleBoxWeight;
    double _lastBoxWeight = _weight == 0 || _singleBoxWeight == 0 ? 0 : _weight % _singleBoxWeight;
    String _numString = _num > 0 ? _num.toString() : '';
    String _lastBoxWeightString = _lastBoxWeight > 0 ? _lastBoxWeight.toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.lastBoxWeight]!) : '';
    NumPadUtil().setText(NumPadUtil.num, _numString, numPadCTList);
    NumPadUtil().setText(NumPadUtil.lastBoxWeight, _lastBoxWeightString, numPadCTList);
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
      case WeightMsgConnectService.dSPackingWeight:
        //region 单箱皮重
        if (isUsePackingPicker || submitType != AppConfig.mesWeightBoxSubmit || submitType != AppConfig.mesWeightSubmit){ return; }
        //region 数据处理
        String formatValue = '';
        if (data.length > 3 && data.substring(0, 3) == '|O|'){ ///容器条码(周转箱条码): |O|序列号|皮重
          List<String> _list  = data.split('|');
          formatValue = weightMsgConnectService.getFormatValue(_list.last);
        }
        else {
          formatValue = weightMsgConnectService.getFormatValue(
            data,
            isWeightMsgReverseOrder: isWeightMsgReverseOrder,
          );
        }
        //endregion
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '';
        bool isLessThen = weightMsgConnectService.isWithinAcceptableErrorRange(
            oldValue: double.tryParse(_oldString),
            value: double.tryParse(formatValue) ?? 0,
            errorRange: accuracy
        );
        if (isLessThen){ return; }
        //endregion
        NumPadUtil().setText(NumPadUtil.packingWeight, formatValue, numPadCTList, isDataByWeightMsg: true);
        calcQty(NumPadUtil.packingWeight);
        //endregion
        break;
      case WeightMsgConnectService.dSSingleBoxWeight:
        //region 单箱重量
        if (submitType != AppConfig.mesWeightBoxSubmit) { return; }
        String formatValue = weightMsgConnectService.getFormatValue(
          data,
          isWeightMsgReverseOrder: isWeightMsgReverseOrder,
        );
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '';
        bool isLessThen = weightMsgConnectService.isWithinAcceptableErrorRange(
            oldValue: double.tryParse(_oldString),
            value: double.tryParse(formatValue) ?? 0,
            errorRange: accuracy
        );
        if (isLessThen){ return; }
        //endregion
        NumPadUtil().setText(NumPadUtil.singleBoxWeight, formatValue, numPadCTList, isDataByWeightMsg: true);
        calcQty(NumPadUtil.singleBoxWeight);
        //endregion
        break;
      case WeightMsgConnectService.dSLastBoxWeight:
        //region 尾箱重量
        if (submitType != AppConfig.mesWeightBoxSubmit) { return; }
        String formatValue = weightMsgConnectService.getFormatValue(
          data,
          isWeightMsgReverseOrder: isWeightMsgReverseOrder,
        );
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.lastBoxWeight, numPadCTList) ?? '';
        bool isLessThen = weightMsgConnectService.isWithinAcceptableErrorRange(
            oldValue: double.tryParse(_oldString),
            value: double.tryParse(formatValue) ?? 0,
            errorRange: accuracy
        );
        if (isLessThen){ return; }
        //endregion
        NumPadUtil().setText(NumPadUtil.lastBoxWeight, formatValue, numPadCTList, isDataByWeightMsg: true);
        calcQty(NumPadUtil.lastBoxWeight);
        //endregion
        break;
      case WeightMsgConnectService.dSWeight:
        //region 报工总重
        if (submitType != AppConfig.mesWeightSubmit && submitType != AppConfig.mesWeightBoxSubmit) { return; }
        String formatValue = weightMsgConnectService.getFormatValue(
          data,
          isWeightMsgReverseOrder: isWeightMsgReverseOrder,
        );
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '';
        bool isLessThen = weightMsgConnectService.isWithinAcceptableErrorRange(
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
      case WeightMsgConnectService.scanGun:
      case WeightMsgConnectService.cardReader:
        onBarcode(data);
        break;
    }
  }


  @override
  Future<void> onBarcode(String searchString) async{
    if (kDebugMode){
      //searchString = '|F|610001|2426495a-9129-41e2-86fd-b8b73aadc906';
      //searchString = '|T|610001|6f5b58f2-be9d-4ef4-91cc-1ccb00c7355b';
      //searchString = '|G|AS001_0115';
      //searchString = '|X|24050506';
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
        //region 工序条码 610001（扫码该条码后，工艺也选中了）
        if (list.length == 4){
          if (list[2] == '610001'){
            if ((submitModel.workBillEntryId ?? '').split(',').contains(list[3])){
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            var wbRes = await MoWorkBillEntryRepository().getMoWorkBillEntry(list[3]);
            if (!wbRes.isSuccess){
              TipsUtils.showTip(
                msg: '获取工序信息时出错：${wbRes.message}',
                toastType: ToastType.error,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (orderOpenType == 1 && wbRes.data.opId != deviceWBModelWithGetxController?.model.currentOp?.opId){
              TipsUtils.showTip(
                msg: '当前设备未生产该工序！',
                toastType: ToastType.error,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (orderOpenType == 1 && wbRes.data.deviceId != null && wbRes.data.deviceId != deviceWBModelWithGetxController?.model.deviceId){
              TipsUtils.showTip(
                msg: '该工序已经在其他设备上生产！',
                toastType: ToastType.error,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (wbRes.data.wbMxId.isEmpty){
              TipsUtils.showTip(
                msg: '未查询到工序信息！',
                toastType: ToastType.error,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if ((wbRes.data.objectId ?? '').isEmpty){
              TipsUtils.showTip(
                msg: '该工序未绑定到任务单！',
                toastType: ToastType.error,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (submitModel.moOrderId != wbRes.data.objectId){
              var orderRes = await MoOrderRepository().getFormData(wbRes.data.objectId!);
              if (!orderRes.isSuccess){
                TipsUtils.showTip(
                  msg: '获取指定条件的任务单时出错：${orderRes.message}',
                  toastType: ToastType.error,
                );
                isLoading = false;
                ProgressDialogUtil.close();
                return;
              }
              if (orderOpenType == 1 && orderRes.data.deviceId != null && orderRes.data.deviceId != deviceWBModelWithGetxController?.model.deviceId){
                TipsUtils.showTip(
                  msg: '该任务单已经被分配到其他设备！',
                  toastType: ToastType.error,
                );
                isLoading = false;
                ProgressDialogUtil.close();
                return;
              }
              if (orderRes.data.moOrderId.isEmpty){
                TipsUtils.showTip(
                  msg: '未查询到任务单信息！',
                  toastType: ToastType.error,
                );
                isLoading = false;
                ProgressDialogUtil.close();
                return;
              }
              await getOtherOrder(orderRes.data, workBillEntryModel: wbRes.data);
            }
            await processAdapter?.validModelValue(wbRes.data.id);
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
        //region 生产任务单条码 610001
        if (list.length == 4){
          if (list[2] == '610001'){
            if (submitModel.moOrderId == list[3]){
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            var orderRes = await MoOrderRepository().getFormData(list[3]);
            if (!orderRes.isSuccess){
              TipsUtils.showTip(
                msg: '获取生产任务单时出错：${orderRes.message}',
                toastType: ToastType.error,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (orderOpenType == 1 && orderRes.data.deviceId != null && orderRes.data.deviceId != deviceWBModelWithGetxController?.model.deviceId){
              TipsUtils.showTip(
                msg: '该任务单已经被分配到其他设备！',
                toastType: ToastType.error,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (orderRes.data.moOrderId.isEmpty){
              TipsUtils.showTip(
                msg: '未查询到任务单信息！',
                toastType: ToastType.error,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            MoWorkBillEntryModel? workBillEntryModel;
            if (orderOpenType == 1){
              var wbRes = await MoWorkBillRepository().getFormData(orderRes.data.wbId, '', {}, 0);
              if (!wbRes.isSuccess){
                TipsUtils.showTip(
                  msg: '获取工序信息时出错：${wbRes.message}',
                  toastType: ToastType.error,
                );
                isLoading = false;
                ProgressDialogUtil.close();
                return;
              }
              workBillEntryModel = wbRes.data.entryList.firstWhereOrNull((element) => element.opId == deviceWBModelWithGetxController?.model.opId);
              if (workBillEntryModel == null){
                TipsUtils.showTip(
                  msg: '该任务单没有符合当前设备生产的工序！',
                  toastType: ToastType.error,
                );
                isLoading = false;
                ProgressDialogUtil.close();
                return;
              }
              if (orderOpenType == 1 && workBillEntryModel.opId != deviceWBModelWithGetxController?.model.currentOp?.opId){
                TipsUtils.showTip(
                  msg: '当前设备未生产该工序！',
                  toastType: ToastType.error,
                );
                isLoading = false;
                ProgressDialogUtil.close();
                return;
              }
              if (orderOpenType == 1 && workBillEntryModel.deviceId != null && workBillEntryModel.deviceId != deviceWBModelWithGetxController?.model.deviceId){
                TipsUtils.showTip(
                  msg: '该工序已经在其他设备上生产！',
                  toastType: ToastType.error,
                );
                isLoading = false;
                ProgressDialogUtil.close();
                return;
              }
              if (workBillEntryModel.wbMxId.isEmpty){
                TipsUtils.showTip(
                  msg: '未查询到工序信息！',
                  toastType: ToastType.error,
                );
                isLoading = false;
                ProgressDialogUtil.close();
                return;
              }
            }
            await getOtherOrder(orderRes.data, workBillEntryModel: workBillEntryModel);
            if (workBillEntryModel != null){
              await processAdapter?.validModelValue(workBillEntryModel.id);
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
        if (orderOpenType == 1){
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
            msg: '条码错误！',
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
        /// 先获取序列号信息、任务单信息，然后判断：
        ///
        /// <任务单是否一致 N> => [获取并切换任务单] => <切换后有选中工序，且只选中一条 Y> => [判断序列号的报工情况：未通过则退出；通过，则选中扫描的序列号，写入报工数量，如果是自动报工，则执行报工并退出]
        /// <任务单是否一致 N> => [获取并切换任务单] => <切换后有选中工序，且只选中一条 N> => [清空选中的工序，并提示“选择工序后再次扫描”]
        ///
        /// <任务单是否一致 Y> => <有选中工序，且只选中一条 Y> => [判断序列号的报工情况：未通过则退出；通过，则选中扫描的序列号，写入报工数量，如果是自动报工，则执行报工并退出]
        /// <任务单是否一致 Y> => <有选中工序，且只选中一条 N> => [清空选中的工序，并提示“选择工序后再次扫描”]
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
        if (submitType == AppConfig.singleBoxSerialNumberSubmit){
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
        }
        //endregion
        String string = list[2];
        void exit({int? errCode = 1, String? msg}) {
          if (errCode != null){
            serialNumberBarcodeMap.addAll({string: errCode});
          }
          if ((submitType == AppConfig.serialNumberSubmit || submitType == AppConfig.singleBoxSerialNumberSubmit)
              && autoCommitSubmit){
            setIsAutoCommitSuccess(false);
          }
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

        ///任务单不一致，先切换任务单
        if (!isBMoSN && orderSNModel != null && orderSNModel.moOrderId != submitModel.moOrderId){
          ///先获取任务单具体信息
          var orderRes = await MoOrderRepository().getFormData(orderSNModel.moOrderId!);
          if (!orderRes.isSuccess){
            return exit(errCode: 2, msg: '获取指定条件的任务单时出错：${orderRes.message}');
          }
          if (orderOpenType == 1
              && orderRes.data.deviceId != null
              && orderRes.data.deviceId != deviceWBModelWithGetxController?.model.deviceId){
            return exit(msg: '该任务单已经被分配到其他设备！');
          }
          if (orderRes.data.moOrderId.isEmpty){
            return exit(msg: '未查询到任务单信息！');
          }
          MoWorkBillEntryModel? workBillEntryModel;
          if (orderOpenType == 1){
            var wbRes = await MoWorkBillRepository().getFormData(orderRes.data.wbId, '', {}, 0);
            if (!wbRes.isSuccess){
              return exit(errCode: 2, msg: '获取工序信息时出错：${wbRes.message}！');
            }
            workBillEntryModel = wbRes.data.entryList.firstWhereOrNull((element) => element.opId == deviceWBModelWithGetxController?.model.opId);
            if (workBillEntryModel == null){
              return exit(msg: '该任务单没有符合当前设备生产的工序！');
            }
            if (orderOpenType == 1 && workBillEntryModel.opId != deviceWBModelWithGetxController?.model.currentOp?.opId){
              return exit(msg: '当前设备未生产该工序！');
            }
            if (orderOpenType == 1 && workBillEntryModel.deviceId != null && workBillEntryModel.deviceId != deviceWBModelWithGetxController?.model.deviceId){
              return exit(msg: '该工序已经在其他设备上生产！');
            }
            if (workBillEntryModel.wbMxId.isEmpty){
              return exit(msg: '未查询到工序信息！');
            }
          }
          orderRes.data.orderSN = string;
          ///切换到该任务单
          await getOtherOrder(orderRes.data, workBillEntryModel: workBillEntryModel);
          ///选择工序
          if (workBillEntryModel != null){
            await processAdapter?.validModelValue(workBillEntryModel.id);
          }
        }
        else {
          orderModel.orderSN = string;
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
                invCCode: orderModel.invCCode,
                needCheckQty: false,
                needCheckOp: false,
                needCheckSN: false,
              );
              if (checkMap.containsKey(false)){
                return exit(msg: checkMap[false]!);
              }
            }
            await orderSNAdapter?.validViewValue([orderSNModel ?? MoOrderSNModel(id: string, code: string)]);
            orderSNOnChanged([orderSNModel ?? MoOrderSNModel(id: string, code: string)]);
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
          orderSNOnChanged(list);
          if (singleBoxSerialNumberSubmitAutoCommit){
            ///数量符合，可以执行自动提交
            ///报工提交前检查，未通过则退出
            Map<bool, String> checkMap = submitCheck(
              isPrint: true,
              invCCode: orderModel.invCCode,
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

        /*///有选中的工序，且只选中一条
        if ((submitModel.opId ?? '').isNotEmpty && submitModel.opId!.split(',').length == 1){
          ///写入序列号前，需要先判断序列号的报工情况：
          ///未通过，退出；
          ///通过，（如果是自动报工，且按序列号报工，则需要先提交前检查）选中扫描的序列号，写入报工数量（如果是自动报工，则执行报工前检查并报工，最后退出）；
          bool isCanContinue = await checkOpSerialNumber(string);
          if (!isCanContinue){
            ///[checkOpSerialNumber()] 中已写入 [serialNumberBarcodeMap]，也执行了 msg
            return exit(errCode: null);
          }
          if (submitType == AppConfig.serialNumberSubmit){
            if (autoCommitSubmit){
              Map<bool, String> checkMap = submitCheck(
                isPrint: false,
                invCCode: orderModel.invCCode,
                needCheckQty: false,
                needCheckOp: false,
                needCheckSN: false,
              );
              if (checkMap.containsKey(false)){
                return exit(msg: checkMap[false]!);
              }
            }
            await orderSNAdapter?.validViewValue([orderSNModel ?? MoOrderSNModel(id: string, code: string)]);
            orderSNOnChanged([orderSNModel ?? MoOrderSNModel(id: string, code: string)]);
            if (autoCommitSubmit){
              ///此时所有报工数据都已填写完成，符合自动报工的条件，直接提交报工记录
              isLoading = false;
              update();
              ProgressDialogUtil.close();
              serialNumberBarcodeMap.addAll({string: 200});
              await saveSubmit(false, byAutoSubmit: true);
              return;
            }
          }
          else if (submitType == AppConfig.singleBoxSerialNumberSubmit){
            List<MoOrderSNModel> list = orderSNAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
            list.add(orderSNModel ?? MoOrderSNModel(id: string, code: string));
            await orderSNAdapter?.validViewValue(list);
            orderSNOnChanged(list);
            if (singleBoxSerialNumberSubmitAutoCommit){
              ///数量符合，可以执行自动提交
              ///报工提交前检查，未通过则退出
              Map<bool, String> checkMap = submitCheck(
                isPrint: true,
                invCCode: orderModel.invCCode,
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
          }
          serialNumberBarcodeMap.addAll({string: 200});
        }*/

        /*///没有选中工序，或者选中多条
        else {
          ///清空选中的工序列表，并提示
          submitModel.workBillEntryId = null;
          submitModel.opId = null;
          submitModel.opName = null;
          submitModel.inspectFlag = null;
          submitModel.pieceRate = null;
          processAdapter?.clearSelection();
          return exit(msg: '当前没有选中工序，或选中多条，请重新选择工序后再次扫描序列号条码！');
        }*/
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
  Future<void> saveSubmit(bool isPrint, {bool byAutoSubmit = false}) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (!byAutoSubmit){
      ///报工提交前检查
      Map<bool, String> checkMap = submitCheck(
        isPrint: isPrint,
        invCCode: orderModel.invCCode,
      );
      if (checkMap.containsKey(false)){
        ToastNotification(Get.overlayContext!).error(checkMap[false]!);
        isLoading = false;
        return;
      }
      //region 超量报工判断 任务单 + 工序计划单
      Map<String, double?>? opQtyMap;
      Map<String, double?>? opSubmitQtyMap;
      if ((submitModel.opId ?? '').isNotEmpty){
        opQtyMap = {};
        opSubmitQtyMap = {};
        List<String> submitOpIdList = submitModel.opId!.split(',');
        List<MoWorkBillEntryModel> opList = processAdapter?.dataList.where(
                (element) => submitOpIdList.contains(element.opId ?? '')).toList() ?? [];
        opList.forEach((element) {
          opQtyMap!.addAll({element.wbMxId: element.qty});
          opSubmitQtyMap!.addAll({element.wbMxId: element.qualifiedQty});
        });
      }
      bool overSubmitCheckRes = await overSubmitCheck(
        qty: orderModel.qty ?? 0,
        submitQty: orderModel.submitQty ?? 0,
        opQtyMap: opQtyMap,
        opSubmitQtyMap: opSubmitQtyMap,
      );
      if (!overSubmitCheckRes){
        isLoading = false;
        return;
      }
      //endregion
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
      max: 2 + (isPrint ? 1 : 0) + (isPrint && isNeedCreateStock ? 1 : 0),
      msg: '正在提交报工记录',
      completedMsg: isPrint && isNeedCreateStock
          ? '生产入库单生成成功'
          : isPrint
          ? '打印成功'
          : '刷新成功！',
      completionDelay: byAutoSubmit ? 1500 : ProgressDialogUtil.defaultCompletionDelay,
    );
    //region 提交报工记录
    setSubmitDataBeforeSave();
    var res = await MoOpSubmitRepository().submitFormData(submitModel, bMoSN: isBMoSN);
    if (!res.isSuccess){
      if (byAutoSubmit){
        ///自动报工，提交失败时，也要清空填写的序列号
        await orderSNAdapter?.validViewValue([]);
        orderSNOnChanged([]);
      }
      setIsAutoCommitSuccess(false);
      TipsUtils.showTip(
        msg: '报工记录提交失败！${res.message}！',
        toastType: ToastType.error,
      );
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
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
    ///刷新本页面的工序
    var refreshProcessAdapter = await AdapterHelper.getAsyncAdapter(
      'process',
      queryData: {
        'wbId': orderModel.wbId,
        'invId': orderModel.productId,
      },
      isNeedLoadData: true,
    ) as ProcessAdapter;
    await processAdapter?.resetData(
      noFilterDataList: refreshProcessAdapter.noFilterDataList,
      postIdList: postIdList,
    );
    ///刷新本页面的任务单数据
    var orderRes = await MoOrderRepository().getFormData(submitModel.moOrderId!);
    if (!orderRes.isSuccess){
      ToastNotification(Get.overlayContext!).warn("任务单数据刷新失败！");
    }
    else {
      orderModel = MoOpOrderModel.fromJson(orderRes.data.toJson());
    }
    //region 首页：当前报工的任务单
    if (orderOpenType == 0){
      try {
        MesOrderController mesOrderController = Get.find<MesOrderController>();
        MoOpOrderModel? order = mesOrderController.dataList.firstWhereOrNull((element) => element.moOrderId == submitModel.moOrderId);
        if (order != null){
          bool isExpanded = order.isExpanded;
          String orderSN = order.orderSN;
          order.fromJson(orderModel.toJson());
          order.isExpanded = isExpanded;
          order.orderSN = orderSN;
        }
        mesOrderController.update();
      } catch (e){}
    }
    else if (orderOpenType == 1){
      /*try { //todo
        if (deviceWB?.currentOrder?.moOrderId == submitModel.moOrderId){
          var wbRes = await MoWorkBillRepository().getFormData(orderModel.wbId, '', {}, 0);
          if (!wbRes.isSuccess){
            ToastNotification(Get.overlayContext!).warn("工序计划单数据刷新失败！");
          }
          else {
            MoWorkBillEntryModel? workBillEntryModel = wbRes.data.entryList.firstWhereOrNull((element) => element.opId == deviceWB?.opId);
            if (workBillEntryModel != null){
              deviceWB?.fromFormJson(workBillEntryModel.toJson());
            }
          }
          deviceWB?.currentOrder!.fromJson(orderModel.toJson());
        }
        deviceWB?.update();
      } catch (e){}*/
    }
    else if (orderOpenType == 2){
      try {
        MesWorkCenterController mesWorkCenterController = Get.find<MesWorkCenterController>();
        MoOpOrderModel? order = mesWorkCenterController.orderList.firstWhereOrNull((element) => element.moOrderId == submitModel.moOrderId);
        if (order != null){
          bool isExpanded = order.isExpanded;
          String orderSN = order.orderSN;
          order.fromJson(orderModel.toJson());
          order.isExpanded = isExpanded;
          order.orderSN = orderSN;
        }
        mesWorkCenterController.update();
      } catch (e){}
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
    //region 报次品页面：工序列表的合格数量；当前报工任务单的已质检数量
    MesOrderCheckRecordController? orderCheckRecordController;
    try {
      orderCheckRecordController = Get.find<MesOrderCheckRecordController>();
    } catch (e){}
    if (orderCheckRecordController != null){
      if (orderCheckRecordController.orderModel.moOrderId == submitModel.moOrderId){
        await orderCheckRecordController.processAdapter?.resetData(
          noFilterDataList: refreshProcessAdapter.noFilterDataList,
          postIdList: orderCheckRecordController.postIdList,
        );
        orderCheckRecordController.orderModel = MoOpOrderModel.fromJson(orderRes.data.toJson());
      }
      orderCheckRecordController.update();
    }
    //endregion
    //region 不良品上报页面：当前任务单刷新
    MesOrderMaterialRejectController? orderMaterialRejectController;
    try {
      orderMaterialRejectController = Get.find<MesOrderMaterialRejectController>();
    } catch (e){}
    if (orderMaterialRejectController != null){
      if (orderMaterialRejectController.orderModel.moOrderId == submitModel.moOrderId){
        await orderMaterialRejectController.processAdapter?.resetData(
          noFilterDataList: refreshProcessAdapter.noFilterDataList,
          postIdList: orderMaterialRejectController.postIdList,
        );
        orderMaterialRejectController.orderModel = MoOpOrderModel.fromJson(orderRes.data.toJson());
      }
      orderMaterialRejectController.update();
    }
    //endregion
    ///刷新报工填报区域的数据
    await resetSubmitDataAfterSave(byAutoSubmit: byAutoSubmit);
    ///历史皮重数据赋值
    if (isSaveTheLastPackingWeightData){
      await setTheLastPackingWeightData(
        theLastContainerSelectedValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY
        ),
        theLastPackingWeightValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY
        ),
        theLastSingleBoxQty: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.MES_ORDER_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY
        ),
      );
    }
    update();
    ProgressDialogUtil.update(value: 2, msg: '${isPrint ? '数据刷新成功，正在打印！' : null}');
    //endregion
    //region 打印
    if (isPrint) {
      Map<bool, String> printRes = await printSubmitBarcode(
        moOpSubmitId: res.data.data,
        printerUrl: printerUrl,
        printerName: printerName,
        printCopies: printCopies,
        printType: printType,
        orderModel: orderModel,
        billCode: orderModel.billCode ?? '',
        submitType: submitType,
        invMnemCode: inventoryModel.invMnemCode ?? '',
      );
      if (printRes.containsKey(true)) {
        ProgressDialogUtil.update(value: 3, msg: '${isNeedCreateStock ? '打印成功，正在生成生产入库单' : null}');
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
    //region 打印后生成生产入库单（执行到这一步的时候报工单和条码一定生成成功）
    if (isPrint && isNeedCreateStock && !res.data.data.toString().contains(',')){
      Map<bool, String> stockRes = await createStock(res.data.data);
      if (stockRes.containsKey(true)) {
        ProgressDialogUtil.update(value: 4);
      }
      else {
        TipsUtils.showTip(
          msg: stockRes[false] ?? '',
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
      await ProgressDialogUtil.awaitCompletionDelay(
        completionDelay: byAutoSubmit ? 3000 : ProgressDialogUtil.defaultCompletionDelay
      );
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
        AppConfig.billDateForm: billDateReportItem(context),
      AppConfig.depForm: depReportItem(context),
      AppConfig.teamForm: teamReportItem(context),
      if (wcDataReportType == 0)
        AppConfig.lineForm: lineReportItem(context)
      else if (wcDataReportType == 1)
        AppConfig.workCenterForm: workCenterReportItem(context)
      else if (wcDataReportType == 2)
        AppConfig.teamGroupForm: teamGroupReportItem(context),
      if (wcDataReportType != 0 && orderOpenType != 1)
        AppConfig.deviceForm: deviceReportItem(context),
      if (wcDataReportType != 2)
        AppConfig.personForm: personReportItem(context),
      if (submitType == AppConfig.serialNumberSubmit)
        AppConfig.orderSNForm: orderSNReportItem(context),
      if (submitType == AppConfig.singleBoxSerialNumberSubmit)
        AppConfig.processForm: processReportItem(context),

      if (submitType == AppConfig.qtySubmit)
        ...{
          NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
        }
      else if (submitType == AppConfig.qtyBoxSubmit)
        ...{
          NumPadUtil.num: numPadReportItem(context, NumPadUtil.num),
          NumPadUtil.singleBoxQty: singleBoxQtyReportItem(context),
          NumPadUtil.lastBoxQty: numPadReportItem(context, NumPadUtil.lastBoxQty),
          NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
        }
      else if (submitType == AppConfig.mesWeightSubmit)
        ...{
          NumPadUtil.packingWeight: containerReportItem(context),
          NumPadUtil.weight: numPadReportItem(context, NumPadUtil.weight),
        }
      else if (submitType == AppConfig.mesWeightBoxSubmit)
        ...{
          NumPadUtil.packingWeight: containerReportItem(context),
          NumPadUtil.num: numPadReportItem(context, NumPadUtil.num),
          NumPadUtil.singleBoxWeight: numPadReportItem(context, NumPadUtil.singleBoxWeight),
          NumPadUtil.lastBoxWeight: numPadReportItem(context, NumPadUtil.lastBoxWeight),
          NumPadUtil.weight: numPadReportItem(context, NumPadUtil.weight),
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
          NumPadUtil.singleBoxQty: singleBoxQtyReportItem(context),
          NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
        }
    });
    formTitleMap.forEach((key, value) {
      if (itemAreaWidgetMap.containsKey(key)){
        itemWidgetList.add(itemAreaWidgetMap[key]!);
      }
    });
    int space = (itemWidgetList.length / 2).ceil();
    bool isShowProcessArea = submitType != AppConfig.singleBoxSerialNumberSubmit
        && processAdapter != null && processAdapter!.dataList.isNotEmpty
        && orderOpenType != 1;
    bool isShowSubmitInfo = submitType != AppConfig.serialNumberSubmit
        && submitType != AppConfig.singleBoxSerialNumberSubmit;
    bool isShowSNArea = submitType == AppConfig.singleBoxSerialNumberSubmit;
    return Column(
      children: [
        if (isShowProcessArea || isShowSNArea)
          Container(
            constraints: BoxConstraints(
              maxHeight: 430,
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
          )
        else
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints){
                double _itemHeight = 72;
                double _needHeight = _itemHeight * itemWidgetList.length;
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
          ),

        if (isShowProcessArea)
          Expanded(
            child: processViewWidget(
              context,
              processAttachRouter: orderOpenType == 0
                  ? AppRoutes.MES_ORDER_DETAIL_ATTACH_PAGE
                  : orderOpenType == 2
                  ? AppRoutes.MES_WORK_CENTER_ORDER_DETAIL_ATTACH_PAGE
                  : '',
              needRightArea: submitType != AppConfig.serialNumberSubmit
                  && submitType != AppConfig.singleBoxSerialNumberSubmit,
            ),
          )
        else if (isShowSubmitInfo)
          Container(
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ScrollbarTheme(
                      data: ScrollbarThemeData(
                        interactive: false,
                        thumbVisibility: WidgetStateProperty.all(false),
                        trackVisibility: WidgetStateProperty.all(false),
                        thumbColor: WidgetStateProperty.all(Colors.transparent),
                        trackColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: submitInfoWidget(context, constraints),
                        ),
                      )
                  );
                }
            ),
          )
        else if (isShowSNArea)
          Expanded(
            child: snViewWidget(context),
          )
      ],
    );
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
            ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_WEIGHT_OVERLAY_DX_KEY, weightOverlayOffset.dx);
            ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_WEIGHT_OVERLAY_DY_KEY, weightOverlayOffset.dy);
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
                          ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_WEIGHT_OVERLAY_DX_KEY, weightOverlayOffset.dx);
                          ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_WEIGHT_OVERLAY_DY_KEY, weightOverlayOffset.dy);
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
    connectList.forEach((element){
      if (element.weightMsgConnectService != null){
        element.weightMsgConnectService!.onClose();
        element.weightMsgConnectService = null;
      }
    });
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