import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/andon/andon_add/andon_add_controller.dart';
import 'package:desktop/app/ui/pages/home/andon/andon_add/andon_add_page.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/date_filter_interface/date_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/dep_filter_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/sign_filter_interface/sign_filter_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///安灯系统 --全场呼叫系统（主页面）
class AndonController
    extends BaseFormWithPageDataController<MoAndonServiceModel>
    with SignFilterInterface,
        DepFilterInterface,
        DateFilterInterface, 
        CommandBarInterface,
        InterfaceUtil {

  ///全场呼叫 状态列表
  List<MoSignModel> get signList => AppConfig.andonSignList;

  get dateSearchTypeList => List.unmodifiable(AppConfig.andonDateSearchTypeList);
  get dateSearchQueryDataList => List.unmodifiable(dateSearchTypeList.expand((e) => e.content.split(',')).toSet().toList());

  ///是否显示全场呼叫类型选择器
  bool isShowAndonClassPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_IS_SHOW_ANDON_CLASS_PICKER_KEY) ?? AppConfig.isShowAndonClassPicker;
  AndonClassWithNoPageAdapter? andonClassAdapter;
  ///类别筛选 选中的类别
  String andonServiceClassId = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_SERVICE_CLASS_ID_KEY) ?? '';

  ///全场呼叫列表页面显示的按钮组列表
  final List<CommandBarBtnModel> commandBarList = [];


  AndonController({
    super.progId = 710012
  });

  @override
  void onInit() {
    super.onInit();

    //region
    isShowSignFilter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_IS_SHOW_SIGN_FILTER_KEY) ?? AppConfig.isShowSignFilter;
    isSignChipMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_IS_SIGN_CHIP_MULTI_KEY)?? AppConfig.isSignChipMulti;
    selectedSignBinary = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_SIGN_SELECTED_KEY) ?? AppConfig.binaryForAndonServiceSignSelected;

    isShowDepPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_IS_SHOW_DEP_PICKER_KEY) ?? AppConfig.isShowDepPicker;
    depIds = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_DEP_IDS_KEY) ?? '';

    isShowDatePicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_IS_SHOW_DATE_PICKER_KEY) ?? AppConfig.isShowDatePicker;
    dateSearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_DATE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.dateSearchTypeIndex;
    String datePickerValueStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_DATE_PICKER_VALUE_MAP_KEY) ?? '';
    datePickerValueMap = getDatePickerValueMapByStorage(datePickerValueStr);

    List<dynamic> commandBarMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_COMMAND_BAR_LIST_KEY) ?? [];
    commandBarList.clear();
    commandBarList.addAll(
        getCommandBarListByStorage(
            commandBarMapList,
            AppConfig.andonCommandBarList
        )
    );
    //endregion

    dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.ANDON_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
    dataListPageConfig.sidx = 'SubmitDate';
    dataListPageConfig.queryData = {
      'Progid': progId,
      //'ClassObjectId': BaseService.profile.userId, /// 该报工台不分登录人员，不需要写
      //ServiceSign：状态 可以传多个
      //ServiceClass：呼叫类别
      //StartTime EndTime
    };
    depQueryDataOnChanged();
    signQueryDataOnChanged();
    dateQueryDataOnChanged();
    andonClassQueryDataOnChanged();
  }

  @override
  Future<bool> initializeForm() async {
    var res = await super.initializeForm();
    await getAndonClassAdapter();
    await getDepAdapter();
    return res;
  }

  ///获取列表数据源
  @override
  Future<PageResult<MoAndonServiceModel>> getDataList(PageConfig pageConfig) async{
    var res = await AndonServiceRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取全场呼叫列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }


  Future<void> getAndonClassAdapter() async{
    List<PickerDataModel> list = andonServiceClassId.isEmpty ? [] : andonServiceClassId.split(',').map((e) => PickerDataModel(id: e)).toList();
    andonClassAdapter = await AdapterHelper.getAsyncAdapter(
      'andonClass',
      selectedItems: list,
    ) as AndonClassWithNoPageAdapter;
  }


  //region OnChanged

  @override
  Future<void> signOnChanged(int sign) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    await super.signOnChanged(sign);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_SIGN_SELECTED_KEY, selectedSignBinary);
    signQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void signQueryDataOnChanged() {
    List<int> serviceSignList = [];
    for (var element in signList) {
      if (selectedSignBinary & element.sign == element.sign){
        serviceSignList.add(element.sign);
      }
    }
    String serviceSign = serviceSignList.isNotEmpty
        ? serviceSignList.join(',')
        : '${MoAndonServiceSign.dcl.sign},'
        '${MoAndonServiceSign.clz.sign},'
        '${MoAndonServiceSign.dqr.sign},'
        '${MoAndonServiceSign.ycl.sign}';
    dataListPageConfig.queryData!['ServiceSign'] = serviceSign;
  }

  @override
  Future<void> depOnChanged(List<PickerDataModel> list) async{
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_DEP_IDS_KEY, depIds);
    depQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }
  void depQueryDataOnChanged() {
    dataListPageConfig.queryData!['DepId'] = depIds;
  }

  ///呼叫类型选择变化
  Future<void> andonClassOnChanged(List<PickerDataModel> list) async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    andonServiceClassId = list.map((e) => e.id).join(',');
    //region ShareStorageUtil.instance?.write
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_SERVICE_CLASS_ID_KEY, andonServiceClassId);
    //endregion
    andonClassQueryDataOnChanged();
    await pageChanged(pageIndex: 1);
    update();
    isLoading = false;
  }
  void andonClassQueryDataOnChanged() {
    dataListPageConfig.queryData!['ServiceClass'] = andonServiceClassId;
  }

  @override
  Future<void> dateSearchTypeOnChanged(ChoiceChipModel item, int index) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (index == dateSearchTypeIndex){
      isLoading = false;
      return;
    }
    dateSearchTypeIndex = index;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.ANDON_DATE_SEARCH_TYPE_INDEX_KEY, dateSearchTypeIndex);
    dateQueryDataOnChanged();
    if (startDate != null && endDate != null){
      await pageChanged();
    }
    update();
    isLoading = false;
  }
  @override
  Future<void> dateOnChanged(String string) async{
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
        dataListPageConfig.queryData![keywordList[1]] = endDateStrWithNoTime;
      }
    }
  }

  //endregion


  //region 点击回调

  @override
  void settingOnTap(){
    Get.rootDelegate.toNamed(
      AppRoutes.ANDON_SETTING_PAGE,
      parameters: {
        'noPermission': (dataService.isEnableOperatePrivilege
            && objectItem.buttons?['desktopUISettingBtn'] == null) ? '1' : '0',
        'permissionInfo': BaseService.profile.isSystem == true ? '【${objectItem.progid}】【desktopUISettingBtn】' : '',
      },
    );
  }

  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    item as MoAndonServiceModel;
    switch (keyName){
      case '${AppConfig.andonListBtn}-${AppConfig.nextStep}':
        await nextStep(item);
        break;
      case '${AppConfig.andonListBtn}-${AppConfig.cancelAndon}':
        await cancelAndon(item);
        break;
    }
  }


  ///下一步（开始处理、处理完成、确认验收）
  Future<void> nextStep(MoAndonServiceModel item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn("正在执行！");
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认提交？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交数据', completedMsg: '数据刷新成功！');
    String nowServiceSignStr = item.serviceSign?.toRadixString(2) ?? '';
    nowServiceSignStr = nowServiceSignStr.replaceAll('1', '0');
    int serviceSign = int.tryParse('1$nowServiceSignStr', radix: 2) ?? 2;
    //region 数据提交
    var res = await AndonServiceRepository().changeServiceSign(
        item.serviceId, serviceSign,
        DateUtil.getDateStrByDateTime(DateTime.now())!
    );
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).warn('数据提交时出错：${res.message}');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '数据提交成功，正在刷新数据');
    //endregion
    //region 数据刷新
    MoSignModel? signModel = signList.firstWhereOrNull((element) => element.sign == serviceSign);
    if (signModel != null && (selectedSignBinary & serviceSign == serviceSign)){
      item.serviceSign = serviceSign;
      var dataRes = await AndonServiceRepository().getFormData(item.serviceId);
      if (!dataRes.isSuccess){
        ToastNotification(Get.overlayContext!).warn('获取刷新数据时出错：${dataRes.message}');
      }
      else {
        item.processUser = dataRes.data.processUser;
        item.processDate = dataRes.data.processDate;
        item.finishUser = dataRes.data.finishUser;
        item.finishDate = dataRes.data.finishDate;
        item.acceptUser = dataRes.data.acceptUser;
        item.acceptDate = dataRes.data.acceptDate;
        item.receiver = dataRes.data.receiver;
        item.receiveDate = dataRes.data.receiveDate;
      }
    }
    else {
      dataList.removeWhere((element) => element.serviceId == item.serviceId);
      total --;
    }
    ProgressDialogUtil.update(value: 2);
    //endregion
    update();
    isLoading = false;
  }

  ///取消呼叫
  Future<void> cancelAndon(MoAndonServiceModel item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn("正在执行！");
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认取消呼叫？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(msg: '正在提交数据', completedMsg: '取消呼叫成功！');
    int serviceSign = MoAndonServiceSign.qx.sign;
    var res = await AndonServiceRepository().changeServiceSign(
        item.serviceId, serviceSign,
        DateUtil.getDateStrByDateTime(DateTime.now())!
    );
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).warn('取消呼叫失败时出错：${res.message}');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    dataList.removeWhere((element) => element.serviceId == item.serviceId);
    total --;
    update();
    isLoading = false;
    ProgressDialogUtil.update();
  }

  ///查看附件
  Future<void> itemAttach(MoAndonServiceModel item) async {
    Get.rootDelegate.toNamed(
      AppRoutes.ANDON_ITEM_ATTACH_PAGE,
      parameters: {
        'pageTitle': '全场呼叫附件',
        'id': item.serviceId,
        'progId': progId.toString(),
        'category': 'attach',
      }
    );
  }

  ///发起新的全场呼叫
  Future<void> getNewAndon() async {
    var res = await DialogUtils.showCustomDialog<AndonAddController, String>(
      Get.context!,
      title: '发起新的全场呼叫',
      isMaximize: true,
      contentPadding: const EdgeInsets.all(12),
      content: AndonAddPage(),
      controller: AndonAddController(
        initDepId: depIds.split(',').first,
      ),
    );
    if (res == null || res.isEmpty){
      return;
    }
    if (selectedSignBinary == 0 || selectedSignBinary & 1 == 1){
      ProgressDialogUtil.showProgressDialog(msg: '正在刷新数据', completedMsg: '数据刷新成功！');
      var dataRes = await AndonServiceRepository().getFormData(res);
      if (!dataRes.isSuccess){
        ToastNotification(Get.overlayContext!).warn('获取刷新数据时出错：${dataRes.message}');
        ProgressDialogUtil.close();
        return;
      }
      dataList.insert(0, dataRes.data);
      total ++;
      update();
      ProgressDialogUtil.update();
    }
  }

  //endregion


}
