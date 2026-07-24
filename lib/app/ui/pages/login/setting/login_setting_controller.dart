import 'package:basement/basement.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_controller.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_view.dart';
import 'package:desktop/app/ui/pages/root/root_controller.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';

import '../../../../utils/toast_notification.dart';


///登录服务器参数设置
class LoginSettingController extends GetxController {

  final RootController rootCtl = Get.find<RootController>();

  ///是否清除部分本地参数配置
  bool isRemoveStorage = false;

  final TextEditingController serverController = TextEditingController(
    text: ShareStorageUtil.instance?.read(BaseSharedPreferencesKeys.SERVER_IP_KEY) ?? BaseAppConfig.host
  );

  ///输入过的IP地址列表 {"IP地址": "别名"}
  final Map<String, String> historyServerMap = {};

  bool isLoading = false;


  @override
  void onInit() {
    super.onInit();

    //region get serverMap
    String ipListString = ShareStorageUtil.instance?.read(BaseSharedPreferencesKeys.SERVER_IP_LIST_KEY) ?? '';
    String ipNameListString = ShareStorageUtil.instance?.read(BaseSharedPreferencesKeys.SERVER_IP_NAME_KEY) ?? '';
    List<String> ipList = ipListString.isEmpty ? [] : ipListString.split(',');
    List<String> ipNameList = ipNameListString.isEmpty ? [] : ipNameListString.split(',');
    if (ipList.isNotEmpty){
      ipList.forEach((element) {
        historyServerMap.addAll({element: ''});
      });
      ipNameList.forEach((element) {
        List<String> list = element.split('?');
        if (list.length == 2){
          historyServerMap.addAll({list[0]: list[1]});
        }
      });
    }
    //endregion
  }

  @override
  void onReady() {
    super.onReady();
  }

  ///历史 IP 地址选择变化
  void historyServerOnSelected(String ip){
    serverController.text = ip;
    update();
  }

  ///别名修改
  Future<void> editAnotherName(String ip, String anotherName) async {
    var dialogRes = await DialogUtils.showCustomDialog<EditFieldController, String>(
      Get.context!,
      title: '别名修改',
      barrierDismissible: false,
      initialWidth: 550, initialHeight: 260,
      content: EditFieldView(),
      controller: EditFieldController(
        hintContent: anotherName,
        initTCText: anotherName,
      ),
    );
    if(dialogRes != null){
      historyServerMap.addAll({ip: dialogRes});
      saveHistoryServer();
      update();
    }
  }

  ///删除指定历史 IP 地址
  void deleteHistoryServer(String ip){
    historyServerMap.remove(ip);
    saveHistoryServer();
    update();
  }

  ///保存历史 IP 地址数据到本地
  void saveHistoryServer() {
    if (historyServerMap.isNotEmpty){
      List<String> ipList = [];
      List<String> ipNameList = [];
      historyServerMap.forEach((key, value) {
        ipList.add(key);
        ipNameList.add('$key?$value');
      });
      String ipListString = ipList.join(',');
      String ipNameListString = ipNameList.join(',');
      ShareStorageUtil.instance?.write(BaseSharedPreferencesKeys.SERVER_IP_LIST_KEY, ipListString);
      ShareStorageUtil.instance?.write(BaseSharedPreferencesKeys.SERVER_IP_NAME_KEY, ipNameListString);
    }
  }

  ///提交按钮回调
  Future<void> setting() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;

    if (serverController.text.isEmpty){
      ToastNotification(Get.overlayContext!).error('loginSetting.ipError'.tr);
      isLoading = false;
      return;
    }

    ProgressDialogUtil.showProgressDialog(msg: 'loginSetting.ipModifying'.tr, completedMsg: 'loginSetting.ipSuccess'.tr);
    serverController.text = serverController.text.trim();
    serverController.text = serverController.text.removeAllWhitespace;
    serverController.text = serverController.text.replaceAll('：', ':');
    serverController.text = serverController.text.replaceAll('。', '.');
    if (serverController.text.substring(serverController.text.length - 1) != '/'){
      serverController.text += '/';
    }
    if (isRemoveStorage){
      ShareStorageUtil.personal?.remove(SharedPreferencesKeys.SOFTWARE_NAME_KEY);
      ShareStorageUtil.instance?.remove(SharedPreferencesKeys.DEVICETASK_DEVICE_ID_DISPLAY_KEY);
      ShareStorageUtil.instance?.remove(SharedPreferencesKeys.DEVICETASK_DEP_ID_DISPLAY_KEY);
      ShareStorageUtil.instance?.remove(SharedPreferencesKeys.DEVICE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY);
      ShareStorageUtil.instance?.remove(SharedPreferencesKeys.MES_ORDER_DEP_IDS_KEY);
      ShareStorageUtil.instance?.remove(SharedPreferencesKeys.MES_ORDER_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY);
      ShareStorageUtil.instance?.remove(SharedPreferencesKeys.MES_TASK_DEP_IDS_KEY);
      ShareStorageUtil.instance?.remove(SharedPreferencesKeys.MES_TASK_LINE_IDS_KEY);
      ShareStorageUtil.instance?.remove(SharedPreferencesKeys.MES_TASK_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY);
      ShareStorageUtil.instance?.remove(SharedPreferencesKeys.LOCATION_STOREHOUSE_NAME_KEY);
      ShareStorageUtil.instance?.remove(SharedPreferencesKeys.LOCATION_STOREHOUSE_CODE_KEY);
      ShareStorageUtil.instance?.remove(SharedPreferencesKeys.LOCATION_STOREHOUSE_ID_KEY);
      ShareStorageUtil.instance?.remove(SharedPreferencesKeys.ANDON_SERVICE_CLASS_ID_KEY);
    }
    if (serverController.text != ShareStorageUtil.instance?.read(BaseSharedPreferencesKeys.SERVER_IP_KEY)){
      AddressService.initHost(serverController.text);
      ShareStorageUtil.instance?.write(BaseSharedPreferencesKeys.SERVER_IP_KEY, serverController.text);
    }
    if (!historyServerMap.containsKey(serverController.text)){
      if (historyServerMap.length == 6){
        historyServerMap.remove(historyServerMap.keys.first);
      }
      historyServerMap.addAll({serverController.text: ''});
      saveHistoryServer();
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    ProgressDialogUtil.update(value: 1, msg: 'IP地址修改成功！');
    await ProgressDialogUtil.awaitCompletionDelay();
    isLoading = false;
    Get.rootDelegate.popRoute();
  }


  @override
  void onClose() {
    super.onClose();
  }

}