import 'dart:io';

import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///工作流程-异常报告 填单窗体 基类
abstract class ExceptionReportBaseDialogController extends BaseFormController{

  final String? deviceId;
  final WfSchemeInfoModel wfSchemeInfo;
  late final ModelWithGetxController<MoDeviceTaskModel> deviceTaskModelWithGetxController = Get.find<ModelWithGetxController<MoDeviceTaskModel>>(tag: 'PMesDevice-${deviceId ?? ''}');

  ///生产人员获取条件的Key
  int psnGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
  ///生产人员获取条件 车间固定值
  String psnDepCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;

  PersonAdapter? personAdapter;
  String empId = '';
  String emploee = '';

  ///故障描述 TextEditingController
  final TextEditingController descTC = TextEditingController();
  ///故障描述 FocusNode
  final FocusNode descFN = FocusNode();

  ///附件
  List<Map<String, dynamic>> imageList = [];


  ExceptionReportBaseDialogController({
    super.progId = 110002,
    required this.deviceId,
    required this.wfSchemeInfo
  });


  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<bool> initializeForm() async {
    var res = await initData();
    return res;
  }

  Future<bool> initData() async {
    return true;
  }

  Future<void> getPersonAdapter() async {
    List<PickerDataModel> list = empId.isEmpty ? [] : empId.split(',').map((e) => PickerDataModel(id: e)).toList();
    personAdapter = await AdapterHelper.getAsyncAdapter(
      'person',
      multipleSelection: true,
      isNeedLoadData: true,
      queryData: {
      'DepCode': getpsnDepCode(),
      'Active': 0, ///Active:0不显示离职人员
      },
      selectedItems: list
    ) as PersonAdapter;
  }

  ///获取人员列表的条件
  String? getpsnDepCode(){
    switch (psnGetWayIndex){
      case 0: //全部
        return '';
      case 1: //选中的车间
        return deviceTaskModelWithGetxController.model.depCode;
      case 2: //固定车间
        return psnDepCode;
      default:
        return '';
    }
  }

  ///人员Adapter选择变化
  void psnOnChanged(List<PickerDataModel> list) {
    empId = list.map((e) => e.id).join(',');
    emploee = list.map((e) => e.name).join(',');
    update();
  }

  ///获取明细列表
  Future<List<TreeModel>> getDetailList(String itemCode) async{
    List<TreeModel> list = [];
    var res = await DataItemRepository().getDetailTree(itemCode);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取明细列表时出错：${res.message}！');
      return [];
    }
    list.addAll(res.data);
    return list;
  }

  ///图片附件重新选择后回调
  void onChange(String uid, File file){
    var attach = imageList.firstWhereOrNull((item) => item["key"].toString() == uid);
    if(attach == null){
      imageList.add({"key": uid, "file": file.path });
    }
    else {
      attach["file"] = file.path;
    }
    update();
  }

  Future<bool> onSave() async{
    return false;
  }

  ///创建流程实例
  Future<bool> saveWfParameter(String sourceId, String desc) async{
    WfParameter wfParameterModel = WfParameter();
    wfParameterModel.schemeCode = wfSchemeInfo.code;
    wfParameterModel.verifyType = '0';
    wfParameterModel.isNew = true;
    wfParameterModel.sourceId = sourceId;
    wfParameterModel.sourceProgid = wfSchemeInfo.progid;
    wfParameterModel.processName = '[${deviceTaskModelWithGetxController.model.deviceCode}]' +
        '[${deviceTaskModelWithGetxController.model.mouldCode}]' + desc;
    wfParameterModel.description = '[${deviceTaskModelWithGetxController.model.deviceName}]' +
        '[${deviceTaskModelWithGetxController.model.mouldName}]' +
        '[${deviceTaskModelWithGetxController.model.invCode}]' + '[${deviceTaskModelWithGetxController.model.invName}]';
    var res = await FlowRepository().create(wfParameterModel);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error("创建流程实例时出错：${res.message}！");
      return false;
    }
    return true;
  }

  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      var res = await onSave();
      if (!res){
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      return DialogReturnDataModel(isCanCloseDialog: true, data: true);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }


  @override
  void onClose() {
    descTC.dispose();
    descFN.dispose();
    super.onClose();
  }

}