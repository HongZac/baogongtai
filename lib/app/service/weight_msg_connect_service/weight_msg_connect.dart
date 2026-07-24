import 'dart:async';
import 'dart:io';
import 'package:basement/utils.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/toast_notification.dart';


typedef Future<VoidCallback?>? OnFire(dynamic response);


@Deprecated('计划不再使用')
class WeightMsgConnect extends GetxService{

  final WeightMsgConnectModel connectModel;
  final OnFire? onFire;

  late Socket sock;

  late StreamSubscription<Uint8List> listen;

  bool isFirstConnect = true;

  late bool run;

  WeightMsgConnect({required this.connectModel,OnFire? this.onFire, this.run = true});

  @override
  void onInit() {
    super.onInit();
    _connect(connectModel);
  }

  Future<void> _connect(WeightMsgConnectModel model) async {
    if ((model.host ?? '').isEmpty || model.com.isNotEmpty){
      ///当端口号为空，或串口号不为空（使用客户端直连串口模式）时，不需要继续执行
      return;
    }
    //region 连接
    try {
      sock = await Socket.connect(model.host, model.port);
    }
    catch (e){
      if (run){
        if (isFirstConnect){
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            ToastNotification(Get.overlayContext!).error('连接失败，5秒后重连！${model.host}:${model.port}\n${e.toString()}');
          });
          isFirstConnect = false;
        }
        PrintUtil.printDebug('连接失败！host:${model.host}；port:${model.port}\n${e.toString().replaceAll(new RegExp(r'[\r\n]'), '')}\n');
        await Future.delayed(Duration(seconds: 5));
        _connect(connectModel);
      }
      return;
    }
    String connectString = '${sock.remoteAddress.address}:${sock.remotePort}';
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ToastNotification(Get.overlayContext!).success('连接成功！' + connectString);
    });
    PrintUtil.printDebug('连接成功: ' + connectString);
    //endregion

    ///监听
    listen = sock.listen((Uint8List data) {
      PrintUtil.printDebug('========== $connectString ==========');
      String hexString = _intToHex(data);
      String stringFromCharCodes = String.fromCharCodes(data);
      ///移到各自的Controller层处理
      //String serverResponse = getServerResponse(stringFromCharCodes);
      String serverResponse = stringFromCharCodes;
      PrintUtil.printDebug('$data $hexString $serverResponse');
      PrintUtil.printDebug('消息发送：${model.key} ${model.host} ${model.port} ${hexString} ${serverResponse}');

      if(onFire != null){
        onFire!(serverResponse);
      }

    }, onError: (error) async {
      if (run){
        PrintUtil.printDebug('onError：$connectString $error');
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          ToastNotification(Get.overlayContext!).error('连接已断开，5秒后重连！' + connectString);
        });
        await Future.delayed(Duration(seconds: 5));
        isFirstConnect = true;
        sock.destroy();
        _connect(connectModel);
      }
    }, onDone: () async {
      if (run){
        PrintUtil.printDebug('onDone：$connectString 连接已断开！');
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          ToastNotification(Get.overlayContext!).error('连接已断开，5秒后重连！' + connectString);
        });
        await Future.delayed(Duration(seconds: 5));
        isFirstConnect = true;
        sock.destroy();
        _connect(connectModel);
      }
    });
  }


  ///UInt8List转Hex字符串
  String _intToHex(Uint8List? byteArr) {

    if (byteArr == null || byteArr.length == 0) {
      return "";
    }

    Uint8List result = Uint8List(byteArr.length << 1);

    ///16进制字符表
    var hexTable = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];

    for (var i = 0; i < byteArr.length; i++) {
      ///取传入的byteArr的每一位
      var bit = byteArr[i];
      ///右移4位,取剩下四位
      var index = bit >> 4 & 15;

      ///byteArr的每一位对应结果的两位,所以对于结果的操作位数要乘2
      var i2 = i << 1;

      ///左边的值取字符表,转为Unicode放进result数组
      result[i2] = hexTable[index].codeUnitAt(0);
      ///取右边四位
      index = bit & 15;
      ///右边的值取字符表,转为Unicode放进result数组
      result[i2 + 1] = hexTable[index].codeUnitAt(0);
    }

    ///Unicode转回为对应字符,生成字符串返回
    return String.fromCharCodes(result);
  }

  String getServerResponse(String stringFromCharCodes){
    String _string = '';
    if (stringFromCharCodes.substring(0,3) == '|O|'){
      ///容器条码(周转箱条码): |O|序列号|皮重
      var _list  = stringFromCharCodes.split('|');
      _string = _list.last.replaceAll(new RegExp(r'[^0-9.]'), '');
    }
    else {
      _string = stringFromCharCodes.replaceAll(new RegExp(r'[^0-9.]'), '');
    }
    return _string;
  }

  @override
  void onClose() {
    run = false;
    try {
      listen.cancel();
      sock.destroy();
    } catch (e){}
    super.onClose();
  }
}


