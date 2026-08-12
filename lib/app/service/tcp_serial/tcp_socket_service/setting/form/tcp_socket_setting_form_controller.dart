import 'package:basement/picker.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/service/tcp_serial/parser/tcp_serial_parser_enum.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/base_tcp_socket.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/tcp_socket_service.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///新增TCP客户端套接字通讯服务
class TcpSocketSettingFormController extends BaseDialogController {

  final TcpSocketService tcpSocketService = Get.find<TcpSocketService>();

  ///需要修改数据的 TCP 通讯配置
  final dynamic oldHost;
  final int oldPost;

  CustomAdapter? parserNameAdapter;
  String parserName = '';
  final List<NumPadController> numPadCTList = [
    NumPadController(key: 'host'),
    NumPadController(key: 'port', keyboardType: TextInputType.number),
  ];
  bool autoOpen = false;


  TcpSocketSettingFormController({
    this.oldHost = '',
    this.oldPost = 0,
  });


  @override
  Future<void> onReady() async {
    ProgressDialogUtil.showProgressDialog();

    BaseTcpSocket? oldBaseTcpSocket;
    if (oldHost != null && oldHost.toString().isNotEmpty){
      oldBaseTcpSocket = tcpSocketService.tcpSocketList.firstWhereOrNull(
              (element) => element.host == oldHost && element.port == oldPost);
    }

    parserNameAdapter = await AdapterHelper.getAsyncAdapter(
      'custom',
      fieldList: TcpSerialParserEnum.values.map((e){
        return PickerDataModel(
          id: e.toString(),
          name: e.name,
        );
      }).toList(),
      selectedItems: oldBaseTcpSocket != null
          ? [PickerDataModel(id: oldBaseTcpSocket.parserName?.toString() ?? '')]
          : null,
    ) as CustomAdapter;

    if (oldBaseTcpSocket != null) {
      parserName = oldBaseTcpSocket.parserName?.toString() ?? '';
      NumPadUtil().setText('host', oldBaseTcpSocket.host.toString(), numPadCTList);
      NumPadUtil().setText('port', oldBaseTcpSocket.port.toString(), numPadCTList);
      autoOpen = oldBaseTcpSocket.autoOpen;
    }
    else {
      parserName = TcpSerialParserEnum.defaultParser.toString();
      await parserNameAdapter?.validModelValue(TcpSerialParserEnum.defaultParser.toString());
      autoOpen = true;
    }
    update();

    ProgressDialogUtil.update(value: 1);
  }


  void parserNameOnChanged(PickerDataModel model) {
    parserName = model.id;
    update();
  }

  void autoOpenOnChanged() {
    autoOpen = !autoOpen;
    update();
  }


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      String host = NumPadUtil().getText('host', numPadCTList) ?? '';
      String portString = NumPadUtil().getText('port', numPadCTList) ?? '';
      int? port = int.tryParse(portString);
      if (port == null){
        ToastNotification(Get.overlayContext!).error('端口号输入有误，请检查！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }

      if (host.isEmpty){
        ToastNotification(Get.overlayContext!).error('请输入主机号！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      BaseTcpSocket? item = tcpSocketService.tcpSocketList.firstWhereOrNull(
              (element) => element.host == host && element.port == port);
      if (oldHost != null && oldHost.toString().isNotEmpty){ ///编辑状态
        if (item == null){
          ToastNotification(Get.overlayContext!).error('错误数据！');
          return DialogReturnDataModel(isCanCloseDialog: false);
        }
        await tcpSocketService.removeTcpSocket(host: item.host, port: item.port);
      }
      else {
        if (item != null){
          ToastNotification(Get.overlayContext!).error('提交失败，当前 TCP 已注册！');
          return DialogReturnDataModel(isCanCloseDialog: false);
        }
      }

      await tcpSocketService.register(
        host: host,
        port: port,
        autoOpen: autoOpen,
        parserName: TcpSerialParserEnum.values.firstWhereOrNull(
                (element) => element.toString() == parserName),
      );
      return DialogReturnDataModel(isCanCloseDialog: true, data: true);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

}