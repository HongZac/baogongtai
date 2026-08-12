import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_msg_process_model.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/serial_com_service.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///串口消息接收设置
class SerialPortMsgConnectSettingController extends BaseDialogController {

  final SerialComService serialComService = Get.find<SerialComService>();

  final SerialPortMsgProcessModel serialPortMsgProcessModel;

  ///串口号
  CustomAdapter? comAdapter;
  String com = '';
  final List<NumPadController> numPadCTList = [
    NumPadController(key: 'accuracy', keyboardType: TextInputType.number), ///精度值
  ];


  SerialPortMsgConnectSettingController({
    required this.serialPortMsgProcessModel,
  });


  @override
  Future<void> onReady() async {
    super.onReady();

    ProgressDialogUtil.showProgressDialog();

    comAdapter = await AdapterHelper.getAsyncAdapter(
      'custom',
      fieldList: serialComService.serialPortList.map((e) => PickerDataModel(
        id: e.portName, name: e.portName,
      )).toList(),
      selectedItems: [PickerDataModel(id: serialPortMsgProcessModel.com)],
    ) as CustomAdapter;
    com = serialPortMsgProcessModel.com;
    NumPadUtil().setText('accuracy', serialPortMsgProcessModel.accuracy.toString(), numPadCTList);
    update();

    ProgressDialogUtil.update(value: 1);
  }


  void comOnChanged(PickerDataModel model) {
    com = model.id;
    update();
  }


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if(actionName == DialogButtonActionEnum.confirm) { ///提交，将修改内容上传到服务器
      if (com.isEmpty) {
        ToastNotification(Get.overlayContext!).error('请选择串口号！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      String accuracyString = NumPadUtil().getText('accuracy', numPadCTList) ?? '';
      double? accuracy = double.tryParse(accuracyString);
      if (serialPortMsgProcessModel.keyName.toLowerCase().contains('weight')
          && accuracy == null) {
        ///如果是电子秤的数据，则必须要有精度值
        ToastNotification(Get.overlayContext!).error('精度值填写错误！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      SerialPortMsgProcessModel newModel = SerialPortMsgProcessModel(
        keyName: serialPortMsgProcessModel.keyName,
        com: com,
        accuracy: accuracy ?? 0,
      );
      SerialPortMsgProcessModel? oldModel = serialComService.serialPortMsgProcessList.firstWhereOrNull(
              (element) => element.keyName == newModel.keyName);
      if (oldModel != null) {
        oldModel.accuracy = newModel.accuracy;
        oldModel.com = newModel.com;
      }
      else {
        serialComService.serialPortMsgProcessList.add(newModel);
      }
      var _saveList = [];
      serialComService.serialPortMsgProcessList.forEach((element) {
        _saveList.add(element.toJson());
      });
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.SERIAL_COM_SERVICE_SERIAL_PORT_MSG_PROCESS_LIST_KEY, _saveList);
      return DialogReturnDataModel(isCanCloseDialog: true, data: true);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

}