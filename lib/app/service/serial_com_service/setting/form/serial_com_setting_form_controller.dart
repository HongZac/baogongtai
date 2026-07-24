import 'package:basement/picker.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/service/serial_com_service/base_serial_port.dart';
import 'package:desktop/app/service/serial_com_service/interface/serial_port_parser_interface.dart';
import 'package:desktop/app/service/serial_com_service/serial_com_service.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///新增串口通讯服务
class SerialComSettingFormController extends BaseDialogController {

  final SerialComService serialComService = Get.find<SerialComService>();

  ///需要修改数据的串口通讯配置
  final String oldCom;

  CustomAdapter? portNameAdapter;
  CustomAdapter? parserNameAdapter;
  String portName = '';
  String parserName = '';
  final List<NumPadController> numPadCTList = [
    NumPadController(key: 'baudRate', keyboardType: TextInputType.number), ///波特率 9600
    NumPadController(key: 'bits', keyboardType: TextInputType.number), ///数据位 8
    NumPadController(key: 'parity', keyboardType: TextInputType.number), ///校验位 0
    NumPadController(key: 'stopBits', keyboardType: TextInputType.number), ///结束位 1
  ];
  bool autoOpen = false;


  SerialComSettingFormController({
    this.oldCom = '',
  });


  @override
  Future<void> onReady() async {
    super.onReady();

    ProgressDialogUtil.showProgressDialog();

    BaseSerialPort? oldBaseSerialPort;
    if (oldCom.isNotEmpty){
      oldBaseSerialPort = serialComService.serialPortList.firstWhereOrNull(
              (element) => element.portName == oldCom);
    }

    List<String> serialComList = [];
    if (!kIsWeb){
      serialComList.addAll(await serialComService.getAvailablePorts());
    }

    portNameAdapter = await AdapterHelper.getAsyncAdapter(
      'custom',
      fieldList: serialComList.map((e) => PickerDataModel(
        id: e, name: e,
      )).toList(),
      selectedItems: oldBaseSerialPort != null
          ? [PickerDataModel(id: oldBaseSerialPort.portName)]
          : null,
    ) as CustomAdapter;

    parserNameAdapter = await AdapterHelper.getAsyncAdapter(
      'custom',
      fieldList: serialPortParserList,
      selectedItems: oldBaseSerialPort != null
          ? [PickerDataModel(id: oldBaseSerialPort.parserName?.name ?? '')]
          : null,
    ) as CustomAdapter;

    if (oldBaseSerialPort != null){
      portName = oldBaseSerialPort.portName;
      parserName = oldBaseSerialPort.parserName?.name ?? '';
      NumPadUtil().setText('baudRate', oldBaseSerialPort.config.baudRate.toString(), numPadCTList);
      NumPadUtil().setText('bits', oldBaseSerialPort.config.bits.toString(), numPadCTList);
      NumPadUtil().setText('parity', oldBaseSerialPort.config.parity.toString(), numPadCTList);
      NumPadUtil().setText('stopBits', oldBaseSerialPort.config.stopBits.toString(), numPadCTList);
      autoOpen = oldBaseSerialPort.autoOpen;
    }
    else {
      parserName = SerialPortParserEnum.defaultParser.name;
      NumPadUtil().setText('baudRate','9600', numPadCTList);
      NumPadUtil().setText('bits', '8', numPadCTList);
      NumPadUtil().setText('parity', '0', numPadCTList);
      NumPadUtil().setText('stopBits', '1', numPadCTList);
      autoOpen = true;
      await parserNameAdapter?.validModelValue(SerialPortParserEnum.defaultParser.name);
    }
    update();

    ProgressDialogUtil.update(value: 1);
  }

  void portNameOnChanged(PickerDataModel model) {
    portName = model.id;
    update();
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
      String baudRateString = NumPadUtil().getText('baudRate', numPadCTList) ?? '';
      int? baudRate = int.tryParse(baudRateString);
      String bitsString = NumPadUtil().getText('bits', numPadCTList) ?? '';
      int? bits = int.tryParse(bitsString);
      String parityString = NumPadUtil().getText('parity', numPadCTList) ?? '';
      int? parity = int.tryParse(parityString);
      String stopBitsString = NumPadUtil().getText('stopBits', numPadCTList) ?? '';
      int? stopBits = int.tryParse(stopBitsString);
      if (baudRate == null || bits == null || parity == null || stopBits == null){
        ToastNotification(Get.overlayContext!).error('输入有误，请检查！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }

      if (portName.isEmpty){
        ToastNotification(Get.overlayContext!).error('请选择串口号！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      BaseSerialPort? item = serialComService.serialPortList.firstWhereOrNull(
              (element) => element.portName == portName);
      if (oldCom.isNotEmpty){ ///编辑状态
        if (item == null){
          ToastNotification(Get.overlayContext!).error('错误数据！');
          return DialogReturnDataModel(isCanCloseDialog: false);
        }
        await serialComService.removeSerialPort(item.portName);
      }
      else {
        if (item != null){
          ToastNotification(Get.overlayContext!).error('提交失败，当前串口已注册！');
          return DialogReturnDataModel(isCanCloseDialog: false);
        }
      }

      await serialComService.register(
        portName: portName,
        autoOpen: autoOpen,
        parserName: SerialPortParserEnum.values.firstWhereOrNull(
                (element) => element.name == parserName),
        baudRate: baudRate,
        bits: bits,
        parity: parity,
        stopBits: stopBits,
      );
      return DialogReturnDataModel(isCanCloseDialog: true, data: true);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

}