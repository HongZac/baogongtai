import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';

///派工单关键字搜索接口
mixin TaskKeywordSearchInterface on SearchInterface {

  ///列表搜索方式，该值是[taskSearchTypeList]中对应项的索引
  int taskSearchTypeIndex = AppConfig.searchTypeIndex;
  ///派工单搜索方式列表
  final List<ChoiceChipModel> taskSearchTypeList = List.unmodifiable(AppConfig.taskSearchTypeList);
  ///搜索时对应的关键字段名称
  late final List<String> taskSearchQueryDataList = List.unmodifiable(taskSearchTypeList.map((e) => e.content).toSet().toList());


  get searchTypeIndex => taskSearchTypeIndex;
  get searchTypeList => List.unmodifiable(taskSearchTypeList);
  get searchQueryDataList => List.unmodifiable(taskSearchQueryDataList);



  //region 设置

  ///“列表搜索方式” 选择变化
  void _taskSearchTypeIndexOnChanged(int index) {
    taskSearchTypeIndex = index;
    update();
  }

  Widget taskSearchTypeIndexChoiceWidget(BuildContext context, {String title = '搜索方式'}){
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      children: List.generate(taskSearchTypeList.length, (index) {
        ChoiceChipModel item = taskSearchTypeList[index];
        return RadioListTile(
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          value: index,
          groupValue: taskSearchTypeIndex,
          onChanged: (int? index){
            _taskSearchTypeIndexOnChanged(index!);
          },
        );
      }).toList(),
    );
  }

  //endregion
}