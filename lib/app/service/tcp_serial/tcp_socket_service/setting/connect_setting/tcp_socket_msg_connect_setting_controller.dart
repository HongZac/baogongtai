import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_msg_process_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/tcp_socket_service.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///TCP客户端套接字消息接收设置
class TcpSocketMsgConnectSettingController extends BaseDialogController {

  final TcpSocketService tcpSocketService = Get.find<TcpSocketService>();

  final TcpSocketMsgProcessModel tcpSocketMsgProcessModel;

  ///服务端（主机端口号）
  CustomAdapter? serverAdapter;
  String server = '';
  final List<NumPadController> numPadCTList = [
    NumPadController(key: 'accuracy', keyboardType: TextInputType.number), ///精度值
  ];


  TcpSocketMsgConnectSettingController({
    required this.tcpSocketMsgProcessModel,
  });


  @override
  Future<void> onReady() async {
    super.onReady();

    ProgressDialogUtil.showProgressDialog();

    serverAdapter = await AdapterHelper.getAsyncAdapter(
      'custom',
      fieldList: tcpSocketService.tcpSocketList.map((e) => PickerDataModel(
        id: '${e.host}:${e.port}',
        name: '${e.host}:${e.port}',
      )).toList(),
      selectedItems: tcpSocketMsgProcessModel.host != null && tcpSocketMsgProcessModel.host.toString().isNotEmpty
          ? [PickerDataModel(id: '${tcpSocketMsgProcessModel.host}:${tcpSocketMsgProcessModel.port}')]
          : null,
    ) as CustomAdapter;
    server = tcpSocketMsgProcessModel.host != null && tcpSocketMsgProcessModel.host.toString().isNotEmpty
        ? '${tcpSocketMsgProcessModel.host}:${tcpSocketMsgProcessModel.port}'
        : '';
    NumPadUtil().setText('accuracy', tcpSocketMsgProcessModel.accuracy.toString(), numPadCTList);
    update();

    ProgressDialogUtil.update(value: 1);
  }


  void serverOnChanged(PickerDataModel model) {
    server = model.id;
    update();
  }


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if(actionName == DialogButtonActionEnum.confirm) { ///提交，将修改内容上传到服务器
      if (server.isEmpty) {
        ToastNotification(Get.overlayContext!).error('请选择发送端！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      List<String> serverList = server.split(':').toList();
      if (serverList.length != 2
          || serverList[0].isEmpty
          || int.tryParse(serverList[1]) == null) {
        ToastNotification(Get.overlayContext!).error('发送端格式有误！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      String accuracyString = NumPadUtil().getText('accuracy', numPadCTList) ?? '';
      double? accuracy = double.tryParse(accuracyString);
      if (tcpSocketMsgProcessModel.keyName.toLowerCase().contains('weight')
          && accuracy == null) {
        ///如果是电子秤的数据，则必须要有精度值
        ToastNotification(Get.overlayContext!).error('精度值填写错误！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }

      TcpSocketMsgProcessModel newModel = TcpSocketMsgProcessModel(
        keyName: tcpSocketMsgProcessModel.keyName,
        host: serverList[0],
        port: int.tryParse(serverList[1])!,
        accuracy: accuracy ?? 0,
      );
      TcpSocketMsgProcessModel? oldModel = tcpSocketService.tcpSocketMsgProcessList.firstWhereOrNull(
              (element) => element.keyName == newModel.keyName);
      if (oldModel != null) {
        oldModel.accuracy = newModel.accuracy;
        oldModel.host = newModel.host;
        oldModel.port = newModel.port;
      }
      else {
        tcpSocketService.tcpSocketMsgProcessList.add(newModel);
      }
      var _saveList = [];
      tcpSocketService.tcpSocketMsgProcessList.forEach((element) {
        _saveList.add(element.toJson());
      });
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.TCP_SOCKET_SERVICE_TCP_SOCKET_MSG_PROCESS_LIST_KEY, _saveList);
      return DialogReturnDataModel(isCanCloseDialog: true, data: true);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

}