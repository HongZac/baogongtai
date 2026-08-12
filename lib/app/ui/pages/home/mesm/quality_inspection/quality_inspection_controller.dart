// ignore_for_file: unnecessary_overrides

import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/mo_task_choice_to_check_voucher/mo_task_choice_to_check_voucher_controller.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/mo_task_choice_to_check_voucher/mo_task_choice_to_check_voucher_view.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///质量巡检 报检单、检验单列表页面 （首页）
class QualityInspectionController
    extends BaseFormController
    with SerialPortGetXListenerMixin<QualityInspectionController>, ScanInterface<QualityInspectionController>,
        TcpSocketGetxListenerMixin<QualityInspectionController> {

  ///报检单（待检验）列表（首巡末完自检）
  final List<MoInspectModel> inspectList = [];
  final PageConfig inspectListPageConfig = PageConfig(
    page: 1,
    rows: 7,
    sord: 'desc',
    sidx: 'ProcessDate',
    queryData: {},
  );
  ///检验单（检验中、已检验）列表（首巡末完自检）
  final List<MoCheckVoucherModel> checkVoucherList = [];
  final PageConfig checkVoucherListPageConfig = PageConfig(
    page: 1,
    rows: 7,
    sord: 'desc',
    sidx: 'CheckDate',
    queryData: {},
  );
  ///来料报检单列表
  final List<QMInspectListModel> qmInspectList = [];
  final PageConfig qmInspectPageConfig = PageConfig(
    page: 1,
    rows: 7,
    sord: 'desc',
    sidx: 'BillDate',
    queryData: {
      'NoCheck': 1, ///只取未检验的报检单
      'ProgID': 810021,
    },
  );
  ///来料检验单列表
  final List<QMCheckVoucherModel> qmCheckVoucherList = [];
  final PageConfig qmCheckVoucherPageConfig = PageConfig(
    page: 1,
    rows: 7,
    sord: 'desc',
    sidx: 'BillDate',
    queryData: {
      'ProgID': 810023,
    },
  );
  final ScrollController listScrollController = ScrollController();

  ///列表总数
  int total = 0;
  ///总页码
  int totalPage = 0;
  ///当前页码
  int nowPage = 0;

  //region 首巡检单据的类型、状态列表
  final int qualityInspectionSignSelectedIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.QUALITY_INSPECTION_SIGN_SELECTED_KEY) ?? AppConfig.qualityInspectionSignSelectedIndex;
  ///检验状态列表
  late final List<MoSignModel> qualityInspectionSignList = [
    MoSignModel(
      isSelected: qualityInspectionSignSelectedIndex == 0,
      title: '待检验', content: '待检验', sign: 0,
    ),
    MoSignModel(
      isSelected: qualityInspectionSignSelectedIndex == 1,
      title: '待判定', content: '待判定', sign: 1,
    ),
    MoSignModel(
      isSelected: qualityInspectionSignSelectedIndex == 256,
      title: '已检验', content: '已检验', sign: 256,
    ),
  ];
  late final List<Widget> qualityInspectionSignMenuList = qualityInspectionSignList.map((e){
    return MenuItemButton(
      onPressed: () async {
        await signOnChanged(e);
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.only(top: 22, bottom: 22, left: 12, right: 44)
        ),
      ),
      child: MenuAcceleratorLabel(e.title),
    );
  }).toList();
  ///'待检验', sign: 0；  '待判定', sign: 1,；  '已检验', sign: 256,;
  late MoSignModel selectedTaskSignModel = qualityInspectionSignList.firstWhereOrNull((element) => element.isSelected) ?? MoSignModel(sign: -1);

  final int qualityInspectionCategorySelectedIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.QUALITY_INSPECTION_CATEGORY_SELECTED_KEY) ?? AppConfig.qualityInspectionCategorySelectedIndex;
  final int showCategory = ShareStorageUtil.instance?.read(SharedPreferencesKeys.QUALITY_INSPECTION_SHOW_CATEGORY_LIST_KEY) ?? AppConfig.showCategory;
  ///检验类型列表
  late final List<MoSignModel> qualityInspectionCategoryList = [
    if (showCategory & IPQCCategory.lljy.category == IPQCCategory.lljy.category)
      MoSignModel(
        isSelected: qualityInspectionCategorySelectedIndex == 1,
        title: '来料检验', content: '来料检验', sign: 1,
      ),
    if (showCategory & IPQCCategory.sj.category == IPQCCategory.sj.category)
      MoSignModel(
        isSelected: qualityInspectionCategorySelectedIndex == 2,
        title: '首检', content: '首检', sign: 2,
      ),
    if (showCategory & IPQCCategory.xj.category == IPQCCategory.xj.category)
      MoSignModel(
        isSelected: qualityInspectionCategorySelectedIndex == 4,
        title: '巡检', content: '巡检', sign: 4,
      ),
    if (showCategory & IPQCCategory.mj.category == IPQCCategory.mj.category)
      MoSignModel(
        isSelected: qualityInspectionCategorySelectedIndex == 8,
        title: '末检', content: '末检', sign: 8,
      ),
    if (showCategory & IPQCCategory.wj.category == IPQCCategory.wj.category)
      MoSignModel(
        isSelected: qualityInspectionCategorySelectedIndex == 16,
        title: '完检', content: '完检', sign: 16,
      ),
    if (showCategory & IPQCCategory.zj.category == IPQCCategory.zj.category)
      MoSignModel(
        isSelected: qualityInspectionCategorySelectedIndex == 32,
        title: '自检', content: '自检', sign: 32,
      ),
  ];
  late final List<Widget> qualityInspectionCategoryMenuList = qualityInspectionCategoryList.map((e){
    return MenuItemButton(
      onPressed: () async {
        await categoryOnChanged(e);
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.only(top: 22, bottom: 22, left: 12, right: 44)
        ),
      ),
      child: MenuAcceleratorLabel(e.title),
    );
  }).toList();
  ///content: '来料检验', sign: 1,；   '首检', sign: 2,；   '巡检', sign: 4,；   '末检', sign: 8,；   '完检', sign: 16,；   '自检', sign: 32,;
  late MoSignModel selectedTaskCategoryModel = qualityInspectionCategoryList.firstWhereOrNull((element) => element.isSelected) ?? MoSignModel(sign: -1);
  //endregion

  ///设备组条件 设备ID（可多选）
  String? deviceIds = ShareStorageUtil.instance?.read(SharedPreferencesKeys.QUALITY_INSPECTION_DEVICES_KEY);
  EAMRoleNoPageAdapter? eamRoleAdapter;

  ///车间筛选 DepId
  String? depId = ShareStorageUtil.instance?.read(SharedPreferencesKeys.QUALITY_INSPECTION_DEP_KEY);
  DepartmentAdapter? departmentAdapter;

  DateTime? startDate;
  DateTime? endDate;

  //region 搜索
  int searchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.QUALITY_INSPECTION_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;
  final TextEditingController searchTC = TextEditingController();
  final FocusNode searchFN = FocusNode();
  bool isSearchWidgetOpen = false;
  //endregion


  QualityInspectionController({
    super.progId = 811014,
  });

  @override
  void onInit() {
    super.onInit();
    scanQueryDataList.addAll(['WorkBillEntryId']);
  }

  @override
  Future<void> onReady() async {
    super.onReady();
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
    if (selectedTaskSignModel.sign == -1 && qualityInspectionSignList.isNotEmpty){
      selectedTaskSignModel = qualityInspectionSignList[0];
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.QUALITY_INSPECTION_SIGN_SELECTED_KEY, selectedTaskSignModel.sign);
    }
    if (selectedTaskCategoryModel.sign == -1 && qualityInspectionCategoryList.isNotEmpty){
      selectedTaskCategoryModel = qualityInspectionCategoryList[0];
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.QUALITY_INSPECTION_CATEGORY_SELECTED_KEY, selectedTaskCategoryModel.sign);
    }
    await getEAMRoleAdapter();
    await getDepartmentAdapter();
    getCategoryAndSignPageConfig(selectedTaskSignModel, selectedTaskCategoryModel);
    setDeviceIdPageConfig(deviceIds);
    setDepIdPageConfig(depId);
    bool res = await pageChanged(pageIndex: 1, showLoading: false);
    return res;
  }

  Future<void> getEAMRoleAdapter() async{
    List<PickerDataModel> list = (deviceIds ?? '').isEmpty
        ? []
        : deviceIds!.split(',').map((e) => PickerDataModel(id: e)).toList();
    eamRoleAdapter = await AdapterHelper.getAsyncAdapter(
      'eamRole',
      isNeedLoadData: list.isNotEmpty,
      selectedItems: list,
    ) as EAMRoleNoPageAdapter;
  }

  Future<void> getDepartmentAdapter() async {
    List<PickerDataModel> list = (depId ?? '').isEmpty
        ? []
        : depId!.split(',').map((e) => PickerDataModel(id: e)).toList();
    departmentAdapter = await AdapterHelper.getAsyncAdapter(
      'dep',
      isNeedLoadData: list.isNotEmpty,
      selectedItems: list,
    ) as DepartmentAdapter;
  }

  Future<bool> pageChanged({int pageIndex = 1, bool showLoading = true}) async{
    if(showLoading){
      ProgressDialogUtil.showProgressDialog();
    }
    bool isSuccess = false;
    if (selectedTaskCategoryModel.sign == 1){ ///来料检验
      switch (selectedTaskSignModel.sign){
        case 0: ///待检验
          qmInspectPageConfig.page = pageIndex;
          var res = await getQMInspectList(qmInspectPageConfig);
          qmInspectList.clear();
          qmInspectList.addAll(res.rows);
          total = res.records ?? 0;
          totalPage = res.total ?? 0;
          nowPage = res.page ?? 0;
          isSuccess = res.isSuccess;
          break;
        case 1: /// 待判定
        case 256: /// 已检验
          qmCheckVoucherPageConfig.page = pageIndex;
          var res = await getQMCheckVoucherList(qmCheckVoucherPageConfig);
          qmCheckVoucherList.clear();
          qmCheckVoucherList.addAll(res.rows);
          total = res.records ?? 0;
          totalPage = res.total ?? 0;
          nowPage = res.page ?? 0;
          isSuccess = res.isSuccess;
          break;
      }
    }
    else {
      switch (selectedTaskSignModel.sign){
        case 0: ///待检验
          inspectListPageConfig.page = pageIndex;
          var res = await getInspectList(inspectListPageConfig);
          inspectList.clear();
          inspectList.addAll(res.rows);
          total = res.records ?? 0;
          totalPage = res.total ?? 0;
          nowPage = res.page ?? 0;
          isSuccess = res.isSuccess;
          break;
        case 1: ///待判定
        case 256: ///已检验
          checkVoucherListPageConfig.page = pageIndex;
          var res = await getCheckVoucherList(checkVoucherListPageConfig);
          checkVoucherList.clear();
          checkVoucherList.addAll(res.rows);
          total = res.records ?? 0;
          totalPage = res.total ?? 0;
          nowPage = res.page ?? 0;
          isSuccess = res.isSuccess;
          break;
      }
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

  ///获取报检单（待检验）列表（首巡末完自检）
  Future<PageResult<MoInspectModel>> getInspectList(PageConfig pageConfig) async{
    var res = await MoInspectRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取报检单列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }

  ///获取检验单（已检验）列表（首巡末完自检）
  Future<PageResult<MoCheckVoucherModel>> getCheckVoucherList(PageConfig pageConfig) async{
    var res = await MoCheckVoucherRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取检验单列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }

  ///获取来料报检单（待检验）列表
  Future<PageResult<QMInspectListModel>> getQMInspectList(PageConfig pageConfig) async{
    var res = await QMInspectVoucherRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取报检单列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }

  ///获取来料检验单（已检验）列表
  Future<PageResult<QMCheckVoucherModel>> getQMCheckVoucherList(PageConfig pageConfig) async{
    if (selectedTaskSignModel.sign == 1){ ///待判定
      return PageResult();
    }
    var res = await QMCheckVoucherRepository().getBillPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取检验单列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }


  //region OnChanged

  ///检验状态标签选择变化
  Future<void> signOnChanged(MoSignModel item) async{
    if (item.sign == selectedTaskSignModel.sign){
      return;
    }
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;

    for (var element in qualityInspectionSignList) {
      element.isSelected = false;
    }
    item.isSelected = true;
    selectedTaskSignModel = item;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.QUALITY_INSPECTION_SIGN_SELECTED_KEY, item.sign);
    getCategoryAndSignPageConfig(selectedTaskSignModel, selectedTaskCategoryModel);
    await pageChanged();
    update();

    isLoading = false;
  }

  ///检验类型标签选择变化
  Future<void> categoryOnChanged(MoSignModel item) async{
    if (item.sign == selectedTaskCategoryModel.sign){
      return;
    }
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;

    for (var element in qualityInspectionCategoryList) {
      element.isSelected = false;
    }
    item.isSelected = true;
    selectedTaskCategoryModel = item;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.QUALITY_INSPECTION_CATEGORY_SELECTED_KEY, item.sign);
    getCategoryAndSignPageConfig(selectedTaskSignModel, selectedTaskCategoryModel);
    await pageChanged();
    update();

    isLoading = false;
  }

  ///设备组条件选择变化
  Future<void> eamRoleOnChanged(PickerDataModel item) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    PageConfig pageConfig = PageConfig(
      page: 1,
      rows: 1000,
      sidx: "",
      sord: "desc",
      queryData: {'EamRoleId': item.id, 'Category': 1}
    );

    var res = await EAMRoleRelationRepository().getPageList(pageConfig);
    if (!res.isSuccess) {
      ToastNotification(Get.overlayContext!).error('获取设备角色关系列表时出错：${res.message}');
      isLoading = false;
      return;
    }
    deviceIds = res.rows.map((e) => e.objectId).join(',');
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.QUALITY_INSPECTION_DEVICES_KEY, deviceIds);
    setDeviceIdPageConfig(deviceIds);
    await pageChanged();
    update();
    isLoading = false;
  }

  ///设备组条件选择变化
  Future<void> depOnChanged(PickerDataModel item) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    depId = item.id;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.QUALITY_INSPECTION_DEP_KEY, depId);
    setDepIdPageConfig(depId);
    await pageChanged();
    update();
    isLoading = false;
  }

  ///日期选择变化
  Future<void> dateOnChanged(String string) async{
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (string.isEmpty){
      startDate = null;
      endDate = null;
      inspectListPageConfig.queryData!['StartTime'] = null;
      inspectListPageConfig.queryData!['EndTime'] = null;
      checkVoucherListPageConfig.queryData!['StartTime'] = null;
      checkVoucherListPageConfig.queryData!['EndTime'] = null;
      qmInspectPageConfig.queryData!['StartTime'] = null;
      qmInspectPageConfig.queryData!['EndTime'] = null;
      qmCheckVoucherPageConfig.queryData!['StartTime'] = null;
      qmCheckVoucherPageConfig.queryData!['EndTime'] = null;
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
      inspectListPageConfig.queryData!['StartTime'] = '${DateUtil.getDateStrByDateTime(
          startDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
      inspectListPageConfig.queryData!['EndTime'] = '${DateUtil.getDateStrByDateTime(
          endDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
      checkVoucherListPageConfig.queryData!['StartTime'] = '${DateUtil.getDateStrByDateTime(
          startDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
      checkVoucherListPageConfig.queryData!['EndTime'] = '${DateUtil.getDateStrByDateTime(
          endDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
      qmInspectPageConfig.queryData!['StartTime'] = '${DateUtil.getDateStrByDateTime(
          startDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
      qmInspectPageConfig.queryData!['EndTime'] = '${DateUtil.getDateStrByDateTime(
          endDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
      qmCheckVoucherPageConfig.queryData!['StartTime'] = '${DateUtil.getDateStrByDateTime(
          startDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
      qmCheckVoucherPageConfig.queryData!['EndTime'] = '${DateUtil.getDateStrByDateTime(
          endDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? ''} 00:00:00';
    }
    await pageChanged();
    update();
    isLoading = false;
  }

  Future<void> itemExpandedOnChanged(dynamic item) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    ProgressDialogUtil.showProgressDialog();
    //region
    if (item is MoInspectModel){
      item.isExpanded = !item.isExpanded;
      if (!item.isGetOpDescription) {
        item.opDescription = await getOpDescription(item.workBillEntryId ?? '');
        item.isGetOpDescription = true;
      }
    }
    else if (item is MoCheckVoucherModel){
      item.isExpanded = !item.isExpanded;
      if (!item.isGetOpDescription) {
        item.opDescription = await getOpDescription(item.workBillEntryId ?? '');
        item.isGetOpDescription = true;
      }
    }
    else if (item is QMInspectListModel){
      item.isExpanded = !item.isExpanded;
    }
    else if (item is QMCheckVoucherModel){
      item.isExpanded = !item.isExpanded;
    }
    //endregion
    ProgressDialogUtil.update();
    isLoading = false;
    update();
  }

  Future<String> getOpDescription(String workBillEntryId) async {
    var res = await MoWorkBillEntryRepository().getMoWorkBillEntry(workBillEntryId);
    return res.data.opDescription ?? '';
  }

  //endregion


  //region 搜索
  
  void searchTCOnChanged() {
    inspectListPageConfig.queryData!.remove('engineerfigno');
    checkVoucherListPageConfig.queryData!.remove('engineerfigno');
    qmInspectPageConfig.queryData!.remove('engineerfigno');
    qmCheckVoucherPageConfig.queryData!.remove('engineerfigno');
    switch (AppConfig.qualityInspectionSearchTypeList[searchTypeIndex].keyName){
      /*case 'sourceCode':
        inspectListPageConfig.queryData!['sourcecode'] = searchTC.text;
        //checkVoucherListPageConfig.queryData![''] = searchTC.text;
        qmInspectPageConfig.queryData![''] = searchTC.text;
        qmCheckVoucherPageConfig.queryData![''] = searchTC.text;
        break;
      case 'invCode':
        inspectListPageConfig.queryData!['invcode'] = searchTC.text;
        checkVoucherListPageConfig.queryData!['invcode'] = searchTC.text;
        qmInspectPageConfig.queryData![''] = searchTC.text;
        qmCheckVoucherPageConfig.queryData![''] = searchTC.text;
        break;
      case 'invName':
        inspectListPageConfig.queryData!['invname'] = searchTC.text;
        checkVoucherListPageConfig.queryData!['invname'] = searchTC.text;
        qmInspectPageConfig.queryData![''] = searchTC.text;
        qmCheckVoucherPageConfig.queryData![''] = searchTC.text;
        break;*/
      case 'engineerFigNo':
        inspectListPageConfig.queryData!['engineerfigno'] = searchTC.text;
        checkVoucherListPageConfig.queryData!['engineerfigno'] = searchTC.text;
        qmInspectPageConfig.queryData!['engineerfigno'] = searchTC.text;
        qmCheckVoucherPageConfig.queryData!['engineerfigno'] = searchTC.text;
        break;
    }
    update();
  }

  ///派工单搜索
  Future<void> searchTCOnSearch() async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchFN.unfocus();
    inspectListPageConfig.queryData!.remove('engineerfigno');
    checkVoucherListPageConfig.queryData!.remove('engineerfigno');
    qmInspectPageConfig.queryData!.remove('engineerfigno');
    qmCheckVoucherPageConfig.queryData!.remove('engineerfigno');
    switch (AppConfig.qualityInspectionSearchTypeList[searchTypeIndex].keyName){
      /*case 'sourceCode':
        inspectListPageConfig.queryData!['sourcecode'] = searchTC.text;
        //checkVoucherListPageConfig.queryData![''] = searchTC.text;
        qmInspectPageConfig.queryData![''] = searchTC.text;
        qmCheckVoucherPageConfig.queryData![''] = searchTC.text;
        break;
      case 'invCode':
        inspectListPageConfig.queryData!['invcode'] = searchTC.text;
        checkVoucherListPageConfig.queryData!['invcode'] = searchTC.text;
        qmInspectPageConfig.queryData![''] = searchTC.text;
        qmCheckVoucherPageConfig.queryData![''] = searchTC.text;
        break;
      case 'invName':
        inspectListPageConfig.queryData!['invname'] = searchTC.text;
        checkVoucherListPageConfig.queryData!['invname'] = searchTC.text;
        qmInspectPageConfig.queryData![''] = searchTC.text;
        qmCheckVoucherPageConfig.queryData![''] = searchTC.text;
        break;*/
      case 'engineerFigNo':
        inspectListPageConfig.queryData!['engineerfigno'] = searchTC.text;
        checkVoucherListPageConfig.queryData!['engineerfigno'] = searchTC.text;
        qmInspectPageConfig.queryData!['engineerfigno'] = searchTC.text;
        qmCheckVoucherPageConfig.queryData!['engineerfigno'] = searchTC.text;
        break;
    }
    await pageChanged(pageIndex: 1, showLoading: true);
    update();
    isLoading = false;
  }

  ///清空搜索框内容
  Future<void> searchTCClear() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchFN.unfocus();
    searchTC.text = '';
    inspectListPageConfig.queryData!.remove('engineerfigno');
    checkVoucherListPageConfig.queryData!.remove('engineerfigno');
    qmInspectPageConfig.queryData!.remove('engineerfigno');
    qmCheckVoucherPageConfig.queryData!.remove('engineerfigno');
    await pageChanged(pageIndex: 1, showLoading: true);
    isSearchWidgetOpen = false;
    update();
    isLoading = false;
  }

  //endregion


  //region 串口、扫码、TCP

  @override
  Future<void> onSerialPortData(SerialPortDataModel serialPortDataModel) async {
    for (var element in serialComService.serialPortMsgProcessList){
      if (element.com == serialPortDataModel.com){
        portMsgOnData(
          element.keyName,
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
      case AppConfig.scanGun:
      case AppConfig.cardReader:
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
    if (kDebugMode){
      searchString = '|T|610001|21440d1c-4983-4786-ac18-33834e2d78ab';
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
            scanQueryDataOnChanged(keyWord: 'WorkBillEntryId', keyValue: list[3]);
            res = await pageChanged(pageIndex: 1, showLoading: false);
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
    inspectListPageConfig.queryData!.removeWhere((key, value) => scanQueryDataList.contains(key));
    if (keyWord != null){
      inspectListPageConfig.queryData![keyWord] = keyValue;
    }
    checkVoucherListPageConfig.queryData!.removeWhere((key, value) => scanQueryDataList.contains(key));
    if (keyWord != null){
      checkVoucherListPageConfig.queryData![keyWord] = keyValue;
    }
  }

  @override
  Future<void> onTcpSocketData(TcpSocketDataModel tcpSocketDataModel) async {
    for (var element in tcpSocketService.tcpSocketMsgProcessList){
      if (element.host == tcpSocketDataModel.host && element.port == tcpSocketDataModel.port){
        portMsgOnData(
          element.keyName,
          data: tcpSocketDataModel.data,
          accuracy: element.accuracy,
        );
      }
    }
  }

  //endregion


  //region item OnTap

  ///删除检验单
  Future<void> deleteCheckVoucher(dynamic item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认删除该检验记录？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }

    if (item is MoCheckVoucherModel){
      ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在删除检验记录', completedMsg: '数据刷新成功！');
      var res = await MoCheckVoucherRepository().deleteForm(item.moCheckId);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('删除失败！${res.message}！');
        ProgressDialogUtil.close();
        isLoading = false;
        return;
      }
      ProgressDialogUtil.update(value: 1, msg: '删除成功，正在刷新数据！');
      checkVoucherList.removeWhere((element) => element.moCheckId == item.moCheckId);
      total --;
      isLoading = false;
      update();
      ProgressDialogUtil.update(value: 2);
    }
    else if (item is QMCheckVoucherModel){
      ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在删除检验记录', completedMsg: '数据刷新成功！');
      var res = await QMCheckVoucherRepository().deleteForm(item.checkID);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('删除失败！${res.message}！');
        ProgressDialogUtil.close();
        isLoading = false;
        return;
      }
      ProgressDialogUtil.update(value: 1, msg: '删除成功，正在刷新数据！');
      qmCheckVoucherList.removeWhere((element) => element.checkID == item.checkID);
      total --;
      isLoading = false;
      update();
      ProgressDialogUtil.update(value: 2);
    }
  }

  ///设置按钮点击回调
  Future<void> settingOnTap() async {
    Get.rootDelegate.toNamed(
        AppRoutes.IPQC_QUALITY_INSPECTION_SETTING_PAGE,
    );
  }

  ///生成自定义的检验单（直接通过派工单去生成检验单，不再生成报检单）
  Future<void> generateCustomCheckVoucher() async {
    ///先选择派工单（可以进行搜索）；
    ///再跳转到“检验单详情”
    Map<String, dynamic>? res = await DialogUtils.showCustomDialog<MoTaskChoiceToCheckVoucherController, Map<String, dynamic>>(
      Get.context!,
      isMaximize: true,
      title: '派工单选择',
      onConfirmName: '确认',
      contentPadding: const EdgeInsets.all(0),
      content: MoTaskChoiceToCheckVoucherView(),
      controller: MoTaskChoiceToCheckVoucherController(),
    );
    if (res != null && res.isNotEmpty){
      if (res['checkVoucherCategory'] == IPQCCategory.wj.category){
        Get.rootDelegate.toNamed(
            AppRoutes.IPQC_QUALITY_INSPECTION_FINAL_INSPECTION_DETAIL_MAIN_PAGE,
            parameters: {
              'taskId': res['taskId'],
              'checkVoucherCategory': res['checkVoucherCategory'].toString(),
            }
        );
      }
      else {
        Get.rootDelegate.toNamed(
            AppRoutes.IPQC_QUALITY_INSPECTION_DETAIL_MAIN_PAGE,
            parameters: {
              'taskId': res['taskId'],
              'checkVoucherCategory': res['checkVoucherCategory'].toString(),
            }
        );
      }
    }
  }

  ///查看附件
  Future<void> getAttach(dynamic item) async{
    if (item is MoInspectModel){
      if (item.inspId == null || item.inspId!.isEmpty){
        ToastNotification(Get.overlayContext!).warn('未关联检验方案！');
        return;
      }
      Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_ATTACH_PAGE,
          parameters: {
            'pageTitle': '检验方案附件',
            'id': item.inspId!,
            'progId': '810003',
            'category': 'attach',
          }
      );
    }
    else if (item is MoCheckVoucherModel){
      if (item.inspId == null || item.inspId!.isEmpty){
        ToastNotification(Get.overlayContext!).warn('未关联检验方案！');
        return;
      }
      Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_ATTACH_PAGE,
          parameters: {
            'pageTitle': '检验方案附件',
            'id': item.inspId!,
            'progId': '810003',
            'category': 'attach',
          }
      );
    }
    else if (item is QMInspectListModel){
      ToastNotification(Get.overlayContext!).warn('未关联检验方案！');
      /*if (item.inspId == null || item.inspId!.isEmpty){
        ToastNotification(Get.overlayContext!).warn('未关联检验方案！');
        return;
      }
      Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_ATTACH_PAGE,
          parameters: {
            'pageTitle': '检验方案附件',
            'id': item.inspId!,
            'progId': '810003',
            'category': 'attach',
          }
      );*/
    }
    else if (item is QMCheckVoucherModel){
      if (item.projectID == null || item.projectID!.isEmpty){
        ToastNotification(Get.overlayContext!).warn('未关联检验方案！');
        return;
      }
      Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_ATTACH_PAGE,
          parameters: {
            'pageTitle': '检验方案附件',
            'id': item.projectID!,
            'progId': '810003',
            'category': 'attach',
          }
      );
    }
  }

  ///查看产品附件
  Future<void> getInvAttach(dynamic item) async{
    if (item is MoInspectModel){
      if (item.invId == null || item.invId!.isEmpty){
        ToastNotification(Get.overlayContext!).error('该报检单没有产品！');
        return;
      }
      Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_ATTACH_PAGE,
          parameters: {
            'pageTitle': '产品附件-${item.invName}',
            'id': item.invId!,
            'progId': '200025',
            'category': 'attach',
          }
      );
    }
    else if (item is MoCheckVoucherModel){
      if (item.invId == null || item.invId!.isEmpty){
        ToastNotification(Get.overlayContext!).error('该检验单没有产品！');
        return;
      }
      Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_ATTACH_PAGE,
          parameters: {
            'pageTitle': '产品附件-${item.invName}',
            'id': item.invId!,
            'progId': '200025',
            'category': 'attach',
          }
      );
    }
    else if (item is QMInspectListModel){
      if (item.invID == null || item.invID!.isEmpty){
        ToastNotification(Get.overlayContext!).error('该报检单没有产品！');
        return;
      }
      Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_ATTACH_PAGE,
          parameters: {
            'pageTitle': '产品附件-${item.invName}',
            'id': item.invID!,
            'progId': '200025',
            'category': 'attach',
          }
      );
    }
    else if (item is QMCheckVoucherModel){
      if (item.invID == null || item.invID!.isEmpty){
        ToastNotification(Get.overlayContext!).error('该检验单没有产品！');
        return;
      }
      Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_ATTACH_PAGE,
          parameters: {
            'pageTitle': '产品附件-${item.invName}',
            'id': item.invID!,
            'progId': '200025',
            'category': 'attach',
          }
      );
    }
  }

  ///查看工序图纸
  Future<void> getOpAttach(dynamic item) async{
    if (item is MoInspectModel){
      ///产品id对应的工艺路线列表
      final List<MoRoutingEntryModel> routingByInvIdList = [];
      var res = await MoRoutingRepository().getRoutingByInvId(item.invId ?? '');
      if (res.isSuccess && res.data.entryList.isNotEmpty){
        routingByInvIdList.addAll(res.data.entryList);
      }
      MoRoutingEntryModel? routingEntryModel = routingByInvIdList.firstWhereOrNull((element) => element.opId == item.opId);
      if (routingEntryModel == null || routingEntryModel.routingDId.isEmpty){
        ToastNotification(Get.overlayContext!).warn('无法获取工序图纸！');
        return;
      }

      Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_ATTACH_PAGE,
          parameters: {
            'pageTitle': '技术指导书-${item.opName ?? ''}',
            'id': routingEntryModel.routingDId,
            'progId': '660011',
            'category': 'sop',
          }
      );
    }
    else if (item is MoCheckVoucherModel){
      ///产品id对应的工艺路线列表
      final List<MoRoutingEntryModel> routingByInvIdList = [];
      var res = await MoRoutingRepository().getRoutingByInvId(item.invId ?? '');
      if (res.isSuccess && res.data.entryList.isNotEmpty){
        routingByInvIdList.addAll(res.data.entryList);
      }
      MoRoutingEntryModel? routingEntryModel = routingByInvIdList.firstWhereOrNull((element) => element.opId == item.opId);
      if (routingEntryModel == null || routingEntryModel.routingDId.isEmpty){
        ToastNotification(Get.overlayContext!).warn('无法获取工序图纸！');
        return;
      }

      Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_ATTACH_PAGE,
          parameters: {
            'pageTitle': '技术指导书-${item.opName ?? ''}',
            'id': routingEntryModel.routingDId,
            'progId': '660011',
            'category': 'sop',
          }
      );
    }
  }

  Future<void> itemOnDoubleTap(dynamic item) async{
    /// moInspectId 报检单Id  inspId 工艺检验方案Id
    /// moCheckId 检验单Id
    if (item is MoInspectModel){ ///报检单
      if (item.category == IPQCCategory.wj.category){ ///终检
        Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_FINAL_INSPECTION_DETAIL_MAIN_PAGE,
          parameters: {
            'moInspectId': item.moInspectId ?? '',
          }
        );
      }
      else {
        Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_DETAIL_MAIN_PAGE,
          parameters: {
            'moInspectId': item.moInspectId ?? '',
          }
        );
      }
    }
    else if (item is MoCheckVoucherModel){ ///检验单
      if (item.category == IPQCCategory.wj.category){ ///终检
        Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_FINAL_INSPECTION_DETAIL_MAIN_PAGE,
          parameters: {
            'moCheckId': item.moCheckId,
          }
        );
      }
      else {
        Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_DETAIL_MAIN_PAGE,
          parameters: {
            'moCheckId': item.moCheckId,
          }
        );
      }
    }
    else if (item is QMInspectListModel){ ///来料报检单
      Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_QM_INSPECTION_DETAIL_MAIN_PAGE,
          parameters: {
            'inspectMxID': item.inspectMxID ?? '',
          }
      );
    }
    else if (item is QMCheckVoucherModel){ ///来料检验单
      Get.rootDelegate.toNamed(
          AppRoutes.IPQC_QUALITY_INSPECTION_QM_INSPECTION_DETAIL_MAIN_PAGE,
          parameters: {
            'moCheckId': item.checkID,
          }
      );
    }
  }

  //endregion


  void getCategoryAndSignPageConfig(MoSignModel signModel, MoSignModel categoryModel) {
    if (categoryModel.sign == 1){ ///来料检验
      return;
    }
    switch (signModel.sign){
      case 0:
        //region 待检验
        inspectListPageConfig.queryData!['sign'] = MoInspectSign.djy.sign;
        switch (categoryModel.sign){
          /*case 1: ///来料检验
            inspectListPageConfig.queryData!['category'] = IPQCCategory.lljy.category;
            inspectListPageConfig.queryData!['ProgID'] = 811011;
            break;*/
          case 2: ///首检
            inspectListPageConfig.queryData!['category'] = IPQCCategory.sj.category;
            inspectListPageConfig.queryData!['ProgID'] = 811011;
            break;
          case 4: ///巡检
            inspectListPageConfig.queryData!['category'] = IPQCCategory.xj.category;
            inspectListPageConfig.queryData!['ProgID'] = 811011;
            break;
          case 8: ///末检
            inspectListPageConfig.queryData!['category'] = IPQCCategory.mj.category;
            inspectListPageConfig.queryData!['ProgID'] = 811011;
            break;
          case 16: ///完检
            inspectListPageConfig.queryData!['category'] = IPQCCategory.wj.category;
            inspectListPageConfig.queryData!['ProgID'] = 811031;
            break;
          case 32: ///自检
            inspectListPageConfig.queryData!['category'] = IPQCCategory.zj.category;
            inspectListPageConfig.queryData!['ProgID'] = 811011;
            break;
        }
        //endregion
        break;
      case 1:
        //region 待判定
        checkVoucherListPageConfig.queryData!['sign'] = MoCheckVoucherSign.ysh.sign;
        switch (categoryModel.sign){
          /*case 1: ///来料检验
            checkVoucherListPageConfig.queryData!['category'] = IPQCCategory.lljy.category;
            checkVoucherListPageConfig.queryData!['ProgID'] = 811021;
            break;*/
          case 2: ///首检
            checkVoucherListPageConfig.queryData!['category'] = IPQCCategory.sj.category;
            checkVoucherListPageConfig.queryData!['ProgID'] = 811021;
            break;
          case 4: ///巡检
            checkVoucherListPageConfig.queryData!['category'] = IPQCCategory.xj.category;
            checkVoucherListPageConfig.queryData!['ProgID'] = 811021;
            break;
          case 8: ///末检
            checkVoucherListPageConfig.queryData!['category'] = IPQCCategory.mj.category;
            checkVoucherListPageConfig.queryData!['ProgID'] = 811021;
            break;
          case 16: ///完检
            checkVoucherListPageConfig.queryData!['category'] = IPQCCategory.wj.category;
            checkVoucherListPageConfig.queryData!['ProgID'] = 811032;
            break;
          case 32: ///自检
            checkVoucherListPageConfig.queryData!['category'] = IPQCCategory.zj.category;
            checkVoucherListPageConfig.queryData!['ProgID'] = 811021;
            break;
        }
        //endregion
        break;
      case 256:
        //region 已检验
        checkVoucherListPageConfig.queryData!['sign'] = MoCheckVoucherSign.ywg.sign;
        switch (categoryModel.sign){
          /*case 1: ///来料检验
            checkVoucherListPageConfig.queryData!['category'] = IPQCCategory.lljy.category;
            checkVoucherListPageConfig.queryData!['ProgID'] = 811021;
            break;*/
          case 2: ///首检
            checkVoucherListPageConfig.queryData!['category'] = IPQCCategory.sj.category;
            checkVoucherListPageConfig.queryData!['ProgID'] = 811021;
            break;
          case 4: ///巡检
            checkVoucherListPageConfig.queryData!['category'] = IPQCCategory.xj.category;
            checkVoucherListPageConfig.queryData!['ProgID'] = 811021;
            break;
          case 8: ///末检
            checkVoucherListPageConfig.queryData!['category'] = IPQCCategory.mj.category;
            checkVoucherListPageConfig.queryData!['ProgID'] = 811021;
            break;
          case 16: ///完检
            checkVoucherListPageConfig.queryData!['category'] = IPQCCategory.wj.category;
            checkVoucherListPageConfig.queryData!['ProgID'] = 811032;
            break;
          case 32: ///自检
            checkVoucherListPageConfig.queryData!['category'] = IPQCCategory.zj.category;
            checkVoucherListPageConfig.queryData!['ProgID'] = 811021;
            break;
        }
        //endregion
        break;
    }
  }

  void setDeviceIdPageConfig(String? deviceIds) {
    inspectListPageConfig.queryData!['DeviceIds'] = deviceIds;
    checkVoucherListPageConfig.queryData!['DeviceIds'] = deviceIds;
    ///qmInspectPageConfig; 来料报检单没有该筛选
    ///qmCheckVoucherPageConfig; 来料检验单没有该筛选
  }

  void setDepIdPageConfig(String? depId) {
    inspectListPageConfig.queryData!['DepId'] = depId;
    checkVoucherListPageConfig.queryData!['DepId'] = depId;
    qmInspectPageConfig.queryData!['DepID'] = depId;
    qmCheckVoucherPageConfig.queryData!['DepID'] = depId;
  }


  @override
  void onClose() {
    listScrollController.dispose();
    super.onClose();
  }
}