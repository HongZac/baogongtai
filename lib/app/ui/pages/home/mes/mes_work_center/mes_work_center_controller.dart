import 'dart:async';
import 'dart:convert';

import 'package:basement/basement.dart';
import 'package:basement/item_model.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/model/web_socket_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/serial_com_service/mixin/serial_port_getx_listener.dart';
import 'package:desktop/app/service/serial_com_service/serial_port_data_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_controller.dart';
import 'package:desktop/app/ui/pages/edit_field/edit_field_view.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/order_date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/task_date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/order_keyword_search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/task_keyword_search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/order_sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/task_sign_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/web_socket_stream_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/verification_loaded/verification_loaded_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/verification_loaded/verification_loaded_view.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/create_inspection/create_inspection_controller.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/create_inspection/create_inspection_view.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 加工中心（可选择派工单报工 OR 任务单报工）
class MesWorkCenterController
    extends BaseFormController
    with SignFilterInterface, TaskSignFilterInterface, OrderSignFilterInterface,
        DateFilterInterface, TaskDateFilterInterface, OrderDateFilterInterface,
        SearchInterface, TaskKeywordSearchInterface, OrderKeywordSearchInterface,
        SerialPortGetXListenerMixin<MesWorkCenterController>, ScanInterface<MesWorkCenterController>,
        WebSocketStreamInterface,
        InfoFormInterface,
        CommandBarInterface,
        InterfaceUtil {

  //region 加工中心
  ///加工中心列表
  final List<MoWorkCenterModel> workCenterList = [];
  ///加工中心实时监控列表-过滤后的数组
  final List<MoWorkCenterModel> workCenterFilterList = [];
  ///选中的加工中心Id
  String selectedWorkCenterId = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_SUBMIT_WC_ID_KEY) ?? '';
  final ScrollController workCenterScrollController = ScrollController();
  //endregion

  //region 加工中心搜索
  ///加工中心搜索 加工中心编号搜索框按制器
  final TextEditingController wcSearchTC = TextEditingController();
  final FocusNode wcSearchFN = FocusNode();
  ///加工中心搜索 搜索时启用时间防抖，超过一定时间不输入才正式搜索数据
  final Debounce _wcDebounce = Debounce(Duration(milliseconds: 1500));
  //endregion

  //region 单据类型列表（单选）
  ///是否显示单据类型选择标签
  bool isShowCategory = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_IS_SHOW_CATEGORY_KEY) ?? AppConfig.isShowCategory;
  ///单据类型列表选中项的 Sign（任务单 610001 OR 派工单 650011）
  int _selectedCategorySign = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_CATEGORY_SELECTED_KEY) ?? AppConfig.workCenterCategorySelectedIndex;
  ///单据类型列表选中项的 Sign（任务单 610001 OR 派工单 650011）
  int get selectedCategorySign => _selectedCategorySign;
  ///单据类型列表选中项的 Sign（任务单 610001 OR 派工单 650011）
  set selectedCategorySign(int sign){
    _selectedCategorySign = sign;
    _selectedCategoryTitle = categoryList.firstWhereOrNull((element) => element.sign == _selectedCategorySign)?.title ?? '（请选择）';
  }
  late String _selectedCategoryTitle = categoryList.firstWhereOrNull((element) => element.sign == _selectedCategorySign)?.title ?? '（请选择）';
  String get selectedCategoryTitle => _selectedCategoryTitle;
  ///单据类型列表
  late final List<MoSignModel> categoryList = [
    MoSignModel(title: '任务单', content: '任务单', sign: 610001,),
    MoSignModel(title: '派工单', content: '派工单', sign: 650011,),
  ];
  //endregion

  //region 任务单
  ///任务单列表
  final List<MoOpOrderModel> orderList = [];
  late final PageConfig orderPageConfig = PageConfig(
    rows: 7,
    sidx: 'BillDate',
    queryData: {
      'progid': 610001,
      'ExtOpFlag': 0, ///ExtOpFlag=0 去除委外
    }
  );
  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> orderListInfoFormListMap = {};
  ///任务单列表页面显示的按钮组列表
  final List<CommandBarBtnModel> orderCommandBarList = [];
  //endregion

  //region 派工单
  ///派工单列表
  final List<MoTaskModel> taskList = [];
  late final PageConfig taskPageConfig = PageConfig(
    rows: 7,
    sidx: 'TaskDate',
    queryData: {
      'progid': 650011,
    }
  );
  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> taskListInfoFormListMap = {};
  ///派工单列表页面显示的按钮组列表
  final List<CommandBarBtnModel> taskCommandBarList = [];
  //endregion

  final ScrollController listScrollController = ScrollController();
  ///列表总数
  int total = 0;
  ///总页码
  int totalPage = 0;
  ///当前页码
  int nowPage = 0;

  @override
  EditFormItem get objectItem => selectedCategorySign == 610001
      ? orderObjectItem
      : selectedCategorySign == 650011
      ? taskObjectItem
      : EditFormItem();
  EditFormItem taskObjectItem = EditFormItem();
  EditFormItem orderObjectItem = EditFormItem();

  int? get mxProgid => selectedCategorySign == 610001
      ? int.tryParse(orderObjectItem.commandLineMap['mxprogid'] ?? '')
      : selectedCategorySign == 650011
      ? int.tryParse(taskObjectItem.commandLineMap['mxprogid'] ?? '')
      : null;

  @override
  get signList => selectedCategorySign == 610001
      ? List.unmodifiable(orderSignList)
      : selectedCategorySign == 650011
      ? List.unmodifiable(taskSignList)
      : [];
  @override
  int get selectedSignBinary => selectedCategorySign == 610001
      ? selectedOrderSignBinary
      : selectedCategorySign == 650011
      ? selectedTaskSignBinary
      : -1;

  @override
  int get searchTypeIndex => selectedCategorySign == 610001
      ? orderSearchTypeIndex
      : selectedCategorySign == 650011
      ? taskSearchTypeIndex
      : -1;
  @override
  List<ChoiceChipModel> get searchTypeList => selectedCategorySign == 610001
      ? List.unmodifiable(orderSearchTypeList)
      : selectedCategorySign == 650011
      ? List.unmodifiable(taskSearchTypeList)
      : [];
  @override
  List<String> get searchQueryDataList => selectedCategorySign == 610001
      ? List.unmodifiable(orderSearchQueryDataList)
      : selectedCategorySign == 650011
      ? List.unmodifiable(taskSearchQueryDataList)
      : [];

  @override
  int get dateSearchTypeIndex => selectedCategorySign == 610001
      ? orderDateSearchTypeIndex
      : selectedCategorySign == 650011
      ? taskDateSearchTypeIndex
      : -1;
  @override
  List<ChoiceChipModel> get dateSearchTypeList => selectedCategorySign == 610001
      ? List.unmodifiable(orderDateSearchTypeList)
      : selectedCategorySign == 650011
      ? List.unmodifiable(taskDateSearchTypeList)
      : [];
  @override
  List<String> get dateSearchQueryDataList => selectedCategorySign == 610001
      ? List.unmodifiable(orderDateSearchQueryDataList)
      : selectedCategorySign == 650011
      ? List.unmodifiable(taskDateSearchQueryDataList)
      : [];


  MesWorkCenterController({
    super.progId = 660022,
  });


  @override
  void onInit() {
    super.onInit();

    //region
    isShowSignFilter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_IS_SHOW_SIGN_FILTER_KEY) ?? AppConfig.isShowSignFilter;
    isSignChipMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_IS_SIGN_CHIP_MULTI_KEY)?? AppConfig.isSignChipMulti;
    selectedTaskSignBinary = selectedOrderSignBinary = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_SIGN_SELECTED_KEY) ?? AppConfig.binaryForSignSelected;

    isShowDatePicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_IS_SHOW_DATE_PICKER_KEY) ?? AppConfig.isShowDatePicker;
    taskDateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_TASK_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;
    orderDateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_ORDER_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;
    String datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_DATE_PICKER_VALUE_MAP_KEY) ?? '';
    datePickerValueMap = getDatePickerValueMapByStorage(datePickerValueStr);

    isShowSearchInputBox = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_IS_SHOW_SEARCH_INPUT_BOX_KEY) ?? AppConfig.isShowSearchInputBox;
    taskSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_TASK_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;
    orderSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_ORDER_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;

    scanQueryDataList.addAll(['MoOrderId', 'MoOpId', 'keyValue', 'EmploeeId']);

    List<dynamic> orderListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_INFO_FORM_LIST_KEY) ?? [];
    orderListInfoFormListMap.clear();
    orderListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                orderListInfoFormMapList,
                AppConfig.mesOrderListInfoFormList
            )
        )
    );

    List<dynamic> orderCommandBarMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_COMMAND_BAR_LIST_KEY) ?? [];
    orderCommandBarList.clear();
    orderCommandBarList.addAll(
        getCommandBarListByStorage(
            orderCommandBarMapList,
            AppConfig.mesOrderCommandBarList
        )
    );

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


    orderPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
    taskPageConfig.rows = orderPageConfig.rows;
    signQueryDataOnChanged();
    dateQueryDataOnChanged();
  }

  Future<void> onReady() async {
    await super.onReady();

    wcSearchFN.addListener(() async {
      if (rootCtl.isKeyboardOpenAfterClickTC && searchFN.hasFocus && !kIsWeb && GetPlatform.isWindows){
        await rootCtl.openKeyboard();
      }
      update();
    });
  }

  @override
  Future<bool> initializeForm() async {
    if (categoryList.firstWhereOrNull((element) => element.sign == _selectedCategorySign) == null && categoryList.isNotEmpty){
      selectedCategorySign = categoryList[0].sign;
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_CATEGORY_SELECTED_KEY, selectedCategorySign);
    }

    await getOrderAndTaskObjectItem();
    await getWorkCenterList();
    getWCPageConfig(selectedWorkCenterId);
    await pageChanged(pageIndex: 1, showLoading: false);
    return true;
  }

  //region 获取加工中心

  ///获取加工中心
  Future<void> getWorkCenterList() async {
    PageConfig pageConfig = PageConfig(
      page: 1,
      rows: 1000,
      queryData: {},
    );
    var res = await MoWorkCenterRepository().getPageList(pageConfig);
    workCenterList.clear();
    workCenterList.addAll(res.rows);
    getFilterOfWorkCenterList();
  }

  void getFilterOfWorkCenterList() {
    ///车间id
    var _hideDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_DEP_ID_DISPLAY_KEY) ?? [];
    ///加工中心id
    var _hideWorkCenterIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_WORK_CENTER_ID_DISPLAY_KEY) ?? [];
    workCenterList.forEach((element) {
      element.isVisibleOfDep = true;
      element.isVisibleOfWorkCenterId = true;
      if (_hideDepIdList.contains(element.depId)){
        element.isVisibleOfDep = false;
      }
      if (_hideWorkCenterIdList.contains(element.id)){
        element.isVisibleOfWorkCenterId = false;
      }
    });
    List<MoWorkCenterModel> workCenterFilterList = workCenterList.where(
            (element) => element.isVisibleOfDep && element.isVisibleOfWorkCenterId).toList();
    this.workCenterFilterList.clear();
    this.workCenterFilterList.addAll(workCenterFilterList);
    MoWorkCenterModel? selectedItem = this.workCenterFilterList.firstWhereOrNull((element) => element.id == selectedWorkCenterId);
    if (selectedItem != null){
      selectedItem.isChoice = true;
    }
    else {
      selectedWorkCenterId = '';
    }
  }

  //endregion

  //region 获取派工单列表、任务单列表

  ///获取任务单列表
  Future<PageResult<MoOpOrderModel>> getOrderList(PageConfig pageConfig) async{
    if (searchTC.text.isNotEmpty){
      switch (orderSearchTypeList[orderSearchTypeIndex].keyName){
        case 'orderSN':
          //region 序列号搜索，读取列表数据前，需要判断序列号是否可用
          var snRes = await MoOrderSNRepository().getModel(searchTC.text);
          if (!snRes.isSuccess){
            ToastNotification(Get.overlayContext!).error('获取序列号数据时出错：${snRes.message}！');
            return PageResult();
          }
          if (snRes.data.id.isEmpty){
            ToastNotification(Get.overlayContext!).error('查询不到该序列号！');
            return PageResult();
          }
          if ((snRes.data.moOrderId ?? '').isEmpty){
            ToastNotification(Get.overlayContext!).error('该序列号还未被分配任务单！');
            return PageResult();
          }
          if (snRes.data.enableMark != 1){
            ToastNotification(Get.overlayContext!).error('该序列号已失效！');
            return PageResult();
          }
          //endregion
          break;
      }
    }

    var res = await MoOrderRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取检验单列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }

  ///获取派工单列表
  Future<PageResult<MoTaskModel>> getTaskList(PageConfig pageConfig) async{
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

    if (kDebugMode){
      ///后台还没更新，派工单搜索缺少 wcId 的条件
      pageConfig.queryData!.remove('wcId');
    }
    var res = await MoTaskRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取检验单列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }

  ///获取单据列表（翻页）
  Future<bool> pageChanged({int pageIndex = 1, bool showLoading = true}) async{
    if(showLoading){
      ProgressDialogUtil.showProgressDialog();
    }
    bool isSuccess = false;
    switch (selectedCategorySign){
      case 610001: ///任务单
        orderPageConfig.page = pageIndex;
        var res = await getOrderList(orderPageConfig);
        orderList.clear();
        orderList.addAll(res.rows);
        total = res.records ?? 0;
        totalPage = res.total ?? 0;
        nowPage = res.page ?? 0;
        isSuccess = res.isSuccess;
        break;
      case 650011: ///派工单
        if (selectedWorkCenterId.isNotEmpty){
          taskPageConfig.page = pageIndex;
          var res = await getTaskList(taskPageConfig);
          taskList.clear();
          taskList.addAll(res.rows);
          total = res.records ?? 0;
          totalPage = res.total ?? 0;
          nowPage = res.page ?? 0;
          isSuccess = res.isSuccess;
        }
        break;
    }

    if (!isSuccess && showLoading){
      ProgressDialogUtil.close();
      return false;
    }
    else if (showLoading){
      ProgressDialogUtil.update(value: 1);
    }
    return true;
  }

  void getWCPageConfig(String wcId) {
    orderPageConfig.queryData!['wcId'] = wcId;
    taskPageConfig.queryData!['wcId'] = wcId;
  }

  //endregion

  ///获取系统对象
  Future<void> getOrderAndTaskObjectItem() async {
    switch (selectedCategorySign){
      case 610001:
        //region 任务单
        if (orderObjectItem.progid == null){
          var orderRes = await FormRepository().getFormSystem(610001);
          if (!orderRes.isSuccess) {
            ToastNotification(Get.overlayContext!).error('获取 610001 系统对象时出错：${orderRes.message}');
            return;
          }
          orderObjectItem = orderRes.data;
        }
        //endregion
        break;
      case 650011:
        //region 派工单
        if (taskObjectItem.progid == null){
          var taskRes = await FormRepository().getFormSystem(650011);
          if (!taskRes.isSuccess) {
            ToastNotification(Get.overlayContext!).error('获取 650011 系统对象时出错：${taskRes.message}');
            return;
          }
          taskObjectItem = taskRes.data;
        }
        //endregion
        break;
    }
  }


  @override
  Future<void> onData(WebSocketModel webSocketModel) async {
    switch (webSocketModel.name){
      case 'MoOrderEntity':
      case 'MoOrderModel':
        if (selectedCategorySign == 610001){ ///任务单
          var data = json.decode(webSocketModel.data);
          if (data != null && orderList.isNotEmpty){
            MoOpOrderModel? orderModel = orderList.firstWhereOrNull((element) => element.moOrderId == data['moOrderId']);
            if (orderModel != null && orderModel.moOrderId.isNotEmpty){
              orderModel.sign = data['sign'];
              orderModel.status = data['status'];
              orderModel.submitQty = data['submitQty'];
              orderModel.qualifiedQty = data['qualifiedQty'];
              orderModel.startDate = DateTime.tryParse(data['startDate'].toString());
              update();
            }
          }
        }
        break;
    }
  }


  //region OnChanged

  ///单据列表区域，类型标签选择变化
  Future<void> categoryOnChanged(MoSignModel item) async {
    if (item.sign == selectedCategorySign){
      return;
    }
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;

    selectedCategorySign = item.sign;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_CATEGORY_SELECTED_KEY, selectedCategorySign);
    await categorySaveOnChanged();
    await pageChanged();
    update();

    isLoading = false;
  }
  Future<void> categorySaveOnChanged() async {
    //region 重置扫描
    await super.resetScan();
    scanQueryDataOnChanged();
    //endregion
    //region 重置搜索
    searchFN.unfocus();
    searchTC.text = '';
    searchQueryDataOnChanged();
    isSearchWidgetOpen = false;
    //endregion
    await getOrderAndTaskObjectItem();
  }

  @override
  Future<void> signOnChanged(int sign) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    await super.signOnChanged(sign);
    selectedTaskSignBinary = selectedOrderSignBinary;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_SIGN_SELECTED_KEY, selectedTaskSignBinary);
    signQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void signQueryDataOnChanged() {
    List<String> tStatusList = [];
    for (var element in taskSignList) {
      if (selectedTaskSignBinary & element.sign == element.sign){
        tStatusList.add(element.content);
      }
    }
    String tStatus = tStatusList.join(',');
    taskPageConfig.queryData!['status'] = tStatus;

    List<String> oStatusList = [];
    bool oIsNoAssign = false;
    for (var element in orderSignList) {
      if (selectedOrderSignBinary & element.sign == element.sign){
        if (element.sign == 8){
          oIsNoAssign = true;
        }
        else {
          oStatusList.add(element.content);
        }
      }
    }
    String oStatus = oStatusList.join(',');
    orderPageConfig.queryData!['status'] = oStatus;
    orderPageConfig.queryData!['NoAssign'] = oIsNoAssign ? 1 : 0;
  }

  @override
  Future<void> dateSearchTypeOnChanged(ChoiceChipModel item, int index) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    switch (selectedCategorySign){
      case 610001:
        //region 任务单
        if (index == orderDateSearchTypeIndex){
          isLoading = false;
          return;
        }
        orderDateSearchTypeIndex = index;
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_ORDER_DATE_SEARCH_TYPE_INDEX_KEY, orderDateSearchTypeIndex);
        //endregion
        break;
      case 650011:
        //region 派工单
        if (index == taskDateSearchTypeIndex){
          isLoading = false;
          return;
        }
        taskDateSearchTypeIndex = index;
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_TASK_DATE_SEARCH_TYPE_INDEX_KEY, taskDateSearchTypeIndex);
        //endregion
        break;
    }
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
    taskPageConfig.queryData!.removeWhere((key, value) => taskDateSearchQueryDataList.contains(key));
    orderPageConfig.queryData!.removeWhere((key, value) => orderDateSearchQueryDataList.contains(key));
    if (startDate != null && endDate != null){
      String orderKeyWord = orderDateSearchTypeList[orderDateSearchTypeIndex].content;
      List<String> orderKeywordList = orderKeyWord.split(',');
      if (orderKeywordList.length == 2){
        orderPageConfig.queryData![orderKeywordList[0]] = startDateStrWithNoTime;
        orderPageConfig.queryData![orderKeywordList[1]] = endDateStrWithNoTime;
      }
      String taskKeyWord = taskDateSearchTypeList[taskDateSearchTypeIndex].content;
      List<String> taskKeywordList = taskKeyWord.split(',');
      if (taskKeywordList.length == 2){
        taskPageConfig.queryData![taskKeywordList[0]] = startDateStrWithNoTime;
        taskPageConfig.queryData![taskKeywordList[1]] = endDateStrWithNoTime;
      }
    }
  }

  ///任务单Item“展开按钮”点击变化
  void orderItemExpandedOnChanged(MoOpOrderModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }

  ///派工单Item“展开按钮”点击变化
  void taskItemExpandedOnChanged(MoTaskModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }

  //endregion
  
  
  //region 加工中心搜索
  
  ///加工中心搜索框输入变化
  Future<void> wcSearchTCOnSearch() async {
    _wcDebounce(() async{
      wcSearchFN.unfocus();
      await wcLineCodeSearch();
      update();
    });
  }

  ///加工中心搜索框清空
  Future<void> wcSearchTCClear() async{
    wcSearchTC.text = '';
    await wcLineCodeSearch();
    wcSearchFN.unfocus();
    update();
  }

  ///根据加工中心编号搜索
  Future<void> wcLineCodeSearch() async{
    ProgressDialogUtil.showProgressDialog();
    List<MoWorkCenterModel> workCenterFilterList = workCenterList.where(
            (element) => element.isVisibleOfDep && element.isVisibleOfWorkCenterId 
                && (element.lineCode ?? '').contains(wcSearchTC.text)).toList();
    this.workCenterFilterList.clear();
    this.workCenterFilterList.addAll(workCenterFilterList);
    ProgressDialogUtil.update(value: 1, msg: '查询成功！');
  }
  
  //endregion


  //region 单据列表搜索

  @override
  Future<void> searchTypeOnChanged(ChoiceChipModel item, int index) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    switch (selectedCategorySign){
      case 610001:
        //region 任务单
        if (index == orderSearchTypeIndex){
          isLoading = false;
          return;
        }
        orderSearchTypeIndex = index;
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_ORDER_SEARCH_TYPE_INDEX_KEY, orderSearchTypeIndex);
        //endregion
        break;
      case 650011:
        //region 派工单
        if (index == taskSearchTypeIndex){
          isLoading = false;
          return;
        }
        taskSearchTypeIndex = index;
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_TASK_SEARCH_TYPE_INDEX_KEY, taskSearchTypeIndex);
        //endregion
        break;
    }
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

  void searchQueryDataOnChanged() {
    orderPageConfig.queryData!.removeWhere((key, value) => orderSearchQueryDataList.contains(key));
    taskPageConfig.queryData!.removeWhere((key, value) => taskSearchQueryDataList.contains(key));
    if (searchTC.text.isNotEmpty) {
      switch (selectedCategorySign){
        case 610001:
          //region 任务单
          String keyWord = orderSearchTypeList[orderSearchTypeIndex].content;
          orderPageConfig.queryData![keyWord] = searchTC.text;
          //endregion
          break;
        case 650011:
          //region 派工单
          String keyWord = taskSearchTypeList[taskSearchTypeIndex].content;
          taskPageConfig.queryData![keyWord] = searchTC.text;
          //endregion
          break;
      }
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
  Future<void> resetScan() async{
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
      TipsUtils.showTip(
        msg: '条码错误，请检查设置的默认条码格式！',
        toastType: ToastType.warn,
      );
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    switch (list[1]){
      case 'F':
        //region 生产任务单条码 610001；生产派工单条码 650011
        switch (selectedCategorySign){
          case 610001:
            //region 任务单
            if (list.length == 4){
              if (list[2] == '610001'){
                scanQueryDataOnChanged(keyWord: 'MoOrderId', keyValue: list[3]);
                res = await pageChanged(pageIndex: 1, showLoading: false);
              }
              else {
                TipsUtils.showTip(
                  msg: '条码错误！',
                  toastType: ToastType.warn,
                );
                isLoading = false;
                ProgressDialogUtil.close();
                return;
              }
            }
            else {
              TipsUtils.showTip(
                msg: '条码错误！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            //endregion
            break;
          case 650011:
            //region 派工单
            if (list.length == 4){
              if (list[2] == '610001'){
                scanQueryDataOnChanged(keyWord: 'MoOrderId', keyValue: list[3]);
                res = await pageChanged(pageIndex: 1, showLoading: false);
              }
              else if (list[2] == '650011'){
                scanQueryDataOnChanged(keyWord: 'keyValue', keyValue: list[3]);
                res = await pageChanged(pageIndex: 1, showLoading: false);
              }
              else {
                TipsUtils.showTip(
                  msg: '条码错误！',
                  toastType: ToastType.warn,
                );
                isLoading = false;
                ProgressDialogUtil.close();
                return;
              }
            }
            else {
              TipsUtils.showTip(
                msg: '条码错误！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            //endregion
            break;
        }
        //endregion
        break;
      case 'T':
        //region 工序条码 610001
        switch (selectedCategorySign) {
          case 610001:
            //region 任务单
            if (list.length == 4){
              if (list[2] == '610001'){
                var res1 = await MoWorkBillEntryRepository().getMoWorkBillEntry(list[3]);
                if (!res1.isSuccess){
                  TipsUtils.showTip(
                    msg: '获取任务单信息和工序信息时出错：${res1.message}',
                    toastType: ToastType.error,
                  );
                  isLoading = false;
                  ProgressDialogUtil.close();
                  return;
                }
                scanQueryDataOnChanged(keyWord: 'MoOrderId', keyValue: res1.data.objectId);
                res = await pageChanged(pageIndex: 1, showLoading: false);
              }
              else {
                TipsUtils.showTip(
                  msg: '条码错误！',
                  toastType: ToastType.warn,
                );
                isLoading = false;
                ProgressDialogUtil.close();
                return;
              }
            }
            else {
              TipsUtils.showTip(
                msg: '条码错误！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            //endregion
            break;
          case 650011:
            //region 派工单
            if (list.length == 4){
              if (list[2] == '610001'){
                scanQueryDataOnChanged(keyWord: 'MoOpId', keyValue: list[3]);
                res = await pageChanged(pageIndex: 1, showLoading: false);
              }
              else {
                TipsUtils.showTip(
                  msg: '条码错误！',
                  toastType: ToastType.warn,
                );
                isLoading = false;
                ProgressDialogUtil.close();
                return;
              }
            }
            else {
              TipsUtils.showTip(
                msg: '条码错误！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            //endregion
            break;
        }
        //endregion
        break;
      case 'IP':
        //region 员工卡号
        switch (selectedCategorySign){
          case 610001:
            //region 任务单
            //endregion
            break;
          case 650011:
            //region 派工单
            String idCode = list[2];
            var psnRes = await PersonRepository().getFormData('', '', {'IdCode': idCode}, 0);
            if (!psnRes.isSuccess){
              TipsUtils.showTip(
                msg: '获取员工数据时出错：${psnRes.message}！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (psnRes.data.id.isEmpty){
              TipsUtils.showTip(
                msg: '查询不到该员工！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            scanQueryDataOnChanged(keyWord: 'EmploeeId', keyValue: psnRes.data.personID);
            res = await pageChanged(pageIndex: 1, showLoading: false);
            //endregion
            break;
        }
        //endregion
        break;
      case 'G':
        //region 员工条码
        switch (selectedCategorySign) {
          case 610001:
            //region 任务单
            //endregion
            break;
          case 650011:
            //region 派工单
            String psnNum = list[2];
            var psnRes = await PersonRepository().getFormData('', '', {'PsnNum': psnNum}, 0);
            if (!psnRes.isSuccess){
              TipsUtils.showTip(
                msg: '获取员工数据时出错：${psnRes.message}！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (psnRes.data.id.isEmpty){
              TipsUtils.showTip(
                msg: '查询不到该员工！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            scanQueryDataOnChanged(keyWord: 'EmploeeId', keyValue: psnRes.data.personID);
            res = await pageChanged(pageIndex: 1, showLoading: false);
            //endregion
            break;
        }
        //endregion
        break;
      case 'X':
        //region 产品序列号
        switch (selectedCategorySign){
          case 610001:
            //region 任务单
            String string = list[2];
            var res1 = await MoOrderSNRepository().getModel(string);
            if (!res1.isSuccess){
              TipsUtils.showTip(
                msg: '获取序列号数据时出错：${res1.message}！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (res1.data.id.isEmpty){
              TipsUtils.showTip(
                msg: '查询不到该序列号！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (res1.data.moOrderId == null || res1.data.moOrderId!.isEmpty){
              TipsUtils.showTip(
                msg: '该序列号未被分配到任务单！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            if (res1.data.enableMark != 1){
              TipsUtils.showTip(
                msg: '该序列号已失效！',
                toastType: ToastType.warn,
              );
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
            orderPageConfig.queryData!['MoOrderId'] = res1.data.moOrderId;
            res = await pageChanged(pageIndex: 1, showLoading: false);
            if (res){
              orderList.forEach((element) {
                element.orderSN = string;
              });
            }
            //endregion
            break;
          case 650011:
            //region 派工单
            //endregion
            break;
        }
        //endregion
        break;
      default:
        TipsUtils.showTip(
          msg: '条码错误！',
          toastType: ToastType.warn,
        );
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
    taskPageConfig.queryData!.removeWhere((key, value) => scanQueryDataList.contains(key));
    orderPageConfig.queryData!.removeWhere((key, value) => scanQueryDataList.contains(key));
    if (keyWord != null){
      switch (selectedCategorySign){
        case 610001:
          //region 任务单
          orderPageConfig.queryData![keyWord] = keyValue;
          //endregion
          break;
        case 650011:
          //region 派工单
          taskPageConfig.queryData![keyWord] = keyValue;
          //endregion
          break;
      }
    }
  }

  //endregion


  //region OnTap

  @override
  void settingOnTap(){
    Get.rootDelegate.toNamed(
      AppRoutes.MES_WORK_CENTER_SETTING_PAGE,
      parameters: {
        'noPermission': (dataService.isEnableOperatePrivilege
            && objectItem.buttons?['desktopUISettingBtn'] == null) ? '1' : '0',
        'permissionInfo': BaseService.profile.isSystem == true ? '【${objectItem.progid}】【desktopUISettingBtn】' : '',
      },
    );
  }

  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    switch (selectedCategorySign){
      case 610001:
        //region 任务单
        item as MoOpOrderModel;
        switch (keyName){
          case '${AppConfig.mesOrderBtn}-${AppConfig.invImage}':
            await getInvImage(item);
            break;
          case '${AppConfig.mesOrderBtn}-${AppConfig.verificationLoaded}':
            await verificationLoaded(item);
            break;
          case '${AppConfig.mesOrderBtn}-${AppConfig.createFirstInspection}':
            await createFirstInspection(item);
            break;
          case '${AppConfig.mesOrderBtn}-${AppConfig.setFinish}':
            await orderFinishMoProcessTask(item);
            break;
          case '${AppConfig.mesOrderBtn}-${AppConfig.shiftTask}':
            await orderSetCheckedSign(item, 16);
            break;
          case '${AppConfig.mesOrderBtn}-${AppConfig.suspendTask}':
            await orderSetCheckedSign(item, 8);
            break;
          case '${AppConfig.mesOrderBtn}-${AppConfig.detail}':
            await itemOnDoubleTap(item);
            break;
          case '${AppConfig.mesOrderBtn}-${AppConfig.expanded}':
            orderItemExpandedOnChanged(item);
            break;
        }
        //endregion
        break;
      case 650011:
        //region 派工单
        item as MoTaskModel;
        switch (keyName){
          case '${AppConfig.mesTaskBtn}-${AppConfig.opSop}':
            await getOpAttach(item);
            break;
          case '${AppConfig.mesTaskBtn}-${AppConfig.setFinish}':
            await taskFinishMoProcessTask(item);
            break;
          case '${AppConfig.mesTaskBtn}-${AppConfig.shiftTask}':
            await taskActionFlagShiftWithCreateFI(item);
            break;
          case '${AppConfig.mesTaskBtn}-${AppConfig.suspendTask}':
            await taskSuspendMoProcessTask(item);
            break;
          case '${AppConfig.mesTaskBtn}-${AppConfig.detail}':
            await itemOnDoubleTap(item);
            break;
          case '${AppConfig.mesTaskBtn}-${AppConfig.expanded}':
            taskItemExpandedOnChanged(item);
            break;
        }
        //endregion
        break;
    }
  }

  @override
  bool commandBarShowCallback(String keyName, ICloneable item) {
    bool isShow = true;
    switch (selectedCategorySign){
      case 610001:
        //region 任务单
        item as MoOpOrderModel;
        switch (keyName){
          case '${AppConfig.mesOrderBtn}-${AppConfig.invImage}':
            isShow = (item.productId ?? '').isNotEmpty;
            break;
          case '${AppConfig.mesOrderBtn}-${AppConfig.createFirstInspection}':
            isShow = (item.sign ?? 0) < MoOpOrderSign.ysc.sign;
            break;
          case '${AppConfig.mesOrderBtn}-${AppConfig.setFinish}':
            isShow = (item.sign ?? 0) < MoOpOrderSign.ysc.sign;
            break;
          case '${AppConfig.mesOrderBtn}-${AppConfig.shiftTask}':
            isShow = (item.sign ?? 0) < MoOpOrderSign.scz.sign;
            break;
          case '${AppConfig.mesOrderBtn}-${AppConfig.suspendTask}':
            isShow = (item.sign ?? 0) >= MoOpOrderSign.scz.sign && (item.sign ?? 0) < MoOpOrderSign.ysc.sign;
            break;
        }
        //endregion
        break;
      case 650011:
        //region 派工单
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
        //endregion
    }
    return isShow;
  }

  ///加工中心 Item 点击变化
  Future<void> wcItemOnTap(MoWorkCenterModel item) async{
    if (item.id == selectedWorkCenterId){
      return;
    }
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;

    for (var element in workCenterList) {
      element.isChoice = false;
    }
    item.isChoice = true;
    selectedWorkCenterId = item.id;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_WORK_CENTER_SUBMIT_WC_ID_KEY, selectedWorkCenterId);
    getWCPageConfig(selectedWorkCenterId);
    if (selectedCategorySign == 650011){
      ///任务单列表的数据不受加工中心影响
      await pageChanged();
    }
    update();

    isLoading = false;
  }

  ///加工中心分配
  Future<void> wcAllocate(MoWorkCenterModel item) async {
    Get.rootDelegate.toNamed(
        AppRoutes.MES_WORK_CENTER_ALLOCATE_DETAIL_PAGE,
        parameters: {
          'progId': progId.toString(),
          'workCenterId': item.id,
        }
    );
    /*await DialogUtils.showCustomDialog<WorkCenterAllocateController, bool>(
      Get.context!, title: '加工中心分配',
      barrierDismissible: false,
      onConfirmName: '确认',
      initialWidth: 1024, initialHeight: 900,
      contentPadding: const EdgeInsets.all(12),
      content: WorkCenterAllocateView(),
      controller: WorkCenterAllocateController(
        workCenterId: item.id,
        workCenterProgId: progId,
      ),
    );*/
  }

  Future<void> itemOnTap(dynamic item) async{  }

  Future<void> itemOnDoubleTap(dynamic item) async{
    if (item is MoOpOrderModel){
      Get.rootDelegate.toNamed(
          AppRoutes.MES_WORK_CENTER_ORDER_DETAIL_MAIN_PAGE,
          arguments: item,
          parameters: {
            'key': item.moOrderId,
            'keyName': 'workCenterTask',
            'orderOpenType': '2',
            'workCenterId': selectedWorkCenterId,
          }
      );
    }
    else if (item is MoTaskModel){
      Get.rootDelegate.toNamed(
        AppRoutes.MES_WORK_CENTER_TASK_DETAIL_MAIN_PAGE,
        arguments: item,
        parameters: {
          'key': item.taskId,
          'keyName': 'workCenterTask',
          'taskOpenType': '2',
        }
      );
    }
  }

  Future<void> itemOnLongPress(dynamic item) async{  }

  ///产品附件（图纸）查看
  Future<void> getInvAttach(dynamic item) async{
    String invId = '';
    String invName = '';
    if (item is MoOpOrderModel){
      invId = item.productId ?? '';
      invName = item.productName ?? '';
    }
    else if (item is MoTaskModel){
      invId = item.invId ?? '';
      invName = item.invName ?? '';
    }
    if (invId.isEmpty){
      ToastNotification(Get.overlayContext!).error('该单据没有产品！');
      return;
    }
    Get.rootDelegate.toNamed(
      AppRoutes.MES_WORK_CENTER_ATTACH_PAGE,
      parameters: {
        'pageTitle': '产品附件-${invName}',
        'id': invId,
        'progId': '200025',
        'category': 'attach',
      }
    );
  }

  ///产品图片查看
  Future<void> getInvImage(dynamic item) async{
    String invId = '';
    String invName = '';
    if (item is MoOpOrderModel){
      invId = item.productId ?? '';
      invName = item.productName ?? '';
    }
    else if (item is MoTaskModel){
      invId = item.invId ?? '';
      invName = item.invName ?? '';
    }
    if (invId.isEmpty){
      ToastNotification(Get.overlayContext!).error('该单据没有产品！');
      return;
    }
    Get.rootDelegate.toNamed(
      AppRoutes.MES_WORK_CENTER_ATTACH_PAGE,
      parameters: {
        'pageTitle': '产品图片-${invName}',
        'id': invId,
        'progId': '200025',
        'category': 'image',
      }
    );
  }

  ///任务单-上料验证
  Future<void> verificationLoaded(MoOpOrderModel item) async {
    await DialogUtils.showCustomDialog<VerificationLoadedController, bool>(
      Get.context!, title: '上料验证-${item.billCode ?? ''}',
      barrierDismissible: false,
      onCancelName: '关闭',
      isNeedConfirmBtn: false,
      isMaximize: true,
      contentPadding: const EdgeInsets.all(12),
      content: VerificationLoadedView(),
      controller: VerificationLoadedController(
          orderModel: item
      ),
    );
  }

  ///任务单生成首检报检单
  Future<void> createFirstInspection(MoOpOrderModel item) async {
    await DialogUtils.showCustomDialog<CreateInspectionController, String>(
      Get.context!,
      title: '任务单生成首检报检单',
      initialWidth: 1024, initialHeight: 900,
      contentPadding: const EdgeInsets.all(0),
      content: CreateInspectionView(),
      controller: CreateInspectionController(
        category: IPQCCategory.sj.category,
        sourceProgid: item.progid ?? 0,
        sourceId: item.moOrderId,
      ),
    );
  }

  ///任务单
  ///sign：1 审核， 0 取消审核, 16 开工\生产中,  8 挂起
  Future<void> orderSetCheckedSign(MoOpOrderModel item, int sign) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (sign == 1 && (item.sign ?? 0) >= MoOpOrderSign.scz.sign){
      ToastNotification(Get.overlayContext!).warn('该任务单已经在生产中，不能审核！');
      isLoading = false;
      return;
    }
    if (sign == 0 && (item.sign ?? 0) >= MoOpOrderSign.scz.sign){
      ToastNotification(Get.overlayContext!).warn('该单已经在生产中，不能取消审核！');
      isLoading = false;
      return;
    }
    if (sign == 16 && (item.sign ?? 0) >= MoOpOrderSign.scz.sign){
      ToastNotification(Get.overlayContext!).warn('该任务单已经在生产中，不能开工！');
      isLoading = false;
      return;
    }
    if (sign == 8 && ((item.sign ?? 0) < MoOpOrderSign.scz.sign || (item.sign ?? 0) >= MoOpOrderSign.ysc.sign)){
      ToastNotification(Get.overlayContext!).warn('该任务单未在生产中，不能挂起！');
      isLoading = false;
      return;
    }
    String signStr = '';
    switch (sign){
      case 0:
        signStr = '取消审核';
        break;
      case 1:
        signStr = '审核';
        break;
      case 8:
        signStr = '挂起';
        break;
      case 16:
        signStr = '开工';
        break;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认$signStr？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交开工数据', completedMsg: '数据刷新成功！');
    //region 提交数据
    var res = await MoOrderRepository().setCheckedSign(item.moOrderId, sign);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('$signStr失败！${res.message}！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '$signStr成功，正在刷新数据');
    //endregion
    //region 数据刷新
    switch (sign){
      case 0: ///取消审核
        if (selectedOrderSignBinary & orderSignList[0].sign == orderSignList[0].sign){
          item.sign = MoOpOrderSign.wpg.sign;
          item.status = '待审核';
        }
        else {
          orderList.remove(item);
          total --;
        }
        break;
      case 1: ///审核
        if (selectedOrderSignBinary & orderSignList[0].sign == orderSignList[0].sign){
          item.sign = MoOpOrderSign.wpg.sign;
          item.status = '已审核';
        }
        else {
          orderList.remove(item);
          total --;
        }
        break;
      case 8: ///挂起
        if (selectedOrderSignBinary & orderSignList[0].sign == orderSignList[0].sign){
          item.sign = MoOpOrderSign.ygq.sign;
          item.status = MoOpOrderSign.ygq.name;
        }
        else {
          orderList.remove(item);
          total --;
        }
        break;
      case 16: ///开工
        if (selectedOrderSignBinary & orderSignList[1].sign == orderSignList[1].sign){
          item.sign = MoOpOrderSign.scz.sign;
          item.status = MoOpOrderSign.scz.name;
        }
        else {
          orderList.remove(item);
          total --;
        }
        break;
    }
    ProgressDialogUtil.update(value: 2);
    //endregion
    update();
    isLoading = false;
  }

  ///任务单设置完工
  Future<void> orderFinishMoProcessTask(MoOpOrderModel item) async{
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if ((item.sign ?? 0) >= MoOpOrderSign.ysc.sign){
      ToastNotification(Get.overlayContext!).warn('该任务单已经完工，不能再次设置完工！');
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
    var res = await MoOrderRepository().setFinish(item.moOrderId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('设置完工失败！${res.message}！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '设置完工成功，正在刷新数据');
    //endregion
    //region 数据刷新
    if (selectedOrderSignBinary & orderSignList[2].sign == orderSignList[2].sign){
      item.sign = MoOpOrderSign.zdwg.sign;
      item.status = MoOpOrderSign.zdwg.name;
    }
    else {
      orderList.remove(item);
      total --;
    }
    ProgressDialogUtil.update(value: 2);
    //endregion
    update();
    isLoading = false;
  }

  ///派工单 查看工序图纸
  Future<void> getOpAttach(MoTaskModel item) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;

    ProgressDialogUtil.showProgressDialog();
    ///产品id对应的工艺路线列表
    final List<MoRoutingEntryModel> routingByInvIdList = [];
    var res = await MoRoutingRepository().getRoutingByInvId(item.invId ?? '');
    if (res.isSuccess && res.data.entryList.isNotEmpty){
      routingByInvIdList.addAll(res.data.entryList);
    }
    MoRoutingEntryModel? routingEntryModel = routingByInvIdList.firstWhereOrNull((element) => element.opId == item.opId);
    if (routingEntryModel == null || routingEntryModel.routingDId.isEmpty){
      ToastNotification(Get.overlayContext!).warn('无法获取工序图纸！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update();
    await ProgressDialogUtil.awaitCompletionDelay();
    isLoading = false;

    Get.rootDelegate.toNamed(
        AppRoutes.MES_WORK_CENTER_ATTACH_PAGE,
        parameters: {
          'pageTitle': '工序图纸-${item.opName}',
          'id': routingEntryModel.routingDId,
          'progId': '660011',
          'category': 'sop',
        }
    );
  }

  ///派工单设置完工
  Future<void> taskFinishMoProcessTask(MoTaskModel item) async {
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
      taskList.remove(item);
      total --;
    }
    ProgressDialogUtil.update(value: 2);
    //endregion
    update();
    isLoading = false;
  }

  ///派工单开工（切单并生成首检报检单）
  Future<void> taskActionFlagShiftWithCreateFI(MoTaskModel item) async{
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
      taskList.remove(item);
      total --;
    }
    if (item.deviceId != null && item.deviceId!.isNotEmpty){
      MoTaskModel? task = taskList.firstWhereOrNull((element) => element.deviceId == item.deviceId && element.taskId != item.taskId);
      if (task != null && task.sign != null && task.sign! >= MoTaskSign.scz.sign && task.sign! < MoTaskSign.ysc.sign){
        if (selectedTaskSignBinary & taskSignList[2].sign == taskSignList[2].sign){
          task.sign = MoTaskSign.scz.sign;
          task.status = MoTaskSign.scz.name;
        }
        else {
          taskList.remove(task);
          total --;
        }
      }
    }
    ProgressDialogUtil.update(value: 2);
    //endregion
    update();
    isLoading = false;
  }

  ///派工单挂起
  Future<void> taskSuspendMoProcessTask(MoTaskModel item) async {
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
      taskList.remove(item);
      total --;
    }

    ProgressDialogUtil.update(value: 2);
    //endregion
    update();
    isLoading = false;
  }

  //endregion

}