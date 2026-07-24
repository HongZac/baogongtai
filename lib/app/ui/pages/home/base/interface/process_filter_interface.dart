

import 'package:basement/picker.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';

///工序选择接口
mixin ProcessFilterInterface {

  ///是否显示工序选择器
  bool isShowProcessPicker = false;
  ProcessAdapter? processAdapter;
  ///工序筛选 选中的工序 ID
  String processId = '';


  Future<void> _getProcessAdapter({String? wbId, String? moOrderId, String? invId}) async {
    processAdapter = await AdapterHelper.getAsyncAdapter(
      'process',
      multipleSelection: false,
      isNeedLoadData: false,
      queryData: {
        'wbId': wbId,
        'moOrderId': moOrderId,
        'invId': invId,
      },
      selectedItems: []
    ) as ProcessAdapter;
  }
  Future<void> Function({String? wbId, String? moOrderId, String? invId}) get getProcessAdapter => _getProcessAdapter;



  ///工序选择变化 需要重写
  Future<void> processOnChanged(List<PickerDataModel> list) async {
    processId = list.map((e) => e.id).join(',');
  }


  ///Input 风格的车间选择器
  Widget processFilterInputWidget(BuildContext context) {
    return TitleTextBoxWidget(
      title: '工序筛选',
      isShowColon: false,
      widthOfSizedBox: 6,
      titleWidth: 70, width: 270,
      customizeContent: PickerInputWidget(
        adapter: processAdapter,
        height: 50,
        onTap: (List<PickerDataModel> selectList) async{
          await processOnChanged(selectList);
        },
      ),
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

}