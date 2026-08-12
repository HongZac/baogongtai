import 'dart:async';

import 'package:basement/utils.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/tcp_socket_service.dart';
import 'package:get/get.dart';


///TCP 客户端套接字消息接收接口
mixin TcpSocketGetxListenerMixin<T> on GetxController {

  final TcpSocketService tcpSocketService = Get.find<TcpSocketService>();

  static List<String> tcpReceiverList = [''];

  ///是否允许接收条码处理程序
  bool enableTcpSocket = true;

  final _appService = Get.find<AppService>();
  late final StreamSubscription<TcpSocketDataModel> _subscription;


  @override
  Future<void> onReady() async{
    super.onReady();

    ///接收 TCP 数组
    _subscription = _appService.eventBus.on<TcpSocketDataModel>().listen((event) async {
      if (enableTcpSocket && !event.isConnectMsg) {
        PrintUtil.printDebug('TCP Socket 消息：${event.data}');
        onTcpSocketData(event);
      }
    });
    tcpReceiverList.add(T.toString());
  }

  ///接收到的 TCP 数据处理，需要继承类里处理实际功能
  Future<void> onTcpSocketData(TcpSocketDataModel tcpSocketDataModel);

  @override
  void onClose() {
    _subscription.cancel();
    tcpReceiverList.remove(T.toString());
    super.onClose();
  }

}