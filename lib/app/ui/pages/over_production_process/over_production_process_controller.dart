import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';


///超产处理弹窗窗体
class OverProductionProcessController extends BaseDialogController{

  final double qty;

  ///可超产百分比
  final TextEditingController percentTC = TextEditingController();
  ///可超产数量
  final TextEditingController qtyTC = TextEditingController();
  ///超产处理 备注
  final TextEditingController descTC = TextEditingController();

  final FocusNode percentFN = FocusNode();
  final FocusNode qtyFN = FocusNode();
  final FocusNode descFN = FocusNode();


  OverProductionProcessController({
    required this.qty,
  });


  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      double? qty = double.tryParse(qtyTC.text);
      if (qty == null || qty < 0){
        ToastNotification(Get.overlayContext!).error("可超产数量输入框输入有误，请重输！");
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      return DialogReturnDataModel(isCanCloseDialog: true, data: {'qty': qty, 'desc': descTC.text});
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

  @override
  void onClose() {
    super.onClose();
  }
}