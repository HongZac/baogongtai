import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';


///设置页面 基础页
abstract class BaseSettingInterface<T extends BaseSettingController> implements BaseFormInterface {

  ///标题名称
  final String title = '';

  ///tabValue 列表
  final List<ChoiceChipModel> tabValueList = [];

}