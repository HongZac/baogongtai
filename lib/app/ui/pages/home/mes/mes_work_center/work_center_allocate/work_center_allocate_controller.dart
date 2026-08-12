import 'package:basement/utils.dart';
import 'dart:async';

import 'package:basement/item_model.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///产线、加工中心、班组 分配页面
class WorkCenterAllocateController
    extends BaseDialogController
    with SerialPortGetXListenerMixin<WorkCenterAllocateController>,
        TcpSocketGetxListenerMixin<WorkCenterAllocateController> {

  ///要修改分配信息的产线、加工中心、班组 ID
  final String workCenterId;
  ///产线、加工中心、班组的 progId
  ///产线管理 660003；加工中心 660022; 生产班组 660021 ; 生产工位 660025 ;
  final int workCenterProgId;
  late final String typeTitle = workCenterProgId == 660003
      ? '生产产线'
      : workCenterProgId == 660022
      ? '加工中心'
      : workCenterProgId == 660021
      ? '生产班组'
      : workCenterProgId == 660025
      ? '生产工位'
      : '';

  ///加工中心信息
  MoWorkCenterItem workCenterItem = MoWorkCenterItem();
  MoBeltLineItem beltLineItem = MoBeltLineItem();
  ScrollController detailScrollController = ScrollController();
  ScrollController dataReportScrollController = ScrollController();

  ///关联类型选择列表
  late final List<ChoiceChipModel> objTypePickerList = [
    ChoiceChipModel(title: '新增关联员工', keyName: 'person', sign: 200009),
    if (workCenterProgId != 660021)
      ChoiceChipModel(title: '新增关联设备', keyName: 'device', sign: 220011),
    if (workCenterProgId != 660021)
      ChoiceChipModel(title: '新增关联模具', keyName: 'mould', sign: 700201),
  ];
  late final List<Widget> objTypeMenuList = objTypePickerList.map((e) {
    return MenuItemButton(
      onPressed: () async {
        await objTypeMenuOnTap(e);
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
            const EdgeInsets.only(top: 22, bottom: 22, left: 12, right: 44)
        ),
      ),
      child: MenuAcceleratorLabel(e.title),
    );
  }).toList();
  final FocusNode submenuBtnFN = FocusNode();

  late PersonAdapter personAdapter;
  late EAMDeviceAdapter deviceAdapter;
  late MouldAdapter mouldAdapter;

  final FocusNode scanFN = FocusNode();
  final TextEditingController scanTC = TextEditingController();

  bool isLoading = false;


  WorkCenterAllocateController({
    required this.workCenterId,
    required this.workCenterProgId,
  });


  @override
  Future<void> onReady() async {
    super.onReady();
    ProgressDialogUtil.showProgressDialog();
    if (workCenterProgId == 660022){
      var res = await MoWorkCenterRepository().getFormData(workCenterId, '', null, 0);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取加工中心数据时出错：${res.message}');
        ProgressDialogUtil.close();
        return;
      }
      workCenterItem = res.data;
    }
    else {
      var res = await MoBeltLineRepository().getFormData(workCenterId, '', null, 0);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取$typeTitle数据时出错：${res.message}');
        ProgressDialogUtil.close();
        return;
      }
      beltLineItem = res.data;
    }

    await getPersonAdapter();
    await getDeviceAdapter();
    await getMouldAdapter();
    update();
    ProgressDialogUtil.update();

    scanFN.addListener(scanFNOnListen);
  }

  Future<void> getPersonAdapter() async {
    personAdapter = await AdapterHelper.getAsyncAdapter(
      'person',
      multipleSelection: true,
      queryData: {
        'Active': 0, ///Active:0不显示离职人员
      },
    ) as PersonAdapter;
  }

  Future<void> getDeviceAdapter() async {
    deviceAdapter = await AdapterHelper.getAsyncAdapter(
      'device',
      multipleSelection: true,
    ) as EAMDeviceAdapter;
  }

  Future<void> getMouldAdapter() async {
    mouldAdapter = await AdapterHelper.getAsyncAdapter(
      'mould',
      multipleSelection: true,
    ) as MouldAdapter;
  }


  void scanFNOnListen() {
    if (submenuBtnFN.hasFocus || Picker.openPickerDialogCount != 0){
      return;
    }
    if (scanFN.hasFocus) {
      PrintUtil.printDebug('扫码监听：得到焦点');
    }
    else{
      PrintUtil.printDebug('扫码监听：失去焦点，正在重新获取焦点');
      FocusScope.of(Get.context!).requestFocus(scanFN);
    }
  }

  ///扫码完成后提交（扫码内容的最后一个字符一定是回车符）
  Future<void> onSubmitted() async {
    await onBarcode(scanTC.text);
    scanTC.clear();
  }


  ///“新增关联”点击回调
  Future<void> objTypeMenuOnTap(ChoiceChipModel item) async {
    IPickerAdapter? adapter;
    PickerChoiceType? pickerChoiceType;
    //region 获取 adapter pickerChoiceType
    switch (item.sign){
      case 200009:
        //region 员工
        adapter = personAdapter;
        pickerChoiceType = PickerChoiceType.chip;
        //endregion
        break;
      case 220011:
        //region 设备
        adapter = deviceAdapter;
        pickerChoiceType = PickerChoiceType.checkboxListTile;
        //endregion
        break;
      case 700201:
        //region 模具
        adapter = mouldAdapter;
        pickerChoiceType = PickerChoiceType.checkboxListTile;
        //endregion
        break;
    }
    //endregion
    if (adapter != null && pickerChoiceType != null){
      Picker(
        adapter: adapter
      ).showPickerDialog(Get.context!, pickerChoiceType: pickerChoiceType).then((value){
        adapter?.clearSelection();
        if (value == null || value.isEmpty){
          return;
        }
        //region 处理选中后回调
        if (workCenterProgId == 660022){
          List<String> existIdList = workCenterItem.entryList.where(
                  (element) => element.objType == item.sign).map(
                  (e) => e.objId ?? '').toList();
          List<PickerDataModel> newList = value.where((element){
            return !existIdList.contains(element.id);
          }).toList();
          List<MoWorkCenterDetailsModel> itemList = newList.map((e) {
            return MoWorkCenterDetailsModel(
              objType: item.sign,
              objId: e.id,
              objCode: e.code,
              objName: e.name,
              wcId: workCenterId,
            );
          }).toList();
          workCenterItem.entryList.addAll(itemList);
        }
        else {
          List<String> existIdList = beltLineItem.entryList.where(
                  (element) => element.objType == item.sign).map(
                  (e) => e.objId ?? '').toList();
          List<PickerDataModel> newList = value.where((element){
            return !existIdList.contains(element.id);
          }).toList();
          List<MoWorkCenterDetailsModel> itemList = newList.map((e) {
            return MoWorkCenterDetailsModel(
              objType: item.sign,
              objId: e.id,
              objCode: e.code,
              objName: e.name,
              wcId: workCenterId,
            );
          }).toList();
          beltLineItem.entryList.addAll(itemList);
        }

        update();
        //endregion
      });
    }
  }

  ///移除指定关联
  Future<void> removeItem(MoWorkCenterDetailsModel item) async {
    if (workCenterProgId == 660022){
      workCenterItem.entryList.removeWhere(
              (element) => element.objType == item.objType && element.objId == item.objId);
    }
    else {
      beltLineItem.entryList.removeWhere(
              (element) => element.objType == item.objType && element.objId == item.objId);
    }
    update();
  }


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

  ///扫码处理
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
    bool res = false;
    ProgressDialogUtil.showProgressDialog(msg: '正在返回扫描结果');

    List<String> list = searchString.split('|');
    if (list.length < 3){
      ToastNotification(Get.overlayContext!).warn('条码错误，请检查设置的默认条码格式！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    switch (list[1]){
      case 'G':
        //region 员工条码
        String psnNum = list[2];
        var res1 = await PersonRepository().getFormData('', '', {'PsnNum': psnNum}, 0);
        if (!res1.isSuccess){
          ToastNotification(Get.overlayContext!).warn('获取员工数据时出错：${res1.message}！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (res1.data.id.isEmpty){
          ToastNotification(Get.overlayContext!).warn('查询不到该员工！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (workCenterProgId == 660022){
          if (workCenterItem.entryList.firstWhereOrNull(
                  (element) => element.objType == 200009 && element.objId == res1.data.personID) != null){
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
        }
        else {
          if (beltLineItem.entryList.firstWhereOrNull(
                  (element) => element.objType == 200009 && element.objId == res1.data.personID) != null){
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
        }
        MoWorkCenterDetailsModel model = MoWorkCenterDetailsModel(
          objType: 200009,
          objId: res1.data.personID,
          objCode: res1.data.psnNum,
          objName: res1.data.psnName,
          wcId: workCenterId,
        );
        if (workCenterProgId == 660022){
          workCenterItem.entryList.add(model);
        }
        else {
          beltLineItem.entryList.add(model);
        }
        res = true;
        //endregion
        break;
      case 'E':
        //region 设备条码
        String deviceInfo = list[2];
        EAMDeviceModel eamDeviceModel = EAMDeviceModel();
        var res1 = await EAMDeviceRepository().getList({'DeviceCode': deviceInfo});
        if (!res1.isSuccess){
          ToastNotification(Get.overlayContext!).warn('获取设备数据时出错：${res1.message}！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (res1.data.isEmpty){
          var res2 = await EAMDeviceRepository().getModel(deviceInfo);
          if (!res2.isSuccess){
            ToastNotification(Get.overlayContext!).warn('获取设备数据时出错：${res2.message}！');
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
          if (res2.data.id.isEmpty){
            ToastNotification(Get.overlayContext!).warn('查询不到该设备！');
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
          eamDeviceModel = res2.data;
        }
        else {
          eamDeviceModel = res1.data[0];
        }
        if (workCenterProgId == 660022){
          if (workCenterItem.entryList.firstWhereOrNull(
                  (element) => element.objType == 220011 && element.objId == eamDeviceModel.deviceId) != null){
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
        }
        else {
          if (beltLineItem.entryList.firstWhereOrNull(
                  (element) => element.objType == 220011 && element.objId == eamDeviceModel.deviceId) != null){
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
        }
        MoWorkCenterDetailsModel model = MoWorkCenterDetailsModel(
          objType: 220011,
          objId: eamDeviceModel.deviceId,
          objCode: eamDeviceModel.deviceCode,
          objName: eamDeviceModel.deviceName,
          wcId: workCenterId,
        );
        if (workCenterProgId == 660022){
          workCenterItem.entryList.add(model);
        }
        else {
          beltLineItem.entryList.add(model);
        }
        res = true;
        //endregion
        break;
      case 'M':
        //region 模具条码
        String mouldCode = list[2];
        var res1 = await MouldRepository().getModel(mouldCode);
        if (!res1.isSuccess){
          ToastNotification(Get.overlayContext!).warn('获取模具数据时出错：${res1.message}！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (res1.data.id.isEmpty){
          ToastNotification(Get.overlayContext!).warn('查询不到该模具！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (workCenterProgId == 660022){
          if (workCenterItem.entryList.firstWhereOrNull(
                  (element) => element.objType == 700201 && element.objId == res1.data.mouldId) != null){
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
        }
        else {
          if (beltLineItem.entryList.firstWhereOrNull(
                  (element) => element.objType == 700201 && element.objId == res1.data.mouldId) != null){
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
        }
        MoWorkCenterDetailsModel model = MoWorkCenterDetailsModel(
          objType: 700201,
          objId: res1.data.mouldId,
          objCode: res1.data.mouldCode,
          objName: res1.data.mouldName,
          wcId: workCenterId,
        );
        if (workCenterProgId == 660022){
          workCenterItem.entryList.add(model);
        }
        else {
          beltLineItem.entryList.add(model);
        }
        res = true;
        //endregion
        break;
      default:
        ToastNotification(Get.overlayContext!).warn('条码错误！');
        isLoading = false;
        ProgressDialogUtil.close();
        return;
    }

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


  String getObjTypeTitle(int? objType){
    String content = '';
    switch (objType){
      case 200009: content = '员工'; break;
      case 220011: content = '设备'; break;
      case 700201: content = '模具'; break;
      case 660001: content = '工艺'; break;
    }
    return content;
  }


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      ProgressDialogUtil.showProgressDialog(msg: '正在提交分配数据', completedMsg: '分配数据提交成功！');
      if (workCenterProgId == 660022){
        workCenterItem.currentToken = null;
        workCenterItem.entryList.forEach((element) {
          element.childId = null;
        });
        var res = await MoWorkCenterRepository().saveVoucher(workCenterId, workCenterItem);
        if (!res.isSuccess){
          ProgressDialogUtil.close();
          ToastNotification(Get.overlayContext!).error('提交数据时出错：${res.message}！');
          return DialogReturnDataModel(isCanCloseDialog: false, data: true);
        }
      }
      else {
        beltLineItem.currentToken = null;
        beltLineItem.entryList.forEach((element) {
          element.childId = null;
        });
        var res = await MoBeltLineRepository().saveVoucher(workCenterId, beltLineItem);
        if (!res.isSuccess){
          ProgressDialogUtil.close();
          ToastNotification(Get.overlayContext!).error('提交数据时出错：${res.message}！');
          return DialogReturnDataModel(isCanCloseDialog: false, data: true);
        }
      }
      ProgressDialogUtil.update();
      await ProgressDialogUtil.awaitCompletionDelay();
      return DialogReturnDataModel(isCanCloseDialog: true, data: true);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

  @override
  void onClose() {
    scanFN.removeListener(scanFNOnListen);
    super.onClose();
  }

}