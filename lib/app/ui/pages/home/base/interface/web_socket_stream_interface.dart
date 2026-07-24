
import 'dart:async';

import 'package:desktop/app/model/web_socket_model.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:get/get.dart';


/// WebSocket 的 [eventBus.on] 监听处理接口
mixin WebSocketStreamInterface on GetxController {

  final _appService = Get.find<AppService>();
  late final StreamSubscription<WebSocketModel> _webSocketModelStreamSubscription;

  @override
  Future<void> onReady() async{
    super.onReady();
    _webSocketStreamOnListen();
  }

  void _webSocketStreamOnListen() {
    _webSocketModelStreamSubscription = _appService.eventBus.on<WebSocketModel>().listen((event) async{
      await onData(event);
    });
  }


  Future<void> onData(WebSocketModel webSocketModel);


  @override
  void onClose() {
    try {
      _webSocketModelStreamSubscription.cancel();
    } catch (e){}
    super.onClose();
  }

}