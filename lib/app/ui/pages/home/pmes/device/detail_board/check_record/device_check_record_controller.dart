
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
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_print_barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/p_mes_task_check_record_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/pmes/check_record_list/pmes_check_record_list_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/detail/device_detail_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/material_reject/device_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/submit/device_submit_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../detail_board_controller.dart';


///机台报工 报次品
class DeviceCheckRecordController
    extends BaseFormController
    with InfoFormInterface,
        SerialPortGetXListenerMixin<DeviceCheckRecordController>, ScanInterface<DeviceCheckRecordController>,
        TcpSocketGetxListenerMixin<DeviceCheckRecordController>,
        InvClassFrxNameInterface,
        CheckRecordPrintBarcodeInterface,
        CheckRecordInterface, PMesTaskCheckRecordInterface,
        InterfaceUtil {

  late final DeviceDetailBoardController deviceDetailBoardController;

  ///上一个页面选中的设备（实时监测）
  final String deviceId;
  late final ModelWithGetxController<MoDeviceTaskModel> deviceTaskModelWithGetxController = Get.find<ModelWithGetxController<MoDeviceTaskModel>>(tag: 'PMesDevice-$deviceId');

  ///实时监测派工单表单页面-数据字段列表
  final List<InfoFormModel> taskInfoFormList = [];

  @override
  final List<NumPadController> numPadCTList = [
    NumPadController(key: NumPadUtil.qty),
    NumPadController(key: NumPadUtil.weight),
  ];

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  final bool showAppBar;


  DeviceCheckRecordController({
    super.progId = 811010,
    required this.deviceId,
    this.showAppBar = true,
    this.noPermission = false,
    this.permissionInfo = '',
  });


  @override
  void onInit() {
    super.onInit();

    if (this is! DeviceMaterialRejectController){
      List<dynamic> taskInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_INFO_FORM_LIST_KEY) ?? [];
      taskInfoFormList.clear();
      taskInfoFormList.addAll(
          getInfoFormListByStorage(
              taskInfoFormMapList,
              AppConfig.pMesTaskInfoFormList
          )
      );

      checkRecordBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_BTN_INDEX_KEY) ?? AppConfig.checkRecordBtnIndex;
      isShowMakeUpBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
      isGetBackAfterCommitSuccess = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
      isShowDataReportTypeBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
      checkRecordType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_TYPE_KEY) ?? AppConfig.qtyCheckRecord;
      String formTitleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_FORM_TITLE_MAP_KEY) ?? '';
      formTitleMap.clear();
      formTitleMap.addAll(getFormTitleMapByStorage(formTitleMapStr, AppConfig.pMesCheckRecordFormTitleMap));
      numPadCTList.sort((a, b){
        return numPadCTListSortVoidCallback.call(formTitleMap, a, b);
      });
      String formStyleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_FORM_STYLE_MAP_KEY) ?? '';
      formStyleMap.clear();
      formStyleMap.addAll(getFormStyleMapByStorage(formStyleMapStr, AppConfig.pMesCheckRecordFormStyleMap));
      numPadCTList.forEach((element) {
        element.styleMap.clear();
        if (formStyleMap.containsKey(element.key)){
          element.styleMap.addAll(formStyleMap[element.key]!);
        }
      });
      numPadFocusField = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
      formRowMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_FORM_ROW_MAX_COUNT_LIMIT_KEY) ?? AppConfig.formRowMaxCountLimit;
      depGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
      wcDataReportType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_WC_DATA_REPORT_TYPE_KEY) ?? AppConfig.wcDataReportType;
      isPsnHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
      isPsnMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
      psnGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
      psnDepCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_PSN_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
      psnLineCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
      frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_TEMPLATE_FILENAME_KEY) ?? AppConfig.deviceCheckRecordPrintFileName;
      String invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
      invClassFrxNameMap.clear();
      invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));
      isSaveTheLastSelectedPsnId = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
        if (!showAppBar){
          deviceDetailBoardController = Get.find<DeviceDetailBoardController>();
        }
      });
      numPadCTListSetEnabled();
    }
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
    setCheckRecordDataAndAdapter(
      isInit: true,
      progId: progId,
    );
    getInventoryInfo(taskModel.invId ?? '').then((value) {
      update();
    });
    getTaskAdapter(deviceId: deviceId).then((value) {
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
                this is! DeviceMaterialRejectController
                    ? SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_THE_LAST_SELECTED_PSN_LIST_KEY
                    : SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_THE_LAST_SELECTED_PSN_LIST_KEY
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
        this is! DeviceMaterialRejectController
            ? SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_TYPE_KEY
            : SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_TYPE_KEY,
        checkRecordType
    );
    numPadCTList.forEach((element) {
      element.controller.clear();
    });
    update();
  }

  @override
  Future<void> psnOnChanged(List<PickerDataModel> list) async{
    await super.psnOnChanged(list);
    ShareStorageUtil.instance?.write(
        this is! DeviceMaterialRejectController
            ? SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_THE_LAST_SELECTED_PSN_LIST_KEY
            : SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_THE_LAST_SELECTED_PSN_LIST_KEY,
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
  Future<void> getOtherTask(MoTaskModel item, {bool isOtherPageNeedChanged = true, InventoryModel? inventoryModel}) async {
    assert((isOtherPageNeedChanged && inventoryModel == null) || ((!isOtherPageNeedChanged && inventoryModel != null)));
    if (taskModel.taskId == item.taskId){
      return;
    }
    taskModel = item;
    await setCheckRecordDataAndAdapter(
      isInit: false,
    );
    if (inventoryModel == null){
      await getInventoryInfo(taskModel.invId ?? '');
    }
    else {
      this.inventoryModel = inventoryModel;
    }
    if (isOtherPageNeedChanged) {
      //region 报工页面的派工单数据也改变
      DeviceSubmitController? deviceSubmitController;
      try{
        deviceSubmitController = Get.find<DeviceSubmitController>();
      } catch (e){}
      if (deviceSubmitController != null){
        await deviceSubmitController.getOtherTask(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel);
        deviceSubmitController.update();
      }
      //endregion

      //region 不良品上报页面/次品页面的派工单数据也改变
      if (this is! DeviceMaterialRejectController){
        DeviceMaterialRejectController? deviceMaterialRejectController;
        try {
          deviceMaterialRejectController = Get.find<DeviceMaterialRejectController>();
        } catch (e){}
        if (deviceMaterialRejectController != null){
          await deviceMaterialRejectController.getOtherTask(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel);
          deviceMaterialRejectController.update();
        }
      }
      else {
        DeviceCheckRecordController? deviceCheckRecordController;
        try {
          deviceCheckRecordController = Get.find<DeviceCheckRecordController>();
        } catch (e){}
        if (deviceCheckRecordController != null){
          await deviceCheckRecordController.getOtherTask(item, isOtherPageNeedChanged: false, inventoryModel: this.inventoryModel);
          deviceCheckRecordController.update();
        }
      }
      //endregion

      ///报工单列表、次品记录列表是根据设备 Id 筛选的，这里不需要刷新
    }
  }

  //endregion


  //region NumPad SetEnabled

  @override
  void numPadCTListSetEnabled() {
    switch (checkRecordType){
      case AppConfig.qtyCheckRecord:
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList);
        break;
      case AppConfig.weightCheckRecord:
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.weight, true, numPadCTList);
        break;
    }
  }

  @override
  void calcQty(String keyName) {
    numPadDebounce(() {
      if (checkRecordType == AppConfig.weightCheckRecord){ ///按重量报次品
        switch (keyName){
          case NumPadUtil.weight:
            getQtyByWCheckRecordType();
            break;
        }
      }
    });
  }

  void getQtyByWCheckRecordType() {
    ///次品总重
    double weight = double.tryParse(NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '') ?? 0;
    double invWeight= inventoryModel.invWeight ?? 0;
    int qty = invWeight == 0 ? 0 : (weight * 1000 / invWeight).ceil();
    String qtyString = qty > 0 ? qty.toString() : '';
    NumPadUtil().setText(NumPadUtil.qty, qtyString, numPadCTList);
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
      case AppConfig.dSWeight:
        //region 报工总重
        if (checkRecordType != AppConfig.weightCheckRecord) { return; }
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
  Future<void> saveCheckRecord(bool isPrint) async{
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
    //region 刷新数据
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
    if (deviceTaskModelWithGetxController.model.taskId == checkRecordModel.taskId){
      deviceTaskModelWithGetxController.model.disabledQty = taskModel.disabledQty;
      deviceTaskModelWithGetxController.update();
    }
    //endregion
    //region DeviceDetailController 详情页
    DeviceDetailController? deviceDetailController;
    try {
      deviceDetailController = Get.find<DeviceDetailController>();
    } catch (e){}
    if (deviceDetailController != null){
      if (deviceDetailController.taskModel.taskId == checkRecordModel.taskId){
        deviceDetailController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
      }
      MoTaskModel? _taskModel = deviceDetailController.taskList.firstWhereOrNull((element) => element.taskId == checkRecordModel.taskId);
      if (_taskModel != null){
        _taskModel.disabledQty = taskRes.data.disabledQty;
      }
      deviceDetailController.update();
    }
    //endregion
    //region PMesCheckRecordListController 次品列表页面
    PMesCheckRecordListController? checkRecordListController;
    try {
      checkRecordListController = Get.find<PMesCheckRecordListController>();
    } catch (e){}
    if (checkRecordListController != null){
      await checkRecordListController.pageChanged(showLoading: false);
      checkRecordListController.update();
    }
    //endregion
    //region SubmitController 报工填报页面
    DeviceSubmitController? deviceSubmitController;
    try {
      deviceSubmitController = Get.find<DeviceSubmitController>();
    } catch (e){}
    if (deviceSubmitController != null){
      if (deviceSubmitController.taskModel.taskId == checkRecordModel.taskId){
        deviceSubmitController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
      }
      MoTaskModel? taskAdapterItem = deviceSubmitController.taskAdapter?.dataList.firstWhereOrNull(
              (element) => element.taskId == checkRecordModel.taskId);
      if (taskAdapterItem != null){
        taskAdapterItem.disabledQty = taskRes.data.disabledQty;
      }
      deviceSubmitController.update();
    }
    //endregion
    //region 不良品上报/次品页面
    if (this is! DeviceMaterialRejectController){
      DeviceMaterialRejectController? deviceMaterialRejectController;
      try {
        deviceMaterialRejectController = Get.find<DeviceMaterialRejectController>();
      } catch (e){}
      if (deviceMaterialRejectController != null){
        if (deviceMaterialRejectController.taskModel.taskId == checkRecordModel.taskId){
          deviceMaterialRejectController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
        }
        MoTaskModel? taskAdapterItem = deviceMaterialRejectController.taskAdapter?.dataList.firstWhereOrNull(
                (element) => element.taskId == checkRecordModel.taskId);
        if (taskAdapterItem != null){
          taskAdapterItem.disabledQty = taskRes.data.disabledQty;
        }
        deviceMaterialRejectController.update();
      }
    }
    else {
      DeviceCheckRecordController? deviceCheckRecordController;
      try {
        deviceCheckRecordController = Get.find<DeviceCheckRecordController>();
      } catch (e){}
      if (deviceCheckRecordController != null){
        if (deviceCheckRecordController.taskModel.taskId == checkRecordModel.taskId){
          deviceCheckRecordController.taskModel = MoTaskModel.fromJson(taskRes.data.toJson());
        }
        MoTaskModel? taskAdapterItem = deviceCheckRecordController.taskAdapter?.dataList.firstWhereOrNull(
                (element) => element.taskId == checkRecordModel.taskId);
        if (taskAdapterItem != null){
          taskAdapterItem.disabledQty = taskRes.data.disabledQty;
        }
        deviceCheckRecordController.update();
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
        deviceAddCode: deviceTaskModelWithGetxController.model.deviceAddCode ?? '',
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
      if (wcDataReportType != 2)
        AppConfig.personForm: personReportItem(context),

      NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
      if (checkRecordType == AppConfig.weightCheckRecord)
        NumPadUtil.weight: numPadReportItem(context, NumPadUtil.weight),
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
    for (var element in numPadCTList) {
      element.dispose();
    }
    super.onClose();
  }

}