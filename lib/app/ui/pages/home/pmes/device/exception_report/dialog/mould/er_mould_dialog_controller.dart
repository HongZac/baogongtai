
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../exception_report_base_dialog_controller.dart';


///工作流程-模具异常报告弹出窗体
class ERMouldDialogController extends ExceptionReportBaseDialogController{

  late final TextEditingController mouldCodeTC = TextEditingController(text: deviceTaskModelWithGetxController.model.mouldCode);
  late final TextEditingController mouldNameTC = TextEditingController(text: deviceTaskModelWithGetxController.model.mouldName);

  ///期望完成时间
  DateTime? expectDate;

  ///模具问题类型
  String problemTypeId = '';
  String problemTypeCode = '';
  String problemTypeName = '';

  ///模具故障等级
  String faultLevelId = '';
  String faultLevelCode = '';
  String faultLevelName = '';

  ///问题类型列表
  final List<TreeModel> problemTypeList = [];
  final ScrollController problemTypeListController = ScrollController();

  ///故障等级列表
  final List<TreeModel> faultLevelList = [];
  final ScrollController faultLevelListController = ScrollController();


  ERMouldDialogController({required super.deviceId, required super.wfSchemeInfo});


  @override
  Future<bool> initData() async{
    await getPersonAdapter();
    List<TreeModel> list1 = await getDetailList('MouldServiceClass');
    problemTypeList.clear();
    problemTypeList.addAll(list1);
    List<TreeModel> list2 = await getDetailList('MouldServiceLevel');
    faultLevelList.clear();
    faultLevelList.addAll(list2);
    update();
    return true;
  }

  ///异常类型选择变化
  Future<void> problemTypeOnChanged(TreeModel item) async{
    if (!item.isChoice){
      for (var element in problemTypeList) {
        if (element.id == item.id){
          element.isChoice = true;
        }
        else {
          element.isChoice = false;
        }
      }
      problemTypeId = item.id;
      problemTypeCode = item.value ?? '';
      problemTypeName = item.text ?? '';
    }
    else {
      item.isChoice = false;
      problemTypeId = '';
      problemTypeCode = '';
      problemTypeName = '';
    }
    update();
  }

  ///故障等级选择变化
  Future<void> faultLevelOnChanged(TreeModel item) async{
    if (!item.isChoice){
      for (var element in faultLevelList) {
        if (element.id == item.id){
          element.isChoice = true;
        }
        else {
          element.isChoice = false;
        }
      }
      faultLevelId = item.id;
      faultLevelCode = item.value ?? '';
      faultLevelName = item.text ?? '';
    }
    else {
      item.isChoice = false;
      faultLevelId = '';
      faultLevelCode = '';
      faultLevelName = '';
    }
    update();
  }

  ///期望日期选择变化
  Future<void> expectDateOnChanged(DateTime? dateTime) async{
    if (dateTime == null){ return; }
    expectDate = dateTime;
    update();
  }


  @override
  Future<bool> onSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn("正在提交！");
      return false;
    }
    isLoading = true;
    //region 提交前检验
    if (deviceTaskModelWithGetxController.model.mouldId == null || deviceTaskModelWithGetxController.model.mouldId!.isEmpty){
      ToastNotification(Get.overlayContext!).warn("该机台没有模具信息！");
      isLoading = false;
      return false;
    }
    if (empId.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择发现人员！");
      isLoading = false;
      return false;
    }
    if (descTC.text.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请输入故障描述！");
      isLoading = false;
      return false;
    }
    if (problemTypeId.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择问题类型！");
      isLoading = false;
      return false;
    }
    if (faultLevelId.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择故障等级！");
      isLoading = false;
      return false;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!,
      barrierDismissible: false,
      msg: '确认提交模具异常报告？',
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return false;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交模具维修记录', completedMsg: '流程实例创建成功！');
    //region 提交模具维修记录
    //region MouldServiceModel 赋值
    MouldServiceItem mouldServiceItem = MouldServiceItem();
    mouldServiceItem.progID = wfSchemeInfo.progid ?? 0;
    mouldServiceItem.deviceId = deviceId;
    mouldServiceItem.objectId = '';
    mouldServiceItem.mouldCode = deviceTaskModelWithGetxController.model.mouldCode;
    mouldServiceItem.mouldName = deviceTaskModelWithGetxController.model.mouldName;
    mouldServiceItem.serviceClass = problemTypeName;
    mouldServiceItem.serviceLevel = faultLevelName;
    mouldServiceItem.applyDate = DateTime.now();
    mouldServiceItem.ariseDescription = descTC.text;
    mouldServiceItem.ariseUser = emploee;
    mouldServiceItem.ariseDate = DateTime.now();
    mouldServiceItem.serviceSign = 1;
    mouldServiceItem.attach = imageList.length;
    mouldServiceItem.expectDate = expectDate;
    //endregion
    var res = await MouldServiceRepository().saveVoucher('', mouldServiceItem, attachList: imageList, progid: wfSchemeInfo.progid ?? 0);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('提交模具维修记录时出错：${res.message}！');
      ProgressDialogUtil.close();
      isLoading = false;
      return false;
    }
    ProgressDialogUtil.update(value: 1, msg: '模具维修记录提交成功，正在创建流程实例！');
    //endregion
    //region 创建流程实例
    bool wfPRes = await saveWfParameter(res.data.data, descTC.text);
    if (!wfPRes){
      ProgressDialogUtil.close();
      isLoading = false;
      return false;
    }
    ProgressDialogUtil.update(value: 2, msg: '流程实例创建成功！');
    await ProgressDialogUtil.awaitCompletionDelay();
    //endregion
    isLoading = false;
    return true;
  }

  @override
  void onClose() {
    mouldCodeTC.dispose();
    mouldNameTC.dispose();
    faultLevelListController.dispose();
    problemTypeListController.dispose();
    super.onClose();
  }
}