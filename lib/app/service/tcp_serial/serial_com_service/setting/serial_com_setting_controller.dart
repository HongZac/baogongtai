import 'dart:async';
import 'dart:convert';

import 'package:basement/utils.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/base_serial_port.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_msg_process_model.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/serial_com_service.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/setting/connect_setting/serial_port_msg_connect_setting_controller.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/setting/connect_setting/serial_port_msg_connect_setting_view.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/setting/form/serial_com_setting_form_controller.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/setting/form/serial_com_setting_form_view.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';


///串口设置
class SerialComSettingController extends BaseDialogController {

  final SerialComService serialComService = Get.find<SerialComService>();

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


  //region 串口消息接收设置

  ///修改
  Future<void> serialPortMsgConnectSetting(String keyName) async {
    SerialPortMsgProcessModel _model = serialComService.serialPortMsgProcessList.firstWhereOrNull(
            (element) => element.keyName == keyName)
        ?? SerialPortMsgProcessModel(keyName: keyName, com: '', accuracy: 0);
    await DialogUtils.showCustomDialog<SerialPortMsgConnectSettingController, bool>(
      Get.context!, title: '串口消息接收设置',
      initialHeight: 500,
      initialWidth: 900,
      barrierDismissible: false,
      content: SerialPortMsgConnectSettingView(),
      controller: SerialPortMsgConnectSettingController(
        serialPortMsgProcessModel: _model
      ),
    );
    update();
  }

  ///清除
  Future<void> serialPortMsgConnectDelete(String keyName) async {
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

    serialComService.serialPortMsgProcessList.removeWhere(
            (element) => element.keyName == keyName);
    List<Map<String, dynamic>> _saveList = [];
    serialComService.serialPortMsgProcessList.forEach((element) {
      _saveList.add(element.toJson());
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.SERIAL_COM_SERVICE_SERIAL_PORT_MSG_PROCESS_LIST_KEY, _saveList);

    ToastNotification(Get.overlayContext!).success("串口删除成功！");
    isLoading = false;
    update();
  }

  //endregion


  @override
  void onClose() {
    subscription.cancel();
    super.onClose();
  }
}