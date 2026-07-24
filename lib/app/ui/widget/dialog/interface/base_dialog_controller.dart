import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/ui/pages/root/root_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:get/get.dart';


///对话框控制器基类
abstract class BaseDialogController extends GetxController with DialogControllerInterface {

  final RootController rootCtl = Get.find<RootController>();

  ///对话框按钮事件 （返回 true 关闭弹窗，）
  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async {
    return DialogReturnDataModel(isCanCloseDialog: true);
  }


  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}