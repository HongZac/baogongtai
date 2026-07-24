import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/utils/app_config.dart';

///派工单日期查询接口
mixin TaskDateFilterInterface on DateFilterInterface {

  ///日期查询类型，该值是[taskDateSearchTypeList]中对应项的索引
  int taskDateSearchTypeIndex = AppConfig.dateSearchTypeIndex;
  ///日期查询类型列表
  final List<ChoiceChipModel> taskDateSearchTypeList = List.unmodifiable(AppConfig.taskDateSearchTypeList);
  ///日期查询时对应的关键字段名称
  late final List<String> taskDateSearchQueryDataList = List.unmodifiable(taskDateSearchTypeList.expand((e) => e.content.split(',')).toSet().toList());

  get dateSearchTypeIndex => taskDateSearchTypeIndex;
  get dateSearchTypeList => List.unmodifiable(taskDateSearchTypeList);
  get dateSearchQueryDataList => List.unmodifiable(taskDateSearchQueryDataList);

}