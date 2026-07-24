
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_andon/dialog/device_andon_base_dialog_controller.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';


///全场呼叫 默认弹出窗体
class DADefaultDialogController extends DeviceAndonBaseDialogController{

  late final TextEditingController deviceCodeTC = TextEditingController(text: deviceTaskModelWithGetxController.model.deviceCode);
  late final TextEditingController deviceNameTC = TextEditingController(text: deviceTaskModelWithGetxController.model.deviceName);
  late final TextEditingController mouldCodeTC = TextEditingController(text: deviceTaskModelWithGetxController.model.mouldCode);
  late final TextEditingController mouldNameTC = TextEditingController(text: deviceTaskModelWithGetxController.model.mouldName);
  late final TextEditingController invCodeTC = TextEditingController(text: deviceTaskModelWithGetxController.model.invCode);
  late final TextEditingController invNameTC = TextEditingController(text: deviceTaskModelWithGetxController.model.invName);

  ///问题列表
  final List<TreeModel> comDefectList = [];
  final ScrollController comDefectListController = ScrollController();

  ///问题
  String comDefectId = '';
  String comDefectCode = '';
  String comDefectName = '';

  ///班次
  TeamAdapter? teamAdapter;
  String teamId = '';
  String teamCode = '';
  String teamName = '';


  DADefaultDialogController({required super.deviceId, required super.wfSchemeInfo});


  @override
  Future<bool> initData() async{
    await getPersonAdapter();
    await getTeamAdapter();
    await getTeam();
    List<TreeModel> list = await getDetailList('ComDefects');
    comDefectList.clear();
    comDefectList.addAll(list);
    update();
    return true;
  }

  Future<void> getTeam() async{
    if (teamAdapter?.dataList != null){
      for (var element in teamAdapter!.dataList) {
        element.isSelected = false;
      }
      DateTime now = DateTime.now();
      for (var element in teamAdapter!.dataList) {
        String dateString = DateUtil.getDateStrByDateTime(now, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? '';
        String beginTimeString = '$dateString ${element.tBeginTime ?? '00:00'}';
        String endTimeString = '$dateString ${element.tEndTime ?? '00:00'}';
        DateTime beginTime = DateTime.tryParse(beginTimeString)!;
        DateTime endTime = DateTime.tryParse(endTimeString)!;
        if (beginTime.isAfter(endTime)){
          ///如果开始时间晚于结束时间：
          ///如果报工时间晚于开始时间，则结束时间加一天，反之开始时间减一天
          if (now.isAfter(beginTime)){
            endTime = endTime.add(const Duration(days: 1));
          }
          else{
            beginTime = beginTime.add(const Duration(days: -1));
          }
        }
        else if (beginTime.isAtSameMomentAs(endTime)){
          ///如果开始时间和结束时间一样，则结束时间加一天
          endTime = endTime.add(const Duration(days: 1));
        }
        if (now.isAfter(element.startDate ?? now)
            && now.isBefore(element.endDate ?? now)
            && now.isAfter(beginTime) && now.isBefore(endTime)){
          teamId = element.teamId;
          element.isSelected = true;
          break;
        }
      }
    }
  }

  ///车间OR派工单OR日期选择后，获取班次Adapter
  Future<void> getTeamAdapter() async{
    teamAdapter = await AdapterHelper.getAsyncAdapter(
        'team',
        queryData: {
          'depCode': deviceTaskModelWithGetxController.model.depCode,
          'dateTime': DateTime.now(),
        },
        selectedItems: [PickerDataModel(id: teamId)]
    ) as TeamAdapter;
  }

  ///班次Adapter选择变化
  void teamOnChanged(PickerDataModel model) {
    if (teamId != model.id){
      teamId = model.id;
      teamCode = model.code;
      teamName = model.name;
      update();
    }
  }

  ///问题类型选择变化
  void comDefectOnChanged(TreeModel item){
    if (!item.isChoice){
      for (var element in comDefectList) {
        if (element.id == item.id){
          element.isChoice = true;
        }
        else {
          element.isChoice = false;
        }
      }
      comDefectId = item.id;
      comDefectCode = item.value ?? '';
      comDefectName = item.text ?? '';
    }
    else {
      item.isChoice = false;
      comDefectId = '';
      comDefectCode = '';
      comDefectName = '';
    }
    update();
  }


  @override
  Future<bool> onSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn("正在提交！");
      return false;
    }
    isLoading = true;
    //region  保存前校验
    if (empId.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择生产人员！");
      isLoading = false;
      return false;
    }
    if (teamAdapter != null && teamAdapter!.dataList.isNotEmpty
        && teamId.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择生产班次！");
      isLoading = false;
      return false;
    }
    if (descTC.text.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请输入备注！");
      isLoading = false;
      return false;
    }
    if (comDefectId.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择问题类型！");
      isLoading = false;
      return false;
    }
    //endregion
    var _dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!,
      barrierDismissible: false,
      msg: '确认提交全场呼叫？',
    );
    if (_dialogRes == null || !_dialogRes){
      isLoading = false;
      return false;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交全场呼叫', completedMsg: '流程实例创建成功！');
    //region 提交全场呼叫
    //region MoAndonServiceModel 赋值
    MoAndonServiceModel andonServiceModel = MoAndonServiceModel();
    andonServiceModel.progid = wfSchemeInfo.progid ?? 0; //670012
    andonServiceModel.objectHalt = 0;
    andonServiceModel.enableMark = 1;
    andonServiceModel.deleteMark = 0;
    andonServiceModel.nPrint = 0;
    andonServiceModel.attach = 0;
    andonServiceModel.sign = 0;
    andonServiceModel.status = '';
    andonServiceModel.submitDate = DateTime.now();
    andonServiceModel.deviceId = deviceTaskModelWithGetxController.model.deviceId;
    andonServiceModel.invId = deviceTaskModelWithGetxController.model.invId;
    andonServiceModel.mouldId = deviceTaskModelWithGetxController.model.mouldId;
    andonServiceModel.mouldCode = deviceTaskModelWithGetxController.model.mouldCode;
    andonServiceModel.depId = deviceTaskModelWithGetxController.model.depId;
    andonServiceModel.processUser = empId;
    andonServiceModel.submitDescription = descTC.text;
    andonServiceModel.serviceClass = comDefectId;
    andonServiceModel.serviceCode = comDefectCode;
    andonServiceModel.serviceName = comDefectName;
    andonServiceModel.attach = imageList.length;
    //endregion
    var res = await AndonServiceRepository().saveVoucher('', andonServiceModel, imageList);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('提交全场呼叫时出错：${res.message}！');
      ProgressDialogUtil.close();
      isLoading = false;
      return false;
    }
    ProgressDialogUtil.update(value: 1, msg: '全场呼叫提交成功，正在创建流程实例！');
    //endregion
    //region 创建流程实例
    bool wfPRes = await saveWfParameter(res.data.data ?? '', descTC.text, teamCode, teamName);
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
    deviceCodeTC.dispose();
    deviceNameTC.dispose();
    mouldCodeTC.dispose();
    mouldNameTC.dispose();
    invCodeTC.dispose();
    invNameTC.dispose();
    comDefectListController.dispose();
    super.onClose();
  }
}
