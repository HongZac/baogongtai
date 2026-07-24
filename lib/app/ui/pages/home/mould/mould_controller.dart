import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///模具查询 首页
class MouldController extends BaseFormWithPageDataController<MouldModel> {

  //region 搜索
  ///0：模具编号搜索      1: 模具名称搜索
  int searchBtnTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MOULD_SEARCH_BTN_TYPE_INDEX_KEY) ?? AppConfig.searchBtnTypeIndex;
  late String searchBtnTypeName = searchBtnTypeList.firstWhereOrNull((element) => element.isSelected)?.title ?? '';

  ///搜索按钮列表
  late final List<ChoiceChipModel> searchBtnTypeList = [
    ChoiceChipModel(title: '模具编号搜索', keyName: 'mouldCode', icon: Icons.search, isSelected: searchBtnTypeIndex == 0),
    ChoiceChipModel(title: '模具名称搜索', keyName: 'mouldName', icon: Icons.search, isSelected: searchBtnTypeIndex == 1),
  ];

  ///搜索按钮列表
  late final List<Widget> searchBtnTypeMenuList = searchBtnTypeList.map((e) {
    return MenuItemButton(
      onPressed: () {
        searchBtnTypeOnChanged(e);
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
            const EdgeInsets.only(top: 22, bottom: 22, left: 12, right: 44)),
      ),
      child: MenuAcceleratorLabel(e.title),
    );
  }).toList();
  final TextEditingController searchTC = TextEditingController();
  final FocusNode searchFN = FocusNode();

  //endregion

  MouldController({
    super.progId = 700200,
    super.isNeedGetObjectItem = false,
  });


  @override
  void onInit() {
    super.onInit();
    dataListPageConfig.rows = 10;
    dataListPageConfig.sidx = 'MouldCode';
    dataListPageConfig.sord = 'asc';
    dataListPageConfig.queryData = {}; ///PreProgID 一定是 700201
  }

  @override
  Future<void> onReady() async {
    await super.onReady();
    searchFN.addListener(() async {
      if (rootCtl.isKeyboardOpenAfterClickTC && searchFN.hasFocus && !kIsWeb && GetPlatform.isWindows){
        await rootCtl.openKeyboard();
      }
    });
  }

  @override
  Future<bool> initializeForm() async {
    return true;
  }

  @override
  Future<PageResult<MouldModel>> getDataList(PageConfig pageConfig) async {
    var res = await MouldRepository().getPageList(pageConfig);
    return res;
  }


  ///搜索按钮列表 选择回调
  void searchBtnTypeOnChanged(ChoiceChipModel item) {
    if (item.title == searchBtnTypeName){
      return;
    }
    int index = searchBtnTypeList.indexWhere((element) => element.title == item.title);
    searchBtnTypeName = item.title;
    searchBtnTypeIndex = index;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MOULD_SEARCH_BTN_TYPE_INDEX_KEY, searchBtnTypeIndex);
    update();
  }


  //region 搜索

  void searchTCOnChanged() {
    dataListPageConfig.queryData!.remove('mouldCode');
    dataListPageConfig.queryData!.remove('mouldName');
    switch (searchBtnTypeIndex){
      case 0:
        //region 模具编号搜索
        dataListPageConfig.queryData!['mouldCode'] = searchTC.text;
        //endregion
        break;
      case 1:
        //region 模具名称搜索
        dataListPageConfig.queryData!['mouldName'] = searchTC.text;
        //endregion
        break;
    }
    update();
  }

  ///搜索按钮点击回调
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
    dataListPageConfig.queryData!.remove('mouldCode');
    dataListPageConfig.queryData!.remove('mouldName');
    bool res = false;
    ProgressDialogUtil.showProgressDialog(msg: '正在返回搜索结果');

    switch (searchBtnTypeIndex){
      case 0:
        //region 模具编号搜索
        dataListPageConfig.queryData!['mouldCode'] = searchTC.text;
        res = await pageChanged(pageIndex: 1, showLoading: false);
        //endregion
        break;
      case 1:
        //region 模具名称搜索
        dataListPageConfig.queryData!['mouldName'] = searchTC.text;
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

  ///搜索内容清空
  Future<void> searchTCClear() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    ProgressDialogUtil.showProgressDialog();

    searchTC.clear();
    dataListPageConfig.queryData!.remove('mouldCode');
    dataListPageConfig.queryData!.remove('mouldName');
    dataList.clear();
    total = 0;
    totalPage = 0;
    nowPage = 0;

    isLoading = false;
    update();
    ProgressDialogUtil.update(value: 1);
  }

  //endregion


  ///模具附件查看
  Future<void> itemAttach(MouldModel item) async {
    if (item.mouldId.isEmpty){
      ToastNotification(Get.overlayContext!).error('无法获取模具附件！');
      return;
    }
    Get.rootDelegate.toNamed(
      AppRoutes.MOULD_ATTACH_PAGE,
      parameters: {
        'pageTitle': '模具附件-${item.mouldName}',
        'id': item.mouldId,
        'progId': '700201',
        'category': 'attach',
      }
    );
  }


  @override
  void onClose() {
    searchTC.dispose();
    searchFN.dispose();
    super.onClose();
  }

}
