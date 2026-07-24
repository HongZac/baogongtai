import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/quality_inspection_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///质量巡检 - 派工单选择（新增自定义的检验单）
class MoTaskChoiceToCheckVoucherController extends BaseFormWithPageDataController<MoTaskModel> {

  ///派工单生成检验单：firstCheckVoucher 2首检检验单；checkVoucher 4巡检检验单；theLastCheckVoucher 8末检检验单；finalCheckVoucher 16终检检验单
  String checkVoucherType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.QUALITY_INSPECTION_MO_TASK_CHECK_VOUCHER_TYPE_KEY) ?? AppConfig.taskToCheckVoucherType;
  ///检验类型列表
  late final List<ChoiceChipModel> operationWayList = [
    ChoiceChipModel(title: '首检', keyName: AppConfig.firstCheckVoucher, isSelected: checkVoucherType == AppConfig.firstCheckVoucher),
    ChoiceChipModel(title: '巡检', keyName: AppConfig.checkVoucher, isSelected: checkVoucherType == AppConfig.checkVoucher),
    ChoiceChipModel(title: '末检', keyName: AppConfig.theLastCheckVoucher, isSelected: checkVoucherType == AppConfig.theLastCheckVoucher),
  ];

  //region 搜索
  ///0：产品图号搜索      1：产品编号搜索      2：产品名称搜索      3：派工单号搜索      4：员工编号搜索
  int searchBtnTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.QUALITY_INSPECTION_MO_TASK_SEARCH_BTN_TYPE_INDEX_KEY) ?? AppConfig.qualityInspectionMoTaskSearchBtnTypeIndex;
  late String searchBtnTypeName = searchBtnTypeList.firstWhereOrNull((element) => element.isSelected)?.title ?? '';
  ///搜索按钮列表
  late final List<ChoiceChipModel> searchBtnTypeList = [
    ChoiceChipModel(title: '产品图号搜索', keyName: 'engineerFigNo', icon: Icons.search, isSelected: searchBtnTypeIndex == 0),
    ChoiceChipModel(title: '产品编号搜索', keyName: 'invCode', icon: Icons.search, isSelected: searchBtnTypeIndex == 1),
    ChoiceChipModel(title: '产品名称搜索', keyName: 'invName', icon: Icons.search, isSelected: searchBtnTypeIndex == 2),
    ChoiceChipModel(title: '派工单号搜索', keyName: 'taskCode', icon: Icons.search, isSelected: searchBtnTypeIndex == 3),
    ChoiceChipModel(title: '员工编号搜索', keyName: 'personCode', icon: Icons.search, isSelected: searchBtnTypeIndex == 4),
  ];
  ///搜索按钮列表
  late final List<Widget> searchBtnTypeMenuList = searchBtnTypeList.map((e) {
    return MenuItemButton(
      onPressed: () {
        searchBtnTypeOnChanged(e);
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
            const EdgeInsets.only(top: 22, bottom: 22, left: 12, right: 44)
        ),
      ),
      child: MenuAcceleratorLabel(e.title),
    );
  }).toList();

  final TextEditingController searchTC = TextEditingController();
  final FocusNode searchFN = FocusNode();
  //endregion

  final QualityInspectionController qualityInspectionController = Get.find<QualityInspectionController>();
  


  MoTaskChoiceToCheckVoucherController({
    super.progId = -1,
    super.isNeedGetObjectItem = false,
  });


  @override
  void onInit() {
    super.onInit();
    dataListPageConfig.rows = 10;
    dataListPageConfig.sidx = 'TaskDate';
    dataListPageConfig.queryData = {
      'ExtOpFlag': 0, ///ExtOpFlag=0 去除委外
      'status': '制单,已计划,已挂起,生产中',
    };
  }

  @override
  Future<void> onReady() async {
    super.onReady();
  }

  @override
  Future<bool> initializeForm() async {
    return true;
  }

  @override
  Future<PageResult<MoTaskModel>> getDataList(PageConfig pageConfig) async{
    if (searchTC.text.isEmpty){
      return PageResult();
    }
    var res = await MoTaskRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取派工单列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }


  //region 搜索

  ///搜索按钮列表 选择回调
  void searchBtnTypeOnChanged(ChoiceChipModel item) {
    if (item.title == searchBtnTypeName){
      return;
    }
    int index = searchBtnTypeList.indexWhere((element) => element.title == item.title);
    searchBtnTypeName = item.title;
    searchBtnTypeIndex = index;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.QUALITY_INSPECTION_MO_TASK_SEARCH_BTN_TYPE_INDEX_KEY, searchBtnTypeIndex);
    update();
  }

  void searchTCOnChanged() {
    dataListPageConfig.queryData!.remove('invdefine4'); ///产品图号
    dataListPageConfig.queryData!.remove('invcode');
    dataListPageConfig.queryData!.remove('invname');
    dataListPageConfig.queryData!.remove('taskcode');
    dataListPageConfig.queryData!.remove('PersonCode');
    switch (searchBtnTypeIndex){
      case 0:
        //region 产品图号搜索
        dataListPageConfig.queryData!['engineerfigno'] = searchTC.text;
        //endregion
        break;
      case 1:
        //region 产品编号搜索
        dataListPageConfig.queryData!['invcode'] = searchTC.text;
        //endregion
        break;
      case 2:
        //region 产品名称搜索
        dataListPageConfig.queryData!['invname'] = searchTC.text;
        //endregion
        break;
      case 3:
        //region 派工编号搜索
        dataListPageConfig.queryData!['taskcode'] = searchTC.text;
        //endregion
        break;
      case 4:
        //region 员工编号搜索
        dataListPageConfig.queryData!['PersonCode'] = searchTC.text;
        //endregion
        break;
    }
    update();
  }

  ///派工单搜索
  Future<void> searchTCOnSearch() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (searchTC.text.isEmpty){
      ToastNotification(Get.overlayContext!).warn('搜索的内容为空！');
      isLoading = false;
      return;
    }
    dataListPageConfig.queryData!.remove('invdefine4'); ///产品图号
    dataListPageConfig.queryData!.remove('invcode');
    dataListPageConfig.queryData!.remove('invname');
    dataListPageConfig.queryData!.remove('taskcode');
    dataListPageConfig.queryData!.remove('PersonCode');
    bool res = false;
    ProgressDialogUtil.showProgressDialog(msg: '正在返回搜索结果');

    switch (searchBtnTypeIndex){
      case 0:
        //region 产品图号搜索
        dataListPageConfig.queryData!['engineerfigno'] = searchTC.text;
        res = await pageChanged(pageIndex: 1, showLoading: false);
        //endregion
        break;
      case 1:
        //region 产品编号搜索
        dataListPageConfig.queryData!['invcode'] = searchTC.text;
        res = await pageChanged(pageIndex: 1, showLoading: false);
        //endregion
        break;
      case 2:
        //region 产品名称搜索
        dataListPageConfig.queryData!['invname'] = searchTC.text;
        res = await pageChanged(pageIndex: 1, showLoading: false);
        //endregion
        break;
      case 3:
        //region 派工编号搜索
        dataListPageConfig.queryData!['taskcode'] = searchTC.text;
        res = await pageChanged(pageIndex: 1, showLoading: false);
        //endregion
        break;
      case 4:
        //region 员工编号搜索
        dataListPageConfig.queryData!['PersonCode'] = searchTC.text;
        res = await pageChanged(pageIndex: 1, showLoading: false);
        //endregion
        break;
    }

    update();
    isLoading = false;
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1);
    }
  }

  ///清空搜索框内容
  Future<void> searchTCClear() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchTC.text = '';
    await pageChanged(pageIndex: 1, showLoading: false);
    isLoading = false;
    update();
  }

  //endregion

  ///检验类型选择变化
  void checkVoucherTypeOnChanged(ChoiceChipModel item) {
    if (checkVoucherType != item.keyName){
      for (var element in operationWayList) {
        element.isSelected = false;
      }
      item.isSelected = true;
      checkVoucherType = item.keyName;
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.QUALITY_INSPECTION_MO_TASK_CHECK_VOUCHER_TYPE_KEY, checkVoucherType);
      update();
    }
  }

  ///派工单当项选中变化
  void itemSelectedOnChanged(MoTaskModel item){
    if (item.isChoice){
      return;
    }
    for (var element in dataList) {
      element.isChoice = false;
    }
    item.isChoice = true;
    update();
  }

  ///派工单Item“展开按钮”点击变化
  void taskItemExpandedOnChanged(MoTaskModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }



  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async {
    if (actionName == DialogButtonActionEnum.confirm){
      int? checkVoucherCategory = checkVoucherType == 'firstCheckVoucher'
          ? 2
          : checkVoucherType == 'checkVoucher'
          ? 4
          : checkVoucherType == 'theLastCheckVoucher'
          ? 8
          : null;
      if (checkVoucherCategory == null){
        ToastNotification(Get.overlayContext!).error('请选择需要生成的检验单类型！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      MoTaskModel? selectedItem = dataList.firstWhereOrNull((element) => element.isChoice);
      if (selectedItem == null){
        ToastNotification(Get.overlayContext!).error('请选择需要生成检验单的派工单！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      return DialogReturnDataModel(
        isCanCloseDialog: true,
        data: {
          'taskId': selectedItem.taskId,
          'checkVoucherCategory': checkVoucherCategory,
        },
      );
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }


  @override
  void onClose() {
    searchTC.dispose();
    searchFN.dispose();
    super.onClose();
  }

}