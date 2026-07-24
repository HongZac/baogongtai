import 'package:basement/utils.dart';
import 'package:desktop/app/service/network_connection_service.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_controller.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_view.dart';
import 'package:desktop/app/ui/pages/home/home_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///网络、WebSocket 连接状态查看和设置
class WebSocketSettingController extends GetxController {

  final homeController = Get.find<HomeController>();

  ///是否需要监测网络连接状态
  bool isNeedCheckNetwork = ShareStorageUtil.instance?.read(SharedPreferencesKeys.IS_NEED_CHECK_NETWORK_KEY) ?? AppConfig.isNeedCheckNetwork;


  ///WebSocket 打开 OR 关闭
  ///
  /// [isClose]：true 打开； false 关闭
  Future<void> webSocketListenOnChanged(bool isClose) async {
    if (homeController.isOnListen) {
      await homeController.closeWebSocketListen();
    }
    homeController.isOnListen = isClose;
    if (homeController.isOnListen){
      homeController.openWebSocketListen();
    }
    ShareStorageUtil.personal?.write(SharedPreferencesKeys.IS_WEBSOCKET_ON_LISTEN_KEY, homeController.isOnListen);
    update();
  }

  Future<void> isNeedCheckNetworkOnChanged() async {
    isNeedCheckNetwork = !isNeedCheckNetwork;
    final networkConnectionService = Get.find<NetworkConnectionService>();
    networkConnectionService.isNeedCheckNetwork = isNeedCheckNetwork;
    homeController.isNeedCheckNetwork = isNeedCheckNetwork;
    if (!isNeedCheckNetwork){
      networkConnectionService.cancel();
    }
    else {
      networkConnectionService.initConnectivity();
    }
    ShareStorageUtil.personal?.write(SharedPreferencesKeys.IS_NEED_CHECK_NETWORK_KEY, isNeedCheckNetwork);
    update();
    homeController.update();
  }


  Future<void> editSecondsOfWSReconnection() async {
    var dialogRes = await DialogUtils.showCustomDialog<EditFieldController, String>(
      Get.context!,
      title: 'WebSocket 定时重连的频率',
      onConfirmName: '确认',
      barrierDismissible: false,
      initialWidth: 550, initialHeight: 260,
      contentPadding: const EdgeInsets.all(12),
      content: EditFieldView(),
      controller: EditFieldController(
        hintContent: homeController.secondsOfWSReconnection?.toString() ?? '',
        infoContent: '不填写，则关闭定时重连',
        initTCText: homeController.secondsOfWSReconnection?.toString() ?? '',
        beforeConfirmCallback: (String str) async {
          int? intValue = int.tryParse(str);
          if (str.isNotEmpty && (intValue == null || intValue < 300)){
            ToastNotification(Get.overlayContext!).error('文本框输入有误，不能小于 300 秒，请检查！');
            return false;
          }
          return true;
        }
      ),
    );
    if (dialogRes == null){
      return;
    }
    int? secondsOfWSReconnection = int.tryParse(dialogRes);
    ShareStorageUtil.personal?.write(SharedPreferencesKeys.SECONDS_OF_WS_RECONNECTION_KEY, secondsOfWSReconnection);
    homeController.secondsOfWSReconnection = secondsOfWSReconnection;
    update();
    ToastNotification(Get.overlayContext!).info('重新打开工作台后，该设置才会生效！');
  }

}