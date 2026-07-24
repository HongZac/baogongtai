import 'dart:io';

import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AndonAddExtraFormController extends BaseFormController {

  ///是否显示【数量】  1 显示；0 不显示
  final int? showAffected;
  ///异常类别组: 1:模具 2:设备 4:材料
  final int? serviceKind;
  final String andonClassSelectedTitle;
  ///是否显示设备选单
  final bool isShowDevicePicker;

  final MoAndonServiceModel andonServiceModel = MoAndonServiceModel();

  MouldAdapter? mouldAdapter;
  EAMDeviceAdapter? deviceAdapter;
  InventoryAdapter? inventoryAdapter;

  ///数量填写
  final TextEditingController qtyTC = TextEditingController();
  ///数量填写
  final FocusNode qtyFN = FocusNode();

  ///提交描述 TextEditingController
  final TextEditingController descTC = TextEditingController();
  ///提交描述 FocusNode
  final FocusNode descFN = FocusNode();


  AndonAddExtraFormController({
    super.progId = -1,
    super.isNeedGetObjectItem = false,
    required MoAndonServiceModel andonServiceModel,
    required this.showAffected,
    required this.serviceKind,
    required this.andonClassSelectedTitle,
    this.isShowDevicePicker = true,
  }){
    this.andonServiceModel.mouldId = andonServiceModel.mouldId;
    this.andonServiceModel.mouldCode = andonServiceModel.mouldCode;
    this.andonServiceModel.mouldName = andonServiceModel.mouldName;
    this.andonServiceModel.deviceId = andonServiceModel.deviceId;
    this.andonServiceModel.deviceCode = andonServiceModel.deviceCode;
    this.andonServiceModel.deviceName = andonServiceModel.deviceName;
    this.andonServiceModel.invId = andonServiceModel.invId;
    this.andonServiceModel.invCode = andonServiceModel.invCode;
    this.andonServiceModel.invName = andonServiceModel.invName;
    this.andonServiceModel.affected = andonServiceModel.affected;
    this.andonServiceModel.submitDescription = andonServiceModel.submitDescription;
    this.andonServiceModel.imageList.clear();
    this.andonServiceModel.imageList.addAll(andonServiceModel.imageList);
    andonServiceModel.attach = andonServiceModel.attach;
    qtyTC.text = this.andonServiceModel.affected?.toString() ?? '';
    descTC.text = this.andonServiceModel.submitDescription?.toString() ?? '';
  }


  @override
  void onInit(){
    super.onInit();
  }


  @override
  Future<bool> initializeForm() async {
    if (((serviceKind ?? 0) & 1) == 1){
      getMouldAdapter().then((value) {
        update();
      });
    }
    if (((serviceKind ?? 0) & 2) == 2){
      getEAMDeviceAdapter().then((value) {
        update();
      });
    }
    if (((serviceKind ?? 0) & 4) == 4){
      getInventoryAdapter().then((value) {
        update();
      });
    }
    return true;
  }

  //region get Adapter

  Future<void> getMouldAdapter() async{
    mouldAdapter = await AdapterHelper.getAsyncAdapter(
      'mould',
      selectedItems: [PickerDataModel(id: andonServiceModel.mouldId)],
    ) as MouldAdapter;
  }

  Future<void> getEAMDeviceAdapter() async{
    deviceAdapter = await AdapterHelper.getAsyncAdapter(
      'device',
      selectedItems: [PickerDataModel(id: andonServiceModel.deviceId)],
    ) as EAMDeviceAdapter;
  }

  Future<void> getInventoryAdapter() async{
    inventoryAdapter = await AdapterHelper.getAsyncAdapter(
      'inventory',
      selectedItems: [PickerDataModel(id: andonServiceModel.invId)],
    ) as InventoryAdapter;
  }

  //endregion

  //region onChanged

  ///模具选择变化
  void mouldOnChanged(PickerDataModel model) {
    andonServiceModel.mouldId = model.id;
    andonServiceModel.mouldCode = model.code;
    andonServiceModel.mouldName = model.name;
    update();
  }

  ///设备选择变化
  void deviceOnChanged(PickerDataModel model) {
    andonServiceModel.deviceId = model.id;
    andonServiceModel.deviceCode = model.code;
    andonServiceModel.deviceName = model.name;
    update();
  }

  ///产品选择变化
  void inventoryOnChanged(PickerDataModel model) {
    andonServiceModel.invId = model.id;
    andonServiceModel.invCode = model.code;
    andonServiceModel.invName = model.name;
    update();
  }

  ///图片附件重新选择后回调
  void attachOnChange(String uid, File file){
    var attach = andonServiceModel.imageList.firstWhereOrNull((item) => item["key"].toString() == uid);
    if(attach == null){
      andonServiceModel.imageList.add({"key": uid, "file": file.path });
    }
    else {
      attach["file"] = file.path;
    }
    update();
  }

  //endregion

  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      var res = await onSave();
      if (!res.isSuccess){
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      return DialogReturnDataModel(isCanCloseDialog: true, data: res.data ?? '');
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

  Future<ApiResult<MoAndonServiceModel?>> onSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在提交！',
      );
      return ApiResult();
    }
    isLoading = true;
    //region 保存前校验
    if (((serviceKind ?? 0) & 1 == 1) && (andonServiceModel.mouldId == null || andonServiceModel.mouldId!.isEmpty)){
      ToastNotification(Get.overlayContext!).warn("请选择模具！");
      isLoading = false;
      return ApiResult();
    }
    if (((serviceKind ?? 0) & 2 == 2) && (andonServiceModel.deviceId == null || andonServiceModel.deviceId!.isEmpty)){
      ToastNotification(Get.overlayContext!).warn("请选择设备！");
      isLoading = false;
      return ApiResult();
    }
    if (((serviceKind ?? 0) & 4 == 4) && (andonServiceModel.invId == null || andonServiceModel.invId!.isEmpty)){
      ToastNotification(Get.overlayContext!).warn("请选择产品！");
      isLoading = false;
      return ApiResult();
    }
    int? affected = int.tryParse(qtyTC.text);
    if (showAffected == 1 && qtyTC.text.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请输入数量！");
      isLoading = false;
      return ApiResult();
    }
    else if (showAffected == 1 && affected == null){
      ToastNotification(Get.overlayContext!).warn("数量输入错误！");
      isLoading = false;
      return ApiResult();
    }
    //endregion
    andonServiceModel.attach = andonServiceModel.imageList.length;
    andonServiceModel.submitDescription = descTC.text;
    andonServiceModel.affected = affected;
    isLoading = false;
    return ApiResult(code: 200, data: andonServiceModel);
  }

}