import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/utils/app_config.dart';


///生产报工单关键字搜索接口
mixin MesSubmitKeywordSearchInterface on SearchInterface {

  ///列表搜索方式，该值是[mesSubmitSearchTypeList]中对应项的索引
  int mesSubmitSearchTypeIndex = AppConfig.searchTypeIndex;

  ///任务单搜索方式列表
  late final List<ChoiceChipModel> mesSubmitSearchTypeList = List.unmodifiable(AppConfig.mesSubmitSearchTypeList);
  ///搜索时对应的关键字段名称
  late final List<String> mesSubmitSearchQueryDataList = List.unmodifiable(mesSubmitSearchTypeList.map((e) => e.content).toSet().toList());


  get searchTypeIndex => mesSubmitSearchTypeIndex;
  get searchTypeList => List.unmodifiable(mesSubmitSearchTypeList);
  get searchQueryDataList => List.unmodifiable(mesSubmitSearchQueryDataList);
  
}