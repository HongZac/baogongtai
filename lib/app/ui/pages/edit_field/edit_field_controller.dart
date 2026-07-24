

import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:flutter/material.dart';

typedef BeforeConfirmCallback = Future<bool> Function(String str);


class EditFieldController extends BaseDialogController {

  final String infoContent;
  final String initTCText;
  final String hintContent;
  final BeforeConfirmCallback? beforeConfirmCallback;

  late final TextEditingController tc = TextEditingController(text: initTCText);
  final FocusNode fn = FocusNode();


  EditFieldController({
    this.infoContent = '',
    this.initTCText = '',
    this.hintContent = '',
    this.beforeConfirmCallback,
  });


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      bool res = await beforeConfirmCallback?.call(tc.text) ?? true;
      if (!res){
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      return DialogReturnDataModel(isCanCloseDialog: true, data: tc.text);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

  @override
  void onClose() {
    super.onClose();
  }

}