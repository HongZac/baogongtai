import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';


///产品关键字搜索接口
mixin InventorySearchInterface on SearchInterface {

  ///列表搜索方式，该值是[inventorySearchTypeList]中对应项的索引
  int inventorySearchTypeIndex = AppConfig.searchTypeIndex;
  ///产品搜索方式列表
  late final List<ChoiceChipModel> inventorySearchTypeList = List.unmodifiable(AppConfig.inventorySearchTypeList);
  ///搜索时对应的关键字段名称
  late final List<String> inventorySearchQueryDataList = List.unmodifiable(inventorySearchTypeList.map((e) => e.content).toSet().toList());


  get searchTypeIndex => inventorySearchTypeIndex;
  get searchTypeList => List.unmodifiable(inventorySearchTypeList);
  get searchQueryDataList => List.unmodifiable(inventorySearchQueryDataList);



  //region 设置

  ///“列表搜索方式” 选择变化
  void _inventorySearchTypeIndexOnChanged(int index) {
    inventorySearchTypeIndex = index;
    update();
  }


  Widget inventorySearchTypeIndexChoiceWidget(BuildContext context, {String title = '搜索方式'}){
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      children: List.generate(inventorySearchTypeList.length, (index) {
        ChoiceChipModel item = inventorySearchTypeList[index];
        return RadioListTile(
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          value: index,
          groupValue: inventorySearchTypeIndex,
          onChanged: (int? index){
            _inventorySearchTypeIndexOnChanged(index!);
          },
        );
      }).toList(),
    );
  }

  //endregion
}