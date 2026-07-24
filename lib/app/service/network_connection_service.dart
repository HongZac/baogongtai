import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:universal_html/html.dart' as html;


///网络连接服务监测服务
class NetworkConnectionService extends GetxService{

  final appService = Get.find<AppService>();

  final Connectivity connectivity = Connectivity();
  ///当前连接状态
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  StreamSubscription<List<ConnectivityResult>>? connectivityResultStreamSubscription;

  final List<AddressCheckOption> checkAddrList = [];
  InternetConnectionChecker? internetConnectionChecker;
  StreamSubscription<InternetConnectionStatus>? internetConnectionStatusStreamSubscription;
  bool isSuccessOfInternetAccess = true;
  ///消息提示框是否弹出
  bool isDialogOpen = false;

  ///是否需要监测网络连接状态
  bool isNeedCheckNetwork = ShareStorageUtil.instance?.read(SharedPreferencesKeys.IS_NEED_CHECK_NETWORK_KEY) ?? AppConfig.isNeedCheckNetwork;


  @override
  Future<void> onInit() async {
    super.onInit();
    if (isNeedCheckNetwork){
      await initConnectivity();
    }
  }

  Future<void> initConnectivity() async{
    connectivityResultStreamSubscription = connectivity.onConnectivityChanged.listen((List<ConnectivityResult> list) async {
      ConnectivityResult event = list.first;
      PrintUtil.printDebug('connectivityStatus: $connectivityResult ==> $event');
      if (connectivityResult != ConnectivityResult.none && event == ConnectivityResult.none){
        ToastNotification(Get.overlayContext!).warn("未连接到任何网络！");
        _internetCancel();
        _internetConnectionCheckerListener(InternetConnectionStatus.disconnected);
      }
      else if (connectivityResult == ConnectivityResult.none && event != ConnectivityResult.none){
        ToastNotification(Get.overlayContext!).success("已连接到${event.name}网络！");
        _internetCancel();
        await _openInternetConnectionCheckerListener();
      }

      connectivityResult = event;
      appService.eventBus.fire(event);
    });
  }

  Future<void> _openInternetConnectionCheckerListener() async {
    if (kIsWeb){
      html.window.addEventListener('online', _htmlInternetOnlineCheckerListener);
      html.window.addEventListener('offline', _htmlInternetOfflineCheckerListener);
    }
    else {
      ///获取检查地址列表
      if (checkAddrList.isEmpty){
        await getCheckAddrList();
      }
      internetConnectionChecker?.dispose();
      internetConnectionChecker = InternetConnectionChecker.createInstance(
        checkTimeout: const Duration(seconds: 5), //InternetConnectionChecker.DEFAULT_TIMEOUT,
        checkInterval: const Duration(seconds: 10),
        addresses: checkAddrList,
      );
      internetConnectionStatusStreamSubscription = internetConnectionChecker!.onStatusChange.listen(_internetConnectionCheckerListener);
    }
  }

  void _htmlInternetOnlineCheckerListener(html.Event event) {
    PrintUtil.printDebug('互联网访问监听:online');
    PrintUtil.printDebug('${DateTime.now()} 访问互联网成功！');
    Get.find<AppService>().eventBus.fire(InternetConnectionStatus.connected);
  }

  void _htmlInternetOfflineCheckerListener(html.Event event) {
    PrintUtil.printDebug('互联网访问监听:offline');
    PrintUtil.printDebug('${DateTime.now()} 访问互联网失败！');
    Get.find<AppService>().eventBus.fire(InternetConnectionStatus.disconnected);
  }

  Future<void> _internetConnectionCheckerListener(InternetConnectionStatus event) async {
    PrintUtil.printDebug('互联网访问监听: $event');
    if (event == InternetConnectionStatus.connected){
      PrintUtil.printDebug('${DateTime.now()} 访问互联网成功！');
      //if (!isSuccessOfInternetAccess){
      //  if (isDialogOpen){
      //    Get.back();
      //  }
      //  isDialogOpen = true;
      //  DialogUtils.showTipsDialog(
      //      Get.context!,
      //      msg: '访问互联网成功,请重新进入该页面！',
      //      onConfirm: () async{
      //        isDialogOpen = false;
      //      }
      //  );
      //}
      //isSuccessOfInternetAccess = true;
    }
    else {
      PrintUtil.printDebug('${DateTime.now()} 访问互联网失败！');
      //if (isDialogOpen){
      //  Get.back();
      //}
      //isSuccessOfInternetAccess = false;
      //isDialogOpen = true;
      //DialogUtils.showTipsDialog(
      //    Get.context!,
      //    msg: '访问互联网失败,请检查网络！',
      //    onConfirm: () async{
      //      isDialogOpen = false;
      //    }
      //);
    }
    Get.find<AppService>().eventBus.fire(event);
  }

  Future<void> getCheckAddrList() async {
    checkAddrList.clear();
    ///192.168.1.1 https://1.1.1.1 https://101.226.4.6 https://123.125.81.6
    var netWorkHostRes = await ClientRepository().getSystemName(key:'NetWorkHost');
    if (netWorkHostRes.isSuccess && netWorkHostRes.data.isNotEmpty){
      checkAddrList.addAll(netWorkHostRes.data.split(';').map((e) => AddressCheckOption(
        uri: Uri.parse(e),
        timeout: const Duration(seconds: 5),
      )));
    }
    else {
      checkAddrList.add(AddressCheckOption(
        //uri: Uri.parse('https://1.1.1.1'),
        uri: Uri.parse('https://123.125.81.6'),
        timeout: const Duration(seconds: 5),
      ));
    }
  }

  void _connectivityCancel(){
    connectivityResultStreamSubscription?.cancel();
    connectivityResultStreamSubscription = null;
    connectivityResult = ConnectivityResult.none;
  }

  void _internetCancel(){
    if (kIsWeb){
      html.window.removeEventListener('online', _htmlInternetOnlineCheckerListener);
      html.window.removeEventListener('offline', _htmlInternetOfflineCheckerListener);
    }
    else {
      internetConnectionChecker?.dispose();
      internetConnectionChecker = null;
      internetConnectionStatusStreamSubscription?.cancel();
      internetConnectionStatusStreamSubscription = null;
    }
  }

  void cancel() {
    _connectivityCancel();
    _internetCancel();
  }

  @override
  void onClose() {
    cancel();
    super.onClose();
  }
}
