import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';


///基本页
abstract class BaseFormInterface implements DialogControllerInterface {

  ///窗体数据创建过程
  Future<bool> initializeForm() async { return true; }

  ///设置按钮点击回调
  void settingOnTap() {  }


}