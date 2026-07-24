import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';


///任务单状态选择过滤接口
mixin OrderSignFilterInterface on SignFilterInterface {

  ///单据状态标签选中对象的 sign（可多选，取二进制的和）
  int selectedOrderSignBinary = AppConfig.binaryForSignSelected;
  ///任务单状态标签列表
  late final List<MoSignModel> orderSignList = List.unmodifiable(AppConfig.orderSignList);


  @override
  List<MoSignModel> get signList => List.unmodifiable(orderSignList);
  @override
  int get selectedSignBinary => selectedOrderSignBinary;


  ///需要重写
  @override
  Future<void> signOnChanged(int sign) async{
    if (isSignChipMulti){
      if (selectedOrderSignBinary & sign == sign){
        selectedOrderSignBinary = selectedOrderSignBinary - sign;
      }
      else {
        selectedOrderSignBinary = selectedOrderSignBinary + sign;
      }
    }
    else {
      selectedOrderSignBinary = sign;
    }

    ///“待派工”和其他标签不能同时选中
    if (selectedSignBinary & 8 == 8){
      selectedOrderSignBinary = sign;
    }
  }



  //region 设置

  ///任务单状态标签的初始选中值 选择变化
  void _binaryForOrderSign(int sign) {
    if (isSignChipMulti){
      if (selectedOrderSignBinary & sign == sign){
        selectedOrderSignBinary = selectedOrderSignBinary - sign;
      }
      else {
        selectedOrderSignBinary = selectedOrderSignBinary + sign;
      }
    }
    else {
      selectedOrderSignBinary = sign;
    }
    update();
  }


  Widget orderSignChoiceWidget(BuildContext context){
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      title: Text(
        '状态标签初始选中对象',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      children: List.generate(orderSignList.length, (index){
        MoSignModel item = orderSignList[index];
        return SwitchListTile(
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          value: selectedOrderSignBinary & item.sign == item.sign,
          onChanged: (bool? boolValue){
            _binaryForOrderSign(item.sign);
          },
        );
      }).toList(),
    );
  }

  //endregion

}