import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///拌料单 651071 OR 粉料单 651076 主页面
class MoMixtureController extends BaseFormWithPageDataController<MoMixtureModel>{

  late final String typeTitle = progId == 651071
      ? '拌料单'
      : progId == 651076
      ? '粉料单'
      : '';

  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now();

  ///材料筛选
  CustomAdapter? inventoryAdapter;

  //region 搜索
  final TextEditingController searchTC = TextEditingController();
  final FocusNode searchFN = FocusNode();
  bool isSearchWidgetOpen = false;
  //endregion


  MoMixtureController({
    required super.progId,
  });

  @override
  void onInit() {
    super.onInit();
    dataListPageConfig.rows = 20;
    dataListPageConfig.sidx = 'InvName';
    dataListPageConfig.sord = 'asc';
    dataListPageConfig.queryData = {
      'progid': progId,
      'startdate': '${DateUtil.getDateStrByDateTime(
          startDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00',
      'enddate': '${DateUtil.getDateStrByDateTime(
          endDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00',
    };
  }

  @override
  Future<void> onReady() async {
    await super.onReady();
    searchFN.addListener(() async { 
      if (searchTC.text.isNotEmpty){
        isSearchWidgetOpen = true;
      }
      else {
        isSearchWidgetOpen = searchFN.hasFocus;
      }
      if (rootCtl.isKeyboardOpenAfterClickTC && searchFN.hasFocus && !kIsWeb && GetPlatform.isWindows){
        await rootCtl.openKeyboard();
      }
      update();
    });
  }

  @override
  Future<bool> initializeForm() async {
    var res = await super.initializeForm();
    await getInventoryAdapter();
    return res;
  }

  Future<void> getInventoryAdapter() async {
    AttributeEntity? attributeEntity = objectItem.attributeList.firstWhereOrNull((element) => element.code == 'searchText');
    List<PickerDataModel> fieldList = attributeEntity?.dataSource == null
        ? []
        : attributeEntity!.dataSource!.split(',').map((e) => PickerDataModel(id: e, name: e)).toList();
    inventoryAdapter = await AdapterHelper.getAsyncAdapter(
      'custom',
      multipleSelection: false,
      fieldList: fieldList,
    ) as CustomAdapter;
  }

  @override
  Future<PageResult<MoMixtureModel>> getDataList(PageConfig pageConfig) async {
    var res = await MoMixtureRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取$typeTitle列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }


  //region OnChanged

  Future<void> inventoryOnChanged(PickerDataModel item) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    dataListPageConfig.queryData!['invname'] = item.id;
    await pageChanged(pageIndex: 1);
    update();
    isLoading = false;
  }


  ///日期选择变化
  Future<void> dateChanged(String string) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (string.isEmpty){
      startDate = null;
      endDate = null;
      dataListPageConfig.queryData!['startdate'] = null;
      dataListPageConfig.queryData!['enddate'] = null;
    }
    else {
      List<String> dateList = string.split('到');
      if (dateList.length != 2){
        ToastNotification(Get.overlayContext!).error("日期数据错误！");
        isLoading = false;
        return;
      }
      startDate = DateTime.tryParse(dateList[0]) ?? DateTime.now();
      endDate = DateTime.tryParse(dateList[1]) ?? DateTime.now();
      dataListPageConfig.queryData!['startdate'] = '${DateUtil.getDateStrByDateTime(
          startDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
      dataListPageConfig.queryData!['enddate'] = '${DateUtil.getDateStrByDateTime(
          endDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
    }
    await pageChanged(pageIndex: 1);
    update();
    isLoading = false;
  }

  ///拌料单Item“展开按钮”点击变化
  void mixtureItemExpandedOnChanged(MoMixtureModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }

  //endregion
  
  
  //region 搜索

  void searchTCOnChanged() {
    dataListPageConfig.queryData!.remove('invname');
    dataListPageConfig.queryData!['invname'] = searchTC.text;
    update();
  }

  Future<void> searchTCOnSearch() async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchFN.unfocus();
    dataListPageConfig.queryData!.remove('invname');
    dataListPageConfig.queryData!['invname'] = searchTC.text;
    await pageChanged(pageIndex: 1, showLoading: true);
    update();
    isLoading = false;
  }

  Future<void> searchTCClear() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchFN.unfocus();
    searchTC.text = '';
    dataListPageConfig.queryData!.remove('invname');
    await pageChanged(pageIndex: 1, showLoading: true);
    isSearchWidgetOpen = false;
    update();
    isLoading = false;
  }

  //endregion


  //region OnTap

  Future<void> itemOnDoubleTap(MoMixtureModel item) async{
    String route = '';
    switch (progId){
      case 651071:
        route = AppRoutes.MO_MIXTURE_DETAIL_MAIN_PAGE;
        break;
      case 651076:
        route = AppRoutes.MO_POWDER_DETAIL_MAIN_PAGE;
        break;
    }
    Get.rootDelegate.toNamed(
      route,
      arguments: item,
      parameters: {
        'moMixtureId': item.moMixtureId ?? '',
        'mainProgId': progId.toString(),
      }
    );
  }

  //endregion


  @override
  void onClose() {
    searchTC.dispose();
    searchFN.dispose();
    super.onClose();
  }

}