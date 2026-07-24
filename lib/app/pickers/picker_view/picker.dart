import 'package:basement/picker.dart';
import 'package:desktop/app/pickers/picker_view/picker_dialog.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


///选单界面的样式类型
enum PickerChoiceType{
  ///左标题右复选框
  checkboxListTile,
  ///栅格视图
  chip,
  ///注塑派工单
  pmesTask,
  ///生产派工单
  mesTask,
  ///工序
  process,
}


///选单界面入口，
///返回的列表数据类型T
class Picker<T extends PickerDataModel>{

  ///数据接口，提供数据源
  final IPickerAdapter<T> adapter;
  ///查看工序的技术指导书 函数回调
  final ProcessItemAttachBuilder? processItemAttach;
  ///工序选单页面的岗位筛选 函数回调
  final AsyncValueSetter<List<PickerDataModel>>? processPostOnChanged;

  ///已打开的选单弹窗页面
  static int openPickerDialogCount = 0;


  Picker({
    required this.adapter,
    this.processItemAttach,
    this.processPostOnChanged,
  });

  Future<List<T>?> showPickerDialog(context, {PickerChoiceType pickerChoiceType = PickerChoiceType.checkboxListTile}){
    openPickerDialogCount ++;
    return showDialog<List<T>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return PickerDialog(
          adapter: adapter,
          pickerChoiceType: pickerChoiceType,
          processItemAttach: processItemAttach,
          processPostOnChanged: processPostOnChanged,
        );
      }
    ).then((value){
      openPickerDialogCount --;
      return value;
    });
  }

}