import 'dart:async';
import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/web_socket_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/web_socket_stream_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/on_off_person/on_off_person_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/on_off_person/on_off_person_page.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 设备对应生产派工单
class MesDeviceTaskController
    extends BaseFormController
    with WebSocketStreamInterface {

  ///设备Item 高度固定 173 347 2
  final double itemHeight = 180;
  double itemWidth = 0;
  double itemAspectRatio = 2;

  ///设备实时监控列表-原始数组
  final List<ModelWithGetxController<EAMDeviceModel>> deviceList = [];
  ///设备实时监控列表-过滤后的数组
  final List<ModelWithGetxController<EAMDeviceModel>> deviceFilterList = [];
  final ScrollController deviceController = ScrollController();

  //region 搜索
  ///设备编号搜索框按制器
  final TextEditingController searchTC = TextEditingController();
  final FocusNode searchFN = FocusNode();
  ///搜索时启用时间防抖，超过一定时间不输入才正式搜索数据
  final Debounce _debounce = Debounce(Duration(milliseconds: 1500));
  //endregion

  ///是否超产闪烁
  bool isBlink = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_IS_BLINK_KEY) ?? AppConfig.isBlink;
  ///超产闪烁的频率
  int rate = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_BLINK_RATE_KEY) ?? AppConfig.rate;

  ///单个设备卡片显示的设备信息 0 设备编号； 1 设备简称； 2设备名称
  int deviceShowInfoType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_DEVICE_SHOW_INFO_TYPE_KEY) ?? AppConfig.deviceShowInfoType;


  MesDeviceTaskController({
    super.progId = 650011,
  });


  @override
  void onInit() {
    super.onInit();
  }

  Future<void> onReady() async{
    await super.onReady();
    searchFN.addListener(() async {
      if (rootCtl.isKeyboardOpenAfterClickTC && searchFN.hasFocus && !kIsWeb && GetPlatform.isWindows){
        await rootCtl.openKeyboard();
      }
      update();
    });
  }


  @override
  Future<bool> initializeForm() async {
    PageConfig pageConfig = PageConfig(
      page: 1,
      rows: 1000,
      sidx: 'DeviceCode',
      sord: 'asc',
      queryData: {
        'module': 0,
        'onpickers': 1, ///有采集器连接的
      },
    );
    var res = await EAMDeviceRepository().getPageList(pageConfig);
    if(!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取设备列表时出错：${res.message}');
      return false;
    }
    deviceList.forEach((element) {
      Get.delete<ModelWithGetxController<EAMDeviceModel>>(tag: 'MesDeviceTask-${element.model.deviceId}', force: true);
      element.onClose();
    });
    deviceList.clear();
    deviceList.addAll(res.rows.map((e) => ModelWithGetxController(model: e)));
    deviceList.forEach((element) {
      Get.create<ModelWithGetxController<EAMDeviceModel>>(() => element, tag: 'MesDeviceTask-${element.model.deviceId}');
      getCurrentTask(element);
    });
    getSeries();
    getFilterOfDeviceTaskList();
    return true;
  }

  ///筛选出相应的机台 （车间Id、设备编号）(display)
  void getFilterOfDeviceTaskList() {
    ///车间Code
    var _hideDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_DEP_ID_DISPLAY_KEY) ?? [];
    ///设备Code
    var _hideDeviceIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_DEVICE_ID_DISPLAY_KEY) ?? [];
    deviceList.forEach((element) {
      element.model.isVisibleOfDep = true;
      element.model.isVisibleOfDevice = true;
      if (_hideDepIdList.contains(element.model.departmentId)){
        element.model.isVisibleOfDep = false;
      }
      if (_hideDeviceIdList.contains(element.model.deviceId)){
        element.model.isVisibleOfDevice = false;
      }
    });
    List<ModelWithGetxController<EAMDeviceModel>> deviceFilterList = deviceList.where(
            (element) => element.model.isVisibleOfDep && element.model.isVisibleOfDevice).toList();
    this.deviceFilterList.clear();
    this.deviceFilterList.addAll(deviceFilterList);
  }

  ///获取当前机台正在生产的派工单信息
  Future<void> getCurrentTask(ModelWithGetxController<EAMDeviceModel> item) async {
    item.model.isLoadingCurrentTask = true;
    item.model.currentTask = null;
    item.update();
    PageConfig pageConfig = PageConfig(
      page: 1, rows: 1,
      queryData: {
        'progid': 650011,
        'DeviceId': item.model.deviceId,
        'GESign': MoTaskSign.scz.sign,
        'LTSign': MoTaskSign.ysc.sign,
      }
    );
    var res = await MoTaskRepository().getPageList(pageConfig);
    if (res.isSuccess && res.rows.isNotEmpty){
      item.model.currentTask = res.rows[0];
    }
    item.model.isLoadingCurrentTask = false;
    item.update();
  }

  Future<void> getSeries() async {
    deviceList.forEach((element) {
      element.model.isLoadingSeries = true;
      element.update();
    });
    var res = await MoPickerRepository().getPresentList();
    if (res.isSuccess) {
      Map<String, PickerPresentDto> map = {};
      res.data.forEach((element) {
        map.addAll({element.pickerNo ?? '': element});
      });
      for (var element in deviceList) {
        if (map.containsKey(element.model.pickerNo)){
          element.model.series = map[element.model.pickerNo!]!.series;
        }
        element.model.isLoadingSeries = false;
        element.update();
      }
    }

  }


  ///读取技术指导书的对象 sopProgid 对应的对象id todo
  Future<Map<String, String>> getSopIdAndCategory(int sopProgid, MoTaskModel item) async {
    String id ='';
    String category = '';
    switch(sopProgid){
      case 700216: ///默认 模具与产品关系
        if (item.mouldId != null && item.mouldId!.isNotEmpty
            && item.invId != null && item.invId!.isNotEmpty){
          PageConfig _pageConfig = PageConfig(
              page: 1,
              rows: 1,
              queryData: {
                'MouldId': item.mouldId,
                'InvId': item.invId,
              }
          );
          var _res = await MouldRepository().getProductRelationPageList(_pageConfig);
          if (_res.isSuccess && _res.rows.isNotEmpty && (_res.rows[0].id ?? '').isNotEmpty){
            id = _res.rows[0].id!;
            category = 'sop';
          }
        }
        break;
      case 700217: ///模具与机台关系
        if (item.mouldId != null && item.mouldId!.isNotEmpty
            && item.deviceId != null && item.deviceId!.isNotEmpty){
          PageConfig _pageConfig = PageConfig(
              page: 1,
              rows: 1,
              queryData: {
                'MouldId': item.mouldId,
                'DeviceId': item.deviceId
              }
          );
          var _res = await MouldRepository().getDeviceRelationPageList(_pageConfig);
          if (_res.isSuccess && _res.rows.isNotEmpty){
            id = _res.rows[0].id ?? '';
            category = 'sop';
          }
        }
        break;
      case 700200: ///模具基本档案列表
      case 700201: ///模具基本档案
        id = item.mouldId ?? '';
        category = 'attach';
        break;
      case 200008: ///产品附件
        id = item.invId ?? '';
        category = 'attach';
        break;
    }

    return {'id': id, 'category': category};
  }


  @override
  Future<void> onData(WebSocketModel webSocketModel) async {
    switch(webSocketModel.name){
      case 'PickerPresentDto':
      case 'PickerPresentDTO':
        //region 采集数量变更
        var data = json.decode(webSocketModel.data);
        if (data != null && deviceList.isNotEmpty) {
          ModelWithGetxController<EAMDeviceModel>? item = deviceList.firstWhereOrNull((element) => element.model.pickerNo == data['pickerNo']);
          if (item != null && item.model.deviceId.isNotEmpty) {
            item.model.series = data['series'];
            Get.find<AppService>().eventBus.fire(item);
            item.update();
          }
        }
        //endregion
        break;
      case 'MoDeviceTaskModel':
        //region 机台生产任务信息变更
        var data = json.decode(webSocketModel.data);
        if (data != null && deviceList.isNotEmpty) {
          ModelWithGetxController<EAMDeviceModel>? item = deviceList.firstWhereOrNull((element) => element.model.deviceId == data['deviceId']);
          if (item != null && item.model.deviceId.isNotEmpty) {
            getCurrentTask(item).then((value){
              Get.find<AppService>().eventBus.fire(item);
            });
          }
        }
        //endregion
        break;
    }
  }


  //region item onTap

  ///员工上下岗
  Future<void> onOffPerson(ModelWithGetxController<EAMDeviceModel> item) async {
    var res = await DialogUtils.showCustomDialog<OnOffPersonController, String>(
      Get.context!,
      title: '员工上下岗',
      initialWidth: 800,
      barrierDismissible: false,
      content: OnOffPersonView(),
      controller: OnOffPersonController(
        deviceId: item.model.deviceId,
      ),
    );
    if (res != null && res.isNotEmpty){
      ProgressDialogUtil.showProgressDialog(msg: '正在刷新数据', completedMsg: '数据刷新成功！');
      var deviceRes = await EAMDeviceRepository().getModel(item.model.deviceId);
      if (deviceRes.isSuccess){
        Map<String, dynamic> newDataMap = deviceRes.data.toJson();
        item.model.fromFormJson(newDataMap);
        item.update();
      }
      ProgressDialogUtil.update();
    }
  }

  Future<void> itemOnDoubleTap(EAMDeviceModel item) async{
    Get.rootDelegate.toNamed(
        AppRoutes.MES_DEVICE_TASK_DETAIL_MAIN_PAGE,
        arguments: MoTaskModel(), ///这里只传递空数据，派工数据在自己的页面中单独获取
        parameters: {
          'key': item.deviceId,
          'keyName': 'deviceTask',
          'taskOpenType': '1',
        }
    );
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
        AppRoutes.MES_DEVICE_TASK_ATTACH_PAGE,
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
        AppRoutes.MES_DEVICE_TASK_ATTACH_PAGE,
        parameters: {
          'pageTitle': '产品附件-${item.invName}',
          'id': item.invId!,
          'progId': '200025',
          'category': 'attach',
        }
    );
  }

  //endregion


  //region 搜索
  ///搜索框输入变化
  Future<void> searchTCOnSearch() async {
    _debounce(() async{
      searchFN.unfocus();
      await deviceCodeSearch();
      update();
    });
  }

  ///搜索框清空
  Future<void> searchTCClear() async{
    searchTC.text = '';
    await deviceCodeSearch();
    searchFN.unfocus();
    update();
  }

  ///根据设备编号搜索
  Future<void> deviceCodeSearch() async{
    ProgressDialogUtil.showProgressDialog();
    List<ModelWithGetxController<EAMDeviceModel>> deviceTaskFilterList = deviceList.where(
            (element) => element.model.isVisibleOfDep && element.model.isVisibleOfDevice
            && (element.model.deviceCode ?? '').contains(searchTC.text)).toList();
    this.deviceFilterList.clear();
    this.deviceFilterList.addAll(deviceTaskFilterList);
    ProgressDialogUtil.update(value: 1, msg: '查询成功！');
  }
  //endregion


  @override
  Future<void> onClose() async {
    _debounce.dispose();
    searchFN.dispose();
    searchTC.dispose();
    deviceList.forEach((element) {
      Get.delete<ModelWithGetxController<EAMDeviceModel>>(tag: 'MesDeviceTask-${element.model.deviceId}', force: true);
      element.onClose();
    });
    deviceController.dispose();
    super.onClose();
  }

}