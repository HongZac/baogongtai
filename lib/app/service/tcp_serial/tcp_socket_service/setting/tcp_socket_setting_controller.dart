import 'dart:async';
import 'dart:convert';

import 'package:basement/utils.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/base_tcp_socket.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_msg_process_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/setting/connect_setting/tcp_socket_msg_connect_setting_controller.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/setting/connect_setting/tcp_socket_msg_connect_setting_view.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/setting/form/tcp_socket_setting_form_controller.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/setting/form/tcp_socket_setting_form_view.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/tcp_socket_service.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';

///TCP客户端套接字设置
class TcpSocketSettingController extends BaseDialogController {
  
  final TcpSocketService tcpSocketService = Get.find<TcpSocketService>();

  final List<bool> isExpandedList = [true, true];

  final appService = Get.find<AppService>();
  late final StreamSubscription<TcpSocketDataModel> subscription;

  bool isLoading = false;


  @override
  void onReady() {
    super.onReady();

    ///接收 TCP 数组
    subscription = appService.eventBus.on<TcpSocketDataModel>().listen((event) async {
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
  

  ///新增 TCP 通讯服务
  Future<void> addTcpSocket() async {
    var res = await DialogUtils.showCustomDialog<TcpSocketSettingFormController, bool>(
      Get.context!, title: '新增 TCP 通讯服务',
      initialHeight: 500,
      initialWidth: 800,
      barrierDismissible: false,
      content: TcpSocketSettingFormView(),
      controller: TcpSocketSettingFormController(),
    );
    if (res != null && res){
      update();
    }
  }

  ///修改 TCP 通讯服务
  Future<void> editTcpSocket(BaseTcpSocket item) async {
    var res = await DialogUtils.showCustomDialog<TcpSocketSettingFormController, bool>(
      Get.context!, title: '编辑 TCP 通讯服务',
      initialHeight: 500,
      initialWidth: 800,
      barrierDismissible: false,
      content: TcpSocketSettingFormView(),
      controller: TcpSocketSettingFormController(
        oldHost: item.host,
        oldPost: item.port,
      ),
    );
    if (res != null && res){
      update();
    }
  }

  ///删除 TCP 通讯服务
  Future<void> deleteTcpSocket(BaseTcpSocket item) async {
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

    await tcpSocketService.removeTcpSocket(host: item.host, port: item.port);

    ToastNotification(Get.overlayContext!).success("TCP 删除成功！");
    isLoading = false;
    update();
  }

  ///打开/关闭 TCP
  Future<void> tcpSocketOpenOnChanged(BaseTcpSocket item) async {
    if (item.isOpen){
      bool res = await item.close();
      if (res){
        ToastNotification(Get.overlayContext!).success("TCP 关闭成功！");
      }
    }
    else {
      bool res = await item.open();
      if (res){
        ToastNotification(Get.overlayContext!).success("TCP 打开成功！");
      }
    }
    update();
  }


  //region TCP 消息接收设置

  ///修改
  Future<void> tcpSocketMsgConnectSetting(String keyName) async {
    TcpSocketMsgProcessModel _model = tcpSocketService.tcpSocketMsgProcessList.firstWhereOrNull(
            (element) => element.keyName == keyName)
        ?? TcpSocketMsgProcessModel(keyName: keyName, host: '', port: 0, accuracy: 0);
    await DialogUtils.showCustomDialog<TcpSocketMsgConnectSettingController, bool>(
      Get.context!, title: 'TCP 消息接收设置',
      initialHeight: 500,
      initialWidth: 900,
      barrierDismissible: false,
      content: TcpSocketMsgConnectSettingView(),
      controller: TcpSocketMsgConnectSettingController(
        tcpSocketMsgProcessModel: _model
      ),
    );
    update();
  }

  ///清除
  Future<void> tcpSocketMsgConnectDelete(String keyName) async {
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

    tcpSocketService.tcpSocketMsgProcessList.removeWhere(
            (element) => element.keyName == keyName);
    List<Map<String, dynamic>> _saveList = [];
    tcpSocketService.tcpSocketMsgProcessList.forEach((element) {
      _saveList.add(element.toJson());
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.TCP_SOCKET_SERVICE_TCP_SOCKET_MSG_PROCESS_LIST_KEY, _saveList);

    ToastNotification(Get.overlayContext!).success("TCP 删除成功！");
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