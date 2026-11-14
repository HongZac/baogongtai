import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/shutdown_record/process_type_edit_form/shutdown_record_process_type_form_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/shutdown_record/process_type_edit_form/shutdown_record_process_type_form_page.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///修改设备状态
class ChangeDeviceSignController extends BaseDialogController {

  ///采集器编号
  final String pickerNo;

  ///当前设备状态
  ///
  /// 1: 运行中， 2： 待机  4：停机   8：未连接
  final int initSign;

  ///选中的设备状态
  ///
  ///1: 运行中， 2： 待机  4：停机   8：未连接
  int? selectedSign;

  ///停机原因弹窗返回的数据（ProcessType/Operator/OperateDate/Description）
  Map<String, dynamic>? shutdownReasonData;

  ///可选的设备状态列表 1: 运行中， 2： 待机  4：停机   8：未连接
  final List<DeviceSign> deviceSignList = [
    DeviceSign.scz,
    DeviceSign.dj,
    DeviceSign.tjz,
    DeviceSign.wlj,
  ];

  ChangeDeviceSignController({
    required this.pickerNo,
    required this.initSign,
  });


  @override
  void onInit() {
    super.onInit();
    selectedSign = initSign;
  }


  void deviceSignOnChanged(DeviceSign item) {
    selectedSign = item.sign;
    update();
  }


  ///选择停机原因
  Future<void> selectShutdownReason() async {
    var res = await DialogUtils.showCustomDialog<ShutdownRecordProcessTypeFormController, Map<String, dynamic>>(
      Get.context!,
      title: '选择停机原因',
      isMaximize: true,
      contentPadding: const EdgeInsets.all(0),
      content: ShutdownRecordProcessTypeFormPage(),
      controller: ShutdownRecordProcessTypeFormController(
        processType: shutdownReasonData?['ProcessType']?.toString(),
        desc: shutdownReasonData?['Description'],
        operatorId: shutdownReasonData?['Operator'],
        processId: null,
      ),
    );
    if (res != null){
      shutdownReasonData = res;
      update();
    }
  }


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      if (selectedSign == null){
        ToastNotification(Get.overlayContext!).error('请选择设备状态！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      bool isNeedSaveShutdownReason = selectedSign == 4 && shutdownReasonData != null;
      ProgressDialogUtil.showProgressDialog(
          max: isNeedSaveShutdownReason ? 2 : 1,
          msg: '正在修改设备状态',
          completedMsg: isNeedSaveShutdownReason
              ? '停机原因提交成功！'
              : '修改设备状态成功！'
      );
      var res = await MoProcessRepository().changeDeviceSign(pickerNo, selectedSign!);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).warn('提交修改设备状态时出错：${res.message}！');
        ProgressDialogUtil.close();
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      ProgressDialogUtil.update(
          value: 1,
          msg: isNeedSaveShutdownReason ? '正在提交停机原因' : null,
      );
      if (isNeedSaveShutdownReason){
        if (res.data.processId == null || res.data.processId!.isEmpty){
          ToastNotification(Get.overlayContext!).warn('修改设备状态后返回的数据有误！');
          ProgressDialogUtil.close();
          return DialogReturnDataModel(isCanCloseDialog: false);
        }
        Map<String, dynamic> dataMap = {};
        dataMap.addAll(shutdownReasonData!);
        dataMap.remove('ProcessTypeName');
        var res1 = await MoProcessRepository().feedbackReason(res.data.processId!, dataMap);
        if (!res1.isSuccess){
          ToastNotification(Get.overlayContext!).warn('停机原因提交失败！${res1.message}！');
          ProgressDialogUtil.close();
          return DialogReturnDataModel(isCanCloseDialog: false);
        }
        ProgressDialogUtil.update(value: 2);
      }
      return DialogReturnDataModel(
        isCanCloseDialog: true,
        data: {
          'isSuccess': 1,
          'sign': selectedSign,
        }
      );
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

}
