
import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';

///派工单状态选择过滤接口
mixin TaskSignFilterInterface on SignFilterInterface {

  ///单据状态标签选中对象的 sign（可多选，取二进制的和）
  int selectedTaskSignBinary = AppConfig.binaryForSignSelected;
  ///派工单状态标签列表
  late final List<MoSignModel> taskSignList = List.unmodifiable(AppConfig.taskSignList);


  @override
  List<MoSignModel> get signList => List.unmodifiable(taskSignList);
  @override
  int get selectedSignBinary => selectedTaskSignBinary;


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



  //region 设置

  ///派工单状态标签的初始选中值 选择变化
  void _binaryForTaskSign(int sign) {
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
    update();
  }


  Widget taskSignChoiceWidget(BuildContext context){
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      title: Text(
        '状态标签初始选中对象',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      children: List.generate(taskSignList.length, (index){
        MoSignModel item = taskSignList[index];
        return SwitchListTile(
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          value: selectedTaskSignBinary & item.sign == item.sign,
          onChanged: (bool? boolValue){
            _binaryForTaskSign(item.sign);
          },
        );
      }).toList(),
    );
  }

  //endregion

}