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
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/assignment_interface/assignment_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/mes_check_record_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/order_check_record_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_print_barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/check_record_list/mes_check_record_list_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/detail_tab/mes_order_detail_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/material_reject/mes_order_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/submit/mes_order_submit_controller.dart';
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产任务单 报次品页面
class MesOrderCheckRecordController
    extends BaseFormController
    with InfoFormInterface,
        SerialPortGetXListenerMixin<MesOrderCheckRecordController>, ScanInterface<MesOrderCheckRecordController>,
        TcpSocketGetxListenerMixin<MesOrderCheckRecordController>,
        AssignmentInterface,
        InvClassFrxNameInterface,
        CheckRecordPrintBarcodeInterface,
        CheckRecordInterface, MesCheckRecordInterface, OrderCheckRecordInterface,
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
    NumPadController(key: NumPadUtil.qty),
  ];

  @override
  final List<AssignmentFormModel> formList = [
    AssignmentFormModel(
      field: 'serialNumberCheckCode',
      title: '序列号校验码',
      sharedKey: SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_ASSIGNMENT_SERIAL_NUMBER_CHECK_CODE_KEY,
      dataType: 2,
      formType: 0,
      hintText: '当前允许报次品的产品序列号，可以填写多个效验码，用“,”隔开，使用“%”来进行模糊匹配序列号，例如：202507%',
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


  MesOrderCheckRecordController({
    super.progId = 811010,
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

    if (this is! MesOrderMaterialRejectController){
      List<dynamic> orderInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_INFO_FORM_LIST_KEY) ?? [];
      orderInfoFormList.clear();
      orderInfoFormList.addAll(
          getInfoFormListByStorage(
              orderInfoFormMapList,
              AppConfig.mesOrderInfoFormList
          )
      );

      checkRecordBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_BTN_INDEX_KEY) ?? AppConfig.checkRecordBtnIndex;
      isShowMakeUpBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
      isGetBackAfterCommitSuccess = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
      isShowDataReportTypeBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
      checkRecordType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_TYPE_KEY) ?? AppConfig.qtyCheckRecord;
      String formTitleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_FORM_TITLE_MAP_KEY) ?? '';
      formTitleMap.clear();
      formTitleMap.addAll(getFormTitleMapByStorage(formTitleMapStr, AppConfig.mesOrderCheckRecordFormTitleMap));
      numPadCTList.sort((a, b){
        return numPadCTListSortVoidCallback.call(formTitleMap, a, b);
      });
      String formStyleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_FORM_STYLE_MAP_KEY) ?? '';
      formStyleMap.clear();
      formStyleMap.addAll(getFormStyleMapByStorage(formStyleMapStr, AppConfig.mesOrderCheckRecordFormStyleMap));
      numPadCTList.forEach((element) {
        element.styleMap.clear();
        if (formStyleMap.containsKey(element.key)){
          element.styleMap.addAll(formStyleMap[element.key]!);
        }
      });
      numPadFocusField = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
      formRowMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_FORM_ROW_MAX_COUNT_LIMIT_KEY) ?? AppConfig.formRowMaxCountLimit;
      depGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
      wcDataReportType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_WC_DATA_REPORT_TYPE_KEY) ?? AppConfig.wcDataReportType;
      isPsnHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
      isPsnMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
      psnGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
      psnDepCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
      psnLineCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
      frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesOrderCheckRecordPrintFileName;
      String invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
      invClassFrxNameMap.clear();
      invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));
      isDeviceHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_DEVICE_HAS_ADAPTER_KEY) ?? AppConfig.isDeviceHasAdapter;
      deviceDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_DEVICE_DEP_ID_LIST_KEY) ?? [];
      deviceClassIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_DEVICE_CLASS_ID_LIST_KEY) ?? [];
      isShowOpDescription = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_SHOW_OP_DESCRIPTION_KEY) ?? AppConfig.isShowOpDescription;
      isSaveTheLastSelectedPsnId = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (!showAppBar){
          mesOrderDetailTabController = Get.find<MesOrderDetailTabController>();
        }
      });
      numPadCTListSetEnabled();
    }
  }

  @override
  Future<bool> initializeForm() async {
    setFormJudgeTypeMap();
    setWeightFormDecimalLengthMap();
    setCheckRecordDataAndAdapter(
      isInit: true,
      progId: progId,
      workCenterId: workCenterId,
      deviceId: deviceWBModelWithGetxController?.model.deviceId,
      deviceCode: deviceWBModelWithGetxController?.model.deviceCode,
      deviceName: deviceWBModelWithGetxController?.model.deviceName,
      opId: deviceWBModelWithGetxController?.model.opId,
      opName: deviceWBModelWithGetxController?.model.opName,
      workBillEntryId: deviceWBModelWithGetxController?.model.wbMxId,
    );
    getInventoryInfo(orderModel.productId ?? '').then((value) {
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
                this is! MesOrderMaterialRejectController
                    ? SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_THE_LAST_SELECTED_PSN_LIST_KEY
                    : SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_THE_LAST_SELECTED_PSN_LIST_KEY
            ) ?? [],
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
  void checkRecordTypeOnChanged(ChoiceChipModel item) {
    if (checkRecordType == item.keyName){ return; }
    super.checkRecordTypeOnChanged(item);
    ShareStorageUtil.instance?.write(
        this is! MesOrderMaterialRejectController
            ? SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_TYPE_KEY
            : SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_TYPE_KEY,
        checkRecordType
    );
    ///按序列号报次品时，不需要填写次品总数（次品总数 = 序列号个数）；
    ///反之，清空序列号相关的数据；
    if (checkRecordType == AppConfig.serialNumberCheckRecord){
      numPadCTList.forEach((element) {
        element.controller.clear();
      });
    }
    else {
      orderSNAdapter?.clearSelection();
      serialNumberBarcodeMap.clear();
      checkRecordModel.serialNumber = null;
    }
    update();
  }

  @override
  Future<void> psnOnChanged(List<PickerDataModel> list, {bool isPostNeedChanged = true}) async{
    await super.psnOnChanged(list, isPostNeedChanged: orderOpenType != 1);
    ShareStorageUtil.instance?.write(
        this is! MesOrderMaterialRejectController
            ? SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_THE_LAST_SELECTED_PSN_LIST_KEY
            : SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_THE_LAST_SELECTED_PSN_LIST_KEY,
        list.map((e) => e.toJson()).toList()
    );
  }

  ///切换当任务单（通过扫码、其他页面切换）
  Future<void> getOtherOrder(MoOpOrderModel item, {bool isOtherPageNeedChanged = true, InventoryModel? inventoryModel, MoWorkBillEntryModel? workBillEntryModel}) async{
    assert((isOtherPageNeedChanged && inventoryModel == null) || ((!isOtherPageNeedChanged && inventoryModel != null)));
    if (orderModel.moOrderId == item.moOrderId){
      return;
    }
    orderModel = item;
    await setCheckRecordDataAndAdapter(
      isInit: false,
      deviceId: deviceWBModelWithGetxController?.model.deviceId,
      deviceCode: deviceWBModelWithGetxController?.model.deviceCode,
      deviceName: deviceWBModelWithGetxController?.model.deviceName,
      opId: workBillEntryModel?.opId,
      opName: workBillEntryModel?.opName,
      workBillEntryId: workBillEntryModel?.wbMxId,
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

      //region 不良品上报页面/次品页面的任务单数据也改变
      if (this is! MesOrderMaterialRejectController) {
        MesOrderMaterialRejectController? orderMaterialRejectController;
        try {
          orderMaterialRejectController = Get.find<MesOrderMaterialRejectController>();
        } catch (e){}
        if (orderMaterialRejectController != null){
          await orderMaterialRejectController.getOtherOrder(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel, workBillEntryModel: workBillEntryModel);
          orderMaterialRejectController.update();
        }
      }
      else {
        MesOrderCheckRecordController? orderCheckRecordController;
        try {
          orderCheckRecordController = Get.find<MesOrderCheckRecordController>();
        } catch (e){}
        if (orderCheckRecordController != null){
          await orderCheckRecordController.getOtherOrder(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel, workBillEntryModel: workBillEntryModel);
          orderCheckRecordController.update();
        }
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

      //region 报工页面的任务单数据也改变
      MesOrderSubmitController? orderSubmitController;
      try {
        orderSubmitController = Get.find<MesOrderSubmitController>();
      } catch (e){}
      if (orderSubmitController != null){
        await orderSubmitController.getOtherOrder(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel, workBillEntryModel: workBillEntryModel);
        orderSubmitController.update();
      }
      //endregion

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
    }
  }

  //endregion


  //region NumPad SetEnabled

  @override
  void numPadCTListSetEnabled() {
    switch (checkRecordType){
      case AppConfig.qtyCheckRecord:
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList); ///报次品总数量
        break;
      case AppConfig.serialNumberCheckRecord:
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///报次品总数量
        break;
    }
  }

  @override
  void calcQty(String keyName) {  }

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
      case AppConfig.scanGun:
      case AppConfig.cardReader:
        onBarcode(data);
        break;
    }
  }

  @override
  Future<void> onBarcode(String searchString) async {
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
            if (checkRecordModel.workBillEntryId == list[3]){
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
            if (checkRecordModel.moOrderId != wbRes.data.objectId){
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
            if (checkRecordModel.moOrderId == list[3]){
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
            msg: '当前报次品方式不需要选择员工！',
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
            msg: '当前报次品方式不需要选择员工！',
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
        if (this is MesOrderMaterialRejectController){
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
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
            msg: '当前报次品方式不需要选择设备！',
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
        if (this is MesOrderMaterialRejectController){
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
            msg: '条码错误！',
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
      case 'X':
        //region 装配派工单条码（生产序列号条码）
        /// 先获取序列号信息、任务单信息，然后判断：
        /// <任务单不一致> => [获取任务单] => [切换到该任务单] => [选中扫描的序列号，写入报次品数量]
        ///
        /// <任务单一致> => [选中扫描的序列号，写入报次品数量]
        if (checkRecordType != AppConfig.serialNumberCheckRecord){
          TipsUtils.showTip(
            msg: '当前报次品方式不需要选择生产序列号！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        String string = list[2];
        void exit({int? errCode = 1, String? msg}) {
          if (errCode != null){
            serialNumberBarcodeMap.addAll({string: errCode});
          }
          //if ((checkRecordType == AppConfig.serialNumberCheckRecord)
          //    && autoCommitSubmit){
          //  setIsAutoCommitSuccess(false);
          //}
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
        if (orderSNModel.moOrderId != checkRecordModel.moOrderId){
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
        if (checkRecordType == AppConfig.serialNumberCheckRecord){
          ///有选中的工序，且只选中一条
          if ((checkRecordModel.opId ?? '').isNotEmpty && checkRecordModel.opId!.split(',').length == 1){
            await orderSNAdapter?.validViewValue([orderSNModel]);
            orderSNOnChanged([orderSNModel]);
            serialNumberBarcodeMap.addAll({string: 200});
          }
          ///没有选中工序，或者选中多条
          else {
            ///清空选中的工序列表，并提示
            checkRecordModel.workBillEntryId = null;
            checkRecordModel.opId = null;
            checkRecordModel.opName = null;
            processAdapter?.clearSelection();
            return exit(msg: '当前没有选中工序，或选中多条，请重新选择工序后再次扫描序列号条码！');
          }
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
  Future<void> saveCheckRecord(bool isPrint) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    Map<bool, String> checkMap = checkRecordCheck(
      isPrint: isPrint,
      invCCode: orderModel.invCCode,
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
        msg: '次品记录提交失败！${res.message}！',
        toastType: ToastType.error,
      );
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    List<String> checkRecordResDataList = (res.data.data?.toString() ?? '').isEmpty
        ? []
        : res.data.data!.toString().split(',');
    List<String> serialNumberList = (checkRecordModel.serialNumber ?? '').isEmpty
        ? []
        : checkRecordModel.serialNumber!.split(',');
    if (serialNumberList.isNotEmpty && checkRecordResDataList.length != serialNumberList.length){
      TipsUtils.showTip(
        msg: '次品记录部分提交失败！${res.message}！',
        toastType: ToastType.error,
      );
      ProgressDialogUtil.update(value: 1, msg: '次品记录部分提交成功，正在刷新数据！');
    }
    else {
      ProgressDialogUtil.update(value: 1, msg: '次品记录提交成功，正在刷新数据！');
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
    var orderRes = await MoOrderRepository().getFormData(checkRecordModel.moOrderId!);
    if (!orderRes.isSuccess){
      ToastNotification(Get.overlayContext!).warn("任务单数据刷新失败！");
    }
    else {
      orderModel = MoOpOrderModel.fromJson(orderRes.data.toJson());
    }
    //region 首页：当前报次品任务单的次品数量
    if (orderOpenType == 0){
      try {
        MesOrderController mesOrderController = Get.find<MesOrderController>();
        MoOpOrderModel? order = mesOrderController.dataList.firstWhereOrNull((element) => element.moOrderId == checkRecordModel.moOrderId);
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
        if (deviceWBModelWithGetxController?.model.currentOrder?.moOrderId == checkRecordModel.moOrderId){
          var wbRes = await MoWorkBillRepository().getFormData(orderModel.wbId, '', {}, 0);
          if (!wbRes.isSuccess){
            ToastNotification(Get.overlayContext!).warn("工序计划单数据刷新失败！");
          }
          else {
            MoWorkBillEntryModel? workBillEntryModel = wbRes.data.entryList.firstWhereOrNull((element) => element.opId == deviceWBModelWithGetxController?.model.opId);
            if (workBillEntryModel != null){
              deviceWBModelWithGetxController?.model.fromFormJson(workBillEntryModel.toJson());
            }
          }
          deviceWBModelWithGetxController?.model.currentOrder!.fromJson(orderModel.toJson());
        }
        deviceWBModelWithGetxController?.update();
      } catch (e){}*/
    }
    else if (orderOpenType == 2){
      try {
        MesWorkCenterController mesWorkCenterController = Get.find<MesWorkCenterController>();
        MoOpOrderModel? order = mesWorkCenterController.orderList.firstWhereOrNull((element) => element.moOrderId == checkRecordModel.moOrderId);
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
    //region 次品记录列表页面：刷新
    MesCheckRecordListController? checkRecordListController;
    try {
      checkRecordListController = Get.find<MesCheckRecordListController>();
    } catch (e){}
    if (checkRecordListController != null){
      await checkRecordListController.pageChanged(showLoading: false);
      checkRecordListController.update();
    }
    //endregion
    //region 报工页面：工序列表的次品数量；当前报工任务单的次品数量
    MesOrderSubmitController? orderSubmitController;
    try {
      orderSubmitController = Get.find<MesOrderSubmitController>();
    } catch (e){}
    if (orderSubmitController != null){
      if (orderSubmitController.orderModel.moOrderId == checkRecordModel.moOrderId){
        await orderSubmitController.processAdapter?.resetData(
          noFilterDataList: refreshProcessAdapter.noFilterDataList,
          postIdList: orderSubmitController.postIdList,
        );
        orderSubmitController.orderModel = MoOpOrderModel.fromJson(orderRes.data.toJson());
      }
      orderSubmitController.update();
    }
    //endregion
    //region 不良品上报/次品页面
    if (this is! MesOrderMaterialRejectController) {
      MesOrderMaterialRejectController? mesOrderMaterialRejectController;
      try {
        mesOrderMaterialRejectController = Get.find<MesOrderMaterialRejectController>();
      } catch (e){}
      if (mesOrderMaterialRejectController != null){
        if (mesOrderMaterialRejectController.orderModel.moOrderId == checkRecordModel.moOrderId){
          await mesOrderMaterialRejectController.processAdapter?.resetData(
            noFilterDataList: refreshProcessAdapter.noFilterDataList,
            postIdList: mesOrderMaterialRejectController.postIdList,
          );
          mesOrderMaterialRejectController.orderModel = MoOpOrderModel.fromJson(orderRes.data.toJson());
        }
        mesOrderMaterialRejectController.update();
      }
    }
    else {
      MesOrderCheckRecordController? mesOrderCheckRecordController;
      try {
        mesOrderCheckRecordController = Get.find<MesOrderCheckRecordController>();
      } catch (e){}
      if (mesOrderCheckRecordController != null){
        if (mesOrderCheckRecordController.orderModel.moOrderId == checkRecordModel.moOrderId){
          await mesOrderCheckRecordController.processAdapter?.resetData(
            noFilterDataList: refreshProcessAdapter.noFilterDataList,
            postIdList: mesOrderCheckRecordController.postIdList,
          );
          mesOrderCheckRecordController.orderModel = MoOpOrderModel.fromJson(orderRes.data.toJson());
        }
        mesOrderCheckRecordController.update();
      }
    }
    //endregion
    ///刷新报次品填报区域的数据
    await resetCheckRecordDataAfterSave();
    update();
    ProgressDialogUtil.update(value: 2, msg: '${isPrint ? '数据刷新成功，正在打印！' : null}');
    //endregion
    //region 打印
    if (isPrint){
      Map<bool, String> printRes = await printCheckRecordBarcode(
        moRecordId: res.data.data,
        printerUrl: printerUrl,
        printerName: printerName,
        printCopies: printCopies,
        printType: printType,
        orderModel: orderModel,
        billCode: orderModel.billCode ?? '',
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
      await ProgressDialogUtil.awaitCompletionDelay(
        completionDelay: ProgressDialogUtil.defaultCompletionDelay
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
  Widget dataReportAreaWidget(BuildContext context) {
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
      if (wcDataReportType != 0 && orderOpenType != 1)
        AppConfig.deviceForm: deviceReportItem(context),
      if (wcDataReportType != 2)
        AppConfig.personForm: personReportItem(context),
      if (checkRecordModel.disposeFlow == 7)
        AppConfig.reProcessForm: reProcessReportItem(context),
      if (checkRecordType == AppConfig.serialNumberCheckRecord)
        AppConfig.orderSNForm: orderSNReportItem(context),
      if (orderOpenType != 1)
        AppConfig.comDefectForm: comDefectReportItem(context),

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

        if (orderOpenType != 1)
          Expanded(
            child: processViewWidget(
                context,
                processAttachRouter: orderOpenType == 0
                    ? AppRoutes.MES_ORDER_DETAIL_ATTACH_PAGE
                    : orderOpenType == 2
                    ? AppRoutes.MES_WORK_CENTER_ORDER_DETAIL_ATTACH_PAGE
                    : '',
                needRightArea: checkRecordType != AppConfig.serialNumberCheckRecord,
            ),
          )
        else
          Expanded(
            child: comDefectViewWidget(context),
          ),
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