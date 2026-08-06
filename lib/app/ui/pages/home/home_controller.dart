import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:basement/basement.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/web_socket_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/app_print_service/print_view/app_print_controller.dart';
import 'package:desktop/app/service/app_print_service/print_view/app_print_view.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/service/auto_reconnect_websocket.dart';
import 'package:desktop/app/service/data_service.dart';
import 'package:desktop/app/service/network_connection_service.dart';
import 'package:desktop/app/service/serial_com_service/setting/serial_com_setting_controller.dart';
import 'package:desktop/app/service/serial_com_service/setting/serial_com_setting_view.dart';
import 'package:desktop/app/ui/pages/home/about_us/about_controller.dart';
import 'package:desktop/app/ui/pages/home/about_us/about_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_order/detail/device_detail/mes_device_order_detail_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/detail/device_detail/mes_device_task_detail_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/detail/device_detail_controller.dart';
import 'package:desktop/app/ui/pages/home/restart_app_setting/restart_app_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/restart_app_setting/restart_app_setting_page.dart';
import 'package:desktop/app/ui/pages/home/setting/overall_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/setting/overall_setting_page.dart';
import 'package:desktop/app/ui/pages/home/websocket_setting/websocket_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/websocket_setting/websocket_setting_view.dart';
import 'package:desktop/app/ui/pages/root/root_controller.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/command_bar.dart';
import 'package:desktop/app/ui/widget/mine_icon_button.dart';
import 'package:desktop/app/ui/widget/scan_gun/scan_gun_listener_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/restsart_desktop_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:basement/utils.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:window_manager/window_manager.dart';


///Desktop主页面
class HomeController extends GetxController {

  final appService = Get.find<AppService>();
  final rootCtl = Get.find<RootController>();
  final dataService = Get.find<DataService>();

  final double navigationRailItemHeight = 50;
  final double minWidth = 45;
  final double minExtendedWidth = kIsWeb || GetPlatform.isWindows ? 160 : 192;
  final double headerHeight = 45;
  int canShowCount = 0;

  ///导航栏是否展开
  bool isNavigationRailExtended = ShareStorageUtil.instance?.read(SharedPreferencesKeys.HOME_IS_NAVIGATION_RAIL_EXTENDED_KEY) ?? AppConfig.isNavigationRailExtended;

  ///NavigationRail默认选中的Item的Key
  final String destinationKeyName = ShareStorageUtil.personal?.read(SharedPreferencesKeys.DEFAULT_DESTINATION_KEY) ?? AppConfig.destinationKeyName;
  int? selectedIndex;
  ///导航栏“更多”弹出框
  OverlayEntry? overlayEntry;

  final List<ChoiceChipModel> destinations = [];

