import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/mes_device_task_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 设备对应生产派工单 - 参数设置
class MesDeviceTaskSettingController extends BaseSettingController {


  @override
  final String title = '设备派工-页面设置';

  @override
  final List<ChoiceChipModel> tabValueList = [
    ChoiceChipModel(icon: Icons.filter_alt_sharp, title: '车间筛选', keyName: 'dep', isSelected: true),
    ChoiceChipModel(icon: Icons.filter_alt_sharp, title: '设备筛选', keyName: 'device', isSelected: false),
    ChoiceChipModel(icon: FluentIcons.view_desktop_24_regular, title: '页面显示设置', keyName: 'interface', isSelected: false),
  ];

  //region 车间筛选
  final List<DepartmentEntity> depList = [];
  //endregion

  //region 设备筛选
  final List<EAMDeviceModel> deviceList = [];
  //endregion

  //region 页面显示设置
  ///是否超产闪烁
  bool isBlink = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_IS_BLINK_KEY) ?? AppConfig.isBlink;
  ///超产闪烁的频率
  final int rate = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_BLINK_RATE_KEY) ?? AppConfig.rate;
  ///超产闪烁的频率 TextEditingController
  late final TextEditingController rateTC = TextEditingController(text: rate.toString());
  final FocusNode rateFN = FocusNode();

  ///单个设备卡片显示的设备信息 0 设备编号； 1 设备简称； 2设备名称
  int deviceShowInfoType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_DEVICE_SHOW_INFO_TYPE_KEY) ?? AppConfig.deviceShowInfoType;
  //endregion


  MesDeviceTaskSettingController({
    super.progId = -1,
  });


  @override
  Future<bool> initializeForm() async {
    bool res1 = await getDepList();
    bool res2 = await getDeviceList();
    return res1 && res2;
  }

  ///获取生产车间列表
  Future<bool> getDepList() async{
    List<dynamic> unVisibleDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_DEP_ID_DISPLAY_KEY) ?? [];
    var res = await DepartmentRepository().getList(4);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('读取车间列表时出错：${res.message}');
      return false;
    }
    depList.clear();
    depList.addAll(res.data);
    for (var element in depList) {
      if (unVisibleDepIdList.contains(element.departmentId)){
        element.isChoice = false;
      }
      else {
        element.isChoice = true;
      }
    }
    return true;
  }

  ///获取设备列表
  Future<bool> getDeviceList() async{
    List<dynamic> unVisibleDeviceIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_DEVICE_ID_DISPLAY_KEY) ?? [];
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
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('读取设备列表时出错：${res.message}');
      return false;
    }
    deviceList.clear();
    deviceList.addAll(res.rows);
    for (var element in deviceList) {
      if (unVisibleDeviceIdList.contains(element.deviceId)){
        element.isChoice = false;
      }
      else {
        element.isChoice = true;
      }
    }
    return true;
  }


  //region inChanged

  void depOnChanged(DepartmentEntity item){
    item.isChoice = !item.isChoice;
    update();
  }

  void deviceOnChanged(EAMDeviceModel item){
    item.isChoice = !item.isChoice;
    update();
  }

  void isBlinkOnChanged() {
    isBlink = !isBlink;
    update();
  }

  void deviceShowInfoTypeOnChanged(int index) {
    deviceShowInfoType = index;
    update();
  }

  //endregion


  //region onSave

  ///车间筛选保存
  Future<void> depSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存车间筛选数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存数据', completedMsg: '数据刷新成功！');

    //region 数据保存
    //     List<String> list = [];
    //     for (var element in depList) {
    //       if (!element.isChoice){
    //         list.add(element.departmentId);
    //       }
    //     }
    //     ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_DEVICE_TASK_DEP_ID_DISPLAY_KEY, list);
    //     //endregion
    ProgressDialogUtil.update(value: 1, msg: '车间筛选数据保存成功，正在刷新数据！');

    //region 数据刷新
    MesDeviceTaskController? mesDeviceTaskController;
    try {
      mesDeviceTaskController = Get.find<MesDeviceTaskController>();
    } catch (e){}
    if (mesDeviceTaskController != null){
      mesDeviceTaskController.getFilterOfDeviceTaskList();
      mesDeviceTaskController.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///设备筛选保存
  Future<void> deviceSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存设备筛选数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存数据', completedMsg: '数据刷新成功！');

    //region 数据保存
    List<String> list = [];
    for (var element in deviceList) {
      if (!element.isChoice){
        list.add(element.deviceId);
      }
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_DEVICE_TASK_DEVICE_ID_DISPLAY_KEY, list);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设备筛选数据保存成功，正在刷新数据！');

    //region 数据刷新
    MesDeviceTaskController? mesDeviceTaskController;
    try {
      mesDeviceTaskController = Get.find<MesDeviceTaskController>();
    } catch (e){}
    if (mesDeviceTaskController != null){
      mesDeviceTaskController.getFilterOfDeviceTaskList();
      mesDeviceTaskController.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///页面显示设置保存
  Future<void> interfaceSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    int? rate = int.tryParse(rateTC.text);
    if (rate == null){
      ToastNotification(Get.overlayContext!).error('“超产闪烁的频率”输入有误！');
      isLoading = false;
      return;
    }

    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存数据', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_DEVICE_TASK_IS_BLINK_KEY, isBlink);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_DEVICE_TASK_BLINK_RATE_KEY, rate);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_DEVICE_TASK_DEVICE_SHOW_INFO_TYPE_KEY, deviceShowInfoType);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '页面显示设置保存成功，正在刷新数据！');

    //region 数据刷新
    MesDeviceTaskController? mesDeviceTaskController;
    try {
      mesDeviceTaskController = Get.find<MesDeviceTaskController>();
    } catch (e){}
    if (mesDeviceTaskController != null){
      mesDeviceTaskController.rate = rate;
      mesDeviceTaskController.isBlink = isBlink;
      mesDeviceTaskController.deviceShowInfoType = deviceShowInfoType;
      mesDeviceTaskController.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  //endregion


  @override
  void onClose() {
    super.onClose();
  }

}