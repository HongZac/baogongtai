import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/utils/app_config.dart';


///注塑报工单关键字搜索接口
mixin PMesSubmitKeywordSearchInterface on SearchInterface {

  ///列表搜索方式，该值是[pMesSubmitSearchTypeList]中对应项的索引
  int pMesSubmitSearchTypeIndex = AppConfig.searchTypeIndex;

  ///任务单搜索方式列表
  late final List<ChoiceChipModel> pMesSubmitSearchTypeList = List.unmodifiable(AppConfig.pMesSubmitSearchTypeList);
  ///搜索时对应的关键字段名称
  late final List<String> pMesSubmitSearchQueryDataList = List.unmodifiable(pMesSubmitSearchTypeList.map((e) => e.content).toSet().toList());


  get searchTypeIndex => pMesSubmitSearchTypeIndex;
  get searchTypeList => List.unmodifiable(pMesSubmitSearchTypeList);
  get searchQueryDataList => List.unmodifiable(pMesSubmitSearchQueryDataList);

}