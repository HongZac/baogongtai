import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/chart_data_model.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_controller.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_view.dart';
import 'package:desktop/app/ui/pages/home/andon/andon_add/andon_add_controller.dart';
import 'package:desktop/app/ui/pages/home/andon/andon_add/andon_add_page.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/device_task_sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/create_inspection/create_inspection_controller.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/create_inspection/create_inspection_view.dart';
import 'package:desktop/app/ui/pages/over_production_process/over_production_process_controller.dart';
import 'package:desktop/app/ui/pages/over_production_process/over_production_process_view.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

import '../detail_board_controller.dart';


///设备详情
class DeviceDetailController
    extends BaseFormController
    with SignFilterInterface, DeviceTaskSignFilterInterface,
        SearchInterface,
        SerialPortGetXListenerMixin<DeviceDetailController>, ScanInterface<DeviceDetailController>,
        TcpSocketGetxListenerMixin<DeviceDetailController>,
        InfoFormInterface,
        CommandBarInterface,
        InterfaceUtil {

  late final DeviceDetailBoardController deviceDetailBoardController;

  ///上一个页面选中的设备（实时监测）
  final String deviceId;
  late final ModelWithGetxController<MoDeviceTaskModel> deviceTaskModelWithGetxController = Get.find<ModelWithGetxController<MoDeviceTaskModel>>(tag: 'PMesDevice-$deviceId');

  get searchTypeList => List.unmodifiable(AppConfig.taskSearchTypeList);
  get searchQueryDataList => List.unmodifiable(searchTypeList.map((e) => e.content).toSet().toList());

  ///实时监测派工单表单页面-数据字段列表
  final List<InfoFormModel> taskInfoFormList = [];
  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> taskListInfoFormListMap = {};
  ///设备详情按钮组列表
  final List<CommandBarBtnModel> detailCommandBarList = [];

  MoTaskModel taskModel = MoTaskModel();
  EAMDeviceModel deviceModel = EAMDeviceModel();
  ///昨日设备利用率
  double lastDayOEE = 0;
  ///近24小时OEE列表
  final List<ChartDataModel> hourOEEList = [];
  ///派工单列表
  final List<MoTaskModel> taskList = [];
  late final PageConfig taskListPageConfig = PageConfig(
    page: 1,
    rows: 50,
    sord: 'desc',
    sidx: 'TaskCode',
    queryData: {
      'progid': 651011, ///注塑
      'ExtOpFlag': 0, ///ExtOpFlag=0 去除委外工序
      'DeviceId': deviceId,
      'NoGroupCode': 1, ///去掉联产品切单
    },
  );
  MoTaskModel selectedTaskModel = MoTaskModel();
  ///派工单列表区域显示的按钮组列表
  final List<CommandBarBtnModel> taskListCommandBarList = [];

  ///读取sop技术指导书的对象，默认：700216，模具与产品关系sop
  late final int sopProgId = int.parse(dataService.accInformationMap['realtime.sop']?.itemValue ?? '700216');

  ///打印装箱单 保存的参数的方式 0：标准； 1：丹丹
  late final String printPackingType = dataService.accInformationMap['deviceTaskPrintPacking']?.itemValue ?? '0';

  final GlobalKey deviceTaskWidgetKey = GlobalKey();
  double deviceTaskWidgetHeight = 200;

  ///是否显示AppBar
  final bool showAppBar;


  DeviceDetailController({
    super.progId = 670011,
    required this.deviceId,
    this.showAppBar = true,
  });


  @override
  void onInit() async {
    super.onInit();

    isSignChipMulti = true;
    selectedTaskSignBinary = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_TADTITLES_KEY) ?? AppConfig.binaryForSignSelected;

    searchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;

    scanQueryDataList.addAll(['MoOrderId','TaskIds']);

    List<dynamic> taskInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_TASK_INFO_FORM_LIST_KEY) ?? [];
    taskInfoFormList.clear();
    taskInfoFormList.addAll(
      getInfoFormListByStorage(
        taskInfoFormMapList,
        AppConfig.pMesDeiceTaskDetailInfoFormList
      )
    );

    List<dynamic> detailCommandBarMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_TASK_COMMAND_BAR_LIST_KEY) ?? [];
    detailCommandBarList.clear();
    detailCommandBarList.addAll(
      getCommandBarListByStorage(
        detailCommandBarMapList,
        AppConfig.pMesDeviceDetailTaskCommandBarList
      )
    );

    List<dynamic> taskListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_TASK_LIST_INFO_FORM_LIST_KEY) ?? [];
    taskListInfoFormListMap.clear();
    taskListInfoFormListMap.addAll(
      getInfoFormListMap(
        getInfoFormListByStorage(
          taskListInfoFormMapList,
          AppConfig.pMesTaskListInfoFormList
        )
      )
    );

    List<dynamic> taskListCommandBarMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_TASK_LIST_COMMAND_BAR_LIST_KEY) ?? [];
    taskListCommandBarList.clear();
    taskListCommandBarList.addAll(
      getCommandBarListByStorage(
        taskListCommandBarMapList,
        AppConfig.pMesDeviceTaskListCommandBarList
      )
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
      if (!showAppBar){
        deviceDetailBoardController = Get.find<DeviceDetailBoardController>();
      }
    });
  }

  @override
  Future<void> onReady() async{
    await super.onReady();
  }

  @override
  Future<bool> initializeForm() async {
    ///数据读取完成后，res 被赋值
    bool? res1;
    bool? res2;
    bool? res3;

    getCurrentTask(deviceId).then((value) {
      res1 = value;
      update();
    });
    getDeviceModel(deviceId);
    getOEE(deviceId).then((value) {
      res2 = value;
      update();
    });
    getTaskList().then((value) {
      res3 = value;
      update();
    });

    await Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (res1 != null && res2 != null && res3 != null){
        return false;
      }
      return true;
    });

    return res1! && res2! && res3!;
  }


  void getDeviceTaskWidgetHeight() {
    Future.delayed(const Duration(milliseconds: 500), (){
      try {
        final RenderBox renderBox = deviceTaskWidgetKey.currentContext!.findRenderObject() as RenderBox;
        final Size size = renderBox.size;
        if (deviceTaskWidgetHeight != size.height){
          deviceTaskWidgetHeight = size.height;
          update();
        }
      } catch(e){
        PrintUtil.printDebug(e.toString());
      }
    });
  }


  //region 获取数据

  ///获取当前设备正在生产的任务 TaskModel
  Future<bool> getCurrentTask(String deviceId) async{
    var res = await MoProcessRepository().getCurrentTask(deviceId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取当前设备正在生产的任务时出错：${res.message}！');
      return false;
    }
    taskModel = res.data;
    return true;
  }

  ///获取设备信息
  Future<bool> getDeviceModel(String deviceId) async {
    var res = await EAMDeviceRepository().getModel(deviceId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取当前设备信息时出错：${res.message}！');
      return false;
    }
    deviceModel = res.data;
    return true;
  }

  ///获取OEE
  Future<bool> getOEE(String deviceId) async{
    ///读取数据完成后，res 被赋值
    bool? res1;
    bool? res2;

    Future.sync(() async {
      ///获取昨天OEE,注意两个日期差服务端加1天了
      DateTime lastDate = DateTime.now().add(const Duration(days: -1));
      var _ldOEE = await MoEffectiveRepository().getOEESum(
          '${DateUtil.getDateStrByDateTime(lastDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00',
          '${DateUtil.getDateStrByDateTime(lastDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00',
          deviceId
      );
      if (!_ldOEE.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取昨日OEE时出错：${_ldOEE.message}！');
        res1 = false;
        return;
      }
      else if (_ldOEE.data.isNotEmpty){
        lastDayOEE = _ldOEE.data[0] ?? 0;
      }
      res1 = true;
    });

    Future.sync(() async {
      ///近24小时OEE走势
      var hoursOEERes = await MoProcessRepository().getHourOEESum(24, deviceId);
      if (!hoursOEERes.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取近24h的OEE走势时出错：${hoursOEERes.message}！');
        res2 = false;
        return;
      }
      else if (hoursOEERes.data['Month'] != null &&  hoursOEERes.data['TimeK'] != null){
        hourOEEList.clear();
        for (int i = 0; i < hoursOEERes.data['Month']!.length; i++){
          hourOEEList.add(
              ChartDataModel(
                  hoursOEERes.data['Month']![i],
                  double.tryParse(hoursOEERes.data['TimeK']![i]) ?? 0
              )
          );
        }
      }
      res2 = true;
    });

    await Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (res1 != null && res2 != null){
        return false;
      }
      return true;
    });

    return res1! && res2!;
  }

  ///获取该机台下派工单
  Future<bool> getTaskList() async {
    taskList.clear();
    selectedTaskModel = MoTaskModel();
    await Future.forEach<MoSignModel>(taskSignList, (element) async{
      if (selectedTaskSignBinary & element.sign == element.sign){
        taskListPageConfig.queryData!['LTSign'] = element.lTSign;
        taskListPageConfig.queryData!['GESign'] = element.gESign;
        if (element.sign == 4){
          taskListPageConfig.sidx = 'TaskCode';
        }
        else {
          taskListPageConfig.sidx = 'DueStartDate';
        }
        var res = await MoTaskRepository().getPageList(taskListPageConfig);
        if (!res.isSuccess){
          ToastNotification(Get.overlayContext!).error('获取该机台下派工单列表时出错：${res.message}！');
          return false;
        }
        taskList.addAll(res.rows);
      }
    });
    return true;
  }

  //endregion


  //region OnChanged

  @override
  Future<void> signOnChanged(int sign) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    await super.signOnChanged(sign);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_DETAIL_TADTITLES_KEY, selectedTaskSignBinary);
    ProgressDialogUtil.showProgressDialog();
    var res = await getTaskList();
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1, msg: '派工单列表数据重新获取成功！');
    }
    isLoading = false;
    update();
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_DETAIL_SEARCH_TYPE_INDEX_KEY, searchTypeIndex);
    searchQueryDataOnChanged();
    if (searchTC.text.isNotEmpty){
      ProgressDialogUtil.showProgressDialog();
      var res = await getTaskList();
      if (!res){
        ProgressDialogUtil.close();
      }
      else {
        ProgressDialogUtil.update(value: 1, msg: '派工单列表数据重新获取成功！');
      }
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
    ProgressDialogUtil.showProgressDialog();
    var res = await getTaskList();
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1, msg: '派工单列表数据重新获取成功！');
    }
    isLoading = false;
    update();
  }

  @override
  Future<void> searchTCOnClear() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchFN.unfocus();
    searchTC.text = '';
    searchQueryDataOnChanged();
    ProgressDialogUtil.showProgressDialog();
    var res = await getTaskList();
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1, msg: '派工单列表数据重新获取成功！');
    }
    isSearchWidgetOpen = false;
    isLoading = false;
    update();
  }

  void searchQueryDataOnChanged() {
    taskListPageConfig.queryData!.removeWhere((key, value) => searchQueryDataList.contains(key));
    if (searchTC.text.isNotEmpty){
      String keyWord = searchTypeList[searchTypeIndex].content;
      taskListPageConfig.queryData![keyWord] = searchTC.text;
    }
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
      case AppConfig.scanGun:
      case AppConfig.cardReader:
        onBarcode(data);
        break;
    }
  }

  @override
  Future<void> resetScan() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    ProgressDialogUtil.showProgressDialog();

    await super.resetScan();
    scanQueryDataOnChanged();
    var res = await getTaskList();
    isLoading = false;
    update();
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1);
    }
  }

  @override
  Future<void> onBarcode(String searchString) async{
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
    bool res = false;
    ProgressDialogUtil.showProgressDialog(msg: '正在返回扫描结果');

    searchString = getBarCodePrefix(searchString, objectItem.attributeList);
    List<String> list = searchString.split('|');
    if (list.length < 3){
      ToastNotification(Get.overlayContext!).warn('条码错误，请检查设置的默认条码格式！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    switch (list[1]){
      case 'F':
        //region 注塑任务单条码 611001   注塑派工单 651011
        if (list.length == 4){
          if (list[2] == '611001') {
            scanQueryDataOnChanged(keyWord: 'MoOrderId', keyValue: list[3]);
            res = await getTaskList();
          }
          else if (list[2] == '651011'){
            scanQueryDataOnChanged(keyWord: 'TaskIds', keyValue: list[3]);
            res = await getTaskList();
          }
          else {
            ToastNotification(Get.overlayContext!).warn('条码错误！');
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
        }
        else {
          ToastNotification(Get.overlayContext!).warn('条码错误！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        //endregion
        break;
      default:
        ToastNotification(Get.overlayContext!).warn('条码错误！');
        isLoading = false;
        ProgressDialogUtil.close();
        return;
    }

    isDataByScan = true;
    isLoading = false;
    update();
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1);
    }
  }

  void scanQueryDataOnChanged({String? keyWord, String? keyValue}) {
    taskListPageConfig.queryData!.removeWhere((key, value) => scanQueryDataList.contains(key));
    if (keyWord != null){
      taskListPageConfig.queryData![keyWord] = keyValue;
    }
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


  //region OnTap

  ///派工单选择变化
  void taskOnSelected(MoTaskModel item){
    if (selectedTaskModel.taskId == item.taskId){
      selectedTaskModel = MoTaskModel();
    }
    else {
      selectedTaskModel = item;
    }
    update();
  }

  @override
  Future<void> infoItemOnTap(ICloneable item) async{
    taskOnSelected(item as MoTaskModel);
  }

  ///派工单 Item “展开按钮”点击变化
  void taskExpandedOnChanged(MoTaskModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }

  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    switch (keyName){
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.shiftTask}':
        item as MoTaskModel;
        await shiftTask(item);
        break;
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.swapTask}':
        item as MoTaskModel;
        await swapTask(item);
        break;
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.setFinish}':
        item as MoTaskModel;
        await finishTask(item);
        break;
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.printPacking}':
        item as MoTaskModel;
        await printPacking(item);
        break;
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.suspendTask}':
        await suspendTask();
        break;
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.setOverQty}':
        await setOverQty();
        break;
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.setAndon}':
        await onAndon();
        break;
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.createFirstInspection}':
        await onFirstInspection();
        break;
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.createPatrolInspection}':
        await onPatrolInspection();
        break;
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.createFirstCheckVoucher}':
        await onFirstCheckVoucher();
        break;
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.createPatrolCheckVoucher}':
        await onPatrolCheckVoucher();
        break;
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.invImage}':
        await getInvImage();
        break;
      case '${AppConfig.pMesDeviceDetailBtn}-${AppConfig.invAttach}':
        await getInvAttach();
        break;
    }
  }

  ///切单
  Future<void> shiftTask(MoTaskModel item) async{
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 判断
    if (item.taskId.isEmpty){
      ToastNotification(Get.overlayContext!).warn('请先选择派工单！');
      isLoading = false;
      return;
    }
    if ((item.sign ?? 0) >= MoTaskSign.scz.sign){
      ToastNotification(Get.overlayContext!).warn('该派工单不能切单！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认切单？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交切单数据', completedMsg: '数据刷新成功！');
    //region 切单
    var res = await MoProcessRepository().shiftTask(deviceId, item.taskId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交切单数据出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '切单成功，正在刷新数据！');
    //endregion

    //region 刷新数据
    bool res1 = await getCurrentTask(deviceId);
    bool res2 = await getTaskList();
    if (!res1 || !res2){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 2);
    }
    //endregion
    update();
    isLoading = false;
  }

  ///对调
  Future<void> swapTask(MoTaskModel item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 判断
    if (item.taskId.isEmpty){
      ToastNotification(Get.overlayContext!).warn('请先选择派工单！');
      isLoading = false;
      return;
    }
    if ((item.sign ?? 0) >= MoTaskSign.scz.sign){
      ToastNotification(Get.overlayContext!).warn('该派工单不能对调！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认对调？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交对调数据', completedMsg: '数据刷新成功！');
    //region 对调
    var res = await MoProcessRepository().swapTask(deviceId, item.taskId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交对调数据时出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '对调成功，正在刷新数据！');
    //endregion

    //region 刷新数据
    bool res1 = await getTaskList();
    bool res2 = await getCurrentTask(deviceId);
    if (!res1 || !res2){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 2);
    }
    //endregion
    update();
    isLoading = false;
  }

  ///设置完工
  Future<void> finishTask(MoTaskModel item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 判断
    if (item.taskId.isEmpty){
      ToastNotification(Get.overlayContext!).warn('请先选择派工单！');
      isLoading = false;
      return;
    }
    if ((item.sign ?? 0) >= MoTaskSign.ysc.sign){
      ToastNotification(Get.overlayContext!).warn('该派工单不能设置完工！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认设置完工？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交完工数据', completedMsg: '数据刷新成功！');
    //region 设置完工
    var res = await MoProcessRepository().finishTask(deviceId, item.taskId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交设置完工数据时出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '设置完工成功，正在刷新数据！');
    //endregion

    //region 刷新数据
    if (taskModel.taskId == item.taskId){
      taskModel = MoTaskModel();
    }
    bool res1 = await getTaskList();
    if (!res1){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 2);
    }
    //endregion
    update();
    isLoading = false;
  }

  ///打印装箱单
  Future<void> printPacking(MoTaskModel item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 判断
    if (item.taskId.isEmpty){
      ToastNotification(Get.overlayContext!).warn('请先选择派工单！');
      isLoading = false;
      return;
    }
    if (printPackingType == '0' && (item.packingQty == null || item.packingQty == 0)){
      ToastNotification(Get.overlayContext!).warn('装箱标准为0，请补充装箱标准后再次尝试！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认打印装箱单？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }

    Map<String, dynamic> printInfoMap = await getPrintInfo();
    String printerUrl = printInfoMap['printerUrl']!; ///打印机Url
    String printerName = printInfoMap['printerName']!; ///打印机Name
    int defaultPrintCopies = printInfoMap['printCopies']!; ///打印份数
    String printType = printInfoMap['printType']!; ///打印方式
    //region 获取模板文件名称 frxName
    String frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_PACKING_PRINT_FILE_NAME_KEY) ?? AppConfig.packingPrintFrxName;
    if (frxName.isEmpty){
      ToastNotification(Get.overlayContext!).error('打印的模板名称为空，请在设置中修改！');
      isLoading = false;
      return;
    }
    //endregion
    //region 准备打印数据
    List<BarcodeEntity> barcodeList = [];
    BarcodeEntity barcode = BarcodeEntity();
    if (printPackingType == '0'){
      barcode.progid = item.progid;
      barcode.preProgid = item.progid;
      barcode.preId = item.taskId;
      barcode.preCode = item.taskCode ?? '';
      barcode.preName = item.soCode ?? '';
      barcode.invID = item.invId ?? '';
      barcode.invCode = item.invCode ?? '';
      barcode.invName = item.invName ?? '';
      barcode.invStd = item.invStd ?? '';
      barcode.free1 = item.free1 ?? '';
      barcode.free2 = item.free2 ?? '';
      barcode.free3 = item.free3 ?? '';
      barcode.free4 = item.free4 ?? '';
      barcode.free5 = item.free5 ?? '';
      barcode.free6 = item.free6 ?? '';
      barcode.free7 = item.free7 ?? '';
      barcode.free8 = item.free8 ?? '';
      barcode.free9 = item.free9 ?? '';
      barcode.free10 = item.free10 ?? '';
      barcode.empty1 = item.gDCode ?? '';
      barcode.empty2 = item.taskDate.toString();
      barcode.empty3 = item.mouldName ?? '';
      barcode.empty4 = item.mtoNo ?? '';
      barcode.empty5 = item.mtoSeq?.toString();
      barcode.empty6 = item.invWhName ?? '';
      barcode.empty7 = item.deviceCode ?? '';
      barcode.empty8 = item.position ?? '';
      barcode.empty9 = item.packingType ?? '';
      barcode.empty10 = item.whName ?? '';
      barcode.billCode = item.taskCode;
      barcode.quantity = item.assignQty; ///生产总数
      var _remainder = (item.assignQty ?? 0) % ((item.packingQty ?? 0) <= 0 ? 1 : item.packingQty!);
      var _prnCount = (item.assignQty ?? 0) ~/ ((item.packingQty ?? 0) <= 0 ? 1 : item.packingQty!);
      barcode.prnCount = _remainder > 0 ? _prnCount + 1 : _prnCount; ///打印份数
      barcode.piece = item.packingQty ?? 0; ///单箱件数
      barcode.boxQuantity = item.packingQty ?? 0; ///单箱件数
    }
    else if (printPackingType == '1'){
      barcode.progid = item.progid;
      barcode.preProgid = item.progid;
      barcode.preId = item.taskId;
      barcode.preCode = item.taskCode ?? '';
      barcode.preName = item.soCode ?? '';
      barcode.invID = item.invId ?? '';
      barcode.invCode = item.invCode ?? '';
      barcode.invName = item.invName ?? '';
      barcode.invStd = item.invStd ?? '';
      barcode.free1 = item.free1 ?? '';
      barcode.free2 = item.free2 ?? '';
      barcode.free3 = item.free3 ?? '';
      barcode.free4 = item.free4 ?? '';
      barcode.free5 = item.free5 ?? '';
      barcode.free6 = item.free6 ?? '';
      barcode.free7 = item.free7 ?? '';
      barcode.free8 = item.free8 ?? '';
      barcode.free9 = item.free9 ?? '';
      barcode.free10 = item.free10 ?? '';
      barcode.empty1 = item.gDCode ?? '';
      barcode.empty2 = item.taskDate.toString();
      barcode.empty3 = item.mouldName ?? '';
      barcode.empty4 = item.mtoNo ?? '';
      barcode.empty5 = item.mtoSeq?.toString();
      barcode.empty6 = item.invWhName ?? '';
      barcode.empty7 = item.deviceCode ?? '';
      barcode.empty8 = item.position ?? '';
      barcode.empty9 = item.packingType ?? '';
      barcode.empty10 = item.whName ?? '';
      barcode.billCode = item.taskCode;
      barcode.quantity = item.assignQty; ///生产总数
      barcode.prnCount = 1; ///打印份数
      barcode.piece = item.packingQty ?? 0; ///单箱件数
      barcode.boxQuantity = item.packingQty ?? 0; ///单箱件数
    }
    barcodeList.add(barcode);
    //endregion

    ProgressDialogUtil.showProgressDialog(
      max: 1,
      msg: '正在打印',
      completedMsg:'打印成功！',
    );
    switch (printType){
      case 'serverPrint':
        //region 服务端打印(支持所有平台) 保存条码，返回条码列表 => 转换List<Map>类型，并增加打印字段，生成PDF，返回pdf下载地址，通过地址打印PDF
        var entityListRes = await BarcodeMainRepository().generate('', barcodeList);
        if (!entityListRes.isSuccess){
          ToastNotification(Get.overlayContext!).error("生成条码时出错：${entityListRes.message}！");
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        var listRes = await BarcodeMainRepository().getPageList(
          PageConfig(
              page: 1,
              sidx: 'Numerical',
              sord: 'asc',
              rows: entityListRes.data.length,
              queryData: {'preId': item.taskId}
          )
        );
        if (!listRes.isSuccess){
          ToastNotification(Get.overlayContext!).error("条码数据获取失败：${listRes.message}！");
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        List<Map<String, dynamic>> mapList = [];
        listRes.rows.forEach((element){
          Map<String, dynamic> map = element.toJson();
          //region
          map['ProgId'] = item.progid;
          map['SoCode'] = item.soCode;
          map['GDCode'] = item.gDCode;
          map['MtoNo'] = item.mtoNo;
          map['MtoSeq'] = item.mtoSeq;
          map['TaskId'] = item.taskId;
          map['TaskCode'] = item.taskCode;
          map['TaskDate'] = item.taskDate.toString();
          map['InvWhName'] = item.invWhName;
          map['WhName'] = item.whName;
          map['Position'] = item.position;
          map['PackingType'] = item.packingType;
          map['DeviceAddCode'] = deviceTaskModelWithGetxController.model.deviceAddCode;
          map['DeviceCode'] = item.deviceCode;
          map['DeviceName'] = item.deviceName;
          map['MouldCode'] = item.mouldCode;
          map['MouldName'] = item.mouldName;
          map['Output'] = item.output; ///标准模穴
          map['AvailOutput'] = item.availOutput; ///实际模穴
          map['OutCycle'] = item.outCycle; ///标准周期
          map['ActualCycle'] = item.actualCycle; ///实际周期
          map['Principal'] = item.principal; ///模具负责人
          map['TeamCode'] = item.teamCode;
          map['TeamName'] = item.teamName;
          map['DepCode'] = item.depCode;
          map['DepName'] = item.depName;
          map['StandWeight'] = item.weight; ///标准单重（产品单重）
          map['AssignQty'] = item.assignQty; ///派工数量
          map['Quantity'] = element.quantity; ///单箱件数 == 单箱数量（尾箱的数据可能和前几箱不一样）
          map['InvDefine1'] = item.invDefine1;
          map['InvDefine2'] = item.invDefine2;
          map['InvDefine3'] = item.invDefine3; ///材料？
          map['InvDefine4'] = item.invDefine4;
          map['InvDefine5'] = item.invDefine5;
          map['InvDefine6'] = item.invDefine6; ///颜色？
          map['InvDefine7'] = item.invDefine7;
          map['InvDefine8'] = item.invDefine8;
          map['InvDefine9'] = item.invDefine9;
          map['InvDefine10'] = item.invDefine10;
          map['CurrentStock'] = item.currentStock; ///当前库存数
          map['Free1'] = item.free1;
          map['Free2'] = item.free2;
          map['Free3'] = item.free3;
          map['Free4'] = item.free4;
          map['Free5'] = item.free5;
          map['Free6'] = item.free6;
          map['Free7'] = item.free7;
          map['Free8'] = item.free8;
          map['Free9'] = item.free9;
          map['Free10'] = item.free10;
          map['InspectFlag'] = item.inspectFlag;
          //endregion
          mapList.add(map);
        });
        String jsonStr = json.encode(
          mapList,
          toEncodable: DioService().datetimeEncode
        );
        Printer? printer = Printer(url: printerUrl, name: printerName);
        bool isPrintFinished = false;
        String printErrMsg = '';
        int copies = 0;
        AppRepository().downloadFile(
          FormRepository().getPrintUrl(
            frxName,
            null, 'pdf',
          ),
          parames: jsonStr,
          onReceiveProgress: (int current, int length){
            if (length == 0){
              length = 1;
            }
            var process = current / length;
            PrintUtil.printDebug(process.toString());
          },
          onDone: (Uint8List data) async {
            for (var page = 0; page < defaultPrintCopies; page ++) {
              bool printingRes;
              if (!kIsWeb && GetPlatform.isWindows){
                printingRes = await Printing.directPrintPdf(
                  printer: printer,
                  onLayout: (format) => Future.value(data),
                  usePrinterSettings: true,
                );
              }
              else {
                printingRes = await Printing.layoutPdf(
                  onLayout: (format) => Future.value(data),
                  usePrinterSettings: true,
                );
              }
              if (!printingRes){
                ToastNotification(Get.overlayContext!).error('打印失败${page != (defaultPrintCopies - 1) ? '，继续打印下一份' : ''}！');
                continue;
              }
              copies ++;
            }
            isPrintFinished = true;
          },
          onError: (String message){
            printErrMsg = '打印文件生成失败：$message！';
            isPrintFinished = true;
          },
        );
        await Future.doWhile(() async{
          await Future.delayed(const Duration(seconds: 1));
          if (isPrintFinished){
            return false;
          }
          return true;
        });
        if (printErrMsg.isNotEmpty){
          ToastNotification(Get.overlayContext!).error("生成PDF文件失败：$printErrMsg！");
          ProgressDialogUtil.close();
        }
        ToastNotification(Get.overlayContext!).success("打印完成，共$copies份，${listRes.rows.length * copies}张！");
        ProgressDialogUtil.update(value: 1);
        /*var barcodeRes = await BarcodeMainRepository().generatePrintMap(frxName, mapList);
        if (!barcodeRes.isSuccess){
          ToastNotification(Get.overlayContext!).error("生成PDF文件时出错：${barcodeRes.message}！");
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        ProgressDialogUtil.showProgressDialog(max: 1, msg: '正在打印装箱单', completedMsg: '打印完成！');
        String url = AddressService.getUrl(barcodeRes.data);
        Printer? printer = Printer(url: printerUrl, name: printerName);
        Uint8List printContent = await DioService().downLoadFile(url);
        if (printContent.isEmpty){
          ToastNotification(Get.overlayContext!).error('打印失败！');
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        int copies = 0;
        for (var page = 0; page < defaultPrintCopies; page ++) {
          Printing.layoutPdf(
          var printingRes = await Printing.directPrintPdf(
            printer: printer,
            onLayout: (format) => Future.value(printContent),
            usePrinterSettings: true,
          );
          if (!printingRes){
            ToastNotification(Get.overlayContext!).error('打印失败${page != (defaultPrintCopies - 1) ? '，继续打印下一份' : ''}！');
            continue;
          }
          copies ++;
        }
        ProgressDialogUtil.update(value: 1);
        ToastNotification(Get.overlayContext!).info("打印完成，共$copies份，${listRes.rows.length * copies}张！");
        isLoading = false;*/
        //endregion
        break;
      case 'localPrint':
        //region 本地打印(仅支持Windows平台) 判断是否可以打开外部打印程序 => 保存条码，返回条码列表 => 启动外部打印程序，打印
        if (kIsWeb || !GetPlatform.isWindows){
          ToastNotification(Get.overlayContext!).error("本地打印仅支持Windows平台，请在全局设置中修改打印方式！");
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        String executable = Directory.current.path + '\\nberp.Desktop.Service.Print\\nberp.Desktop.Service.Print.exe';
        if(!(await File(executable).exists())){
          ToastNotification(Get.overlayContext!).error("没有发现本地打印主程序nberp.Desktop.Service.Print.exe!");
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        var listRes = await BarcodeMainRepository().generate('', barcodeList);
        if (!listRes.isSuccess){
          ToastNotification(Get.overlayContext!).error("生成条码时出错：${listRes.message}！");
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        ProgressDialogUtil.showProgressDialog(max: 1, msg: '正在打印装箱单', completedMsg: '打印完成，共${listRes.data.length}份！');
        var base64Str = base64.encode(utf8.encode(json.encode(listRes.data.map((e) => e.toJson()).toList(), toEncodable: DioService().datetimeEncode)));
        ///写入文档
        File _testFile = File(ShareStorageUtil.printDirectory!.path +
            '\\${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}.txt');
        await _testFile.writeAsString(base64Str);
        ///打印时是否显示参数设置
        bool isShowPrintSetting = ShareStorageUtil.instance?.read(SharedPreferencesKeys.IS_SHOW_PRINT_SETTING_KEY) ?? AppConfig.isShowPrintSetting;
        List<String> arguments = [
          '-datafile', listRes.data.length > 10 ? _testFile.path : base64Str, ///如果条码份数大于10份的话，则通过 "datafile" 文件来传替打印内容
          '-file', Directory.current.path + '\\nberp.Desktop.Service.Print\\print\\$frxName',
          '-printer', printerUrl,
          '-printerdialog', isShowPrintSetting.toString()
        ];
        ///启动进程进行打印
        try {
          var process = await Process.run(executable, arguments);
          ToastNotification(Get.overlayContext!).info(process.stdout.toString());
        } catch (e){
          ToastNotification(Get.overlayContext!).error('打印失败！\n' + e.toString());
          ProgressDialogUtil.close();
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        ProgressDialogUtil.update(value: 1);
        isLoading = false;
        //endregion
        break;
    }
  }


  ///挂起
  Future<void> suspendTask() async{
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 判断
    if (dataService.isEnableOperatePrivilege
        && objectItem.buttons?['btnhugup'] == null){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? '【${objectItem.progid}】【btnhugup】' : ''}！');
      isLoading = false;
      return;
    }
    if (deviceTaskModelWithGetxController.model.taskId == null || deviceTaskModelWithGetxController.model.taskId!.isEmpty){
      ToastNotification(Get.overlayContext!).warn('该机台当前没有生产任务，不能挂起！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showCustomDialog<EditFieldController, String>(
      Get.context!,
      title: '确认挂起？',
      onConfirmName: '确认',
      barrierDismissible: false,
      initialWidth: 550, initialHeight: 260,
      contentPadding: const EdgeInsets.all(12),
      content: EditFieldView(),
      controller: EditFieldController(
        hintContent: '挂起原因',
      ),
    );
    if (dialogRes == null){
      isLoading = false;
      return;
    }
    String desc = dialogRes;
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交挂起数据', completedMsg: '数据刷新成功！');
    //region 挂起
    var res = await MoProcessRepository().suspendTask(deviceId, deviceTaskModelWithGetxController.model.taskId!, desc);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交挂起数据时出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '挂起成功，正在刷新数据！');
    //endregion

    //region 刷新数据
    bool res1 = await getTaskList();
    taskModel = MoTaskModel();
    if (!res1){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 2);
    }
    //endregion
    update();
    isLoading = false;
  }

  ///超产处理（允许超产数量变更）
  Future<void> setOverQty() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn("正在提交数据！");
      return;
    }
    isLoading = true;

    //region 进行判断
    if (dataService.isEnableOperatePrivilege
        && objectItem.buttons?['btnSetOverQty'] == null){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? '【${objectItem.progid}】【btnSetOverQty】' : ''}！');
      isLoading = false;
      return;
    }
    if (deviceTaskModelWithGetxController.model.taskId == null || deviceTaskModelWithGetxController.model.taskId!.isEmpty){
      ToastNotification(Get.overlayContext!).error('该机台当前没有生产任务，不能提交超产处理！');
      isLoading = false;
      return;
    }
    //endregion

    var dialogRes = await DialogUtils.showCustomDialog<OverProductionProcessController, Map<String, dynamic>>(
      Get.context!, title: '超产处理',
      barrierDismissible: false,
      onConfirmName: '确认',
      initialWidth: 500, initialHeight: 410,
      contentPadding: const EdgeInsets.all(12),
      content: OverProductionProcessView(),
      controller: OverProductionProcessController(
        qty: taskModel.assignQty ?? 0,
      ),
    );
    if (dialogRes == null){
      isLoading = false;
      return;
    }
    double qty = dialogRes['qty'];
    String desc = dialogRes['desc'];
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交超产处理', completedMsg: '数据刷新成功！');
    var res = await MoTaskRepository().getOverQtyResult(deviceTaskModelWithGetxController.model.taskId ?? '', qty, desc);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交超产处理数据时出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '提交成功，正在刷新数据');
    deviceTaskModelWithGetxController.model.overQty = taskModel.overQty = qty;
    deviceTaskModelWithGetxController.update();
    update();
    ProgressDialogUtil.update(value: 2);
    isLoading = false;
  }

  ///全场呼叫
  Future<void> onAndon() async {
    await DialogUtils.showCustomDialog<AndonAddController, String>(
      Get.context!,
      title: '发起新的全场呼叫',
      isMaximize: true,
      contentPadding: const EdgeInsets.all(12),
      content: AndonAddPage(),
      controller: AndonAddController(
        initDepId: deviceModel.departmentId ?? '',
        initDeviceId: deviceTaskModelWithGetxController.model.deviceId ?? '',
        initDeviceCode: deviceTaskModelWithGetxController.model.deviceCode ?? '',
        initDeviceName: deviceTaskModelWithGetxController.model.deviceName ?? '',
        isNeedSelectedIsDefault: true,
      ),
    );
  }

  ///生成首检报检单
  Future<void> onFirstInspection() async {
    await DialogUtils.showCustomDialog<CreateInspectionController, String>(
      Get.context!,
      title: '派工单生成首检报检单',
      initialWidth: 1024, initialHeight: 900,
      contentPadding: const EdgeInsets.all(0),
      content: CreateInspectionView(),
      controller: CreateInspectionController(
        category: IPQCCategory.sj.category,
        sourceProgid: taskModel.progid,
        sourceId: taskModel.taskId,
      ),
    );
  }

  ///生成巡检报检单
  Future<void> onPatrolInspection() async {
    await DialogUtils.showCustomDialog<CreateInspectionController, String>(
      Get.context!,
      title: '派工单生成巡检报检单',
      initialWidth: 1024, initialHeight: 900,
      contentPadding: const EdgeInsets.all(0),
      content: CreateInspectionView(),
      controller: CreateInspectionController(
        category: IPQCCategory.xj.category,
        sourceProgid: taskModel.progid,
        sourceId: taskModel.taskId,
      ),
    );
  }

  ///生成首检检验单
  Future<void> onFirstCheckVoucher() async {
    if (isLoading) {
      return;
    }
    isLoading = true;

    String? moInspectId;
    String? moCheckId;
    ///先检查是否生成报检单
    var inspectRes = await MoInspectRepository().getPageList(PageConfig(
      page: 1,
      rows: 1,
      sord: 'desc',
      sidx: 'ProcessDate',
      queryData: {
        'category': IPQCCategory.sj.category, ///首检
        'TaskId': taskModel.taskId,
      },
    ));
    if (!inspectRes.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取报检单数据时出错：${inspectRes.message}');
      isLoading = false;
      return;
    }
    if (inspectRes.rows.isEmpty){
      ///未生成首检报检单：跳转到报检单提交页面，提交后再跳转到检验单提交页面
      ToastNotification(Get.overlayContext!).info('请先生成报检单！');
      var res = await DialogUtils.showCustomDialog<CreateInspectionController, String>(
        Get.context!,
        title: '派工单生成首检报检单',
        initialWidth: 1024, initialHeight: 900,
        contentPadding: const EdgeInsets.all(0),
        content: CreateInspectionView(),
        controller: CreateInspectionController(
          category: IPQCCategory.sj.category,
          sourceProgid: taskModel.progid,
          sourceId: taskModel.taskId,
        ),
      );
      if (res == null || res.isEmpty){
        ToastNotification(Get.overlayContext!).error('未生成报检单，无法首检！');
        isLoading = false;
        return;
      }
      moInspectId = res;
    }
    else if (inspectRes.rows[0].sign == MoInspectSign.djy.sign) {
      ///已经生成报检单，但未生成检验单：跳转到检验单提交页面
      moInspectId = inspectRes.rows[0].moInspectId;
    }
    else if (inspectRes.rows[0].sign == MoInspectSign.jyz.sign) {
      ///已经生成报检单，已经生成检验单，但未检验完成：获取检验单，并跳转到检验单提交页面
      var res = await MoCheckVoucherRepository().getFormData(
        '', '', {'MoInspectId': moInspectId}, 0
      );
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取检验单数据时出错：${inspectRes.message}');
        isLoading = false;
        return;
      }
      moCheckId = res.data.moCheckId;
    }
    else {
      ///已经生成报检单，已经检验完成：退出该回调
      ToastNotification(Get.overlayContext!).info('首检已完成！');
      isLoading = false;
      return;
    }

    if ((moInspectId ?? '').isNotEmpty || (moCheckId ?? '').isNotEmpty){
      Get.rootDelegate.toNamed(
          AppRoutes.PMES_REAL_TIME_MONITOR_DETAIL_IPQC_QUALITY_INSPECTION_MAIN_PAGE,
          parameters: {
            'moInspectId': moInspectId ?? '',
            'moCheckId': moCheckId ?? '',
            'taskId': '',
            'taskToCheckVoucherCategory': '2',
            'openType': '1',
          }
      );
    }

    isLoading = false;
  }

  ///生成巡检检验单
  Future<void> onPatrolCheckVoucher() async {
    if (isLoading) {
      return;
    }
    isLoading = true;

    String? moInspectId;
    String? moCheckId;
    ///先检查是否生成报检单
    var inspectRes = await MoInspectRepository().getPageList(PageConfig(
      page: 1,
      rows: 1,
      sord: 'desc',
      sidx: 'ProcessDate',
      queryData: {
        'category': IPQCCategory.xj.category, ///巡检
        'TaskId': taskModel.taskId,
      },
    ));
    if (!inspectRes.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取报检单数据时出错：${inspectRes.message}');
      isLoading = false;
      return;
    }
    if (inspectRes.rows.isEmpty
        || (inspectRes.rows[0].sign != MoInspectSign.djy.sign
            && inspectRes.rows[0].sign != MoInspectSign.jyz.sign)){
      ///1. 未生成巡检报检单：跳转到报检单提交页面，提交后再跳转到检验单提交页面
      ///2. 已经生成报检单，已经检验完成：重新生成新的报检单
      ToastNotification(Get.overlayContext!).info('请先生成报检单！');
      var res = await DialogUtils.showCustomDialog<CreateInspectionController, String>(
        Get.context!,
        title: '派工单生成巡检报检单',
        initialWidth: 1024, initialHeight: 900,
        contentPadding: const EdgeInsets.all(0),
        content: CreateInspectionView(),
        controller: CreateInspectionController(
          category: IPQCCategory.xj.category,
          sourceProgid: taskModel.progid,
          sourceId: taskModel.taskId,
        ),
      );
      moInspectId = res;
    }
    else if (inspectRes.rows[0].sign == MoInspectSign.djy.sign) {
      ///已经生成报检单，但未生成检验单：跳转到检验单提交页面
      moInspectId = inspectRes.rows[0].moInspectId;
    }
    else if (inspectRes.rows[0].sign == MoInspectSign.jyz.sign) {
      ///已经生成报检单，已经生成检验单，但未检验完成：获取检验单，并跳转到检验单提交页面
      var res = await MoCheckVoucherRepository().getFormData(
        '', '', {'MoInspectId': moInspectId}, 0
      );
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取检验单数据时出错：${inspectRes.message}');
        isLoading = false;
        return;
      }
      moCheckId = res.data.moCheckId;
    }

    if ((moInspectId ?? '').isNotEmpty || (moCheckId ?? '').isNotEmpty){
      Get.rootDelegate.toNamed(
          AppRoutes.PMES_REAL_TIME_MONITOR_DETAIL_IPQC_QUALITY_INSPECTION_MAIN_PAGE,
          parameters: {
            'moInspectId': moInspectId ?? '',
            'moCheckId': moCheckId ?? '',
            'taskId': '',
            'taskToCheckVoucherCategory': '4',
            'openType': '1',
          }
      );
    }

    isLoading = false;
  }

  ///当前机台生产任务的产品图片
  Future<void> getInvImage() async {
    if (deviceTaskModelWithGetxController.model.invId == null || deviceTaskModelWithGetxController.model.invId!.isEmpty){
      ToastNotification(Get.overlayContext!).error('当前机台没有正在生产的产品！');
      return;
    }
    Get.rootDelegate.toNamed(
        AppRoutes.PMES_REAL_TIME_MONITOR_DETAIL_ATTACH_PAGE,
        parameters: {
          'pageTitle': '产品图片-${deviceTaskModelWithGetxController.model.invName}',
          'id': deviceTaskModelWithGetxController.model.invId!,
          'progId': '200025',
          'category': 'image',
        }
    );
  }

  ///当前机台生产任务的产品附件
  Future<void> getInvAttach() async {
    if (deviceTaskModelWithGetxController.model.invId == null || deviceTaskModelWithGetxController.model.invId!.isEmpty){
      ToastNotification(Get.overlayContext!).error('当前机台没有正在生产的产品！');
      return;
    }
    Get.rootDelegate.toNamed(
        AppRoutes.PMES_REAL_TIME_MONITOR_DETAIL_ATTACH_PAGE,
        parameters: {
          'pageTitle': '产品附件-${deviceTaskModelWithGetxController.model.invName}',
          'id': deviceTaskModelWithGetxController.model.invId!,
          'progId': '200025',
          'category': 'attach',
        }
    );
  }

  //endregion


  @override
  void onClose() {
    super.onClose();
  }

}