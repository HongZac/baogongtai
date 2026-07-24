import 'dart:async';
import 'dart:convert';

import 'package:basement/utils.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/service/serial_com_service/base_serial_port.dart';
import 'package:desktop/app/service/serial_com_service/serial_com_service.dart';
import 'package:desktop/app/service/serial_com_service/serial_port_data_model.dart';
import 'package:desktop/app/service/serial_com_service/setting/connect_setting/serial_port_msg_connect_setting_controller.dart';
import 'package:desktop/app/service/serial_com_service/setting/connect_setting/serial_port_msg_connect_setting_view.dart';
import 'package:desktop/app/service/serial_com_service/setting/form/serial_com_setting_form_controller.dart';
import 'package:desktop/app/service/serial_com_service/setting/form/serial_com_setting_form_view.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';


///串口设置
class SerialComSettingController extends BaseDialogController {

  final SerialComService serialComService = Get.find<SerialComService>();
  final WeightMsgConnectService weightMsgConnectService = Get.find<WeightMsgConnectService>();

  final List<bool> isExpandedList = [true, true];

  final appService = Get.find<AppService>();
  late final StreamSubscription<SerialPortDataModel> subscription;

  bool isLoading = false;


  @override
  void onReady() {
    super.onReady();

    ///接收串口数组
    subscription = appService.eventBus.on<SerialPortDataModel>().listen((event) async {
      if (event.isConnectMsg) {
        Map<String, dynamic> dataMap = jsonDecode(event.data);
        if (dataMap.containsKey('-1')){
          ToastNotification(Get.overlayContext!).error(dataMap['-1'].toString());
          update();
        }
        else if (dataMap.containsKey('-2')) {
          update();
        }
      }
    });
  }


  ///新增串口通讯服务
  Future<void> addSerialPort() async {
    var res = await DialogUtils.showCustomDialog<SerialComSettingFormController, bool>(
      Get.context!, title: '新增串口通讯服务',
      initialHeight: 500,
      initialWidth: 800,
      barrierDismissible: false,
      content: SerialComSettingFormView(),
      controller: SerialComSettingFormController(),
    );
    if (res != null && res){
      update();
    }
  }

  ///修改串口通讯服务
  Future<void> editSerialPort(BaseSerialPort item) async {
   var res = await DialogUtils.showCustomDialog<SerialComSettingFormController, bool>(
      Get.context!, title: '编辑串口通讯服务',
      initialHeight: 500,
      initialWidth: 800,
      barrierDismissible: false,
      content: SerialComSettingFormView(),
      controller: SerialComSettingFormController(
        oldCom: item.portName,
      ),
    );
    if (res != null && res){
      update();
    }
  }

  ///删除串口通讯服务
  Future<void> deleteSerialPort(BaseSerialPort item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn("正在处理数据……");
      return;
    }
    isLoading = true;

    var confirm = await DialogUtils.showConfirmationDialog(Get.overlayContext!,
        msg: "确认删除？");
    if (confirm == null || !confirm) {
      isLoading = false;
      return;
    }

    await serialComService.removeSerialPort(item.portName);

    ToastNotification(Get.overlayContext!).success("串口删除成功！");
    isLoading = false;
    update();
  }

  ///打开/关闭 串口
  Future<void> serialPortOpenOnChanged(BaseSerialPort item) async {
    if (item.isOpen){
      bool res = await item.close();
      if (res){
        ToastNotification(Get.overlayContext!).success("串口关闭成功！");
      }
    }
    else {
      bool res = await item.open();
      if (res){
        ToastNotification(Get.overlayContext!).success("串口打开成功！");
      }
    }
    update();
  }


  ///串口消息接收设置
  Future<void> serialPortMsgConnectSetting(String key) async {
    WeightMsgConnectModel _model = weightMsgConnectService.connectList.firstWhereOrNull(
            (element) => element.key == key)
        ?? WeightMsgConnectModel(key: key, host: '', port: 0, accuracy: 0, com: '');
    await DialogUtils.showCustomDialog<SerialPortMsgConnectSettingController, bool>(
      Get.context!, title: '串口消息接收设置',
      initialHeight: 500,
      initialWidth: 900,
      barrierDismissible: false,
      content: SerialPortMsgConnectSettingView(),
      controller: SerialPortMsgConnectSettingController(weightMsgConnectModel: _model),
    );
    update();
  }

  ///串口消息接收-清除设置
  Future<void> serialPortMsgConnectDelete(String key) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn("正在处理数据……");
      return;
    }
    isLoading = true;

    var confirm = await DialogUtils.showConfirmationDialog(Get.overlayContext!,
        msg: "确认清除？");
    if (confirm == null || !confirm) {
      isLoading = false;
      return;
    }

    weightMsgConnectService.connectList.removeWhere(
            (element) => element.key == key);
    List<Map<String, dynamic>> _saveList = [];
    weightMsgConnectService.connectList.forEach((element) {
      _saveList.add(element.toJson());
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.CONNECTLIST_KEY, _saveList);

    ToastNotification(Get.overlayContext!).success("串口删除成功！");
    isLoading = false;
    update();
  }


  @override
  void onClose() {
    subscription.cancel();
    super.onClose();
  }
}