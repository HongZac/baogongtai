import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/service/serial_com_service/serial_com_service.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
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
  final WeightMsgConnectService weightMsgConnectService = Get.find<WeightMsgConnectService>();

  final WeightMsgConnectModel weightMsgConnectModel;

  ///串口号
  CustomAdapter? comAdapter;
  String com = '';
  final List<NumPadController> numPadCTList = [
    NumPadController(key: 'accuracy', keyboardType: TextInputType.number), ///精度值
  ];


  SerialPortMsgConnectSettingController({
    required this.weightMsgConnectModel,
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
      selectedItems: [PickerDataModel(id: weightMsgConnectModel.com)],
    ) as CustomAdapter;
    com = weightMsgConnectModel.com;
    NumPadUtil().setText('accuracy', weightMsgConnectModel.accuracy.toString(), numPadCTList);
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
      if (weightMsgConnectModel.key.toLowerCase().contains('weight') && accuracy == null) {
        ToastNotification(Get.overlayContext!).error('精度值填写错误！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      WeightMsgConnectModel model = WeightMsgConnectModel(
        key: weightMsgConnectModel.key,
        host: weightMsgConnectModel.host,
        port: weightMsgConnectModel.port,
        accuracy: accuracy ?? 0,
        isWeightMsgReverseOrder: weightMsgConnectModel.isWeightMsgReverseOrder,
        com: com,
      );
      WeightMsgConnectModel? _model = weightMsgConnectService.connectList.firstWhereOrNull((element) => element.key == model.key);
      if (_model != null) {
        _model.accuracy = model.accuracy;
        _model.com = model.com;
      }
      else {
        weightMsgConnectService.connectList.add(model);
      }
      var _saveList = [];
      weightMsgConnectService.connectList.forEach((element) {
        _saveList.add(element.toJson());
      });
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.CONNECTLIST_KEY, _saveList);
      return DialogReturnDataModel(isCanCloseDialog: true, data: true);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

}