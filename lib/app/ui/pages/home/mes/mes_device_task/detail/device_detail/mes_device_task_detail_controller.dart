import 'dart:async';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
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
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/task_sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/mes_device_task_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/detail_tab/mes_task_detail_tab_controller.dart';
import 'package:desktop/app/ui/pages/over_production_process/over_production_process_controller.dart';
import 'package:desktop/app/ui/pages/over_production_process/over_production_process_view.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 设备对应生产派工单 详情
class MesDeviceTaskDetailController 
    extends BaseFormController 
    with SignFilterInterface, TaskSignFilterInterface, 
        SearchInterface,
        SerialPortGetXListenerMixin<MesDeviceTaskDetailController>, ScanInterface<MesDeviceTaskDetailController>,
        TcpSocketGetxListenerMixin<MesDeviceTaskDetailController>,
        InfoFormInterface,
        CommandBarInterface,
        InterfaceUtil {

  final MesDeviceTaskController mesDeviceTaskController = Get.find<MesDeviceTaskController>();
  late final MesTaskDetailTabController? mesTaskDetailTabController;
  ///首页 单个机器数据刷新后，通过 EventBus 通知详情页面刷新
  late final StreamSubscription<ModelWithGetxController<EAMDeviceModel>> mesDeviceTaskStreamSubscription;

  bool isOpenBarcodeInput = false;

  ///上一个页面选中的设备
  final String deviceId;
  late final ModelWithGetxController<EAMDeviceModel> eamDeviceModelWithGetxController = Get.find<ModelWithGetxController<EAMDeviceModel>>(tag: 'MesDeviceTask-$deviceId');

  get searchTypeList => List.unmodifiable(AppConfig.taskSearchTypeList);
  get searchQueryDataList => List.unmodifiable(searchTypeList.map((e) => e.content).toSet().toList());

  ///表单页面-数据字段列表
  final List<InfoFormModel> taskInfoFormList = [];
  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> taskListInfoFormListMap = {};

  final List<CommandBarBtnModel> taskListCommandBarList = [
    CommandBarBtnModel(
      title: '切单',
      icon: Icons.change_history,
      keyName: '${AppConfig.MesDeviceTaskDetailBtn}-${AppConfig.shiftTask}',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnpass',
    ),
    CommandBarBtnModel(
      title: '对调',
      icon: FluentIcons.arrow_swap_20_filled,
      keyName: '${AppConfig.MesDeviceTaskDetailBtn}-${AppConfig.swapTask}',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnswap',
    ),
    CommandBarBtnModel(
      title: '设置完工',
      icon: Icons.assignment_turned_in_outlined,
      keyName: '${AppConfig.MesDeviceTaskDetailBtn}-${AppConfig.setFinish}',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnfinish',
    ),
  ];

  MoTaskModel taskModel = MoTaskModel();
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
      'progid': 650011, ///生产
      'ExtOpFlag': 0, ///ExtOpFlag=0 去除委外工序
      'DeviceId': deviceId,
    },
  );
  MoTaskModel selectedTaskModel = MoTaskModel();
  
  final ScrollController detailController = ScrollController();
  final ScrollController taskListController = ScrollController();

  final GlobalKey deviceTaskWidgetKey = GlobalKey();
  double deviceTaskWidgetHeight = 200;


  MesDeviceTaskDetailController({
    super.progId = 670011,
    required this.deviceId,
  });


  @override
  void onInit() {
    super.onInit();
    isSignChipMulti = true;
    selectedTaskSignBinary = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_DETAIL_TADTITLES_KEY) ?? AppConfig.binaryForSignSelected;

    searchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_DETAIL_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;

    scanQueryDataList.addAll(['ObjectId']);

    List<dynamic> taskInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_DETAIL_TASK_INFO_FORM_LIST_KEY) ?? [];
    taskInfoFormList.clear();
    taskInfoFormList.addAll(
        getInfoFormListByStorage(
            taskInfoFormMapList,
            AppConfig.mesDeiceTaskDetailInfoFormList
        )
    );

    List<dynamic> taskListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_DETAIL_TASK_LIST_INFO_FORM_LIST_KEY) ?? [];
    taskListInfoFormListMap.clear();
    taskListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                taskListInfoFormMapList,
                AppConfig.mesTaskListInfoFormList
            )
        )
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
      mesTaskDetailTabController = Get.find<MesTaskDetailTabController>();
    });
  }

  @override
  Future<void> onReady() async{
    await super.onReady();

    mesDeviceTaskStreamSubscription = appService.eventBus.on<ModelWithGetxController<EAMDeviceModel>>().listen((event) async {
      eamDeviceModelWithGetxController.update();
      update();
    });
  }


  Future<bool> initializeForm() async {
    ///数据读取完成后，res 被赋值
    bool? res1;
    bool? res2;
    bool? res3;

    getCurrentTask(deviceId).then((value) {
      res1 = value;
      update();
    });
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
      if (res.rows.isNotEmpty) {
        taskModel = res.rows[0];
      }
      return true;
    }
    ToastNotification(Get.overlayContext!).error('获取当前设备正在生产的派工单时出错：找不到设备信息！');
    return false;
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

  ///获取该机台下派工单列表
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_DEVICE_TASK_DETAIL_TADTITLES_KEY, selectedTaskSignBinary);
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_DEVICE_TASK_DETAIL_SEARCH_TYPE_INDEX_KEY, searchTypeIndex);
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

  ///扫码返回
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
    taskListPageConfig.queryData!.remove('TaskIds');
    taskListPageConfig.queryData!.remove('MoOrderId');
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
        //region 生产任务单条码 610001   生产派工单 650011
        if (list.length == 4){
          if (list[2] == '610001') {
            taskListPageConfig.queryData!['MoOrderId'] = list[3];
            res = await getTaskList();
          }
          else if (list[2] == '650011'){
            taskListPageConfig.queryData!['TaskIds'] = list[3];
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
    item as MoTaskModel;
    switch (keyName){
      case '${AppConfig.MesDeviceTaskDetailBtn}-${AppConfig.shiftTask}':
        await shiftTask(item);
        break;
      case '${AppConfig.MesDeviceTaskDetailBtn}-${AppConfig.swapTask}':
        await swapTask(item);
        break;
      case '${AppConfig.MesDeviceTaskDetailBtn}-${AppConfig.setFinish}':
        await finishTask(item);
        break;
    }
  }

  ///切单（开工）
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
    var res = await MoProcessTaskRepository().shiftMoProcessTask(item.taskId);
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
    if (item.id.isEmpty){
      ToastNotification(Get.overlayContext!).warn('请先选择派工单！');
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
    var res = await MoProcessTaskRepository().swapMoProcessTask(item.id);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交对调数据出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '对调成功，正在刷新数据！');
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
    //region 设置完工 \
    var res = await MoProcessTaskRepository().finishMoProcessTask(item.taskId);
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

  ///挂起
  Future<void> suspendTask() async{
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 判断
    if (taskModel.taskId.isEmpty){
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
    var res = await MoProcessTaskRepository().suspendMoProcessTask(taskModel.taskId, desc);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交挂起数据时出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '挂起成功，正在刷新数据！');
    //endregion

    //region 刷新数据
    taskModel = MoTaskModel();
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

  ///超产处理（允许超产数量变更）
  Future<void> setOverQty() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn("正在提交数据！");
      return;
    }
    isLoading = true;

    //region 进行判断
    if (taskModel.taskId.isEmpty){
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
    //region 提交数据
    var res = await MoTaskRepository().getOverQtyResult(taskModel.taskId, qty, desc);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交超产处理数据时出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '提交成功，正在刷新数据');
    //endregion
    
    //region 刷新数据
    taskModel.overQty = qty;
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

  ///工序图纸
  Future<void> getOpAttach(MoTaskModel item) async {
    ///产品id对应的工艺路线列表
    final List<MoRoutingEntryModel> routingByInvIdList = [];
    var res = await MoRoutingRepository().getRoutingByInvId(item.invId ?? '');
    if (res.isSuccess && res.data.entryList.isNotEmpty){
      routingByInvIdList.addAll(res.data.entryList);
    }
    MoRoutingEntryModel? routingEntryModel = routingByInvIdList.firstWhereOrNull((element) => element.opId == item.opId);
    if (routingEntryModel == null || routingEntryModel.routingDId.isEmpty){
      ToastNotification(Get.overlayContext!).warn('无法获取工序图纸！');
      return;
    }

    Get.rootDelegate.toNamed(
        AppRoutes.MES_DEVICE_TASK_DETAIL_ATTACH_PAGE,
        parameters: {
          'pageTitle': '工序图纸-${item.opName ?? ''}',
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
        AppRoutes.MES_DEVICE_TASK_DETAIL_ATTACH_PAGE,
        parameters: {
          'pageTitle': '产品附件-${item.invName}',
          'id': item.invId!,
          'progId': '200025',
          'category': 'attach',
        }
    );
  }

  //endregion


  @override
  void onClose() {
    try {
      mesDeviceTaskStreamSubscription.cancel();
    } catch(e){ PrintUtil.printDebug('$e'); }
    super.onClose();
  }

}