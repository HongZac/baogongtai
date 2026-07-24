

import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/utils/app_config.dart';

///机台派工单状态选择过滤接口
mixin DeviceTaskSignFilterInterface on SignFilterInterface {


  ///单据状态标签选中对象的 sign（可多选，取二进制的和）
  int selectedTaskSignBinary = AppConfig.binaryForSignSelected;
  ///派工单状态标签列表
  late final List<MoSignModel> taskSignList = List.unmodifiable(AppConfig.deviceTaskSignList);


  get signList => List.unmodifiable(taskSignList);
  get selectedSignBinary => selectedTaskSignBinary;


  ///需要重写
  @override
  Future<void> signOnChanged(int sign) async{
    if (isSignChipMulti){
      if (selectedTaskSignBinary & sign == sign){
        selectedTaskSignBinary = selectedTaskSignBinary - sign;
      }
      else {
        selectedTaskSignBinary = selectedTaskSignBinary + sign;
      }
    }
    else {
      selectedTaskSignBinary = sign;
    }
  }

}