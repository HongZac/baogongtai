import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop/app/routes/mine_get_delegate.dart';
import 'package:desktop/app/ui/pages/home/websocket_setting/websocket_setting_controller.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///网络、WebSocket 连接状态查看和设置
class WebSocketSettingView extends GetView<WebSocketSettingController> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WebSocketSettingController>(builder: (_){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          mineInputBoxWithTitle(
              context, _,
              title: '网络连接状态监测',
              contentWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      _.isNeedCheckNetwork ? '已打开' : '已关闭',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(171)
                      ),
                    ),
                  ),
                  FilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.outlineVariant),
                        foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.onPrimaryContainer),
                        minimumSize: WidgetStateProperty.all(
                            kIsWeb || GetPlatform.isWindows
                                ? const Size(80, 30)
                                : const Size(80, 35)
                        ),
                        maximumSize: WidgetStateProperty.all(
                            kIsWeb || GetPlatform.isWindows
                                ? const Size(80, 30)
                                : const Size(80, 35)
                        ),
                        //padding: WidgetStateProperty.all(EdgeInsets.zero),
                      ),
                      onPressed: () async {
                        await controller.isNeedCheckNetworkOnChanged();
                      },
                      child: Text(
                        _.isNeedCheckNetwork ? '关闭' : '打开',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                        ),
                      )
                  )
                ],
              ),
          ),

          if (_.isNeedCheckNetwork)
            ...[
              mineInputBoxWithTitle(
                  context, _,
                  title: '网络连接属性',
                  content: getConnectivityResultStr(_.homeController.connectivityResult),
                  contentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: _.homeController.connectivityResult == ConnectivityResult.none
                          ? Theme.of(context).colorScheme.error
                          : null
                  )
              ),
              const SizedBox(height: 8,),
              mineInputBoxWithTitle(
                  context, _,
                  title: '互联网访问状态',
                  content: _.homeController.isSuccessOfInternetAccess
                      ? '已连接到 Internet'
                      : '无法访问 Internet',
                  contentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: !_.homeController.isSuccessOfInternetAccess
                          ? Theme.of(context).colorScheme.error
                          : null
                  )
              ),
            ],

          const SizedBox(height: 8,),
          mineInputBoxWithTitle(
              context, _,
              title: 'WebSocket 连接状态',
              contentWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      _.homeController.isOnListen
                          ? '已打开，${_.homeController.isWebSocketConnected == true
                          ? '已连接'
                          : _.homeController.isWebSocketConnected == false
                          ? '已断开连接'
                          : '正在连接……'}'
                          : '已关闭',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(171)
                      ),
                    ),
                  ),
                  FilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states){
                          if (states.contains(WidgetState.disabled)){
                            return null;
                          }
                          return Theme.of(context).colorScheme.outlineVariant;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states){
                          if (states.contains(WidgetState.disabled)){
                            return null;
                          }
                          return Theme.of(context).colorScheme.onPrimaryContainer;
                        }),
                        minimumSize: WidgetStateProperty.all(
                            kIsWeb || GetPlatform.isWindows
                                ? const Size(80, 30)
                                : const Size(80, 35)
                        ),
                        maximumSize: WidgetStateProperty.all(
                            kIsWeb || GetPlatform.isWindows
                                ? const Size(80, 30)
                                : const Size(80, 35)
                        ),
                        //padding: WidgetStateProperty.all(EdgeInsets.zero),
                      ),
                      onPressed: _.homeController.isOnListen && _.homeController.isWebSocketConnected == null ? null : () async {
                        await controller.webSocketListenOnChanged(!_.homeController.isOnListen);
                      },
                      child: Text(
                        _.homeController.isOnListen ? '关闭' : '打开',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                        ),
                      )
                  ),
                ],
              )
          ),
          const SizedBox(height: 8,),
          mineInputBoxWithTitle(
            context, _,
            title: 'WebSocket 定时重连',
            contentWidget: Container(
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () async {
                    await controller.editSecondsOfWSReconnection();
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                        kIsWeb || GetPlatform.isWindows
                            ? const EdgeInsets.symmetric(vertical: 16, horizontal: 0)
                            : const EdgeInsets.symmetric(vertical: 8, horizontal: 0)
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8,),
                      Text(
                        _.homeController.secondsOfWSReconnection == null
                            ? '定时重连已关闭'
                            : '${_.homeController.secondsOfWSReconnection!.toString()}秒',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 8,),
                      Icon(
                        Icons.edit,
                        size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                      ),
                      const SizedBox(width: 8,),
                    ],
                  ),
              ),
            ),
          ),
        ],
      );
    }, initState: (GetBuilderState<WebSocketSettingController> state){
      MineGetDelegate().pageInitState(controller);
    }, dispose: (GetBuilderState<WebSocketSettingController> state){
      try {
        MineGetDelegate().pageDispose(controller);
      } catch(e){}
    },);
  }

  Widget mineInputBoxWithTitle(BuildContext context, WebSocketSettingController _, {
    required String title,
    String? content, TextStyle? contentStyle, Widget? contentWidget,
  }) {
    return TitleTextBoxWidget(
      title: title,
      width: 1000, titleWidth: 180,
      crossAxisAlignment: CrossAxisAlignment.center,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      content: content ?? '',
      contentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(171)
      ),
      customizeContent: contentWidget,
    );
  }

  String getConnectivityResultStr(ConnectivityResult connectivityResult){
    String content = '';
    switch (connectivityResult){
      case ConnectivityResult.bluetooth:
        content = '通过蓝牙连接';
        break;
      case ConnectivityResult.wifi:
        content = '通过Wi-Fi连接';
        break;
      case ConnectivityResult.ethernet:
        content = '通过以太网连接';
        break;
      case ConnectivityResult.mobile:
        content = '通过移动设备连接';
        break;
      case ConnectivityResult.none:
        content = '未连接到任何网络';
        break;
      case ConnectivityResult.vpn:
        content = '通过VPN连接';
        break;
      case ConnectivityResult.other:
        content = '连接到未知网络';
        break;
      case ConnectivityResult.satellite:
        content = '通过卫星连接';
        break;
    }
    return content;
  }

}