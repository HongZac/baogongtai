import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/utils/app_config.dart';

///任务单日期查询接口
mixin OrderDateFilterInterface on DateFilterInterface {

  ///日期查询类型，该值是[orderDateSearchTypeList]中对应项的索引
  int orderDateSearchTypeIndex = AppConfig.dateSearchTypeIndex;
  ///日期查询类型列表
  final List<ChoiceChipModel> orderDateSearchTypeList = List.unmodifiable(AppConfig.orderDateSearchTypeList);
  ///日期查询时对应的关键字段名称
  late final List<String> orderDateSearchQueryDataList = List.unmodifiable(orderDateSearchTypeList.expand((e) => e.content.split(',')).toSet().toList());


  get dateSearchTypeIndex => orderDateSearchTypeIndex;
  get dateSearchTypeList => List.unmodifiable(orderDateSearchTypeList);
  get dateSearchQueryDataList => List.unmodifiable(orderDateSearchQueryDataList);

}