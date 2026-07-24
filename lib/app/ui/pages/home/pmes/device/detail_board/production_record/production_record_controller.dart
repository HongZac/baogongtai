import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';


///生产记录 670006
class ProductionRecordController
    extends BaseFormWithPageDataController<MoProcessTeamData>
    with DateFilterInterface {

  get dateSearchTypeList => List.unmodifiable(AppConfig.productionRecordDateSearchTypeList);
  get dateSearchQueryDataList => List.unmodifiable(dateSearchTypeList.expand((e) => e.content.split(',')).toSet().toList());

  final String deviceId;


  ProductionRecordController({
    super.progId = 670006,
    required this.deviceId,
  });

  @override
  void onInit() {
    super.onInit();
    dataListPageConfig.sidx = 'ProcessDate';
    dataListPageConfig.sord = 'desc';
    dataListPageConfig.rows = 7;
    dataListPageConfig.queryData = {
      'DeviceId': deviceId,
    };
    datePickerValueMap = getDatePickerValueMapByStorage(
      jsonEncode(AppConfig.todayDatePickerValueMap)
    );
    dateQueryDataOnChanged();
  }

  @override
  Future<PageResult<MoProcessTeamData>> getDataList(PageConfig pageConfig) async {
    var res = await MoProcessRepository().getTeamDataPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取生产记录列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }


  @override
  Future<void> dateOnChanged(String string) async {
    DateTime? oldStartDate = startDate;
    DateTime? oldEndDate = endDate;
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    await super.dateOnChanged(string);
    if (oldStartDate == startDate && oldEndDate == endDate){
      isLoading = false;
      return;
    }
    dateQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void dateQueryDataOnChanged() {
    dataListPageConfig.queryData!.removeWhere((key, value) => dateSearchQueryDataList.contains(key));
    if (startDate != null && endDate != null){
      String keyWord = dateSearchTypeList[dateSearchTypeIndex].content;
      List<String> keywordList = keyWord.split(',');
      if (keywordList.length == 2){
        dataListPageConfig.queryData![keywordList[0]] = startDateStrWithNoTime;
        dataListPageConfig.queryData![keywordList[1]] = endDateStrWithEndTime;
      }
    }
  }

  ///Item“展开按钮”点击变化
  void itemExpandedOnChanged(MoProcessTeamData item){
    item.isExpanded = !item.isExpanded;
    update();
  }


}