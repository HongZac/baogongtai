import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_split_view/multi_split_view.dart';
//import 'package:multi_split_view/multi_split_view.dart';


///dio 网络检查器 消息队列显示
class DioInspectorController
    extends BaseDialogController
    with SearchInterface {

  final dioLogCollector = DioLogCollector();

  final List<DioLogDataModel> dioLogDataList = [];
  ///当前选中的请求项
  DioLogDataModel? selectedResponse;

  final ScrollController scrollController = ScrollController();
  MultiSplitViewController multiSplitViewController = MultiSplitViewController(
      areas: [Area(size: 5000, min: 220), Area(size: 0)]
  );

  ///请求方法列表
  final List<ChoiceChipModel> methodList = [
    ChoiceChipModel(keyName: 'all', title: '全部'),
    ChoiceChipModel(keyName: 'get', title: 'GET'),
    ChoiceChipModel(keyName: 'post', title: 'POST'),
    ChoiceChipModel(keyName: 'put', title: 'PUT'),
    ChoiceChipModel(keyName: 'patch', title: 'PATCH'),
    ChoiceChipModel(keyName: 'delete', title: 'DELETE'),
    ChoiceChipModel(keyName: 'head', title: 'HEAD'),
    ChoiceChipModel(keyName: 'options', title: 'OPTIONS'),
  ];

  ///当前显示的请求方法类型
  String method = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DIO_INSPECTOR_METHOD_KEY) ?? AppConfig.dioLogMethod;
  ///是否启用过滤
  bool isFilter = true; //ShareStorageUtil.instance?.read(SharedPreferencesKeys.DIO_INSPECTOR_IS_FILTER_KEY) ?? AppConfig.dioLogIsFilter;
  ///过滤的内容
  String filterKeyWord = '';

  String? mouseEnterKey;

  final List<bool> isExpandedList = [true, true, true, true];
  bool isAllExpanded = true;

  bool isLoading = false;

  get searchTypeList => List.unmodifiable([
    ChoiceChipModel(title: '关键字搜索', keyName: 'keyword', content: 'keyword'),
  ]);
  get searchQueryDataList => List.unmodifiable(['keyword']);


  @override
  Future<void> onReady() async {
    super.onReady();
    selectedResponse = null;
    getLogList();
    update();
    dioLogCollector.addListener(dioLogCollectorListener);
  }


  void getLogList() {
    dioLogDataList.clear();
    ///用于更新 selectedResponse，如果 selectedResponse 没有数据的话就不用判断了
    bool isSelectedResponseUpdate = selectedResponse == null;
    for (var key in dioLogCollector.dioLogReversedKeyList) {
      DioLogDataModel item = dioLogCollector.getModel(key)!;
      if (!isSelectedResponseUpdate && selectedResponse?.uuid == item.uuid){
        isSelectedResponseUpdate = true;
        selectedResponse = item;
      }
      bool matchLevel = method == 'all'
          || item.requestOptions?.method.toLowerCase() == method.toLowerCase();
      bool matchKeyword = !isFilter
          || filterKeyWord.isEmpty
          || (isFilter
              && filterKeyWord.isNotEmpty
              && (item.requestOptions?.uri.toString() ?? '').toLowerCase().contains(filterKeyWord.toLowerCase()));
      if (matchLevel && matchKeyword){
        dioLogDataList.add(item);
      }
      if (selectedResponse?.uuid == item.uuid && (!matchLevel || !matchKeyword)){
        selectedResponse = null;
      }
    }
    if (!isSelectedResponseUpdate){
      selectedResponse = null;
    }
  }

  Future<void> dioLogCollectorListener() async {
    getLogList();
    update();
    /// selectedResponse 有数据时，是否需要滚动
    //_scrollToTop();
  }

  ///滚动到最顶部
  void _scrollToTop({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      //final offset = scrollController.position.maxScrollExtent;
      if (animate) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(0);
      }
    });
  }


  void selectedResponseOnChanged(DioLogDataModel item) {
    selectedResponse = item;
    ///代码控制 右侧区域扩大展开
    if (multiSplitViewController.getArea(1).size == 0){
      multiSplitViewController = MultiSplitViewController(
          areas: [Area(size: 220, min: 220), Area(size: 5000)]
      );
    }
    update();
  }

  void responseOnDeleted(DioLogDataModel item) {
    dioLogDataList.removeWhere((element) => element.uuid == item.uuid);
    if (selectedResponse?.uuid == item.uuid){
      selectedResponse = null;
    }
    update();
    dioLogCollector.delete(item.uuid, isNeedUpdate: false);
  }

  void responseOnClearEmpty() {
    dioLogDataList.clear();
    selectedResponse = null;
    update();
    dioLogCollector.clearEmpty(isNeedUpdate: false);
  }

  //region 搜索

  @override
  void searchTCOnChanged() {
    searchQueryDataOnChanged();
    update();
  }

  @override
  Future<void> onSearch() async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchFN.unfocus();
    searchQueryDataOnChanged();
    selectedResponse = null;
    getLogList();
    update();
    isLoading = false;
  }

  @override
  Future<void> searchTCOnClear() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchFN.unfocus();
    searchTC.text = '';
    searchQueryDataOnChanged();
    selectedResponse = null;
    getLogList();
    isSearchWidgetOpen = false;
    update();
    isLoading = false;
  }

  void searchQueryDataOnChanged(){
    filterKeyWord = searchTC.text;
  }

  //endregion

  void mouseEnterKeyOnChanged({required bool isEnter, required String key}){
    if (isEnter){
      mouseEnterKey = key;
    }
    else {
      mouseEnterKey = null;
    }
    update();
  }

  void expansionCallback(int index, bool boolValue) {
    isExpandedList[index] = boolValue;
    Set<bool> set = isExpandedList.toSet();
    if (set.length == 1 && set.first){
      isAllExpanded = true;
    }
    else {
      isAllExpanded = false;
    }
    update();
  }

  void setAllExpanded(bool isExpanded){
    isAllExpanded = isExpanded;
    isExpandedList.fillRange(0, isExpandedList.length, isAllExpanded);
    update();
  }


  @override
  void onClose() {
    dioLogCollector.removeListener(dioLogCollectorListener);
    super.onClose();
  }

}