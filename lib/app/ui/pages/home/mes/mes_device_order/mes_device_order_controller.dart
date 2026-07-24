import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/web_socket_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/web_socket_stream_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 设备对应生产任务单
class MesDeviceOrderController
    extends BaseFormController
    with WebSocketStreamInterface {

  ///设备Item 高度固定 173 347 2
  final double itemHeight = 160;
  double itemWidth = 0;
  double itemAspectRatio = 2;

  ///设备实时监控列表-原始数组
  final List<ModelWithGetxController<MoDeviceWorkBillList>> deviceWBList = [];
  ///设备实时监控列表-过滤后的数组
  final List<ModelWithGetxController<MoDeviceWorkBillList>> deviceWBFilterList = [];
  final ScrollController deviceWBController = ScrollController();

  //region 搜索
  ///设备编号搜索框按制器
  final TextEditingController searchTC = TextEditingController();
  final FocusNode searchFN = FocusNode();
  ///搜索时启用时间防抖，超过一定时间不输入才正式搜索数据
  final Debounce _debounce = Debounce(Duration(milliseconds: 1500));
  //endregion

  ///是否超产闪烁
  bool isBlink = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_IS_BLINK_KEY) ?? AppConfig.isBlink;
  ///超产闪烁的频率
  int rate = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_BLINK_RATE_KEY) ?? AppConfig.rate;

  ///单个设备卡片显示的设备信息 0 设备编号； 1 设备简称； 2设备名称
  int deviceShowInfoType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_DEVICE_SHOW_INFO_TYPE_KEY) ?? AppConfig.deviceShowInfoType;

  MoOperAdapter? operAdapter;

  MesDeviceOrderController({
    super.progId = 610001,
  });


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
    getMoOperAdapter().then((value) {
      update();
    });
    PageConfig pageConfig = PageConfig(
      page: 1,
      rows: 10000,
      sidx: 'DeviceCode',
      sord: 'asc',
      queryData: {
        'module': 0,
        'onpickers': 1, ///有采集器连接的
      }
    );
    var result = await MoProcessOpRepository().getRealTimeMonitorByOp(pageConfig);
    if(!result.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取工序生产实时监控时出错：${result.message}');
      return false;
    }
    deviceWBList.forEach((element) {
      Get.delete<ModelWithGetxController<MoDeviceWorkBillList>>(tag: 'MesDeviceOrder-${element.model.deviceId}', force: true);
      element.onClose();
    });
    deviceWBList.clear();
    deviceWBList.addAll(result.rows.map((e) => ModelWithGetxController(model: e)));
    deviceWBList.forEach((element) {
      Get.create<ModelWithGetxController<MoDeviceWorkBillList>>(() => element, tag: 'MesDeviceOrder-${element.model.deviceId}');
    });
    getFilterOfDeviceOrderList();
    getCurrentOp();
    return true;
  }

  Future<void> getMoOperAdapter() async{
    operAdapter = await AdapterHelper.getAsyncAdapter(
      'moOper',
    ) as MoOperAdapter;
  }

  ///筛选出相应的机台 （车间Id、设备编号）(display)
  void getFilterOfDeviceOrderList() {
    ///车间Code
    var _hideDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_DEP_ID_DISPLAY_KEY) ?? [];
    ///设备Code
    var _hideDeviceIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_DEVICE_ID_DISPLAY_KEY) ?? [];
    deviceWBList.forEach((element) {
      element.model.isVisibleOfDep = true;
      element.model.isVisibleOfDevice = true;
      if (_hideDepIdList.contains(element.model.depId)){
        element.model.isVisibleOfDep = false;
      }
      if (_hideDeviceIdList.contains(element.model.deviceId)){
        element.model.isVisibleOfDevice = false;
      }
    });
    List<ModelWithGetxController<MoDeviceWorkBillList>> deviceFilterList = deviceWBList.where(
            (element) => element.model.isVisibleOfDep && element.model.isVisibleOfDevice).toList();
    this.deviceWBFilterList.clear();
    this.deviceWBFilterList.addAll(deviceFilterList);
  }

  ///获取当前机台正在生产的工艺信息
  void getCurrentOp() {
    ///currentOp 写入完成后，再根据写入的结果保存到本地
    ///（如果 key 值在设备列表中没有找到的话，就需要从该 Map 中删除，再保存到本地）
    Map<String, Map<String, dynamic>> saveMap = {};
    Map<String, dynamic> deviceCurrentOpMap = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_DEVICE_CURRENT_OP_MAP_KEY) ?? {};
    if (deviceCurrentOpMap.isNotEmpty && deviceWBList.isNotEmpty){
      deviceWBList.forEach((element) {
        if (deviceCurrentOpMap.containsKey(element.model.deviceId)){
          try {
            element.model.currentOp = MoOperModel.fromJson(deviceCurrentOpMap[element.model.deviceId]);
            if (element.model.opId != null
                && (element.model.currentOp == null
                    || element.model.currentOp?.opId != element.model.opId)){
              ToastNotification(Get.overlayContext!).error('机台${element.model.deviceCode}正在生产的任务工艺与当前选择的工艺不符合！');
            }
          } catch (e){}
          if (element.model.currentOp != null){
            saveMap.addAll({element.model.deviceId ?? '': deviceCurrentOpMap[element.model.deviceId]});
          }
        }
      });
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_DEVICE_ORDER_DEVICE_CURRENT_OP_MAP_KEY, saveMap);
  }


  ///读取技术指导书的对象 sopProgid 对应的对象id todo
  Future<Map<String, String>> getSopIdAndCategory(int sopProgid, MoOpOrderModel item) async {
    String id ='';
    String category = '';
    switch(sopProgid){
      case 700216: ///默认 模具与产品关系
        if (item.mouldId != null && item.mouldId!.isNotEmpty
            && item.productId != null && item.productId!.isNotEmpty){
          PageConfig _pageConfig = PageConfig(
              page: 1,
              rows: 1,
              queryData: {
                'MouldId': item.mouldId,
                'InvId': item.productId,
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
        id = item.productId ?? '';
        category = 'attach';
        break;
    }

    return {'id': id, 'category': category};
  }


  ///选择设备当前生产的工艺信息
  Future<void> selectedCurrentOp(String deviceId, PickerDataModel model) async {
    ModelWithGetxController<MoDeviceWorkBillList> item = Get.find<ModelWithGetxController<MoDeviceWorkBillList>>(tag: 'MesDeviceOrder-$deviceId');
    item.model.currentOp = model.id.isEmpty ? null : MoOperModel.fromJson(model.toJson());
    if (item.model.opId != null
        && (item.model.currentOp == null
            || item.model.currentOp?.opId != item.model.opId)){
      ToastNotification(Get.overlayContext!).error('机台${item.model.deviceCode}正在生产的任务工艺与当前选择的工艺不符合！');
    }
    //region 保存到本地
    Map<String, dynamic> deviceCurrentOpMap = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_DEVICE_CURRENT_OP_MAP_KEY) ?? {};
    Map<String, Map<String, dynamic>> saveMap = {};
    deviceCurrentOpMap.forEach((key, value) {
      if (value is Map<String, dynamic>){
        saveMap.addAll({key: value});
      }
    });
    if (item.model.currentOp != null){
      saveMap.addAll({deviceId: item.model.currentOp!.toJson()});
    }
    else {
      saveMap.remove(deviceId);
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_DEVICE_ORDER_DEVICE_CURRENT_OP_MAP_KEY, saveMap);
    //endregion
    ///每次回调完成清空上次选择的状态
    operAdapter?.clearSelection();
    update();
  }

  @override
  Future<void> onData(WebSocketModel webSocketModel) async {
    switch (webSocketModel.name){
      case 'MoWorkBillList':
        //region 机台工序生产任务变更
        var data = json.decode(webSocketModel.data);
        if (data != null && deviceWBList.isNotEmpty){
          ModelWithGetxController<MoDeviceWorkBillList>? item = deviceWBList.firstWhereOrNull((element) => element.model.deviceId == data['deviceId']);
          if (item != null && item.model.deviceId != null && item.model.deviceId!.isNotEmpty) {
            //region
            item.model.productQty = data['productQty'];
            item.model.wbMxId = data['wbMxId'];
            item.model.rId = data['rId'];
            item.model.rId = data['rId'];
            item.model.opId = data['opId'];
            item.model.opName = data['opName'];
            item.model.sequ = data['sequ'];
            item.model.qty = data['qty'];
            item.model.num = data['num'];
            item.model.pieceRate = data['pieceRate'];
            item.model.depId = data['depId'];
            item.model.deviceId = data['deviceId'];
            item.model.wcId = data['wcId'];
            item.model.inspectOpFlag = data['inspectOpFlag'];
            item.model.opDescription = data['opDescription'];
            item.model.inspId = data['inspId'];
            item.model.assignQty = data['assignQty'];
            item.model.assignNum = data['assignNum'];
            item.model.submitQty = data['submitQty'];
            item.model.qualifiedQty = data['qualifiedQty'];
            item.model.qualifiedNum = data['qualifiedNum'];
            item.model.acceptQty = data['acceptQty'];
            item.model.disabledQty = data['disabledQty'];
            item.model.dueStartDate = DateTime.tryParse(data['dueStartDate']);
            item.model.dueFinishDate = DateTime.tryParse(data['dueFinishDate']);
            item.model.startDate = DateTime.tryParse(data['startDate']);
            item.model.finishDate = DateTime.tryParse(data['finishDate']);
            item.model.billCode = data['billCode'];
            item.model.objectId = data['objectId'];
            item.model.billDate = DateTime.tryParse(data['billDate']);
            item.model.opCode = data['opCode'];
            item.model.wbId = data['wbId'];
            item.model.progid = data['progid'];
            item.model.moCode = data['moCode'];
            item.model.shiftBillID = data['shiftBillID'];
            item.model.originWBID = data['originWBID'];
            item.model.originWBNO = data['originWBNO'];
            item.model.invId = data['invId'];
            item.model.batch = data['batch'];
            item.model.invCode = data['invCode'];
            item.model.invName = data['invName'];
            item.model.invStd = data['invStd'];
            item.model.comUnitName = data['comUnitName'];
            item.model.invDefine1 = data['invDefine1'];
            item.model.invDefine2 = data['invDefine2'];
            item.model.invDefine3 = data['invDefine3'];
            item.model.invDefine4 = data['invDefine4'];
            item.model.invDefine5 = data['invDefine5'];
            item.model.invDefine6 = data['invDefine6'];
            item.model.invDefine7 = data['invDefine7'];
            item.model.invDefine8 = data['invDefine8'];
            item.model.invDefine9 = data['invDefine9'];
            item.model.invDefine10 = data['invDefine10'];
            item.model.invDefine11 = data['invDefine11'];
            item.model.invDefine12 = data['invDefine12'];
            item.model.invDefine13 = data['invDefine13'];
            item.model.invDefine14 = data['invDefine14'];
            item.model.invDefine15 = data['invDefine15'];
            item.model.invDefine16 = data['invDefine16'];
            item.model.isFree1 = data['isFree1'];
            item.model.isFree2 = data['isFree2'];
            item.model.isFree3 = data['isFree3'];
            item.model.isFree4 = data['isFree4'];
            item.model.isFree5 = data['isFree5'];
            item.model.isFree6 = data['isFree6'];
            item.model.isFree7 = data['isFree7'];
            item.model.isFree8 = data['isFree8'];
            item.model.isFree9 = data['isFree9'];
            item.model.isFree10 = data['isFree10'];
            item.model.soCode = data['soCode'];
            item.model.mtoNo = data['mtoNo'];
            item.model.mtoSeq = data['mtoSeq'];
            item.model.orderCode = data['orderCode'];
            item.model.moQty = data['moQty'];
            item.model.orderQty = data['orderQty'];
            item.model.stockQty = data['stockQty'];
            item.model.free1 = data['free1'];
            item.model.free2 = data['free2'];
            item.model.free3 = data['free3'];
            item.model.free4 = data['free4'];
            item.model.free5 = data['free5'];
            item.model.free6 = data['free6'];
            item.model.free7 = data['free7'];
            item.model.free8 = data['free8'];
            item.model.free9 = data['free9'];
            item.model.free10 = data['free10'];
            //endregion
            //region 读取SOP附件
            //endregion
            Get.find<AppService>().eventBus.fire(item);
            item.update();
            //region MesDeviceSubmitController 刷新首检检验标志
            /*MesDeviceSubmitController? mesDeviceSubmitController;
            try {
              mesDeviceSubmitController = Get.find<MesDeviceSubmitController>();
            } catch (e){}
            if (mesDeviceSubmitController != null){
              await mesDeviceSubmitController.getIsFirstInspectionPassed();
              mesDeviceSubmitController.update();
            }*/
            //endregion
          }
        }
        //endregion
        break;
      case 'MoWorkBillListModelByOtherPage':
        //region 详情页挂起、设置完工后返回的生产任务数据
        var data = json.decode(webSocketModel.data);
        if (data != null && deviceWBList.isNotEmpty){
          MoDeviceWorkBillList dataModel = MoDeviceWorkBillList.fromJson(data);
          ModelWithGetxController<MoDeviceWorkBillList>? item = deviceWBList.firstWhereOrNull((element) => element.model.deviceId == dataModel.deviceId);
          if (item != null && item.model.deviceId != null && item.model.deviceId!.isNotEmpty) {
            item.model.fromFormJson(data);
            Get.find<AppService>().eventBus.fire(item);
            item.update();
            //region MesDeviceSubmitController 刷新报工页面的首检检验信息
            /*MesDeviceSubmitController? mesDeviceSubmitController;
            try {
              mesDeviceSubmitController = Get.find<MesDeviceSubmitController>();
            } catch (e){}
            if (mesDeviceSubmitController != null){
              await mesDeviceSubmitController.getIsFirstInspectionPassed();
              mesDeviceSubmitController.update();
            }*/
            //endregion
          }
        }
        //endregion
        break;
    }
  }


  ///员工上下岗
  Future<void> onOffPerson(String deviceId) async {
    //todo
  }


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
    List<ModelWithGetxController<MoDeviceWorkBillList>> deviceWBFilterList = deviceWBList.where(
            (element) => element.model.isVisibleOfDep && element.model.isVisibleOfDevice
                && (element.model.deviceCode ?? '').contains(searchTC.text)).toList();
    this.deviceWBFilterList.clear();
    this.deviceWBFilterList.addAll(deviceWBFilterList);
    ProgressDialogUtil.update(value: 1, msg: '查询成功！');
  }
  //endregion


  Future<void> onClose() async {
    _debounce.dispose();
    searchFN.dispose();
    searchTC.dispose();
    deviceWBList.forEach((element) {
      Get.delete<ModelWithGetxController<MoDeviceWorkBillList>>(tag: 'MesDeviceOrder-${element.model.deviceId}', force: true);
      element.onClose();
    });
    deviceWBController.dispose();
    super.onClose();
  }

}