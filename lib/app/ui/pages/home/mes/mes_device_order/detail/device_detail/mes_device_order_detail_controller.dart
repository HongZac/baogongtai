import 'dart:async';
import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/chart_data_model.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/model/web_socket_model.dart';
import 'package:desktop/app/service/app_service.dart';
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
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/wb_entry_sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_order/mes_device_order_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 设备对应生产任务单 设备详情页
class MesDeviceOrderDetailController
    extends BaseFormController
    with SignFilterInterface, WBEntrySignFilterInterface,
        SearchInterface,
        SerialPortGetXListenerMixin<MesDeviceOrderDetailController>, ScanInterface<MesDeviceOrderDetailController>,
        TcpSocketGetxListenerMixin<MesDeviceOrderDetailController>,
        InfoFormInterface,
        CommandBarInterface,
        InterfaceUtil {

  final MesDeviceOrderController mesDeviceOrderController = Get.find<MesDeviceOrderController>();
  ///首页 单个机器数据刷新后，通过 EventBus 通知详情页面刷新
  late final StreamSubscription<ModelWithGetxController<MoDeviceWorkBillList>> moDeviceWorkBillListStreamSubscription;

  bool isOpenBarcodeInput = false;

  ///上一个页面选中的设备
  final String deviceId;
  late final ModelWithGetxController<MoDeviceWorkBillList> deviceWBModelWithGetxController = Get.find<ModelWithGetxController<MoDeviceWorkBillList>>(tag: 'MesDeviceOrder-$deviceId');

  get searchTypeList => List.unmodifiable(AppConfig.wbEntrySearchTypeList);
  get searchQueryDataList => List.unmodifiable(searchTypeList.map((e) => e.content).toSet().toList());

  ///表单页面-数据字段列表
  final List<InfoFormModel> wBEntryInfoFormList = [];
  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> wBEntryListInfoFormListMap = {};

  final List<CommandBarBtnModel> wBEntryListCommandBarList = [
    CommandBarBtnModel(
      title: '切单',
      icon: Icons.change_history,
      keyName: '${AppConfig.MesDeviceOrderDetailBtn}-${AppConfig.shiftTask}',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnpass',
    ),
    CommandBarBtnModel(
      title: '对调',
      icon: FluentIcons.arrow_swap_20_filled,
      keyName: '${AppConfig.MesDeviceOrderDetailBtn}-${AppConfig.swapTask}',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnswap',
    ),
    CommandBarBtnModel(
      title: '设置完工',
      icon: Icons.assignment_turned_in_outlined,
      keyName: '${AppConfig.MesDeviceOrderDetailBtn}-${AppConfig.setFinish}',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnfinish',
    ),
  ];

  MoOpOrderModel orderModel = MoOpOrderModel();
  ///昨日设备利用率
  double lastDayOEE = 0;
  ///近24小时OEE列表
  final List<ChartDataModel> hourOEEList = [];

  final List<MoWorkBillListModel> wBEntryList = [];
  late final PageConfig wBEntryListPageConfig = PageConfig(
    page: 1,
    rows: 50,
    sord: 'desc',
    sidx: 'BillCode',
    queryData: {
      //'NoRk': 1, ///只取未入库的
      'ExtOpFlag': 0, ///ExtOpFlag=0 去除委外工序
      'DeviceId': deviceId,
      'OpId': deviceWBModelWithGetxController.model.currentOp?.opId,
      'nStatus': 1, ///筛选出有任务单的且未派工的单据
      //'GESign': MoWorkBillEntrySign.scz.sign,
      //'LTSign': MoWorkBillEntrySign.ysc.sign,
    },
  );
  MoWorkBillListModel selectedWBModel = MoWorkBillListModel();

  ///读取sop技术指导书的对象，默认：700216，模具与产品关系sop
  late final int sopProgId = int.parse(dataService.accInformationMap['realtime.sop']?.itemValue ?? '700216');

  final ScrollController detailController = ScrollController();
  final ScrollController wBListController = ScrollController();

  final GlobalKey deviceOrderWidgetKey = GlobalKey();
  double deviceOrderWidgetHeight = 200;


  MesDeviceOrderDetailController({
    super.progId = 670011,
    required this.deviceId,
  });


  @override
  void onInit() {
    super.onInit();

    isSignChipMulti = true;
    selectedWBEntrySignBinary = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_DETAIL_TADTITLES_KEY) ?? AppConfig.binaryForSignSelected;

    searchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_DETAIL_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;

    scanQueryDataList.addAll(['ObjectId']);

    List<dynamic> wBEntryInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_DETAIL_WB_ENTRY_INFO_FORM_LIST_KEY) ?? [];
    wBEntryInfoFormList.clear();
    wBEntryInfoFormList.addAll(
        getInfoFormListByStorage(
            wBEntryInfoFormMapList,
            AppConfig.mesDeiceOrderDetailInfoFormList
        )
    );

    List<dynamic> wBEntryListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_DETAIL_WB_ENTRY_LIST_INFO_FORM_LIST_KEY) ?? [];
    wBEntryListInfoFormListMap.clear();
    wBEntryListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                wBEntryListInfoFormMapList,
                AppConfig.mesWBEntryListInfoFormList
            )
        )
    );
  }

  @override
  Future<void> onReady() async {
    await super.onReady();

    moDeviceWorkBillListStreamSubscription = appService.eventBus.on<ModelWithGetxController<MoDeviceWorkBillList>>().listen((event) async {
      deviceWBModelWithGetxController.update();
      update();
    });
  }

  Future<bool> initializeForm() async {
    ///数据读取完成后，res 被赋值
    bool? res1;
    bool? res2;
    bool? res3;

    getCurrentOrder(deviceId).then((value) {
      res1 = value;
      update();
    });
    getOEE(deviceId).then((value) {
      res2 = value;
      update();
    });
    getWBEntryList().then((value) {
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


  void getDeviceOrderWidgetHeight() {
    Future.delayed(const Duration(milliseconds: 500), (){
      try {
        final RenderBox renderBox = deviceOrderWidgetKey.currentContext!.findRenderObject() as RenderBox;
        final Size size = renderBox.size;
        if (deviceOrderWidgetHeight != size.height){
          deviceOrderWidgetHeight = size.height;
          update();
        }
      } catch(e){
        PrintUtil.printDebug(e.toString());
      }
    });
  }

  
  //region 获取数据
  
  ///获取当前设备正在生产的任务 OrderModel
  Future<bool> getCurrentOrder(String deviceId) async {
    if ((deviceWBModelWithGetxController.model.objectId ?? '').isNotEmpty){
      var res = await MoOrderRepository().getFormData(deviceWBModelWithGetxController.model.objectId!);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取当前设备正在生产的任务时出错：${res.message}！');
        return false;
      }
      orderModel = res.data;
      return true;
    }
    ToastNotification(Get.overlayContext!).error('获取当前设备正在生产的任务时出错：找不到设备信息！');
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

  ///获取该机台下任务单
  Future<bool> getWBEntryList() async {
    wBEntryList.clear();
    selectedWBModel = MoWorkBillListModel();
    await Future.forEach<MoSignModel>(wBEntrySignList, (element) async{
      if (selectedWBEntrySignBinary & element.sign == element.sign){
        wBEntryListPageConfig.queryData!['LTSign'] = element.lTSign;
        wBEntryListPageConfig.queryData!['GESign'] = element.gESign;
        if (element.sign == 4){
          wBEntryListPageConfig.sidx = 'BillCode';
        }
        else {
          wBEntryListPageConfig.sidx = 'DueStartDate';
        }
        var res = await MoWorkBillRepository().getPageList(wBEntryListPageConfig);
        if (!res.isSuccess){
          ToastNotification(Get.overlayContext!).error('获取该机台下任务单（工序计划明细）列表时出错：${res.message}！');
          return false;
        }
        wBEntryList.addAll(res.rows);
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_DEVICE_ORDER_DETAIL_TADTITLES_KEY, selectedWBEntrySignBinary);
    ProgressDialogUtil.showProgressDialog();
    var res = await getWBEntryList();
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1, msg: '任务单（工序计划明细）列表数据重新获取成功！');
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_DEVICE_ORDER_DETAIL_SEARCH_TYPE_INDEX_KEY, searchTypeIndex);
    searchQueryDataOnChanged();
    if (searchTC.text.isNotEmpty){
      ProgressDialogUtil.showProgressDialog();
      var res = await getWBEntryList();
      if (!res){
        ProgressDialogUtil.close();
      }
      else {
        ProgressDialogUtil.update(value: 1, msg: '任务单列表数据重新获取成功！');
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
    var res = await getWBEntryList();
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1, msg: '任务单列表数据重新获取成功！');
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
    var res = await getWBEntryList();
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1, msg: '任务单列表数据重新获取成功！');
    }
    isSearchWidgetOpen = false;
    isLoading = false;
    update();
  }

  void searchQueryDataOnChanged() {
    wBEntryListPageConfig.queryData!.removeWhere((key, value) => searchQueryDataList.contains(key));
    if (searchTC.text.isNotEmpty){
      String keyWord = searchTypeList[searchTypeIndex].content;
      wBEntryListPageConfig.queryData![keyWord] = searchTC.text;
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
    var res = await getWBEntryList();
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
    wBEntryListPageConfig.queryData!.remove('ObjectId');
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
        //region 生产任务单条码 610001
        if (list.length == 4){
          if (list[2] == '610001') {
            wBEntryListPageConfig.queryData!['ObjectId'] = list[3];
            res = await getWBEntryList();
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
    wBEntryListPageConfig.queryData!.removeWhere((key, value) => scanQueryDataList.contains(key));
    if (keyWord != null){
      wBEntryListPageConfig.queryData![keyWord] = keyValue;
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

  ///工序计划明细单选择变化
  void orderOnSelected(MoWorkBillListModel item){
    if (selectedWBModel.objectId == item.objectId){
      selectedWBModel = MoWorkBillListModel();
    }
    else {
      selectedWBModel = item;
    }
    update();
  }

  @override
  Future<void> infoItemOnTap(ICloneable item) async{
    orderOnSelected(item as MoWorkBillListModel);
  }

  ///工序计划明细单 Item “展开按钮”点击变化
  void orderExpandedOnChanged(MoWorkBillListModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }

  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    item as MoWorkBillListModel;
    switch (keyName){
      case '${AppConfig.MesDeviceOrderDetailBtn}-${AppConfig.shiftTask}':
        await shiftTask(item);
        break;
      case '${AppConfig.MesDeviceOrderDetailBtn}-${AppConfig.swapTask}':
        await swapTask(item);
        break;
      case '${AppConfig.MesDeviceOrderDetailBtn}-${AppConfig.setFinish}':
        await finishTask(item);
        break;
    }
  }

  ///切单
  Future<void> shiftTask(MoWorkBillListModel item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 判断
    if (item.id.isEmpty){
      ToastNotification(Get.overlayContext!).warn('请先选择任务单！');
      isLoading = false;
      return;
    }
    if ((deviceWBModelWithGetxController.model.currentOp?.opId ?? '').isEmpty){
      ToastNotification(Get.overlayContext!).warn('请先选择当前机台需要生产的工艺！');
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
    var res = await MoProcessOpRepository().getShiftTaskByOp(item.id, deviceId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交切单数据出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '切单成功，正在刷新数据！');
    //endregion

    //region 刷新数据
    bool res1 = await getCurrentOrder(deviceId);
    bool res2 = await getWBEntryList();
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
  Future<void> swapTask(MoWorkBillListModel item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 判断
    if (item.id.isEmpty){
      ToastNotification(Get.overlayContext!).warn('请先选择任务单！');
      isLoading = false;
      return;
    }
    if ((deviceWBModelWithGetxController.model.currentOp?.opId ?? '').isEmpty){
      ToastNotification(Get.overlayContext!).warn('请先选择当前机台需要生产的工艺！');
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
    var res = await MoProcessOpRepository().getSwapTaskByOp(item.id, deviceId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交对调数据出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '对调成功，正在刷新数据！');
    //endregion

    //region 刷新数据
    bool res1 = await getCurrentOrder(deviceId);
    bool res2 = await getWBEntryList();
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
  Future<void> finishTask(MoWorkBillListModel item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 判断
    if (item.id.isEmpty){
      ToastNotification(Get.overlayContext!).warn('请先选择任务单！');
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
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交设置完工数据', completedMsg: '数据刷新成功！');
    //region 设置完工
    var res = await MoProcessOpRepository().getFinishTaskByOp(item.id);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交设置完工数据出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '设置完工成功，正在刷新数据！');
    //endregion

    //region 刷新数据
    //region 用代码去更新机台的生产任务
    Map<String, dynamic> map = MoWorkBillListModel().toJson();
    map.addAll({
      'DeviceId': deviceWBModelWithGetxController.model.deviceId,
      'DeviceAddCode': deviceWBModelWithGetxController.model.deviceAddCode,
      'DeviceCode': deviceWBModelWithGetxController.model.deviceCode,
      'DeviceName': deviceWBModelWithGetxController.model.deviceName,
    });
    Get.find<AppService>().eventBus.fire(
      WebSocketModel(name: 'MoWorkBillListModelByOtherPage', data: json.encode(map))
    );
    //endregion
    if (orderModel.moOrderId == item.objectId){
      orderModel = MoOpOrderModel();
    }
    bool res1 = await getWBEntryList();
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
  Future<void> suspendTask() async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 判断
    if (deviceWBModelWithGetxController.model.id.isEmpty){
      ToastNotification(Get.overlayContext!).warn('当前机台暂无生产任务！');
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
    var res = await MoProcessOpRepository().getSuspendTaskByOp(deviceWBModelWithGetxController.model.id, desc);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交挂起数据出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '挂起成功，正在刷新数据！');
    //endregion

    //region 刷新数据
    //region 用代码去更新机台的生产任务
    Map<String, dynamic> map = MoWorkBillListModel().toJson();
    map.addAll({
      'DeviceId': deviceWBModelWithGetxController.model.deviceId,
      'DeviceAddCode': deviceWBModelWithGetxController.model.deviceAddCode,
      'DeviceCode': deviceWBModelWithGetxController.model.deviceCode,
      'DeviceName': deviceWBModelWithGetxController.model.deviceName,
    });
    Get.find<AppService>().eventBus.fire(
      WebSocketModel(name: 'MoWorkBillListModelByOtherPage', data: json.encode(map))
    );
    //endregion
    bool res1 = await getWBEntryList();
    orderModel = MoOpOrderModel();
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

  //endregion


  @override
  void onClose() {
    try {
      moDeviceWorkBillListStreamSubscription.cancel();
    } catch(e){ PrintUtil.printDebug('$e'); }
    super.onClose();
  }

}