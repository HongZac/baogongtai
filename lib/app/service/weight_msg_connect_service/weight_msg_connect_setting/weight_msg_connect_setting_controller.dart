import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///称重消息端口号、接口号、误差值 修改页面
@Deprecated('计划不再使用')
class WeightMsgConnectSettingController extends BaseDialogController{

  final WeightMsgConnectService weightMsgConnectService = Get.find<WeightMsgConnectService>();
  final WeightMsgConnectModel weightMsgConnectModel;

  late final TextEditingController hostCtl = TextEditingController(text: (weightMsgConnectModel.host ?? '').toString());
  late final TextEditingController portCtl = TextEditingController(text: (weightMsgConnectModel.port).toString());
  late final TextEditingController accuracyCtl = TextEditingController(text: (weightMsgConnectModel.accuracy).toString());
  ///端口号设置 FocusNode
  final FocusNode hostFocusNode = FocusNode();
  ///接口号设置 FocusNode
  final FocusNode portFocusNode = FocusNode();
  ///可接受误差值 FocusNode
  final FocusNode accuracyFocusNode = FocusNode();
  ///消息顺序是否是反向的
  ///
  ///重量数据均为最低位在前，高位和符号位在最后。负数符号位发送为“-”，正数时符号位发送 0；
  ///
  ///例如当前仪表显示的重量为 -500.00 kg，则串行输出数据为：=00.005-；
  ///
  ///当前仪表显示的重量为 500.00 kg，则串行输出数据为：=00.0050；
  late bool isWeightMsgReverseOrder = weightMsgConnectModel.isWeightMsgReverseOrder;


  WeightMsgConnectSettingController({required this.weightMsgConnectModel, });

  
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }


  void isWeightMsgReverseOrderOnChanged() {
    isWeightMsgReverseOrder = !isWeightMsgReverseOrder;
    update();
  }

  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if(actionName == DialogButtonActionEnum.confirm) { ///提交，将修改内容上传到服务器
      if (int.tryParse(portCtl.text) == null) {
        ToastNotification(Get.overlayContext!).error('端口号填写错误！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      if (double.tryParse(accuracyCtl.text) == null) {
        ToastNotification(Get.overlayContext!).error('精度值填写错误！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      WeightMsgConnectModel model = WeightMsgConnectModel(
        key: weightMsgConnectModel.key,
        host: hostCtl.text,
        port: int.tryParse(portCtl.text)!,
        accuracy: double.tryParse(accuracyCtl.text)!,
        isWeightMsgReverseOrder: isWeightMsgReverseOrder,
        com: weightMsgConnectModel.com,
      );
      WeightMsgConnectModel? _model = weightMsgConnectService.connectList.firstWhereOrNull((element) => element.key == model.key);
      if (_model != null) {
        _model.host = model.host;
        _model.port = model.port;
        _model.accuracy = model.accuracy;
        _model.isWeightMsgReverseOrder = model.isWeightMsgReverseOrder;
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


  @override
  void onClose() {
    super.onClose();
  }

}