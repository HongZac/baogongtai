import 'dart:async';

import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/service/tcp_serial/utils/tcp_serial_data_utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/p_mes_task_submit_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_print_barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/check_record/device_check_record_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/detail/device_detail_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/material_reject/device_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/submit_list/pmes_submit_list_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import '../../../../../../../utils/app_config.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../detail_board_controller.dart';


///机台报工页
class DeviceSubmitController
    extends BaseFormController
    with InfoFormInterface,
        SerialPortGetXListenerMixin<DeviceSubmitController>, ScanInterface<DeviceSubmitController>,
        TcpSocketGetxListenerMixin<DeviceSubmitController>,
        InvClassFrxNameInterface,
        SubmitPrintBarcodeInterface,
        SubmitInterface, PMesTaskSubmitInterface,
        InterfaceUtil {

  late final DeviceDetailBoardController deviceDetailBoardController;

  ///上一个页面选中的设备（实时监测）
  final String deviceId;
  late final ModelWithGetxController<MoDeviceTaskModel> deviceTaskModelWithGetxController = Get.find<ModelWithGetxController<MoDeviceTaskModel>>(tag: 'PMesDevice-$deviceId');

  ///实时监测派工单表单页面-数据字段列表
  final List<InfoFormModel> taskInfoFormList = [];

  @override
  final List<NumPadController> numPadCTList = [
    NumPadController(key: NumPadUtil.eBWeight), ///称重重量(g)
    NumPadController(key: NumPadUtil.eBPiece), ///称重件数
    NumPadController(key: NumPadUtil.pieceWeight, enabled: false), ///实际单重(g)
    NumPadController(key: NumPadUtil.packingWeight), ///单箱皮重(kg)
    NumPadController(key: NumPadUtil.num), ///入库箱数（装箱数）(整箱箱数)
    NumPadController(key: NumPadUtil.boxNumOfPallet), ///单托箱数 只读，总数量 / 单箱数量，有余数进一位
    NumPadController(key: NumPadUtil.singleBoxQty), ///单箱数量 单箱件数（一箱里面装几个）（从数据库中读取，且数据可修改）
    NumPadController(key: NumPadUtil.lastBoxQty), ///尾箱数量 尾箱件数（箱子中数量未装满）（按托报工时，只读）
    NumPadController(key: NumPadUtil.singleBoxWeight), ///单箱重量(kg)
    NumPadController(key: NumPadUtil.lastBoxWeight), ///尾箱重量(kg)
    NumPadController(key: NumPadUtil.qty), ///报工总数量
    NumPadController(key: NumPadUtil.weight), ///报工总重(kg)
    NumPadController(key: NumPadUtil.boxWeight), ///箱重（按托报工时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重） (kg)
  ];

  @override
  bool get isHavePackingWeightReport => submitType == AppConfig.qtySubmit
      || submitType == AppConfig.qtyBoxSubmit
      || submitType == AppConfig.weightSubmit
      || submitType == AppConfig.weightBoxSubmit;

  @override
  bool get isHaveSingleBoxQtyReport => submitType == AppConfig.qtyBoxSubmit
      || submitType == AppConfig.palletSubmit;

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  final bool showAppBar;


  DeviceSubmitController({
    super.progId = 651051,
    required this.deviceId,
    this.showAppBar = true,
    this.noPermission = false,
    this.permissionInfo = '',
  });


  @override
  void onInit() async{
    super.onInit();

    List<dynamic> taskInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_INFO_FORM_LIST_KEY) ?? [];
    taskInfoFormList.clear();
    taskInfoFormList.addAll(
      getInfoFormListByStorage(
        taskInfoFormMapList,
        AppConfig.pMesTaskInfoFormList
      )
    );

    submitBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_BTN_INDEX_KEY) ?? AppConfig.submitBtnIndex;
    isShowMakeUpBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
    isGetBackAfterCommitSuccess = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
    isShowDataReportTypeBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
    submitType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_TYPE_KEY) ?? AppConfig.qtySubmit;
    calcRuleForPalletSubmitType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_CALC_RULE_FOR_PALLET_SUBMIT_TYPE_KEY) ?? AppConfig.calcRuleForPalletSubmitType;
    String formTitleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_FORM_TITLE_MAP_KEY) ?? '';
    formTitleMap.clear();
    formTitleMap.addAll(getFormTitleMapByStorage(formTitleMapStr, AppConfig.pMesSubmitFormTitleMap));
    numPadCTList.sort((a, b){
      return numPadCTListSortVoidCallback.call(formTitleMap, a, b);
    });
    String formStyleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_FORM_STYLE_MAP_KEY) ?? '';
    formStyleMap.clear();
    formStyleMap.addAll(getFormStyleMapByStorage(formStyleMapStr, AppConfig.pMesSubmitFormStyleMap));
    numPadCTList.forEach((element) {
      element.styleMap.clear();
      if (formStyleMap.containsKey(element.key)){
        element.styleMap.addAll(formStyleMap[element.key]!);
      }
    });
    numPadFocusField = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
    formRowMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_FORM_ROW_MAX_COUNT_LIMIT_KEY) ?? AppConfig.formRowMaxCountLimit;
    depGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
    wcDataReportType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_WC_DATA_REPORT_TYPE_KEY) ?? AppConfig.wcDataReportType;
    isPsnHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
    isPsnMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
    psnGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
    psnDepCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
    psnLineCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
    numMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_NUM_MAX_COUNT_LIMIT_KEY) ?? AppConfig.numMaxCountLimit;
    singleBoxQtyMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_SINGLE_BOX_QTY_MAX_COUNT_LIMIT_KEY) ?? AppConfig.singleBoxQtyMaxCountLimit;
    frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_TEMPLATE_FILENAME_KEY) ?? AppConfig.deviceSubmitPrintFileName;
    String invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMap.clear();
    invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));
    isUsePackingPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_USE_PACKING_PICKER_KEY) ?? AppConfig.isUsePackingPicker;
    isAutoWritePieceWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_AUTO_WRITE_PIECE_WEIGHT_KEY) ?? AppConfig.isAutoWritePieceWeight;
    isShowGetPieceWeightBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_GET_FIRST_INSPECT_EBWEIGHT_BTN) ?? AppConfig.isShowGetPieceWeightBtn;
    qtyIsNeedPieceWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_QTY_ISNEED_PIECEWEIGHT_KEY) ?? AppConfig.isNeedPieceWeight;
    qtyCanWeightCalcByStandWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_QTY_CAN_WEIGHT_CALC_BY_STAND_WEIGHT_KEY) ?? AppConfig.canWeightCalcByStandWeight;
    qtyBoxIsNeedPieceWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_QTY_BOX_ISNEED_PIECEWEIGHT_KEY) ?? AppConfig.isNeedPieceWeight;
    qtyBoxCanWeightCalcByStandWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_QTY_BOX_CAN_WEIGHT_CALC_BY_STAND_WEIGHT_KEY) ?? AppConfig.canWeightCalcByStandWeight;
    palletIsNeedPieceWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_PALLET_ISNEED_PIECEWEIGHT_KEY) ?? AppConfig.isNeedPieceWeight;
    palletCanWeightCalcByStandWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_PALLET_CAN_WEIGHT_CALC_BY_STAND_WEIGHT_KEY) ?? AppConfig.canWeightCalcByStandWeight;
    weightIsNeedPieceWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_WEIGHT_ISNEED_PIECEWEIGHT_KEY) ?? AppConfig.isNeedPieceWeight;
    weightIsAddPieceWeightToTotal = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_WEIGHT_IS_ADD_PIECE_WEIGHT_TO_TOTAL_KEY) ?? AppConfig.weightIsAddPieceWeightToTotal;
    weightBoxIsNeedPieceWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_WEIGHT_BOX_ISNEED_PIECEWEIGHT_KEY) ?? AppConfig.isNeedPieceWeight;
    isShowExpectSingleBoxQty = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_EXPECT_SINGLE_BOX_QTY_KEY) ?? AppConfig.isShowExpectSingleBoxQty;
    isShowInspectFlagBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_INSPECT_FLAG_BTN_KEY) ?? AppConfig.isShowInspectFlagBtn;
    isCanClickInspectFlagBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_CAN_CLICK_INSPECT_FLAG_BTN_KEY) ?? AppConfig.isCanClickInspectFlagBtn;
    inspectFlagDefaultValue = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_INSPECT_FLAG_DEFAULT_VALUE_KEY) ?? AppConfig.inspectFlagDefaultValue;
    isSaveTheLastSelectedPsnId = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;
    isSaveTheLastPackingWeightData = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY) ?? AppConfig.isSaveTheLastPackingWeightData;
    isSingleBoxQtyOnlyChangedByContainer = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY) ?? AppConfig.isSingleBoxQtyOnlyChangedByContainer;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
      if (!showAppBar){
        deviceDetailBoardController = Get.find<DeviceDetailBoardController>();
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
    //region 获取当前设备正在生产的任务 [taskModel]
    var taskRes = await MoProcessRepository().getCurrentTask(deviceId);
    if (!taskRes.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取当前设备正在生产的任务时出错：${taskRes.message}！');
      return false;
    }
    taskModel = taskRes.data;
    //endregion
    setFormJudgeTypeMap();
    setWeightFormDecimalLengthMap();
    setSubmitDataAndAdapter(
      isInit: true,
      progId: progId,
    );
    getInventoryInfo(taskModel.invId ?? '').then((value) {
      update();
    });
    getTaskAdapter(deviceId: deviceId).then((value) {
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
                SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY
            ),
            theLastPackingWeightValue: ShareStorageUtil.instance?.read(
                SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY
            ),
            theLastSingleBoxQty: ShareStorageUtil.instance?.read(
                SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY
            ),
          );
          return false;
        }
        return true;
      });
    }

    ///写入实际单重数据
    if (isAutoWritePieceWeight){
      getPieceWeightBtnOnTap();
    }

    ///写入历史选中的员工数据
    if (isSaveTheLastSelectedPsnId){
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        ///需要等待 personAdapter 被赋值后，再写入历史员工数据
        if (!isPsnHasAdapter || personAdapter != null){
          await setTheLastSelectedPsnData(
            ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_SELECTED_PSN_LIST_KEY) ?? [],
          );
          return false;
        }
        return true;
      });
    }

    return true;
  }

  Map<String, String> setAccItemMap(){
    return {'limit.weight': 'pdm'};
  }


  //region OnChanged

  @override
  void submitTypeOnChanged(ChoiceChipModel item) {
    if (submitType == item.keyName){ return; }
    super.submitTypeOnChanged(item);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_TYPE_KEY, submitType);
    numPadCTList.forEach((element) {
      element.controller.clear();
    });
    updateFormJudgeTypeMap();
    containerWithNoPageAdapter?.clearSelection();

    ///历史皮重数据赋值
    if (isSaveTheLastPackingWeightData){
      setTheLastPackingWeightData(
        theLastContainerSelectedValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY
        ),
        theLastPackingWeightValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY
        ),
        theLastSingleBoxQty: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY
        ),
      );
    }

    ///写入实际单重数据
    if (isAutoWritePieceWeight){
      getPieceWeightBtnOnTap();
    }

    update();
  }

  @override
  void containerOnChanged(PickerDataModel model) {
    super.containerOnChanged(model);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY, model.id);
  }

  @override
  Future<void> psnOnChanged(List<PickerDataModel> list) async{
    await super.psnOnChanged(list);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_SELECTED_PSN_LIST_KEY, list.map((e) => e.toJson()).toList());
  }

  @override
  Future<void> taskOnChanged(PickerDataModel model) async {
    MoTaskModel item = MoTaskModel.fromJson(model.toJson());
    await getOtherTask(item);
    update();
  }

  ///切换当派工单（通过扫码、其他页面切换）
  Future<void> getOtherTask(MoTaskModel item, {bool isOtherPageNeedChanged = true, InventoryModel? inventoryModel}) async {
    assert((isOtherPageNeedChanged && inventoryModel == null) || ((!isOtherPageNeedChanged && inventoryModel != null)));
    if (taskModel.taskId == item.taskId){
      return;
    }
    taskModel = item;
    await setSubmitDataAndAdapter(
      isInit: false,
    );
    if (inventoryModel == null){
      await getInventoryInfo(taskModel.invId ?? '');
    }
    else {
      this.inventoryModel = inventoryModel;
    }
    if (isOtherPageNeedChanged) {
      //region 次品录入页面的派工单数据也改变
      DeviceCheckRecordController? deviceCheckRecordController;
      try{
        deviceCheckRecordController = Get.find<DeviceCheckRecordController>();
      } catch (e){}
      if (deviceCheckRecordController != null){
        await deviceCheckRecordController.getOtherTask(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel);
        deviceCheckRecordController.update();
      }
      //endregion

      //region 不良品上报页面的派工单数据也改变
      DeviceMaterialRejectController? deviceMaterialRejectController;
      try {
        deviceMaterialRejectController = Get.find<DeviceMaterialRejectController>();
      } catch (e){}
      if (deviceMaterialRejectController != null){
        await deviceMaterialRejectController.getOtherTask(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel);
        deviceMaterialRejectController.update();
      }
      //endregion

      ///报工单列表、次品记录列表是根据设备 Id 筛选的，这里不需要刷新
    }
  }

  //endregion


  //region NumPad SetEnabled + 计算

  @override
  void numPadCTListSetEnabled() {
    switch (submitType){
      case AppConfig.qtySubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, qtyIsNeedPieceWeight, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, qtyIsNeedPieceWeight, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, !isUsePackingPicker, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList);
        break;
      case AppConfig.qtyBoxSubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, qtyBoxIsNeedPieceWeight, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, qtyBoxIsNeedPieceWeight, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, !isUsePackingPicker, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, !isUsePackingPicker || !isSingleBoxQtyOnlyChangedByContainer, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, true, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList);
        break;
      case AppConfig.palletSubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, palletIsNeedPieceWeight, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, palletIsNeedPieceWeight, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, true, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, true, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, true, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, true, numPadCTList);
        break;
      case AppConfig.weightSubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, weightIsNeedPieceWeight, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, weightIsNeedPieceWeight, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, !isUsePackingPicker, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, true, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList);
        break;
      case AppConfig.weightBoxSubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, weightBoxIsNeedPieceWeight, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, weightBoxIsNeedPieceWeight, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, !isUsePackingPicker, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, true, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList);
        break;
      case AppConfig.weight:
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///报工总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList);
        break;
    }
  }

  @override
  void calcQty(String keyName) {
    numPadDebounce((){
      //todo
      if (keyName == NumPadUtil.packingWeight){
        ///填写皮重数据时，把填写的数据保存到本地
        double? packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '');
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY, packingWeight);
      }
      else if (keyName == NumPadUtil.singleBoxQty){
        double? singleBoxQty = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '');
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY, singleBoxQty);
      }

      if (submitType == AppConfig.qtySubmit) { ///按数量报工
        switch (keyName){
          case NumPadUtil.eBWeight: ///称重重量(g)
          case NumPadUtil.eBPiece: ///称重件数
            getPieceWeightTC();
            getWeightByQSubmitType();
            break;
          case NumPadUtil.packingWeight: ///皮重
          case NumPadUtil.qty: /// 总件数
            getWeightByQSubmitType();
            break;
        }
      }
      else if (submitType == AppConfig.qtyBoxSubmit){ ///按数量（多箱）报工
        switch (keyName){
          case NumPadUtil.eBWeight: ///称重重量(g)
          case NumPadUtil.eBPiece: ///称重件数
            getPieceWeightTC();
            getWeightByQBSubmitType();
            break;
          case NumPadUtil.packingWeight: ///单箱皮重(kg)
          case NumPadUtil.singleBoxQty: ///单箱数量
          case NumPadUtil.lastBoxQty: ///尾箱数量
          case NumPadUtil.num: ///入库箱数（装箱数）
            getQtyByQBSubmitType();
            getWeightByQBSubmitType();
            break;
          case NumPadUtil.qty: ///总数量
            getBoxNumByQBSubmitType();
            getWeightByQBSubmitType();
            break;
        }
      }
      else if (submitType == AppConfig.palletSubmit){ ///按托报工
        switch (keyName){
          case NumPadUtil.eBWeight: ///称重重量(g)
          case NumPadUtil.eBPiece: ///称重件数
            getPieceWeightTC();
            break;
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
      else if (submitType == AppConfig.weightSubmit) { ///按重量报工
        switch (keyName){
          case NumPadUtil.eBWeight: ///称重重量(g)
          case NumPadUtil.eBPiece: ///称重件数
            getPieceWeightTC();
            getQtyByWSubmitType();
            break;
          case NumPadUtil.packingWeight: ///皮重
          case NumPadUtil.weight: ///报工总重
            getQtyByWSubmitType();
            break;
        }
      }
      else if (submitType == AppConfig.weightBoxSubmit) { ///按重量（多箱）报工
        switch (keyName){
          case NumPadUtil.eBWeight: ///称重重量(g)
          case NumPadUtil.eBPiece: ///称重件数
            getPieceWeightTC();
            getQtyByWBSubmitType();
            break;
          case NumPadUtil.packingWeight: ///单箱皮重(kg)
          case NumPadUtil.singleBoxWeight: ///单箱重量
          case NumPadUtil.lastBoxWeight: ///尾箱重量
          case NumPadUtil.num: ///入库箱数（装箱数）
            getWeightByWBSubmitType();
            getQtyByWBSubmitType();
            break;
          case NumPadUtil.weight: ///总重量
            getBoxNumByWBSubmitType();
            getQtyByWBSubmitType();
            break;
        }
      }
      else if (submitType == AppConfig.weight) { ///报单重
        switch (keyName){
          case NumPadUtil.eBWeight: ///称重重量(g)
          case NumPadUtil.eBPiece: ///称重件数
            getPieceWeightTC();
            break;
        }
      }

      if (isShowExpectSingleBoxQty
          && (submitType == AppConfig.qtyBoxSubmit || submitType == AppConfig.weightBoxSubmit)
          && (keyName == NumPadUtil.singleBoxWeight || keyName == NumPadUtil.eBWeight || keyName == NumPadUtil.eBPiece || keyName == NumPadUtil.packingWeight)){
        singleBoxWeightForExpect = double.tryParse(NumPadUtil().getText(
            NumPadUtil.singleBoxWeight, numPadCTList
        ) ?? '') ?? 0;
      }

      update();
    });
  }

  ///计算实际单重：称重重量 / 称重件数
  void getPieceWeightTC(){
    ///称重重量
    double _eBWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.eBWeight, numPadCTList) ?? '') ?? 0;
    ///称重件数
    int _eBPiece = int.tryParse(NumPadUtil().getText(NumPadUtil.eBPiece, numPadCTList) ?? '') ?? 0;
    String _pieceWeightString;
    if (_eBWeight > 0 && _eBPiece > 0){
      _pieceWeightString = (_eBWeight / _eBPiece).toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.pieceWeight]!);
    }
    else {
      _pieceWeightString = '';
    }
    double _pieceWeight = double.tryParse(_pieceWeightString) ?? 0;
    NumPadUtil().setText(NumPadUtil.pieceWeight, _pieceWeightString, numPadCTList);
    isWeightError = _pieceWeight != 0
        && ((submitType == AppConfig.qtySubmit && qtyIsNeedPieceWeight)
            || (submitType == AppConfig.qtyBoxSubmit && qtyBoxIsNeedPieceWeight)
            || (submitType == AppConfig.weightSubmit && weightIsNeedPieceWeight)
            || (submitType == AppConfig.weightBoxSubmit && weightBoxIsNeedPieceWeight)
            || submitType == AppConfig.weight)
        && ((inventoryModel.invWeight ?? 0) / _pieceWeight - 1).abs() > (limitWeightDeviationValue / 100);
  }

  ///按数量报工时，计算预计总重：实际单重(标准单重)(g) * 报工总数量 + 皮重(kg)
  void getWeightByQSubmitType(){
    ///报工总数量
    int _qty = int.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '') ?? 0;
    ///单箱皮重
    double _packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '') ?? 0;
    ///单重
    double _pieceWeight = 0;
    if (qtyIsNeedPieceWeight){ ///先判断是否需要产品重量检验，如果需要的话，就取实际单重
      _pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '') ?? 0;
    }
    else if (qtyCanWeightCalcByStandWeight){ ///如果不需要产品重量检验，并且可以根据标准单重计算总重，取标准单重
      _pieceWeight = inventoryModel.invWeight ?? 0;
    }
    String _weightString = _pieceWeight == 0
        ? ''
        : (_pieceWeight / 1000 * _qty + _packingWeight).toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.weight]!);
    NumPadUtil().setText(NumPadUtil.weight, _weightString, numPadCTList);
  }

  ///按数量（多箱）报工时，计算总件数：整箱箱数 * 单箱件数 + 尾箱件数
  void getQtyByQBSubmitType() {
    ///整箱箱数
    int _num = int.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '') ?? 1;
    ///单箱件数
    int _singleBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') ?? 0;
    ///尾箱件数
    int _lastBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxQty,numPadCTList) ?? '') ?? 0;
    ///报工总数量
    String _qtyString = (_num * _singleBoxQty + _lastBoxQty).toStringAsFixed(0);
    NumPadUtil().setText(NumPadUtil.qty, _qtyString, numPadCTList);
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

  ///按数量（多箱）报工时，计算预计总重：报工总数量 * 实际单重(标准单重)(g) + 皮重(kg) * (整箱箱数 + (尾箱件数 > 0 ? 1 : 0))
  void getWeightByQBSubmitType() {
    ///报工总数量
    int _qty = int.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '') ?? 0;
    ///单重
    double _pieceWeight = 0;
    if (qtyBoxIsNeedPieceWeight){ ///先判断是否需要产品重量检验，如果需要的话，就取实际单重
      _pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '') ?? 0;
    }
    else if (qtyBoxCanWeightCalcByStandWeight){ ///如果不需要产品重量检验，并且可以根据标准单重计算总重，取标准单重
      _pieceWeight = inventoryModel.invWeight ?? 0;
    }
    ///皮重
    double _packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '') ?? 0;
    ///整箱箱数
    int _num = int.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '') ?? 1;
    ///尾箱件数
    int _lastBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxQty, numPadCTList) ?? '') ?? 0;
    String _weightString = _pieceWeight == 0
        ? ''
        : (_qty * _pieceWeight / 1000 + _packingWeight * (_num + (_lastBoxQty > 0 ? 1 : 0))).toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.weight]!);
    NumPadUtil().setText(NumPadUtil.weight, _weightString, numPadCTList);
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
  void getQtyOfPallet(){
    int _singleBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') ?? 0;
    int _boxNumOfPallet = int.tryParse(NumPadUtil().getText(NumPadUtil.boxNumOfPallet, numPadCTList) ?? '') ?? 0;
    int _lastBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxQty, numPadCTList) ?? '') ?? 0;
    int _qty = _singleBoxQty * _boxNumOfPallet + _lastBoxQty;
    String _qtyString = _qty > 0 ? _qty.toString() : '';
    NumPadUtil().setText(NumPadUtil.qty, _qtyString, numPadCTList);
  }

  ///按重量报工时 计算预计总件数：(总重 - 皮重)kg / 实际单重(标准单重)(g)
  void getQtyByWSubmitType(){
    ///报工总重
    double _weight = double.tryParse(NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '') ?? 0;
    ///单箱皮重
    double _packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '') ?? 0;
    ///单重
    double _pieceWeight = 0;
    if (weightIsNeedPieceWeight){ ///先判断是否需要产品重量检验，如果需要的话，就取实际单重
      _pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '') ?? 0;
    }
    else { ///如果不需要产品重量检验，并且可以根据标准单重计算总数，取标准单重
      _pieceWeight = inventoryModel.invWeight ?? 0;
    }
    String _qtyString = _pieceWeight == 0 ? '' : ((_weight - _packingWeight) * 1000 / _pieceWeight).toStringAsFixed(0);
    NumPadUtil().setText(NumPadUtil.qty, _qtyString, numPadCTList);
  }

  ///按重量（多箱）报工时，计算总重量：整箱箱数 * 单箱重量 + 尾箱重量
  void getWeightByWBSubmitType() {
    ///整箱箱数
    int _num = int.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '') ?? 1;
    ///单箱重量
    double _singleBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '') ?? 0;
    ///尾箱重量
    double _lastBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxWeight, numPadCTList) ?? '') ?? 0;
    ///报工总重
    String _weightString = (_num * _singleBoxWeight + _lastBoxWeight).toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.weight]!);
    NumPadUtil().setText(NumPadUtil.weight, _weightString, numPadCTList);
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
    String _lastBoxWeightString = _lastBoxWeight > 0
        ? _lastBoxWeight.toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.lastBoxWeight]!)
        : '';
    NumPadUtil().setText(NumPadUtil.num, _numString, numPadCTList);
    NumPadUtil().setText(NumPadUtil.lastBoxWeight, _lastBoxWeightString, numPadCTList);
  }

  ///按重量（多箱）报工时，计算总件数：
  ///单箱数量 = (单箱重量(kg) - 单箱皮重(kg)) / 实际单重(标准单重)(g) (有余数进一位)
  ///尾箱数量 = (尾箱重量(kg) - 单箱皮重(kg)) / 实际单重(标准单重)(g) (有余数进一位)
  ///报工总数量 = 整箱箱数 * 单箱数量 + 尾箱数量
  void getQtyByWBSubmitType() {
    ///单箱重量
    double _singleBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '') ?? 0;
    ///尾箱重量
    double _lastBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxWeight,numPadCTList) ?? '') ?? 0;
    ///皮重
    double _packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '') ?? 0;
    ///整箱箱数
    int _num = int.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '') ?? 1;
    ///单重
    double _pieceWeight = 0;
    if (weightBoxIsNeedPieceWeight){ ///先判断是否需要产品重量检验，如果需要的话，就取实际单重
      _pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '') ?? 0;
    }
    else { ///如果不需要产品重量检验，并且可以根据标准单重计算总数，取标准单重
      _pieceWeight = inventoryModel.invWeight ?? 0;
    }

    int _singleBoxQty = _pieceWeight == 0 || _singleBoxWeight <= _packingWeight
        ? 0
        : ((_singleBoxWeight - _packingWeight) * 1000 / _pieceWeight).ceil();
    _singleBoxQty = _singleBoxQty < 0 ? 0 : _singleBoxQty;
    int _lastBoxQty = _pieceWeight == 0 || _lastBoxWeight <= _packingWeight
        ? 0
        : ((_lastBoxWeight - _packingWeight) * 1000 / _pieceWeight).ceil();
    _lastBoxQty = _lastBoxQty < 0 ? 0 : _lastBoxQty;
    int _qty = _num * _singleBoxQty + _lastBoxQty;
    NumPadUtil().setText(NumPadUtil.qty, _qty.toString(), numPadCTList);
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
    switch (key){
      case AppConfig.dSEBWeight:
        //region 称重重量
        if (submitType == AppConfig.weight){ return; }
        String formatValue = TcpSerialDataUtils.getFormatValue(
          data,
        );
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.eBWeight, numPadCTList) ?? '';
        bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
            oldValue: double.tryParse(_oldString),
            value: double.tryParse(formatValue) ?? 0,
            errorRange: accuracy
        );
        if (isLessThen){ return; }
        //endregion
        NumPadUtil().setText(NumPadUtil.eBWeight, formatValue, numPadCTList, isDataByWeightMsg: true);
        calcQty(NumPadUtil.eBWeight);
        //endregion
        break;
      case AppConfig.dSEBWeightForWeightSubmitType:
        //region 报单重的称重重量消息
        if (submitType != AppConfig.weight) { return; }
        String formatValue = TcpSerialDataUtils.getFormatValue(
          data,
        );
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.eBWeight, numPadCTList) ?? '';
        bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
            oldValue: double.tryParse(_oldString),
            value: double.tryParse(formatValue) ?? 0,
            errorRange: accuracy
        );
        if (isLessThen){ return; }
        //endregion
        NumPadUtil().setText(NumPadUtil.eBWeight, formatValue, numPadCTList, isDataByWeightMsg: true);
        calcQty(NumPadUtil.eBWeight);
        //endregion
        break;
      case AppConfig.dSPackingWeight:
        //region 单箱皮重
        if (isUsePackingPicker || submitType == AppConfig.weight || submitType == AppConfig.palletSubmit){ return; }
        //region 数据处理
        String formatValue = '';
        if (data.length > 3 && data.substring(0, 3) == '|O|'){ ///容器条码(周转箱条码): |O|序列号|皮重
          List<String> _list  = data.split('|');
          formatValue = TcpSerialDataUtils.getFormatValue(_list.last);
        }
        else {
          formatValue = TcpSerialDataUtils.getFormatValue(
            data,
          );
        }
        //endregion
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '';
        bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
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
      case AppConfig.dSSingleBoxWeight:
        //region 单箱重量
        if (isShowExpectSingleBoxQty){
          if (submitType == AppConfig.qtyBoxSubmit || submitType == AppConfig.weightBoxSubmit){
            String formatValue = TcpSerialDataUtils.getFormatValue(
              data,
            );
            //region 判断差值
            bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
                oldValue: singleBoxWeightForExpect,
                value: double.tryParse(formatValue) ?? 0,
                errorRange: accuracy
            );
            if (isLessThen){ return; }
            //endregion
            singleBoxWeightForExpect = double.tryParse(formatValue);
          }
        }
        else if (submitType == AppConfig.weightBoxSubmit) {
          String formatValue = TcpSerialDataUtils.getFormatValue(
            data,
          );
          //region 判断差值
          String _oldString = NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '';
          bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
              oldValue: double.tryParse(_oldString),
              value: double.tryParse(formatValue) ?? 0,
              errorRange: accuracy
          );
          if (isLessThen){ return; }
          //endregion
          NumPadUtil().setText(NumPadUtil.singleBoxWeight, formatValue, numPadCTList, isDataByWeightMsg: true);
          calcQty(NumPadUtil.singleBoxWeight);
        }
        //endregion
        break;
      case AppConfig.dSLastBoxWeight:
        //region 尾箱重量
        if (submitType != AppConfig.weightBoxSubmit) { return; }
        String formatValue = TcpSerialDataUtils.getFormatValue(
          data,
        );
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.lastBoxWeight, numPadCTList) ?? '';
        bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
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
      case AppConfig.dSWeight:
        //region 报工总重
        if (submitType != AppConfig.weightSubmit && submitType != AppConfig.weightBoxSubmit) { return; }
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
    }
  }

  @override
  Future<void> onBarcode(String searchString) async{
    if (isLoading){
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
      case 'F':
        //region 派工单条码 651011
        if (list.length == 4){
          if (list[2] == '651011'){
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
  Future<void> weightOnSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    Map<bool, String> checkMap = weightSaveCheck();
    if (checkMap.containsKey(false)){
      ToastNotification(Get.overlayContext!).error(checkMap[false]!);
      isLoading = false;
      return;
    }
    String _pieceWeightString = NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '';
    double _pieceWeight = double.tryParse(_pieceWeightString)!;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!,
      msg: ((inventoryModel.invWeight ?? 0) / _pieceWeight - 1).abs() > (limitWeightDeviationValue / 100)
          ? '标准单重与实际单重偏差超过${limitWeightDeviationValue}%\n'
          '标准单重：${inventoryModel.invWeight ?? 0}g\u00A0\u00A0\u00A0实际单重：${_pieceWeightString}g\n'
          '，是否继续提交？'
          : '确认提交单重记录？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交单重记录', completedMsg: '数据刷新成功！');
    //region 提交单重记录
    var res = await MouldProductRepository().changeProductWeight(
      taskModel.mouldId!,
      taskModel.invId!,
      _pieceWeight
    );
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('单重记录提交失败！${res.message}');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '单重记录提交成功，正在刷新数据！');
    //endregion
    //region 刷新
    deviceTaskModelWithGetxController.model.weight = _pieceWeight;
    taskModel.weight = _pieceWeight;
    numPadCTList.forEach((element) {
      element.controller.clear();
    });
    update();
    ProgressDialogUtil.update(value: 2);
    //endregion
    isLoading = false;
  }


  @override
  Future<void> saveSubmit(bool isPrint, {bool byAutoSubmit = false}) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
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
    );
    //region 提交报工记录
    setSubmitDataBeforeSave(inventoryModel: inventoryModel);
    var res = await MoOpSubmitRepository().submitFormData(submitModel);
    if (!res.isSuccess){
      TipsUtils.showTip(
        msg: '报工记录提交失败！${res.message}！',
        toastType: ToastType.error,
      );
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '报工记录提交成功，正在刷新数据！');
    //endregion
    //region 刷新数据
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
    //region 首页
    if (deviceTaskModelWithGetxController.model.taskId == submitModel.taskId){
      deviceTaskModelWithGetxController.model.submitQty = taskModel.submitQty;
      deviceTaskModelWithGetxController.update();
    }
    //endregion
    //region DeviceDetailController 详情页
    DeviceDetailController? deviceDetailController;
    try {
      deviceDetailController = Get.find<DeviceDetailController>();
    } catch (e){}
    if (deviceDetailController != null){
      if (deviceDetailController.taskModel.taskId == submitModel.taskId){
        deviceDetailController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
      }
      MoTaskModel? _taskModel = deviceDetailController.taskList.firstWhereOrNull((element) => element.taskId == submitModel.taskId);
      if (_taskModel != null){
        _taskModel.submitQty = taskModel.submitQty;
        _taskModel.acceptQty = taskModel.acceptQty;
      }
      deviceDetailController.update();
    }
    //endregion
    //region SubmitListController 报工单列表页面
    PMesSubmitListController? submitListController;
    try {
      submitListController = Get.find<PMesSubmitListController>();
    } catch (e){}
    if (submitListController != null){
      await submitListController.pageChanged(showLoading: false);
      submitListController.update();
    }
    //endregion
    //region DeviceCheckRecordController 次品填报页面
    DeviceCheckRecordController? deviceCheckRecordController;
    try {
      deviceCheckRecordController = Get.find<DeviceCheckRecordController>();
    } catch (e){}
    if (deviceCheckRecordController != null){
      if (deviceCheckRecordController.taskModel.taskId == submitModel.taskId){
        deviceCheckRecordController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
      }
      MoTaskModel? taskAdapterItem = deviceCheckRecordController.taskAdapter?.dataList.firstWhereOrNull(
              (element) => element.taskId == submitModel.taskId);
      if (taskAdapterItem != null){
        taskAdapterItem.submitQty = taskModel.submitQty;
        taskAdapterItem.acceptQty = taskModel.acceptQty;
      }
      deviceCheckRecordController.update();
    }
    //endregion
    //region 不良品上报页面：当前派工单刷新
    DeviceMaterialRejectController? deviceMaterialRejectController;
    try {
      deviceMaterialRejectController = Get.find<DeviceMaterialRejectController>();
    } catch (e){}
    if (deviceMaterialRejectController != null){
      if (deviceMaterialRejectController.taskModel.taskId == submitModel.taskId){
        deviceMaterialRejectController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
      }
      MoTaskModel? taskAdapterItem = deviceMaterialRejectController.taskAdapter?.dataList.firstWhereOrNull(
              (element) => element.taskId == submitModel.taskId);
      if (taskAdapterItem != null){
        taskAdapterItem.submitQty = taskModel.submitQty;
        taskAdapterItem.acceptQty = taskModel.acceptQty;
      }
      deviceMaterialRejectController.update();
    }
    //endregion
    ///刷新报次品填报区域的数据
    await resetSubmitDataAfterSave();
    ///历史皮重数据赋值
    if (isSaveTheLastPackingWeightData){
      await setTheLastPackingWeightData(
        theLastContainerSelectedValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY
        ),
        theLastPackingWeightValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY
        ),
        theLastSingleBoxQty: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.DEVICE_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY
        ),
      );
    }
    ///写入实际单重数据
    if (isAutoWritePieceWeight){
      getPieceWeightBtnOnTap();
    }
    ///写入历史选中的员工数据，已经在[resetSubmitDataAfterSave()]处理好了，这里无需再次处理
    update();
    ProgressDialogUtil.update(value: 2, msg: '${isPrint ? '数据刷新成功，正在打印！' : null}');
    //endregion
    //region 打印
    if (isPrint){
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
        deviceAddCode: deviceTaskModelWithGetxController.model.deviceAddCode ?? '',
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
    //region 生成生产入库单（执行到这一步的时候报工单和条码一定生成成功）
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
      if (submitType != AppConfig.weight)
        ...{
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
          if (wcDataReportType != 2)
            AppConfig.personForm: personReportItem(context),
        },

      if ((submitType == AppConfig.qtySubmit && qtyIsNeedPieceWeight)
          || (submitType == AppConfig.qtyBoxSubmit && qtyBoxIsNeedPieceWeight)
          || (submitType == AppConfig.palletSubmit && palletIsNeedPieceWeight)
          || (submitType == AppConfig.weightSubmit && weightIsNeedPieceWeight)
          || (submitType == AppConfig.weightBoxSubmit && weightBoxIsNeedPieceWeight)
          || submitType == AppConfig.weight)
        ...{
          NumPadUtil.eBWeight: numPadReportItem(context, NumPadUtil.eBWeight),
          NumPadUtil.eBPiece: numPadReportItem(context, NumPadUtil.eBPiece),
          NumPadUtil.pieceWeight: numPadReportItem(context, NumPadUtil.pieceWeight),
        },

      if (submitType == AppConfig.qtySubmit)
        ...{
          NumPadUtil.packingWeight: containerReportItem(context),
          NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
          NumPadUtil.weight: numPadReportItem(context, NumPadUtil.weight),
        }
      else if (submitType == AppConfig.qtyBoxSubmit)
        ...{
          NumPadUtil.packingWeight: containerReportItem(context),
          NumPadUtil.num: numPadReportItem(context, NumPadUtil.num),
          NumPadUtil.singleBoxQty: singleBoxQtyReportItem(context),
          NumPadUtil.lastBoxQty: numPadReportItem(context, NumPadUtil.lastBoxQty),
          NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
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
      else if (submitType == AppConfig.weightSubmit)
        ...{
          NumPadUtil.packingWeight: containerReportItem(context),
          NumPadUtil.weight: numPadReportItem(context, NumPadUtil.weight),
          NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
        }
      else if (submitType == AppConfig.weightBoxSubmit)
        ...{
          NumPadUtil.packingWeight: containerReportItem(context),
          NumPadUtil.num: numPadReportItem(context, NumPadUtil.num),
          NumPadUtil.singleBoxWeight: numPadReportItem(context, NumPadUtil.singleBoxWeight),
          NumPadUtil.lastBoxWeight: numPadReportItem(context, NumPadUtil.lastBoxWeight),
          NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
          NumPadUtil.weight: numPadReportItem(context, NumPadUtil.weight),
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


  @override
  Future<void> onClose() async {
    numPadDebounce.dispose();
    numPadCTList.forEach((element) {
      element.dispose();
    });
    super.onClose();
  }

}
