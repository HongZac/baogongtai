
import 'package:basement/logger.dart';
import 'package:basement/picker.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/ui/widget/fluent_ui/command_bars/command_bar.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';


///程序日志视图显示
///
/// 日志写入方式：
///
/// PrintUtil.printDebug('');  PrintUtil.PrintUtil.printDebug('');
///
/// debugPrint('');
///
/// ToastNotification(Get.overlayContext!).error(''); ......
///
/// Logger(output: LoggerCollector()).d(''); ......
class LogInspectorController
    extends BaseDialogController
    with SearchInterface {

  final LoggerCollector loggerCollector = LoggerCollector();

  final List<LoggerDataModel> loggerDataList = [];
  LoggerDataModel? selectedLoggerData;

  final ScrollController scrollController = ScrollController();

  ///当前显示的日志的级别
  String level = ShareStorageUtil.instance?.read(SharedPreferencesKeys.LOGGER_LEVEL_KEY) ?? AppConfig.loggerLevel;
  ///是否启用过滤
  bool isFilter = true; //ShareStorageUtil.instance?.read(SharedPreferencesKeys.LOGGER_IS_FILTER_KEY) ?? AppConfig.loggerIsFilter;
  ///过滤的内容
  String filterKeyWord = '';

  late final List<CommandBarItem> commandBarList = [
    /*CommandBarSeparator(),
    CommandBarTextField(
      items: [
        CommandBarTextFieldItemModel(
            keyName: 'keyword', title: '关键字', textTip: '请输入关键字'
        ),
      ],
      onSubmitted: (String keyName, String value, bool isNeedRefreshData) {
        onSearch(value);
      },
    ),
    CommandBarSeparator(),
    CommandBarSelectionDropdown(
      commandBarItemKeyName: 'level',
      keyName: 'level',
      title: '类型筛选',
      adapter: null,
      showCodeName: ShowCodeNameEnum.name,
      onChanged: (String keyName, List<IPickerDataModel> selectedList) async {
        onLevelFilter(selectedList.isEmpty ? 'all' : selectedList[0].id);
      },
    ),
    CommandBarSeparator(),
    CommandBarButton(
      icon: FluentIcons.delete_16_regular,
      label: '清空',
      onPressed: () { loggerOnClearEmpty(); },
    ),
    if (!kIsWeb)
      CommandBarButton(
        icon: FluentIcons.delete_16_regular,
        label: '清理7天前的日志文件',
        onPressed: () async { await logFileOnClear(7); },
      ),*/
  ];

  bool isLoading = false;

  get searchTypeList => List.unmodifiable([
    ChoiceChipModel(title: '关键字搜索', keyName: 'keyword', content: 'keyword'),
  ]);
  get searchQueryDataList => List.unmodifiable(['keyword']);

  CustomAdapter? levelAdapter;


  @override
  Future<void> onReady() async {
    super.onReady();
    selectedLoggerData = null;
    getLoggerList();
    //region 获取日志类型的选择控制器
    levelAdapter = await AdapterHelper.getAsyncAdapter(
      'custom',
      isNeedLoadData: true,
      fieldList: [
        PickerDataModel(id: 'all', name: '全部'),
        PickerDataModel(id: 'trace', name: 'Trace'),
        PickerDataModel(id: 'debug', name: 'Debug'),
        PickerDataModel(id: 'info', name: 'Info'),
        PickerDataModel(id: 'warning', name: 'Warning'),
        PickerDataModel(id: 'error', name: 'Error'),
        PickerDataModel(id: 'fatal', name: 'Fatal'),
        PickerDataModel(id: 'off', name: 'Off'),
      ],
      selectedItems: [PickerDataModel(id: level)],
    ) as CustomAdapter;
    //endregion
    update();
    loggerCollector.addListener(loggerCollectorListener);
  }

  void getLoggerList() {
    loggerDataList.clear();
    ///用于更新 selectedLoggerData，如果 selectedLoggerData 没有数据的话就不用判断了
    bool isSelectedResponseUpdate = selectedLoggerData == null;
    for (var key in loggerCollector.logReversedKeyList) {
      LoggerDataModel item = loggerCollector.getModel(key)!;
      if (!isSelectedResponseUpdate && selectedLoggerData?.uuid == item.uuid){
        isSelectedResponseUpdate = true;
        selectedLoggerData = item;
      }
      bool matchLevel = level == 'all'
          || item.outputEvent.level.name.toLowerCase() == level.toLowerCase();
      bool matchKeyword = !isFilter
          || filterKeyWord.isEmpty
          || (isFilter
              && filterKeyWord.isNotEmpty
              && (item.outputEvent.origin.message.toString()).toLowerCase().contains(filterKeyWord.toLowerCase()));
      if (matchLevel && matchKeyword){
        loggerDataList.add(item);
      }
      if (selectedLoggerData?.uuid == item.uuid && (!matchLevel || !matchKeyword)){
        selectedLoggerData = null;
      }
    }
    if (!isSelectedResponseUpdate){
      selectedLoggerData = null;
    }
  }

  Future<void> loggerCollectorListener() async {
    getLoggerList();
    update();
  }

  void loggerOnDeleted(LoggerDataModel item) {
    loggerDataList.removeWhere((element) => element.uuid == item.uuid);
    if (selectedLoggerData?.uuid == item.uuid){
      selectedLoggerData = null;
    }
    update();
    loggerCollector.delete(item.uuid, isNeedUpdate: false);
  }

  void loggerOnClearEmpty() {
    loggerDataList.clear();
    selectedLoggerData = null;
    update();
    loggerCollector.clearEmpty(isNeedUpdate: false);
  }

  Future<void> logFileOnClear(int days) async {
    if (kIsWeb){ return; }
    var confirm = await DialogUtils.showConfirmationDialog(Get.overlayContext!,
        msg: "确认删除？");
    if (confirm == null || !confirm) {
      isLoading = false;
      return;
    }
    isLoading = true;
    var res = await loggerCollector.logFileOnClear(days);
    if (res){
      ToastNotification(Get.overlayContext!).success('日志文件删除成功！');
    }
    isLoading = false;
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
    selectedLoggerData = null;
    getLoggerList();
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
    selectedLoggerData = null;
    getLoggerList();
    isSearchWidgetOpen = false;
    update();
    isLoading = false;
  }

  void searchQueryDataOnChanged(){
    filterKeyWord = searchTC.text;
  }

  //endregion

  void onLevelFilter(String level) {
    this.level = level;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.LOGGER_LEVEL_KEY, this.level);
    selectedLoggerData = null;
    getLoggerList();
    update();
  }

  void isMsgExpandedOnChanged(LoggerDataModel item){
    item.isMsgExpanded = !item.isMsgExpanded;
    update();
  }

  void isErrorExpandedOnChanged(LoggerDataModel item){
    item.isErrorExpanded = !item.isErrorExpanded;
    update();
  }

  void isStackTraceExpandedOnChanged(LoggerDataModel item){
    item.isStackTraceExpanded = !item.isStackTraceExpanded;
    update();
  }

  void isLineExpandedOnChanged(LoggerDataModel item){
    item.isLineExpanded = !item.isLineExpanded;
    update();
  }


  @override
  void onClose() {
    loggerCollector.removeListener(loggerCollectorListener);
    super.onClose();
  }

}