  //region 扫码
  ///扫码完成后的回调
  Future<void> Function(String searchString)? _onBarcodeFun;
  ///扫码完成后的回调
  set onBarcodeFun(Future<void> Function(String searchString)? value) {
    _onBarcodeFun = value;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      update();
    });
  }
  ///扫码完成后的回调
  Future<void> Function(String searchString)? get onBarcodeFun => _onBarcodeFun;
  //endregion

  //region 任务说明
  Future<void> Function()? _assignmentFun;
  ///“任务说明”按钮点击回调
  set assignmentFun(Future<void> Function()? value) {
    _assignmentFun = value;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      update();
    });
  }
  ///“任务说明”按钮点击回调
  Future<void> Function()? get assignmentFun => _assignmentFun;
  //endregion

  final Color? fontColor = Theme.of(Get.context!).navigationRailTheme.unselectedLabelTextStyle!.color;
  final double? fontSize = Theme.of(Get.context!).textTheme.bodyLarge!.fontSize;
  final Color? iconColor = Theme.of(Get.context!).navigationRailTheme.unselectedLabelTextStyle!.color;
  final double? iconSize = Theme.of(Get.context!).textTheme.bodyLarge!.fontSize! * 1.43;
  late final List<CommandBarItem> commandBarList = [
    CommandBarButton(
      label: '关于软件',
      icon: FluentIcons.home_20_filled,
      fontColor: fontColor,
      fontSize: fontSize,
      iconColor: iconColor,
      iconSize: iconSize,
      onPressed: () async{ await aboutUs(); },
    ),
    if (!kIsWeb && GetPlatform.isWindows)
      CommandBarButton(
        label: '软键盘',
        icon: Icons.keyboard,
        fontColor: fontColor,
        fontSize: fontSize,
        iconColor: iconColor,
        iconSize: iconSize,
        onPressed: () async{ await rootCtl.openKeyboard(); },
      ),
    if (!kIsWeb && GetPlatform.isWindows)
      CommandBarButton(
        label: '最小化',
        icon: Icons.remove,
        fontColor: fontColor,
        fontSize: fontSize,
        iconColor: iconColor,
        iconSize: iconSize,
        onPressed: () async{ await toMinimize(); },
      ),
    if (!kIsWeb && GetPlatform.isWindows)
      CommandBarButton(
        label: '全屏切换',
        icon: Icons.fullscreen_outlined,
        fontColor: fontColor,
        fontSize: fontSize,
        iconColor: iconColor,
        iconSize: iconSize,
        onPressed: () async{ await fullScreenChanged(); },
      ),
    /*if (!kIsWeb && GetPlatform.isWindows)
      CommandBarButton(
        label: '定时重启',
        icon: Icons.restart_alt,
        fontColor: fontColor,
        fontSize: fontSize,
        iconColor: iconColor,
        iconSize: iconSize,
        onPressed: () async{ await restartAppSetting(); },
      ),*/
    CommandBarButton(
      label: '退出系统',
      icon: Icons.power_settings_new,
      fontColor: fontColor,
      fontSize: fontSize,
      iconColor: iconColor,
      iconSize: iconSize,
      onPressed: () async{ await rootCtl.exitApp(); },
    ),
  ];

  //region WebSocket
  ///Websocket 的连接地址
  Uri get socketServer => Uri.parse(AddressService.socketServer);
  ///需要在登录之后，才能获取到 WebSocket Server 地址
  AutoReconnectWebSocket? webSocketConnect;
  StreamSubscription? socketSubscription;
  ///是否可以接收 websocket 消息数据
  bool isOnListen = ShareStorageUtil.personal?.read(SharedPreferencesKeys.IS_WEBSOCKET_ON_LISTEN_KEY) ?? AppConfig.isOnListen;
  ///WebSocket 服务器连接之后的Session ID
  String wsSessionId = '';
  ///webSocket 连接状态（是否可以实时接收到消息）
  ///
  /// [True]：已连接
  ///
  /// [False]：已断开连接
  ///
  /// [Null]：正在连接（不能操作）
  bool? isWebSocketConnected;
  ///websocket 定时重连的频率
  int? secondsOfWSReconnection = ShareStorageUtil.personal?.read(SharedPreferencesKeys.SECONDS_OF_WS_RECONNECTION_KEY) ?? AppConfig.secondsOfWSReconnection;
  bool reconnectionRunning = false;
  //endregion

  //region 网络状态监听
  ///是否需要监测网络连接状态
  bool isNeedCheckNetwork = ShareStorageUtil.instance?.read(SharedPreferencesKeys.IS_NEED_CHECK_NETWORK_KEY) ?? AppConfig.isNeedCheckNetwork;
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  bool isSuccessOfInternetAccess = true;
  ///接收网络连接状态消息的 eventBus
  late final StreamSubscription<ConnectivityResult> connectivityResultStreamSubscription;
  ///接收互联网访问消息的 eventBus
  late final StreamSubscription<InternetConnectionStatus> internetConnectionStatusStreamSubscription;
  final networkConnectionService = Get.find<NetworkConnectionService>();
  //endregion

  //region 定时重启
  ///应用程序是否需要定时重启
  final bool isNeedTimedRestart = ShareStorageUtil.instance?.read(SharedPreferencesKeys.IS_NEED_TIMED_RESTART_KEY) ?? AppConfig.isNeedTimedRestart;
  ///应用程序定时重启的天数
  final int? dayOfAppRestart = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DAY_OF_APP_RESTART_KEY) ?? AppConfig.dayOfAppRestart;
  ///应用程序定时重启的时间
  final DateTime? dateTimeOfAppRestart = DateTime.tryParse(
    ShareStorageUtil.instance?.read(SharedPreferencesKeys.DATE_TIME_OF_APP_RESTART_KEY) ?? AppConfig.dateTimeOfAppRestart ?? ''
  );

  Timer? appRestartTimer;
  ///应用程序定时重启 天 + 指定时间
  late final DateTime appRestartTimeDate;
  //endregion


  @override
  void onInit(){
    super.onInit();
    assert(headerHeight <= minWidth);

    final nowDateTime = DateTime.now();
    DateTime dateTime = nowDateTime.copyWith(
      day: nowDateTime.day + (dayOfAppRestart ?? 0),
      hour: dateTimeOfAppRestart?.hour ?? 0,
      minute: dateTimeOfAppRestart?.minute ?? 0,
      second: 0,
      millisecond: 0,
    );
    if (dateTime.isBefore(nowDateTime)){
      dateTime = dateTime.add(Duration(days: 1));
    }
    appRestartTimeDate = dateTime;
    update();
  }


  @override
  Future<void> onReady() async{
    super.onReady();

    //region 获取[destinations]
    destinations.clear();
    if (kDebugMode){
      Map<String, IconData> destinationMap = {
        'home.navigate.device': FluentIcons.camera_dome_16_filled,
        'home.navigate.mesDeviceTask': FluentIcons.device_eq_16_filled,
        'home.navigate.mesDeviceOrder': FluentIcons.tasks_app_20_filled,
        'home.navigate.mesWorkCenter': Icons.precision_manufacturing,
        'home.navigate.order': FluentIcons.clipboard_16_filled,
        'home.navigate.task': Icons.assignment,
        'home.navigate.mixture': Icons.assignment,
        'home.navigate.powder': Icons.assignment,
        'home.navigate.message': FluentIcons.mail_16_filled,
        'home.navigate.barcode': FluentIcons.qr_code_28_filled,
        'home.navigate.andon': Icons.perm_phone_msg,
        'home.navigate.mould': Icons.widgets_rounded,
        'home.navigate.ipqc.qualityInspection': Icons.fact_check_rounded,
        'home.navigate.mes.base.beltLine': Icons.conveyor_belt,
        'home.navigate.mes.base.teamGroup': Icons.groups_2,
        'home.navigate.mes.base.workCenter': Icons.precision_manufacturing,
        'home.navigate.tm.invBarcode': FluentIcons.qr_code_28_filled,
        'home.navigate.cloudServiceTask': FluentIcons.cloud_swap_24_filled,
      };
      destinationMap.forEach((key, value) {
        destinations.add(ChoiceChipModel(
          keyName: key,
          title: key.tr,
          icon: value,
          content: getDestinationContent(key),
        ));
      });
    }
    else {
      ///读取客户端菜单系统，如果需要考虑不同的语言状态，需要指定不同的name,默认读取的是client.config中的配置
      var result = await ClientRepository().getMenuTree(configName: 'desktop');
      if (!result.isSuccess) {
        ToastNotification(Get.overlayContext!).error('读取配置文件的菜单模块读取时出错：${result.message}！');
      }
      if (result.data.isNotEmpty && result.data[0].childNodes != null && result.data[0].childNodes!.isNotEmpty){
        destinations.addAll(result.data[0].childNodes!.map((e){
          IconData iconData = Icons.widgets;
          List<String> iconList = (e.data?.icon ?? '').isEmpty
              ? []
              : e.data!.icon!.split(',');
          int? codePoint;
          if (iconList.length >= 2 && (codePoint = int.tryParse(iconList[0])) != null){
            iconData = IconData(
                codePoint!,
                fontFamily: iconList[1],
                fontPackage: iconList.length > 2 ? iconList[2] : null
            );
          }
          return ChoiceChipModel(
            keyName: e.id,
            title: e.data?.caption ?? e.id.tr,
            icon: iconData,
            content: getDestinationContent(e.id),
          );
        }).toList());
      }
    }

    int index = destinations.indexWhere((element) => element.keyName == destinationKeyName);
    selectedIndex = index != -1
        ? index
        : destinations.isNotEmpty
        ? 0
        : null;
    //endregion

    if (isOnListen){
      openWebSocketListen();

      if (secondsOfWSReconnection != null){
        reconnectionRunning = true;
        Future.doWhile(wsReconnectionDoWhile);
      }
    }

    ///定时重启
    if (!kIsWeb && Platform.isWindows
        && isNeedTimedRestart){
      await appRestart();
    }

    connectivityResult = networkConnectionService.connectivityResult;
    connectivityResultStreamSubscription = appService.eventBus.on<ConnectivityResult>().listen((event) {
      if (connectivityResult != event){
        connectivityResult = event;
        update();
        try {
          var controller = Get.find<WebSocketSettingController>();
          controller.update();
        } catch(e){}
      }
    });

    internetConnectionStatusStreamSubscription = appService.eventBus.on<InternetConnectionStatus>().listen((event) async{
      if (isSuccessOfInternetAccess != (event == InternetConnectionStatus.connected)){
        isSuccessOfInternetAccess = (event == InternetConnectionStatus.connected);
        update();
        try {
          var controller = Get.find<WebSocketSettingController>();
          controller.update();
        } catch(e){}
      }

    });

    update();
  }

  String getDestinationContent(String key){
    switch (key){
      case 'home.navigate.device':
        return AppRoutes.PMES_REAL_TIME_MONITOR_PAGE;
      case 'home.navigate.mesDeviceTask':
        return AppRoutes.MES_DEVICE_TASK_PAGE;
      case 'home.navigate.mesDeviceOrder':
        return AppRoutes.MES_DEVICE_ORDER_PAGE;
      case 'home.navigate.mesWorkCenter':
        return AppRoutes.MES_WORK_CENTER_PAGE;
      case 'home.navigate.order':
        return AppRoutes.MES_ORDER_PAGE;
      case 'home.navigate.task':
        return AppRoutes.MES_TASK_PAGE;
      case 'home.navigate.mixture':
        return AppRoutes.MO_MIXTURE_PAGE;
      case 'home.navigate.issuance':
        return AppRoutes.MO_ISSUANCE_PAGE;
      case 'home.navigate.message':
        return AppRoutes.MESSAGE_PAGE;
      case 'home.navigate.barcode':
        return AppRoutes.SUBMIT_BARCODE_PAGE;
      case 'home.navigate.andon':
        return AppRoutes.ANDON_PAGE;
      case 'home.navigate.mould':
        return AppRoutes.MOULD_PAGE;
      case 'home.navigate.ipqc.qualityInspection':
        return AppRoutes.IPQC_QUALITY_INSPECTION_PAGE;
      case 'home.navigate.powder':
        return AppRoutes.MO_MIXTURE_PAGE;
      case 'home.navigate.mes.base.beltLine':
        return AppRoutes.BELT_LINE_PAGE;
      case 'home.navigate.mes.base.teamGroup':
        return AppRoutes.TEAM_GROUP_PAGE;
      case 'home.navigate.mes.base.workCenter':
        return AppRoutes.WORK_CENTER_PAGE;
      case 'home.navigate.tm.invBarcode':
        return AppRoutes.INV_BARCODE_PAGE;
      case 'home.navigate.cloudServiceTask':
        return AppRoutes.CLOUD_SERVICE_TASK_PAGE;
      default:
        return AppRoutes.EMPTY_PAGE;
    }
  }

  //region WebSocket
  ///WebSocket 打开连接并监听
  void openWebSocketListen() {
    webSocketConnect = AutoReconnectWebSocket(socketServer);
    listenWebSocket();
  }

  Future<void> closeWebSocketListen() async {
    await webSocketConnect?.onClose();
    socketSubscription?.cancel();
    webSocketConnect = null;
  }

  Future<bool> wsReconnectionDoWhile() async {
    await wsReconnection();
    return reconnectionRunning;
  }
  Future<void> wsReconnection() async {
    ///定时重连 等待的时长需要随机，防止多个客户端同时重新建立连接，出现卡顿
    int defaultReconnectDelay = Random().nextInt(15) + secondsOfWSReconnection!;
    await Future.delayed(Duration(seconds: defaultReconnectDelay));
    if (!reconnectionRunning){ return; }
    await closeWebSocketListen();
    openWebSocketListen();
  }

  ///监听 AutoReconnectWebSocket 传过来的消息
  void listenWebSocket() async {
    socketSubscription?.cancel();
    socketSubscription = webSocketConnect?.stream.listen(
      _onData,
      onDone: () {
        PrintUtil.printDebug('ws listen closed');
        wsSessionId = "";
      },
      onError: (error) {
        PrintUtil.printDebug('ws listen error: $error');
        wsSessionId = "";
      },
    );
  }

  ///处理 WebSocket 消息
  Future<void> _onData(dynamic message) async{
    if (message == null || message.toString().isEmpty) { return; }
    var map = json.decode(message.toString());
    switch (map['name']){
      case "SessionStarted":
        //region WEBSOCKET 连接
        var data = json.decode(map['data']);
        if (data != null){
          wsSessionId = data['id'].toString();
          PrintUtil.printDebug('Have weSession Id: $wsSessionId');
          ///登录成功之后，需要提交用户和Session关联信息
          WSServiceRepository().sessionStart(wsSessionId);
        }
        //endregion
        break;
      case "SessionEnded":
         //region WEBSOCKET 关闭
         //endregion
        break;
      case AutoReconnectWebSocket.WEBSOCKET_CONNECTION:
        //region WEBSOCKET 连接状态
        if (map['data'].runtimeType == bool || map['data'] == null){
          if (isWebSocketConnected == map['data']){
            return;
          }
          isWebSocketConnected = map['data'];
          update();
          try {
            var controller = Get.find<WebSocketSettingController>();
            controller.update();
          } catch(e){}
        }
        //endregion
        break;
      default:
        appService.eventBus.fire(
          WebSocketModel(name: map['name'], data: map['data'])
        );
        break;
    }
  }
  //endregion


  ///定时重启
  Future<void> appRestart() async {
    appRestartTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      DateTime now = DateTime.now();
      if (!now.isBefore(appRestartTimeDate)){
        ///执行重启
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.IS_OPEN_BY_RESTART_KEY, true).then((value) async {
          await RestartApplicationUtil.restartApp();
        });
      }
    });
  }


  void onDestinationSelected(ChoiceChipModel item, {BuildContext? context, List<ChoiceChipModel>? hideList}){
    if (item.keyName == 'more'){
      overlayEntry = _buildOverlayEntry(hideList!);
      Overlay.of(context!).insert(overlayEntry!);
    }
    else {
      selectedIndex = destinations.indexWhere((element) => element.keyName == item.keyName);
      Get.rootDelegate.toNamed(item.content);
      try {
        overlayEntry?.remove(); ///收起下拉框
      } catch(e){}
    }
  }
  OverlayEntry _buildOverlayEntry(List<ChoiceChipModel> list) {
    double _verticalSpacer = 4;
    double itemHeight = 50;
    double canHeight = (8 + headerHeight + 5 + 8) + canShowCount * navigationRailItemHeight - 8;
    double needHeight = list.length * itemHeight + _verticalSpacer * 2;
    double left = (isNavigationRailExtended ? minExtendedWidth : headerHeight) + 20;
    double bottom = Get.height - canHeight - 8;
    int? selectedIndex = this.selectedIndex != null && this.selectedIndex! >= (canShowCount - 1)
        ? this.selectedIndex! - (canShowCount - 1)
        : null;
    return OverlayEntry(
      builder: (BuildContext context){
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () async {
                  overlayEntry?.remove(); ///收起下拉框
                },
              ),
            ),
            Positioned(
              left: left,
              bottom: bottom,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 120,
                  height: needHeight > canHeight ? canHeight : needHeight,
                  padding: EdgeInsets.symmetric(vertical: _verticalSpacer),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      interactive: false,
                      thumbVisibility: WidgetStateProperty.all(false),
                      trackVisibility: WidgetStateProperty.all(false),
                      thumbColor: WidgetStateProperty.all(Colors.transparent),
                      trackColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(list.length, (index) {
                          ChoiceChipModel item = list[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: (){
                                  onDestinationSelected(item);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: itemHeight,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: index == selectedIndex
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.title,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
  

  /// WebSocket 设置（打开关闭）
  Future<void> webSocketSetting() async {
    await DialogUtils.showCustomDialog<WebSocketSettingController, bool>(
      Get.context!,
      initialWidth: 600, initialHeight: 400,
      title: '网络和 WebSocket', onCancelName: '关闭',
      contentPadding: const EdgeInsets.all(12),
      isNeedConfirmBtn: false,
      content: WebSocketSettingView(),
      controller: WebSocketSettingController(),
    );
  }

  ///APP 远程打印服务
  Future<void> appPrintService() async {
    await DialogUtils.showCustomDialog<AppPrintController, bool>(
      Get.context!,
      isMaximize: true,
      title: 'APP 远程打印服务',
      onCancelName: '关闭',
      isNeedConfirmBtn: false,
      contentPadding: const EdgeInsets.all(12),
      content: AppPrintView(),
      controller: AppPrintController(),
    );
  }

  ///串口设置
  Future<void> serialComService() async {
    await DialogUtils.showCustomDialog<SerialComSettingController, bool>(
      Get.context!,
      isMaximize: true,
      title: '串口设置',
      onCancelName: '关闭',
      isNeedConfirmBtn: false,
      contentPadding: const EdgeInsets.all(12),
      content: SerialComSettingView(),
      controller: SerialComSettingController(),
    );
  }

  ///关于我们
  Future<void> aboutUs() async{
    await DialogUtils.showCustomDialog<AboutController, bool>(
      Get.context!,
      initialWidth: 600, initialHeight: 400,
      isNeedConfirmBtn: false,
      title: '关于', onCancelName: '关闭',
      contentPadding: const EdgeInsets.all(12),
      content: const AboutView(),
      controller: AboutController(),
      titleBarWidgetList: [
        MineIconButton(
          icon: Icons.system_update,
          tooltip: '升级地址修改',
          onPressed: () async {
            AboutController aboutCtl = Get.find<AboutController>();
            await aboutCtl.updateServerOnChanged();
          },
        ),
      ],
    );
  }

  ///全局设置
  Future<void> setting() async{
    await DialogUtils.showCustomDialog<OverallSettingController, bool>(
      Get.context!,
      isMaximize: true,
      isNeedConfirmBtn: false,
      title: '全局设置', onCancelName: '关闭',
      contentPadding: const EdgeInsets.all(4),
      content: OverallSettingPage(),
      controller: OverallSettingController(),
    );
  }

  ///导航菜单展开变化
  void navigationRailExtendedChanged(){
    isNavigationRailExtended = !isNavigationRailExtended;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.HOME_IS_NAVIGATION_RAIL_EXTENDED_KEY, isNavigationRailExtended);
    update();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
      //region update 部分设备详情页面
      try {
        var ctl = Get.find<DeviceDetailController>();
        ctl.getDeviceTaskWidgetHeight();
      } catch (e){}
      try {
        var ctl = Get.find<MesDeviceTaskDetailController>();
        ctl.getDeviceTaskWidgetHeight();
      } catch (e){}
      try {
        var ctl = Get.find<MesDeviceOrderDetailController>();
        ctl.getDeviceOrderWidgetHeight();
      } catch (e){}
      //endregion
    });
  }

  ///全屏切换
  Future<void> fullScreenChanged() async{
    bool isFullScreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullScreen); ///全屏切换
    if (isFullScreen){ ///当前未全屏显示（全屏 => 非全屏）
      bool isMaximized = await windowManager.isMaximized();
      if (isMaximized){
        await windowManager.unmaximize();
        await windowManager.maximize();
      }
    }
  }

  ///关闭软件
  Future<void> exitApp() async{
    var confirm = await DialogUtils.showConfirmationDialog(
        Get.overlayContext!,
        msg: '确认关闭软件？'
    );
    if (confirm == null || !confirm){
      return;
    }
    exit(0);
  }

  ///切换账号
  Future<void> loginOut() async{
    var confirm = await DialogUtils.showConfirmationDialog(
        Get.overlayContext!,
        msg: '确认返回到登录页面？'
    );
    if (confirm == null || !confirm){
      return;
    }

    if(!kIsWeb && GetPlatform.isWindows){
      await windowManager.hide();
    }
    Get.find<IAuthenticationService>().signOut();
    ///退出登录，需要销毁部分服务
    try {
      Get.delete<NetworkConnectionService>(force: true);
    } catch (e){}
    try {
      Get.delete<DataService>(force: true);
    } catch (e){}
    Get.rootDelegate.offAndToNamed(AppRoutes.LOGIN_PAGE);
    if(!kIsWeb && GetPlatform.isWindows){
      WindowOptions windowOptions = const WindowOptions(
        size: Size(780, 545),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  ///最小化切换
  Future<void> toMinimize() async{
    bool isFullScreen = await windowManager.isFullScreen();
    if (!isFullScreen){
      bool isMinimized = await windowManager.isMinimized();
      if (!isMinimized){
        await windowManager.minimize();
      }
    }
  }

  ///定时重启设置
  Future<void> restartAppSetting() async {
    await DialogUtils.showCustomDialog<RestartAppSettingController, bool>(
      Get.context!,
      initialWidth: 600, initialHeight: 400,
      title: '定时重启设置',
      contentPadding: const EdgeInsets.all(12),
      content: RestartAppSettingView(),
      controller: RestartAppSettingController(),
    );
  }


  @override
  Future<void> onClose() async {
    reconnectionRunning = false;
    appRestartTimer?.cancel();
    if (isOnListen){
      await closeWebSocketListen();
    }
    internetConnectionStatusStreamSubscription.cancel();
    connectivityResultStreamSubscription.cancel();
    super.onClose();
  }

}