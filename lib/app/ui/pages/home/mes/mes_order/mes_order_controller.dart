
import 'dart:async';
import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/model/web_socket_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/order_date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/dep_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/order_keyword_search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/order_sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/web_socket_stream_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/order_to_task/order_to_task_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/order_to_task/order_to_task_view.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/verification_loaded/verification_loaded_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/verification_loaded/verification_loaded_view.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/create_inspection/create_inspection_controller.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/create_inspection/create_inspection_view.dart';
import 'package:desktop/app/ui/pages/work_bill_op_choice/work_bill_op_choice_controller.dart';
import 'package:desktop/app/ui/pages/work_bill_op_choice/work_bill_op_choice_view.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产任务单 主页面
class MesOrderController
    extends BaseFormWithPageDataController<MoOpOrderModel>
    with SignFilterInterface, OrderSignFilterInterface,
        DepFilterInterface,
        DateFilterInterface, OrderDateFilterInterface,
        SearchInterface, OrderKeywordSearchInterface,
        SerialPortGetXListenerMixin<MesOrderController>, ScanInterface<MesOrderController>,
        TcpSocketGetxListenerMixin<MesOrderController>,
        WebSocketStreamInterface,
        InfoFormInterface,
        CommandBarInterface,
        InterfaceUtil {

  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> orderListInfoFormListMap = {};

  ///任务单列表页面显示的按钮组列表
  final List<CommandBarBtnModel> orderCommandBarList = [];


  MesOrderController({
    super.progId = 610001,
  });


  @override
  void onInit() {
    super.onInit();

    //region
    isShowSignFilter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_IS_SHOW_ORDER_SIGN_FILTER_KEY) ?? AppConfig.isShowSignFilter;
    isSignChipMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_IS_ORDER_SIGN_CHIP_MULTI_KEY)?? AppConfig.isSignChipMulti;
    selectedOrderSignBinary = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SIGN_SELECTED_KEY) ?? AppConfig.binaryForSignSelected;

    isShowDepPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_IS_SHOW_DEP_PICKER_KEY) ?? AppConfig.isShowDepPicker;
    depIds = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_DEP_IDS_KEY) ?? '';

    isShowDatePicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_IS_SHOW_DATE_PICKER_KEY) ?? AppConfig.isShowDatePicker;
    dateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
    String datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_DATE_PICKER_VALUE_MAP_KEY) ?? '';
    datePickerValueMap = getDatePickerValueMapByStorage(datePickerValueStr);

    isShowSearchInputBox = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_IS_SHOW_SEARCH_INPUT_BOX_KEY) ?? AppConfig.isShowSearchInputBox;
    orderSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;

    scanQueryDataList.addAll(['MoOrderId']);

    List<dynamic> orderListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_INFO_FORM_LIST_KEY) ?? [];
    orderListInfoFormListMap.clear();
    orderListInfoFormListMap.addAll(
      getInfoFormListMap(
        getInfoFormListByStorage(
          orderListInfoFormMapList,
          AppConfig.mesOrderListInfoFormList
        )
      )
    );

    List<dynamic> orderCommandBarMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_COMMAND_BAR_LIST_KEY) ?? [];
    orderCommandBarList.clear();
    orderCommandBarList.addAll(
      getCommandBarListByStorage(
        orderCommandBarMapList,
        AppConfig.mesOrderCommandBarList
      )
    );
    //endregion

    dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
    dataListPageConfig.sidx = 'BillDate';
    dataListPageConfig.queryData = {
      'progid': progId,
      'ExtOpFlag': 0, ///ExtOpFlag=0 去除委外
    };
    depQueryDataOnChanged();
    signQueryDataOnChanged();
    dateQueryDataOnChanged();
  }

  @override
  Future<bool> initializeForm() async {
    var res = await super.initializeForm();
    await getDepAdapter();
    return res;
  }

  @override
  Future<PageResult<MoOpOrderModel>> getDataList(PageConfig pageConfig) async {
    if (searchTC.text.isNotEmpty){
      switch (orderSearchTypeList[orderSearchTypeIndex].keyName){
        case 'orderSN':
          //region 序列号搜索，读取列表数据前，需要判断序列号是否可用
          var snRes = await MoOrderSNRepository().getModel(searchTC.text);
          if (!snRes.isSuccess){
            ToastNotification(Get.overlayContext!).error('获取序列号数据时出错：${snRes.message}！');
            return PageResult();
          }
          if (snRes.data.id.isEmpty){
            ToastNotification(Get.overlayContext!).error('查询不到该序列号！');
            return PageResult();
          }
          if ((snRes.data.moOrderId ?? '').isEmpty){
            ToastNotification(Get.overlayContext!).error('该序列号还未被分配任务单！');
            return PageResult();
          }
          if (snRes.data.enableMark != 1){
            ToastNotification(Get.overlayContext!).error('该序列号已失效！');
            return PageResult();
          }
          //endregion
          break;
      }
    }

    var res = await MoOrderRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取生产任务单列表时出错：${res.message}');
      return PageResult();
    }

    if (searchTC.text.isNotEmpty){
      switch (orderSearchTypeList[orderSearchTypeIndex].keyName){
        case 'orderSN':
          res.rows.forEach((element) {
            element.orderSN = searchTC.text;
          });
          break;
      }
    }

    return res;
  }

  @override
  Future<void> onData(WebSocketModel webSocketModel) async {
    switch (webSocketModel.name){
      case 'MoOrderEntity':
      case 'MoOrderModel':
        var data = json.decode(webSocketModel.data);
        if (data != null && dataList.isNotEmpty){
          MoOpOrderModel? orderModel = dataList.firstWhereOrNull((element) => element.moOrderId == data['moOrderId']);
          if (orderModel != null && orderModel.moOrderId.isNotEmpty){
            orderModel.sign = data['sign'];
            orderModel.status = data['status'];
            orderModel.submitQty = data['submitQty'];
            orderModel.qualifiedQty = data['qualifiedQty'];
            orderModel.startDate = DateTime.tryParse(data['startDate'].toString());
            update();
          }
        }
        break;
    }
  }


  //region OnChanged

  @override
  Future<void> depOnChanged(List<PickerDataModel> list) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    String oldDepIds = depIds;
    await super.depOnChanged(list);
    if (oldDepIds == depIds){
      isLoading = false;
      return;
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_DEP_IDS_KEY, depIds);
    depQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void depQueryDataOnChanged() {
    dataListPageConfig.queryData!['depid'] = depIds;
  }

  @override
  Future<void> signOnChanged(int sign) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    await super.signOnChanged(sign);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SIGN_SELECTED_KEY, selectedOrderSignBinary);
    signQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void signQueryDataOnChanged() {
    List<String> statusList = [];
    bool isNoAssign = false; ///未派工完成
    for (var element in orderSignList) {
      if (selectedOrderSignBinary & element.sign == element.sign){
        if (element.sign == 8){
          isNoAssign = true;
        }
        else {
          statusList.add(element.content);
        }
      }
    }
    String status = statusList.join(',');
    dataListPageConfig.queryData!['status'] = status;
    dataListPageConfig.queryData!['NoAssign'] = isNoAssign ? 1 : 0;
  }

  @override
  Future<void> dateSearchTypeOnChanged(ChoiceChipModel item, int index) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (index == orderDateSearchTypeIndex){
      isLoading = false;
      return;
    }
    orderDateSearchTypeIndex = index;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_DATE_SEARCH_TYPE_INDEX_KEY, orderDateSearchTypeIndex);
    dateQueryDataOnChanged();
    if (startDate != null && endDate != null){
      await pageChanged();
    }
    update();
    isLoading = false;
  }
  @override
  Future<void> dateOnChanged(String string) async{
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
    dataListPageConfig.queryData!.removeWhere((key, value) => orderDateSearchQueryDataList.contains(key));
    if (startDate != null && endDate != null){
      String keyWord = dateSearchTypeList[orderDateSearchTypeIndex].content;
      List<String> keywordList = keyWord.split(',');
      if (keywordList.length == 2){
        dataListPageConfig.queryData![keywordList[0]] = startDateStrWithNoTime;
        dataListPageConfig.queryData![keywordList[1]] = endDateStrWithNoTime;
      }
    }
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
    if (index == orderSearchTypeIndex){
      isLoading = false;
      return;
    }
    orderSearchTypeIndex = index;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SEARCH_TYPE_INDEX_KEY, orderSearchTypeIndex);
    searchQueryDataOnChanged();
    if (searchTC.text.isNotEmpty){
      await pageChanged();
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
    await pageChanged();
    update();
    isLoading = false;
  }

  @override
  Future<void> searchTCOnClear() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchFN.unfocus();
    searchTC.text = '';
    searchQueryDataOnChanged();
    await pageChanged();
    isSearchWidgetOpen = false;
    update();
    isLoading = false;
  }

  void searchQueryDataOnChanged() {
    dataListPageConfig.queryData!.removeWhere((key, value) => orderSearchQueryDataList.contains(key));
    if (searchTC.text.isNotEmpty){
      String keyWord = orderSearchTypeList[orderSearchTypeIndex].content;
      dataListPageConfig.queryData![keyWord] = searchTC.text;
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
    bool res = await pageChanged(showLoading: false);
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
        //region 生产任务单条码 610001
        if (list.length == 4){
          if (list[2] == '610001'){
            scanQueryDataOnChanged(keyWord: 'MoOrderId', keyValue: list[3]);
            res = await pageChanged(showLoading: false);
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
      case 'T':
        //region 工序条码 610001
        if (list.length == 4){
          if (list[2] == '610001'){
            var res1 = await MoWorkBillEntryRepository().getMoWorkBillEntry(list[3]);
            if (!res1.isSuccess){
              ToastNotification(Get.overlayContext!).error('获取任务单信息和工序信息时出错：${res1.message}');
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if ((res1.data.objectId ?? '').isEmpty){
              ToastNotification(Get.overlayContext!).error('未查询到工序信息！');
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            scanQueryDataOnChanged(keyWord: 'MoOrderId', keyValue: res1.data.objectId);
            res = await pageChanged(showLoading: false);
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
      case 'X':
        //region 产品序列号
        String string = list[2];
        var res1 = await MoOrderSNRepository().getModel(string);
        if (!res1.isSuccess){
          ToastNotification(Get.overlayContext!).error('获取序列号数据时出错：${res1.message}！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (res1.data.id.isEmpty){
          ToastNotification(Get.overlayContext!).error('查询不到该序列号！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (res1.data.moOrderId == null || res1.data.moOrderId!.isEmpty){
          ToastNotification(Get.overlayContext!).error('该序列号未被分配到任务单！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (res1.data.enableMark != 1){
          ToastNotification(Get.overlayContext!).error('该序列号已失效！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        scanQueryDataOnChanged(keyWord: 'MoOrderId', keyValue: res1.data.moOrderId);
        res = await pageChanged(showLoading: false);
        if (res){
          ///实际上，此时[dataList]只会有一条记录
          dataList.forEach((element) {
            element.orderSN = string;
          });
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
    dataListPageConfig.queryData!.removeWhere((key, value) => scanQueryDataList.contains(key));
    if (keyWord != null){
      dataListPageConfig.queryData![keyWord] = keyValue;
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

  @override
  void settingOnTap(){
    Get.rootDelegate.toNamed(
      AppRoutes.MES_ORDER_SETTING_PAGE,
      parameters: {
        'noPermission': (dataService.isEnableOperatePrivilege
            && objectItem.buttons?['desktopUISettingBtn'] == null) ? '1' : '0',
        'permissionInfo': BaseService.profile.isSystem == true ? '【${objectItem.progid}】【desktopUISettingBtn】' : '',
      },
    );
  }

  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    item as MoOpOrderModel;
    switch (keyName){
      case '${AppConfig.mesOrderBtn}-${AppConfig.invImage}':
        await getInvImage(item);
        break;
      case '${AppConfig.mesOrderBtn}-${AppConfig.verificationLoaded}':
        await verificationLoaded(item);
        break;
      case '${AppConfig.mesOrderBtn}-${AppConfig.createFirstInspection}':
        await createFirstInspection(item);
        break;
      case '${AppConfig.mesOrderBtn}-${AppConfig.toTask}':
        await toTask(item);
        break;
      case '${AppConfig.mesOrderBtn}-${AppConfig.setFinish}':
        await finishMoProcessTask(item);
        break;
      case '${AppConfig.mesOrderBtn}-${AppConfig.shiftTask}':
        await orderSetCheckedSign(item, 16);
        break;
      case '${AppConfig.mesOrderBtn}-${AppConfig.suspendTask}':
        await orderSetCheckedSign(item, 8);
        break;
      case '${AppConfig.mesOrderBtn}-${AppConfig.detail}':
        await itemOnDoubleTap(item);
        break;
      case '${AppConfig.mesOrderBtn}-${AppConfig.expanded}':
        orderItemExpandedOnChanged(item);
        break;
    }
  }

  @override
  bool commandBarShowCallback(String keyName, ICloneable item) {
    bool isShow = true;
    item as MoOpOrderModel;
    switch (keyName){
      case '${AppConfig.mesOrderBtn}-${AppConfig.invImage}':
        isShow = (item.productId ?? '').isNotEmpty;
        break;
      case '${AppConfig.mesOrderBtn}-${AppConfig.createFirstInspection}':
        isShow = (item.sign ?? 0) < MoOpOrderSign.ysc.sign;
        break;
      case '${AppConfig.mesOrderBtn}-${AppConfig.setFinish}':
        isShow = (item.sign ?? 0) < MoOpOrderSign.ysc.sign;
        break;
      case '${AppConfig.mesOrderBtn}-${AppConfig.shiftTask}':
        isShow = (item.sign ?? 0) < MoOpOrderSign.scz.sign;
        break;
      case '${AppConfig.mesOrderBtn}-${AppConfig.suspendTask}':
        isShow = (item.sign ?? 0) >= MoOpOrderSign.scz.sign && (item.sign ?? 0) < MoOpOrderSign.ysc.sign;
        break;
    }
    return isShow;
  }


  ///任务单Item“展开按钮”点击变化
  void orderItemExpandedOnChanged(MoOpOrderModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }

  Future<void> itemOnTap(MoOpOrderModel item) async{  }

  Future<void> itemOnDoubleTap(MoOpOrderModel item) async{
    Get.rootDelegate.toNamed(
        AppRoutes.MES_ORDER_DETAIL_MAIN_PAGE,
        arguments: MoOpOrderModel.fromJson(item.toJson()),
        parameters: {
          'key': item.moOrderId,
          'keyName': 'order',
          'orderOpenType': '0',
          'noPermission': (dataService.isEnableOperatePrivilege
              && objectItem.buttons?['desktopUISettingBtn'] == null) ? '1' : '0',
          'permissionInfo': BaseService.profile.isSystem == true ? '【${objectItem.progid}】【desktopUISettingBtn】' : '',
        }
    );
  }

  Future<void> itemOnLongPress(MoOpOrderModel item) async{  }

  Future<void> getInvImage(MoOpOrderModel item) async{
    if (item.productId == null || item.productId!.isEmpty){
      ToastNotification(Get.overlayContext!).error('该任务单没有产品！');
      return;
    }
    Get.rootDelegate.toNamed(
        AppRoutes.MES_ORDER_ITEM_ATTACH_PAGE,
        parameters: {
          'pageTitle': '产品图片-${item.productName}',
          'id': item.productId!,
          'progId': '200025',
          'category': 'image',
        }
    );
  }

  ///查看产品附件
  Future<void> getInvAttach(MoOpOrderModel item) async{
    if (item.productId == null || item.productId!.isEmpty){
      ToastNotification(Get.overlayContext!).error('该任务单没有产品！');
      return;
    }
    Get.rootDelegate.toNamed(
        AppRoutes.MES_ORDER_ITEM_ATTACH_PAGE,
        parameters: {
          'pageTitle': '产品附件-${item.productName}',
          'id': item.productId!,
          'progId': '200025',
          'category': 'attach',
        }
    );
  }

  ///接收 移交 （action：0 接收标识  1 移交标识）
  Future<void> actionFlag(MoOpOrderModel item, int action) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    String actionStr = action == 1 ? '移交' : action == 0 ? '接收' : '';
    //region 判断
    if ((item.wbId ?? '').isEmpty){
      ToastNotification(Get.overlayContext!).warn('该任务单没有工序计划！');
      isLoading = false;
      return;
    }
    if ((item.sign ?? 0) >= MoOpOrderSign.ysc.sign){
      ToastNotification(Get.overlayContext!).warn('该任务单已生产，不能$actionStr！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showCustomDialog<WorkBillOpChoiceController, String>(
      Get.context!, title: '请选择$actionStr的工序！',
      barrierDismissible: false,
      onConfirmName: '确认',
      initialWidth: 1024, initialHeight: 900,
      contentPadding: const EdgeInsets.all(12),
      content: WorkBillOpChoiceView(),
      controller: WorkBillOpChoiceController(wbId: item.wbId!),
    );
    if (dialogRes == null || dialogRes.isEmpty){
      isLoading = false;
      return;
    }
    String workBillEntryId = dialogRes;
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交$actionStr数据', completedMsg: '数据刷新成功！');
    //region 接收 移交
    var res = await MoWorkBillEntryRepository().actionFlag(workBillEntryId, action);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("提交$actionStr数据出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '$actionStr成功，正在刷新数据！');
    //endregion

    //region 刷新数据
    var orderRes = await MoOrderRepository().getFormData(item.moOrderId);
    if (!orderRes.isSuccess){
      ToastNotification(Get.overlayContext!).error("刷新数据出错：${res.message}！");
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    item.fromJson(orderRes.data.toJson());
    update();
    ProgressDialogUtil.update(value: 2);
    //endregion
    isLoading = false;
  }

  ///任务单生成首检报检单
  Future<void> createFirstInspection(MoOpOrderModel item) async {
    await DialogUtils.showCustomDialog<CreateInspectionController, String>(
      Get.context!,
      title: '任务单生成首检报检单',
      initialWidth: 1024, initialHeight: 900,
      contentPadding: const EdgeInsets.all(0),
      content: CreateInspectionView(),
      controller: CreateInspectionController(
        category: IPQCCategory.sj.category,
        sourceProgid: item.progid ?? 0,
        sourceId: item.moOrderId,
      ),
    );
  }

  ///派工
  Future<void> toTask(MoOpOrderModel item) async {
    await DialogUtils.showCustomDialog<OrderToTaskController, String>(
      Get.context!, title: '生产任务单派工',
      barrierDismissible: false,
      isMaximize: true,
      contentPadding: const EdgeInsets.all(12),
      content: OrderToTaskView(),
      controller: OrderToTaskController(
        orderModel: item,
      ),
    );
  }

  ///设置完工
  Future<void> finishMoProcessTask(MoOpOrderModel item) async{
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if ((item.sign ?? 0) >= MoOpOrderSign.ysc.sign){
      ToastNotification(Get.overlayContext!).warn('该任务单已经完工，不能再次设置完工！');
      isLoading = false;
      return;
    }
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
    var res = await MoOrderRepository().setFinish(item.moOrderId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('设置完工失败！${res.message}！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '设置完工成功，正在刷新数据');
    //endregion
    //region 数据刷新
    if (selectedOrderSignBinary & orderSignList[2].sign == orderSignList[2].sign){
      item.sign = MoOpOrderSign.zdwg.sign;
      item.status = MoOpOrderSign.zdwg.name;
    }
    else {
      dataList.remove(item);
      total --;
    }
    ProgressDialogUtil.update(value: 2);
    //endregion
    update();
    isLoading = false;
  }

  ///sign：1 审核， 0 取消审核, 16 开工\生产中,  8 挂起
  Future<void> orderSetCheckedSign(MoOpOrderModel item, int sign) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (sign == 1 && (item.sign ?? 0) >= MoOpOrderSign.scz.sign){
      ToastNotification(Get.overlayContext!).warn('该任务单已经在生产中，不能审核！');
      isLoading = false;
      return;
    }
    if (sign == 0 && (item.sign ?? 0) >= MoOpOrderSign.scz.sign){
      ToastNotification(Get.overlayContext!).warn('该单已经在生产中，不能取消审核！');
      isLoading = false;
      return;
    }
    if (sign == 16 && (item.sign ?? 0) >= MoOpOrderSign.scz.sign){
      ToastNotification(Get.overlayContext!).warn('该任务单已经在生产中，不能开工！');
      isLoading = false;
      return;
    }
    if (sign == 8 && ((item.sign ?? 0) < MoOpOrderSign.scz.sign || (item.sign ?? 0) >= MoOpOrderSign.ysc.sign)){
      ToastNotification(Get.overlayContext!).warn('该任务单未在生产中，不能挂起！');
      isLoading = false;
      return;
    }
    String signStr = '';
    switch (sign){
      case 0:
        signStr = '取消审核';
        break;
      case 1:
        signStr = '审核';
        break;
      case 8:
        signStr = '挂起';
        break;
      case 16:
        signStr = '开工';
        break;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认$signStr？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交开工数据', completedMsg: '数据刷新成功！');
    //region 提交数据
    var res = await MoOrderRepository().setCheckedSign(item.moOrderId, sign);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('$signStr失败！${res.message}！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '$signStr成功，正在刷新数据');
    //endregion
    //region 数据刷新
    switch (sign){
      case 0: ///取消审核
        if (selectedOrderSignBinary & orderSignList[0].sign == orderSignList[0].sign){
          item.sign = MoOpOrderSign.wpg.sign;
          item.status = '待审核';
        }
        else {
          dataList.remove(item);
          total --;
        }
        break;
      case 1: ///审核
        if (selectedOrderSignBinary & orderSignList[0].sign == orderSignList[0].sign){
          item.sign = MoOpOrderSign.wpg.sign;
          item.status = '已审核';
        }
        else {
          dataList.remove(item);
          total --;
        }
        break;
      case 8: ///挂起
        if (selectedOrderSignBinary & orderSignList[0].sign == orderSignList[0].sign){
          item.sign = MoOpOrderSign.ygq.sign;
          item.status = MoOpOrderSign.ygq.name;
        }
        else {
          dataList.remove(item);
          total --;
        }
        break;
      case 16: ///开工
        if (selectedOrderSignBinary & orderSignList[1].sign == orderSignList[1].sign){
          item.sign = MoOpOrderSign.scz.sign;
          item.status = MoOpOrderSign.scz.name;
        }
        else {
          dataList.remove(item);
          total --;
        }
        break;
    }
    ProgressDialogUtil.update(value: 2);
    //endregion
    update();
    isLoading = false;
  }

  ///上料验证
  Future<void> verificationLoaded(MoOpOrderModel item) async {
    await DialogUtils.showCustomDialog<VerificationLoadedController, bool>(
      Get.context!, title: '上料验证-${item.billCode ?? ''}',
      barrierDismissible: false,
      onCancelName: '关闭',
      isNeedConfirmBtn: false,
      isMaximize: true,
      contentPadding: const EdgeInsets.all(12),
      content: VerificationLoadedView(),
      controller: VerificationLoadedController(
        orderModel: item
      ),
    );
  }
  
  //endregion


  @override
  void onClose() {
    super.onClose();
  }


}