import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';


///工序计划详细单据状态选择过滤接口
mixin WBEntrySignFilterInterface on SignFilterInterface {

  ///单据状态标签选中对象的 sign（可多选，取二进制的和）
  int selectedWBEntrySignBinary = AppConfig.binaryForSignSelected;
  ///任务单状态标签列表
  late final List<MoSignModel> wBEntrySignList = List.unmodifiable(AppConfig.workBillEntrySignList);


  @override
  List<MoSignModel> get signList => List.unmodifiable(wBEntrySignList);
  @override
  int get selectedSignBinary => selectedWBEntrySignBinary;


  ///需要重写
  @override
  Future<void> signOnChanged(int sign) async{
    if (isSignChipMulti){
      if (selectedWBEntrySignBinary & sign == sign){
        selectedWBEntrySignBinary = selectedWBEntrySignBinary - sign;
      }
      else {
        selectedWBEntrySignBinary = selectedWBEntrySignBinary + sign;
      }
    }
    else {
      selectedWBEntrySignBinary = sign;
    }
  }



  //region 设置

  ///任务单状态标签的初始选中值 选择变化
  void _binaryForWBEntrySign(int sign) {
    if (isSignChipMulti){
      if (selectedWBEntrySignBinary & sign == sign){
        selectedWBEntrySignBinary = selectedWBEntrySignBinary - sign;
      }
      else {
        selectedWBEntrySignBinary = selectedWBEntrySignBinary + sign;
      }
    }
    else {
      selectedWBEntrySignBinary = sign;
    }
    update();
  }


  Widget wBEntrySignChoiceWidget(BuildContext context){
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      title: Text(
        '状态标签初始选中对象',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      children: List.generate(wBEntrySignList.length, (index){
        MoSignModel item = wBEntrySignList[index];
        return SwitchListTile(
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          value: selectedWBEntrySignBinary & item.sign == item.sign,
          onChanged: (bool? boolValue){
            _binaryForWBEntrySign(item.sign);
          },
        );
      }).toList(),
    );
  }

//endregion

}