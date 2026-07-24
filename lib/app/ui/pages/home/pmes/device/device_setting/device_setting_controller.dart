import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///设备概览 - 参数设置
class DeviceSettingController extends BaseSettingController {

  @override
  final String title = '实时监测-页面设置';

  @override
  final List<ChoiceChipModel> tabValueList = [
    ChoiceChipModel(icon: Icons.filter_alt_sharp, title: '车间筛选', keyName: 'dep', isSelected: true),
    ChoiceChipModel(icon: Icons.filter_alt_sharp, title: '设备筛选', keyName: 'device', isSelected: false),
    ChoiceChipModel(icon: FluentIcons.view_desktop_24_regular, title: '页面显示设置', keyName: 'interface', isSelected: false),
    ChoiceChipModel(icon: FluentIcons.speaker_settings_24_filled, title: '语音播报设置', keyName: 'tts', isSelected: false),
    ChoiceChipModel(icon: Icons.timer, title: '定时刷新设置', keyName: 'timerRefresh', isSelected: false),
  ];

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  final DeviceController deviceController = Get.find<DeviceController>();


  //region 车间筛选
  final List<DepartmentEntity> depList = [];
  //endregion

  //region 设备筛选
  final List<EAMDeviceModel> deviceList = [];
  //endregion

  //region 页面显示设置
  ///是否超产闪烁
  bool isBlink = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_BLINK_KEY) ?? AppConfig.isBlink;
  ///超产闪烁的频率
  final int rate = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_BLINK_RATE_KEY) ?? AppConfig.rate;
  ///超产闪烁的频率 TextEditingController
  late final TextEditingController rateTC = TextEditingController(text: rate.toString());
  final FocusNode rateFN = FocusNode();

  ///单个设备卡片显示的设备信息 0 设备编号； 1 设备简称； 2设备名称
  int deviceShowInfoType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_DEVICE_SHOW_INFO_TYPE_KEY) ?? AppConfig.deviceShowInfoType;
  //endregion

  //region 语音播报设置
  ///超产 设备概览是否超产语音播报
  bool isOpenOverProductFlutterTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_OPEN_OVER_PRODUCT_FLUTTER_TTS) ?? AppConfig.isOpenFlutterTts;
  ///异常报告 是否语音播报
  bool isOpenExceptionReportTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_OPEN_EXCEPTION_REPORT_FLUTTER_TTS) ?? AppConfig.isOpenFlutterTts;
  ///全场呼叫 是否打开语音播报
  bool isOpenAndonTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_OPEN_ANDON_FLUTTER_TTS) ?? AppConfig.isOpenFlutterTts;
  ///超产预警 播报提前时间（秒）
  final int leadTimeOverProductWarnFlutterTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_LEAD_TIME_OVER_PRODUCT_WARN_FLUTTER_TTS) ?? AppConfig.leadTimeOverProductWarnFlutterTts;
  ///两次循环之间的间隔时间（秒）
  final int timeBetweenCyclesFlutterTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_TIME_BETWEEN_CYCLES_FLUTTER_TTS) ?? AppConfig.timeBetweenCyclesFlutterTts;
  ///单次循环的播报次数
  final int numOfEachCycleFlutterTts = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_NUM_OF_EACH_CYCLE_FLUTTER_TTS) ?? AppConfig.numOfEachCycleFlutterTts;
  ///超产预警 播报提前时间（秒） TextEditingController
  late final TextEditingController lTOPWFTTC = TextEditingController(text: leadTimeOverProductWarnFlutterTts.toString());
  final FocusNode lTOPWFTFN = FocusNode();
  ///两次循环之间的间隔时间（秒） TextEditingController
  late final TextEditingController tBCOPFTTC = TextEditingController(text: timeBetweenCyclesFlutterTts.toString());
  final FocusNode tBCOPFTFN = FocusNode();
  ///单次循环的播报次数 TextEditingController
  late final TextEditingController nOECOPFTTC = TextEditingController(text: numOfEachCycleFlutterTts.toString());
  final FocusNode nOECOPFTFN = FocusNode();
  //endregion

  //region 定时刷新
  ///是否可以定时刷新
  bool isCanTimedRefresh = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_IS_CAN_TIMED_REFRESH_KEY) ?? AppConfig.isCanTimedRefresh;
  ///刷新 数据刷新频率（时间 秒）
  late int secondOfRefresh = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_SCROLL_REFRESH_TIME_KEY) ?? AppConfig.secondOfRefresh;
  late final TextEditingController secondOfRefreshTC = TextEditingController(text: secondOfRefresh.toString());
  final FocusNode secondOfRefreshFN = FocusNode();
  //endregion


  DeviceSettingController({
    super.progId = -1,
    this.noPermission = false,
    this.permissionInfo = '',
  });


  @override
  Future<bool> initializeForm() async {
    bool res1 = await getDepList();
    bool res2 = await getDeviceList();
    return res1 && res2;
  }

  ///获取生产车间列表
  Future<bool> getDepList() async{
    List<dynamic> unVisibleDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_DEP_ID_DISPLAY_KEY) ?? [];
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
    List<dynamic> unVisibleDeviceIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_DEVICE_ID_DISPLAY_KEY) ?? [];
    PageConfig pageConfig = PageConfig(
      page: 1,
      rows: 1000,
      sidx: 'DeviceCode',
      sord: 'asc',
      queryData: {
        'module': 1,
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

  void overProductFlutterTtsOnChanged() {
    isOpenOverProductFlutterTts = !isOpenOverProductFlutterTts;
    update();
  }

  void isOpenExceptionReportTtsOnChanged() {
    isOpenExceptionReportTts= !isOpenExceptionReportTts;
    update();
  }

  void isOpenAndonTtsOnChanged() {
    isOpenAndonTts = !isOpenAndonTts;
    update();
  }

  void isCanTimedRefreshOnChanged() {
    isCanTimedRefresh = !isCanTimedRefresh;
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
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
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
    List<String> list = [];
    for (var element in depList) {
      if (!element.isChoice){
        list.add(element.departmentId);
      }
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_DEP_ID_DISPLAY_KEY, list);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '车间筛选数据保存成功，正在刷新数据！');

    //region 数据刷新
    deviceController.getFilterOfDeviceTaskList();
    deviceController.getNumOfDeviceSign();
    deviceController.update();
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
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_DEVICE_ID_DISPLAY_KEY, list);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设备筛选数据保存成功，正在刷新数据！');

    //region 数据刷新
    deviceController.getFilterOfDeviceTaskList();
    deviceController.getNumOfDeviceSign();
    deviceController.update();
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
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_IS_BLINK_KEY, isBlink);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_BLINK_RATE_KEY, rate);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_DEVICE_SHOW_INFO_TYPE_KEY, deviceShowInfoType);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '页面显示设置保存成功，正在刷新数据！');

    //region 数据刷新
    deviceController.rate = rate;
    deviceController.isBlink = isBlink;
    deviceController.deviceShowInfoType = deviceShowInfoType;
    deviceController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///语音播报设置保存
  Future<void> ttsSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    int? leadTimeOverProductWarnFlutterTts = int.tryParse(lTOPWFTTC.text);
    int? timeBetweenCyclesFlutterTts = int.tryParse(tBCOPFTTC.text);
    int? numOfEachCycleFlutterTts = int.tryParse(nOECOPFTTC.text);
    if (leadTimeOverProductWarnFlutterTts == null){
      ToastNotification(Get.overlayContext!).error('“超产预警 播报提前时间”输入有误！');
      isLoading = false;
      return;
    }
    if (timeBetweenCyclesFlutterTts == null){
      ToastNotification(Get.overlayContext!).error('“两次循环之间的间隔时间”输入有误！');
      isLoading = false;
      return;
    }
    if (numOfEachCycleFlutterTts == null){
      ToastNotification(Get.overlayContext!).error('“单次循环的播报次数”输入有误！');
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_IS_OPEN_OVER_PRODUCT_FLUTTER_TTS, isOpenOverProductFlutterTts);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_IS_OPEN_EXCEPTION_REPORT_FLUTTER_TTS, isOpenExceptionReportTts);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_IS_OPEN_ANDON_FLUTTER_TTS, isOpenAndonTts);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_LEAD_TIME_OVER_PRODUCT_WARN_FLUTTER_TTS, leadTimeOverProductWarnFlutterTts);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_TIME_BETWEEN_CYCLES_FLUTTER_TTS, timeBetweenCyclesFlutterTts);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_NUM_OF_EACH_CYCLE_FLUTTER_TTS, numOfEachCycleFlutterTts);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '页面显示设置保存成功，正在刷新数据！');

    //region 数据刷新
    deviceController.isOpenOverProductFlutterTts = isOpenOverProductFlutterTts;
    deviceController.isOpenExceptionReportTts = isOpenExceptionReportTts;
    deviceController.isOpenAndonTts = isOpenAndonTts;
    deviceController.leadTimeOverProductWarnFlutterTts = leadTimeOverProductWarnFlutterTts;
    deviceController.timeBetweenCycleFlutterTts = timeBetweenCyclesFlutterTts;
    deviceController.numOfEachCycleFlutterTts = numOfEachCycleFlutterTts;
    deviceController.update();
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2, msg: '请在保存成功后，重新打开“实时监测”页面');
  }

  ///定时刷新设置保存
  Future<void> timerRefreshSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    int? secondOfRefresh = int.tryParse(secondOfRefreshTC.text);
    if (secondOfRefresh == null){
      ToastNotification(Get.overlayContext!).error('“刷新频率”输入有误！');
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_IS_CAN_TIMED_REFRESH_KEY, isCanTimedRefresh);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_SCROLL_REFRESH_TIME_KEY, secondOfRefresh);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '页面显示设置保存成功，正在刷新数据！');

    //region 数据刷新
    deviceController.isCanTimedRefresh = isCanTimedRefresh;
    deviceController.secondOfRefresh = secondOfRefresh;
    deviceController.update();
    //endregion

    isLoading = false;
    ProgressDialogUtil.update(value: 2, msg: '请在保存成功后，重新打开“实时监测”页面');
  }

  //endregion


  @override
  void onClose() {
    super.onClose();
  }

}