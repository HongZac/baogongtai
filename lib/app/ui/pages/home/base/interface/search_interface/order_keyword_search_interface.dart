
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';

///任务单关键字搜索接口
mixin OrderKeywordSearchInterface on SearchInterface {

  ///列表搜索方式，该值是[orderSearchTypeList]中对应项的索引
  int orderSearchTypeIndex = AppConfig.searchTypeIndex;
  ///任务单搜索方式列表
  late final List<ChoiceChipModel> orderSearchTypeList = List.unmodifiable(AppConfig.orderSearchTypeList);
  ///搜索时对应的关键字段名称
  late final List<String> orderSearchQueryDataList = List.unmodifiable(orderSearchTypeList.map((e) => e.content).toSet().toList());


  get searchTypeIndex => orderSearchTypeIndex;
  get searchTypeList => List.unmodifiable(orderSearchTypeList);
  get searchQueryDataList => List.unmodifiable(orderSearchQueryDataList);



  //region 设置

  ///“列表搜索方式” 选择变化
  void _orderSearchTypeIndexOnChanged(int index) {
    orderSearchTypeIndex = index;
    update();
  }


  Widget orderSearchTypeIndexChoiceWidget(BuildContext context, {String title = '搜索方式'}){
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      children: List.generate(orderSearchTypeList.length, (index) {
        ChoiceChipModel item = orderSearchTypeList[index];
        return RadioListTile(
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          value: index,
          groupValue: orderSearchTypeIndex,
          onChanged: (int? index){
            _orderSearchTypeIndexOnChanged(index!);
          },
        );
      }).toList(),
    );
  }

  //endregion

}