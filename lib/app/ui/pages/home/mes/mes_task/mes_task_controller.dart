import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/serial_com_service/mixin/serial_port_getx_listener.dart';
import 'package:desktop/app/service/serial_com_service/serial_port_data_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_controller.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_view.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/task_date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/dep_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/line_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/task_keyword_search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/task_sign_filter_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///生产派工单列表页面
class MesTaskController
    extends BaseFormWithPageDataController<MoTaskModel>
    with SignFilterInterface, TaskSignFilterInterface,
        DepFilterInterface,
        LineFilterInterface,
        DateFilterInterface, TaskDateFilterInterface,
        SearchInterface, TaskKeywordSearchInterface,
        SerialPortGetXListenerMixin<MesTaskController>, ScanInterface<MesTaskController>,
        InfoFormInterface,
        CommandBarInterface,
        InterfaceUtil {

  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> taskListInfoFormListMap = {};

  ///派工单列表页面显示的按钮组列表
  final List<CommandBarBtnModel> taskCommandBarList = [];


  MesTaskController({
    super.progId = 650011,
  });


  @override
  void onInit() {
    super.onInit();

    //region
    isShowSignFilter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_IS_SHOW_TASK_SIGN_FILTER_KEY) ?? AppConfig.isShowSignFilter;
    isSignChipMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_IS_TASK_SIGN_CHIP_MULTI_KEY)?? AppConfig.isSignChipMulti;
    selectedTaskSignBinary = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SIGN_SELECTED_KEY) ?? AppConfig.binaryForSignSelected;

    isShowDepPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_IS_SHOW_DEP_PICKER_KEY) ?? AppConfig.isShowDepPicker;
    depIds = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_DEP_IDS_KEY) ?? '';

    isShowLinePicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_IS_SHOW_LINE_PICKER_KEY) ?? AppConfig.isShowLinePicker;
    lineIds = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_LINE_IDS_KEY) ?? '';

    isShowDatePicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_IS_SHOW_DATE_PICKER_KEY) ?? AppConfig.isShowDatePicker;
    taskDateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
    String datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_DATE_PICKER_VALUE_MAP_KEY) ?? '';
    datePickerValueMap = getDatePickerValueMapByStorage(datePickerValueStr);

    isShowSearchInputBox = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_IS_SHOW_SEARCH_INPUT_BOX_KEY) ?? AppConfig.isShowSearchInputBox;
    taskSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;

    scanQueryDataList.addAll(['MoOpId', 'MoOrderId', 'keyValue', 'EmploeeId']);

    List<dynamic> taskListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_INFO_FORM_LIST_KEY) ?? [];
    taskListInfoFormListMap.clear();
    taskListInfoFormListMap.addAll(
      getInfoFormListMap(
        getInfoFormListByStorage(
          taskListInfoFormMapList,
          AppConfig.mesTaskListInfoFormList
        )
      )
    );

    List<dynamic> taskCommandBarMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_COMMAND_BAR_LIST_KEY) ?? [];
    taskCommandBarList.clear();
    taskCommandBarList.addAll(
      getCommandBarListByStorage(
        taskCommandBarMapList,
        AppConfig.mesTaskCommandBarList
      )
    );
    //endregion

    dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
    dataListPageConfig.sidx = 'TaskDate';
    dataListPageConfig.queryData = {
      'progid': progId,
      //'depid': depIds,
      //'wcId': lineIds,
    };
    depQueryDataOnChanged();
    lineQueryDataOnChanged();
    signQueryDataOnChanged();
    dateQueryDataOnChanged();
  }

  @override
  Future<void> onReady() async{
    await super.onReady();
  }

  @override
  Future<bool> initializeForm() async {
    var res = await super.initializeForm();
    await getDepAdapter();
    await getLineAdapter();
    return res;
  }
  
  @override
  Future<PageResult<MoTaskModel>> getDataList(PageConfig pageConfig) async{
    if (searchTC.text.isNotEmpty){
      switch (taskSearchTypeList[taskSearchTypeIndex].keyName){
        case 'psnIdCode':
          //region 员工卡号搜索
          var psnRes = await PersonRepository().getFormData('', '', {'IdCode': searchTC.text}, 0);
          if (!psnRes.isSuccess){
            ToastNotification(Get.overlayContext!).error('获取员工数据时出错：${psnRes.message}！');
            return PageResult();
          }
          if (psnRes.data.personID.isEmpty){
            ToastNotification(Get.overlayContext!).error('查询不到该员工！');
            return PageResult();
          }
          pageConfig.queryData!['EmploeeId'] = psnRes.data.personID;
          //endregion
          break;
        case 'psnNum':
          //region 员工编号搜索
          var psnRes = await PersonRepository().getFormData('', '', {'PsnNum': searchTC.text}, 0);
          if (!psnRes.isSuccess){
            ToastNotification(Get.overlayContext!).error('获取员工数据时出错：${psnRes.message}！');
            return PageResult();
          }
          if (psnRes.data.personID.isEmpty){
            ToastNotification(Get.overlayContext!).error('查询不到该员工！');
            return PageResult();
          }
          pageConfig.queryData!['EmploeeId'] = psnRes.data.personID;
          //endregion
          break;
      }
    }

    var res = await MoTaskRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取生产派工单列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }


  //region OnChanged

  @override
  Future<void> depOnChanged(List<PickerDataModel> list) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    String oldDepIds = depIds;
    await super.depOnChanged(list);
    if (oldDepIds == depIds){
      isLoading = false;
      return;
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_DEP_IDS_KEY, depIds);
    depQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void depQueryDataOnChanged() {
    dataListPageConfig.queryData!['depid'] = depIds;
  }

  @override
  Future<void> lineOnChanged(List<PickerDataModel> list) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    String oldLineIds = lineIds;
    await super.lineOnChanged(list);
    if (oldLineIds == lineIds){
      isLoading = false;
      return;
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_LINE_IDS_KEY, lineIds);
    lineQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void lineQueryDataOnChanged(){
    dataListPageConfig.queryData!['wcId'] = lineIds;
  }

  @override
  Future<void> signOnChanged(int sign) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    await super.signOnChanged(sign);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SIGN_SELECTED_KEY, selectedTaskSignBinary);
    signQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void signQueryDataOnChanged() {
    List<String> statusList = [];
    for (var element in taskSignList) {
      if (selectedTaskSignBinary & element.sign == element.sign){
        statusList.add(element.content);
      }
    }
    String status = statusList.join(',');
    dataListPageConfig.queryData!['status'] = status;
  }

  @override
  Future<void> dateSearchTypeOnChanged(ChoiceChipModel item, int index) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (index == taskDateSearchTypeIndex){
      isLoading = false;
      return;
    }
    taskDateSearchTypeIndex = index;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_DATE_SEARCH_TYPE_INDEX_KEY, taskDateSearchTypeIndex);
    dateQueryDataOnChanged();
    if (startDate != null && endDate != null){
      await pageChanged();
    }
    update();
    isLoading = false;
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
    dataListPageConfig.queryData!.removeWhere((key, value) => taskDateSearchQueryDataList.contains(key));
    if (startDate != null && endDate != null){
      String keyWord = taskDateSearchTypeList[taskDateSearchTypeIndex].content;
      List<String> keywordList = keyWord.split(',');
      if (keywordList.length == 2){
        dataListPageConfig.queryData![keywordList[0]] = startDateStrWithNoTime;
        dataListPageConfig.queryData![keywordList[1]] = endDateStrWithNoTime;
      }
    }
  }

  //endregion


  //region 搜索

  @override
  Future<void> searchTypeOnChanged(ChoiceChipModel item, int index) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (index == taskSearchTypeIndex){
      isLoading = false;
      return;
    }
    taskSearchTypeIndex = index;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_TASK_SEARCH_TYPE_INDEX_KEY, taskSearchTypeIndex);
    searchQueryDataOnChanged();
    if (searchTC.text.isNotEmpty){
      await pageChanged();
    }
    update();
    isLoading = false;
  }

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
    await pageChanged();
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
    await pageChanged();
    isSearchWidgetOpen = false;
    update();
    isLoading = false;
  }

  void searchQueryDataOnChanged(){
    dataListPageConfig.queryData!.removeWhere((key, value) => taskSearchQueryDataList.contains(key));
    if (searchTC.text.isNotEmpty){
      String keyWord = taskSearchTypeList[taskSearchTypeIndex].content;
      dataListPageConfig.queryData![keyWord] = searchTC.text;
    }
  }

  //endregion


  //region 串口、扫码

  @override
  Future<void> onSerialPortData(SerialPortDataModel serialPortDataModel) async {
    for (var element in weightMsgConnectService.connectList){
      if (element.com == serialPortDataModel.com){
        portMsgOnData(
          element.key,
          data: serialPortDataModel.data,
          accuracy: element.accuracy,
        );
      }
    }
  }

  void portMsgOnData(String key, {
    required dynamic data,
    bool isWeightMsgReverseOrder = false,
    double accuracy = 0,
  }){
    switch (key){
      case WeightMsgConnectService.scanGun:
      case WeightMsgConnectService.cardReader:
        onBarcode(data);
        break;
    }
  }

  @override
  Future<void> resetScan() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    ProgressDialogUtil.showProgressDialog();

    await super.resetScan();
    scanQueryDataOnChanged();
    bool res = await pageChanged(showLoading: false);
    isLoading = false;
    update();
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1);
    }
  }

  @override
  Future<void> onBarcode(String searchString) async {
    if (kDebugMode){
      //searchString = '|F|650011|86656667-2641-4760-91d8-f97d8bc56bf8';
      //searchString = '|F|650011|f3b4e0e9-2bbf-4482-95d3-9385626db024';
    }
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (searchString.isEmpty){
      ToastNotification(Get.overlayContext!).warn('条码为空！');
      isLoading = false;
      return;
    }
    bool res = false;
    ProgressDialogUtil.showProgressDialog(msg: '正在返回扫描结果');

    searchString = getBarCodePrefix(searchString, objectItem.attributeList);
    List<String> list = searchString.split('|');
    if (list.length < 3){
      ToastNotification(Get.overlayContext!).warn('条码错误，请检查设置的默认条码格式！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    switch (list[1]){
      case 'T':
        //region 工序条码 610001
        if (list.length == 4){
          if (list[2] == '610001'){
            scanQueryDataOnChanged(keyWord: 'MoOpId', keyValue: list[3]);
            res = await pageChanged(showLoading: false);
          }
          else {
            ToastNotification(Get.overlayContext!).warn('条码错误！');
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
        }
        else {
          ToastNotification(Get.overlayContext!).warn('条码错误！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        //endregion
        break;
      case 'F':
        //region 生产任务单条码 610001；生产派工单条码 650011
        if (list.length == 4){
          if (list[2] == '610001'){
            scanQueryDataOnChanged(keyWord: 'MoOrderId', keyValue: list[3]);
            res = await pageChanged(showLoading: false);
          }
          else if (list[2] == '650011'){
            scanQueryDataOnChanged(keyWord: 'keyValue', keyValue: list[3]);
            dataListPageConfig;
            res = await pageChanged(showLoading: false);
          }
          else {
            ToastNotification(Get.overlayContext!).warn('条码错误！');
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
        }
        else {
          ToastNotification(Get.overlayContext!).warn('条码错误！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        //endregion
        break;
      case 'IP':
        //region 员工卡号
        String idCode = list[2];
        var psnRes = await PersonRepository().getFormData('', '', {'IdCode': idCode}, 0);
        if (!psnRes.isSuccess){
          ToastNotification(Get.overlayContext!).warn('获取员工数据时出错：${psnRes.message}！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (psnRes.data.personID.isEmpty){
          ToastNotification(Get.overlayContext!).warn('查询不到该员工！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        scanQueryDataOnChanged(keyWord: 'EmploeeId', keyValue: psnRes.data.personID);
        res = await pageChanged(pageIndex: 1, showLoading: false);
        //endregion
        break;
      case 'G':
        //region 员工条码
        String psnNum = list[2];
        var psnRes = await PersonRepository().getFormData('', '', {'PsnNum': psnNum}, 0);
        if (!psnRes.isSuccess){
          ToastNotification(Get.overlayContext!).warn('获取员工数据时出错：${psnRes.message}！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        if (psnRes.data.personID.isEmpty){
          ToastNotification(Get.overlayContext!).warn('查询不到该员工！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        scanQueryDataOnChanged(keyWord: 'EmploeeId', keyValue: psnRes.data.personID);
        res = await pageChanged(pageIndex: 1, showLoading: false);
        //endregion
        break;
      default:
        ToastNotification(Get.overlayContext!).warn('条码错误！');
        isLoading = false;
        ProgressDialogUtil.close();
        return;
    }

    isDataByScan = true;
    isLoading = false;
    update();
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1);
    }
  }

  void scanQueryDataOnChanged({String? keyWord, String? keyValue}) {
    dataListPageConfig.queryData!.removeWhere((key, value) => scanQueryDataList.contains(key));
    if (keyWord != null){
      dataListPageConfig.queryData![keyWord] = keyValue;
    }
  }

  //endregion


  //region onTap

  @override
  void settingOnTap() {
    Get.rootDelegate.toNamed(
      AppRoutes.MES_TASK_SETTING_PAGE,
      parameters: {
        'noPermission': (dataService.isEnableOperatePrivilege
            && objectItem.buttons?['desktopUISettingBtn'] == null) ? '1' : '0',
        'permissionInfo': BaseService.profile.isSystem == true ? '【${objectItem.progid}】【desktopUISettingBtn】' : '',
      },
    );
  }

  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    item as MoTaskModel;
    switch (keyName){
      case '${AppConfig.mesTaskBtn}-${AppConfig.opSop}':
        await getOpSop(item);
        break;
      case '${AppConfig.mesTaskBtn}-${AppConfig.setFinish}':
        await finishMoProcessTask(item);
        break;
      case '${AppConfig.mesTaskBtn}-${AppConfig.shiftTask}':
        await actionFlagShiftWithCreateFI(item);
        break;
      case '${AppConfig.mesTaskBtn}-${AppConfig.suspendTask}':
        await suspendMoProcessTask(item);
        break;
      case '${AppConfig.mesTaskBtn}-${AppConfig.detail}':
        await itemOnDoubleTap(item);
        break;
      case '${AppConfig.mesTaskBtn}-${AppConfig.expanded}':
        taskItemExpandedOnChanged(item);
        break;
    }
  }

  @override
  bool commandBarShowCallback(String keyName, ICloneable item) {
    bool isShow = true;
    item as MoTaskModel;
    switch (keyName){
      case '${AppConfig.mesTaskBtn}-${AppConfig.opSop}':
        isShow = (item.invId ?? '').isNotEmpty && (item.opId ?? '').isNotEmpty;
        break;
      case '${AppConfig.mesTaskBtn}-${AppConfig.setFinish}':
        isShow = (item.sign ?? 0) < MoTaskSign.ysc.sign;
        break;
      case '${AppConfig.mesTaskBtn}-${AppConfig.shiftTask}':
        isShow = (item.sign ?? 0) < MoTaskSign.scz.sign;
        break;
      case '${AppConfig.mesTaskBtn}-${AppConfig.suspendTask}':
        isShow = (item.sign ?? 0) >= MoTaskSign.scz.sign && (item.sign ?? 0) < MoTaskSign.ysc.sign;
        break;
    }
    return isShow;
  }


  ///派工单Item“展开按钮”点击变化
  void taskItemExpandedOnChanged(MoTaskModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }

  Future<void> itemOnTap(MoTaskModel item) async{  }

  Future<void> itemOnDoubleTap(MoTaskModel item) async{
    Get.rootDelegate.toNamed(
        AppRoutes.MES_TASK_DETAIL_MAIN_PAGE,
        arguments: item,
        parameters: {
          'key': item.taskId,
          'keyName': 'task',
          'taskOpenType': '0',
        }
    );
  }

  Future<void> itemOnLongPress(MoTaskModel item) async{  }

  Future<void> itemInvAttach(MoTaskModel item) async{
    if (item.invId == null || item.invId!.isEmpty){
      ToastNotification(Get.overlayContext!).error('该派工单没有产品！');
      return;
    }
    Get.rootDelegate.toNamed(
        AppRoutes.MES_TASK_ITEM_ATTACH_PAGE,
        parameters: {
          'pageTitle': '产品附件-${item.invName}',
          'id': item.invId!,
          'progId': '200025',
          'category': 'attach',
        }
    );
  }

  ///查看工序图纸
  Future<void> getOpSop(MoTaskModel item) async{
    ProgressDialogUtil.showProgressDialog(msg: '正在获取工序数据', completedMsg: '工序数据获取成功！',);
    ///产品id对应的工艺路线列表
    final List<MoRoutingEntryModel> routingByInvIdList = [];
    var res = await MoRoutingRepository().getRoutingByInvId(item.invId ?? '');
    if (res.isSuccess && res.data.entryList.isNotEmpty){
      routingByInvIdList.addAll(res.data.entryList);
    }
    MoRoutingEntryModel? routingEntryModel = routingByInvIdList.firstWhereOrNull((element) => element.opId == item.opId);
    if (routingEntryModel == null || routingEntryModel.routingDId.isEmpty){
      ToastNotification(Get.overlayContext!).warn('无法获取工序图纸！');
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update();
    await ProgressDialogUtil.awaitCompletionDelay();

    Get.rootDelegate.toNamed(
        AppRoutes.MES_TASK_ITEM_ATTACH_PAGE,
        parameters: {
          'pageTitle': '工序图纸-${item.opName}',
          'id': routingEntryModel.routingDId,
          'progId': '660011',
          'category': 'sop',
        }
    );
  }

  ///开工（切单并生成首检报检单）
  Future<void> actionFlagShiftWithCreateFI(MoTaskModel item) async{
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if ((item.sign ?? 0) >= MoTaskSign.scz.sign){
      ToastNotification(Get.overlayContext!).warn('该派工单已经在生产中，不能开工！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认开工？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交开工数据', completedMsg: '数据刷新成功！');
    //region 开工
    var res = await MoProcessTaskRepository().shiftMoProcessTask(item.taskId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('开工失败！${res.message}！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '开工成功，正在刷新数据');
    //endregion
    //region 数据刷新
    if (selectedTaskSignBinary & taskSignList[1].sign == taskSignList[1].sign){
      item.sign = MoTaskSign.scz.sign;
      item.status = MoTaskSign.scz.name;
    }
    else {
      dataList.remove(item);
      total --;
    }
    if (item.deviceId != null && item.deviceId!.isNotEmpty){
      MoTaskModel? task = dataList.firstWhereOrNull((element) => element.deviceId == item.deviceId && element.taskId != item.taskId);
      if (task != null && task.sign != null && task.sign! >= MoTaskSign.scz.sign && task.sign! < MoTaskSign.ysc.sign){
        if (selectedTaskSignBinary & taskSignList[2].sign == taskSignList[2].sign){
          task.sign = MoTaskSign.scz.sign;
          task.status = MoTaskSign.scz.name;
        }
        else {
          dataList.remove(task);
          total --;
        }
      }
    }
    ProgressDialogUtil.update(value: 2);
    //endregion
    update();
    isLoading = false;
  }

  ///设置完工
  Future<void> finishMoProcessTask(MoTaskModel item) async{
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if ((item.sign ?? 0) >= MoTaskSign.ysc.sign){
      ToastNotification(Get.overlayContext!).warn('该派工单已经完工，不能再次设置完工！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认设置完工？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交完工数据', completedMsg: '数据刷新成功！');
    //region 设置完工
    var res = await MoProcessTaskRepository().finishMoProcessTask(item.taskId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('设置完工失败！${res.message}！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '设置完工成功，正在刷新数据');
    //endregion
    //region 数据刷新
    if (selectedTaskSignBinary & taskSignList[2].sign == taskSignList[2].sign){
      item.sign = MoTaskSign.zdwg.sign;
      item.status = MoTaskSign.zdwg.name;
    }
    else {
      dataList.remove(item);
      total --;
    }
    ProgressDialogUtil.update(value: 2);
    //endregion
    update();
    isLoading = false;
  }

  ///挂起
  Future<void> suspendMoProcessTask(MoTaskModel item) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if ((item.sign ?? 0) < MoTaskSign.scz.sign || (item.sign ?? 0) >= MoTaskSign.ysc.sign){
      ToastNotification(Get.overlayContext!).warn('该派工单不在生产中，不能挂起！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showCustomDialog<EditFieldController, String>(
      Get.context!,
      title: '确认挂起？',
      onConfirmName: '确认',
      barrierDismissible: false,
      initialWidth: 550, initialHeight: 260,
      contentPadding: const EdgeInsets.all(12),
      content: EditFieldView(),
      controller: EditFieldController(
        hintContent: '挂起原因',
      ),
    );
    if (dialogRes == null){
      isLoading = false;
      return;
    }
    String desc = dialogRes;
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交挂起数据', completedMsg: '数据刷新成功！');
    //region 挂起
    var res = await MoProcessTaskRepository().suspendMoProcessTask(item.taskId, desc);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('挂起失败！${res.message}！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '挂起成功，正在刷新数据');
    //endregion

    //region 数据刷新
    if (selectedTaskSignBinary & taskSignList[0].sign == taskSignList[0].sign){
      item.sign = MoTaskSign.ygq.sign;
      item.status = MoTaskSign.ygq.name;
    }
    else {
      dataList.remove(item);
      total --;
    }
    ProgressDialogUtil.update(value: 2);
    //endregion
    update();
    isLoading = false;
  }

  //endregion


  @override
  void onClose() {
    super.onClose();
  }

}