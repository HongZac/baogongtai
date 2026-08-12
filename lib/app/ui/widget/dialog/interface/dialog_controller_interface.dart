
import 'package:desktop/app/model/dialog_return_data_model.dart';

enum DialogButtonActionEnum {
   confirm,
   cancel,
   button1
}

mixin DialogControllerInterface {

  ///对话框按钮事件 （返回 true 关闭弹窗，）
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async {
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

}