import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/work_center_allocate/work_center_allocate_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/work_center_allocate/work_center_allocate_view.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///加工中心 660022
class WorkCenterController extends BaseFormController {

  ///Item 高度固定
  final double itemHeight = 84;
  double itemWidth = 0;
  double itemAspectRatio = 2.7;

  ///加工中心列表-原始数组
  final List<MoWorkCenterModel> workCenterList = [];
  ///加工中心列表-过滤后的数组
  final List<MoWorkCenterModel> workCenterFilterList = [];
  final ScrollController workCenterListController = ScrollController();

  //region 搜索
  final TextEditingController searchTC = TextEditingController();
  final FocusNode searchFN = FocusNode();
  ///搜索时启用时间防抖，超过一定时间不输入才正式搜索数据
  final Debounce _debounce = Debounce(Duration(milliseconds: 1500));
  bool isSearchWidgetOpen = false;
  //endregion

  //region 状态列表
  ///不显示的机器状态列表
  final List<int> unVisibleDeviceSignList = [];
  late final List<ChoiceChipModel> deviceSignList = [
    ///全部 -1
    ChoiceChipModel(
        sign: -1, keyName: 'all',
        title: '全部', isSelected: true,
        activeColor: AppColors.totalColor,
        icon: Icons.computer,
    ),
    ///运行 1
    ChoiceChipModel(
        sign: 1, keyName: 'run',
        title: '运行',
        activeColor: AppColors.runColor,
        icon: Icons.online_prediction,
    ),
    ///待机 2
    ChoiceChipModel(
        sign: 2, keyName: 'standby',
        title: '待机',
        activeColor: AppColors.standByColor,
        icon: Icons.access_time_outlined,
    ),
    ///停机 4
    ChoiceChipModel(
        sign: 4, keyName: 'stop',
        title: '停机',
        activeColor: AppColors.stopColor,
        icon: Icons.warning,
    ),
    ///未连接 8
    ChoiceChipModel(
        sign: 8, keyName: 'notConnected',
        title: '未连接',
        activeColor: AppColors.notConnectedColor,
        icon: Icons.wifi_off,
    ),
    ChoiceChipModel(
        sign: 16, keyName: 'noSign',
        title: '无状态',
        activeColor: AppColors.notConnectedColor,
        icon: Icons.no_sim,
    ),
  ];
  //endregion


  WorkCenterController({
    super.progId = 660022,
  });

  @override
  void onInit() {
    super.onInit();
    List<dynamic> list = ShareStorageUtil.instance?.read(SharedPreferencesKeys.WORK_CENTER_UN_VISIBLE_DEVICE_SIGN_LIST_KEY) ?? [];
    unVisibleDeviceSignList.addAll(list.map((e) => int.tryParse(e.toString()) ?? -1).toList());
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

  Future<bool> initializeForm() async {
    bool res = await getWorkCenterList();
    return res;
  }

  Future<bool> getWorkCenterList() async {
    PageConfig pageConfig = PageConfig(
      page: 1,
      rows: 1000,
      sord: 'desc',
      queryData: {},
    );
    var res = await MoWorkCenterRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取加工中心列表时出错：${res.message}');
      return false;
    }
    workCenterList.clear();
    workCenterList.addAll(res.rows);
    getFilterOfWorkCenterList();
    getNumOfDeviceSign();
    return true;
  }

  void getFilterOfWorkCenterList() {
    workCenterList.forEach((element) {
      element.isVisibleOfDeviceSign = true;
      if (unVisibleDeviceSignList.contains(element.sign) || (element.sign == null && unVisibleDeviceSignList.contains(16))){
        element.isVisibleOfDeviceSign = false;
      }
    });
    List<MoWorkCenterModel> filterList = workCenterList.where(
            (element) => element.isVisibleOfDeviceSign).toList();
    this.workCenterFilterList.clear();
    this.workCenterFilterList.addAll(filterList);
  }

  void getNumOfDeviceSign() {
    deviceSignList[0].content = workCenterList.length.toString();
    deviceSignList[1].content = workCenterList.where((element) => element.sign == DeviceSign.scz.sign).length.toString();
    deviceSignList[2].content = workCenterList.where((element) => element.sign == DeviceSign.dj.sign).length.toString();
    deviceSignList[3].content = workCenterList.where((element) => element.sign == DeviceSign.tjz.sign).length.toString();
    deviceSignList[4].content = workCenterList.where((element) => element.sign == DeviceSign.wlj.sign).length.toString();
    deviceSignList[5].content = workCenterList.where((element) => element.sign == null).length.toString();
  }

  ///设备状态标签选择变化
  Future<void> deviceSignOnChanged(ChoiceChipModel item) async {
    if(item.sign == -1){
      return;
    }
    if (unVisibleDeviceSignList.contains(item.sign)){
      unVisibleDeviceSignList.remove(item.sign);
    }
    else {
      unVisibleDeviceSignList.add(item.sign);
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.WORK_CENTER_UN_VISIBLE_DEVICE_SIGN_LIST_KEY, unVisibleDeviceSignList);

    for (var element in workCenterList){
      element.isVisibleOfDeviceSign = true;
      if (unVisibleDeviceSignList.contains(element.sign) || (element.sign == null && unVisibleDeviceSignList.contains(16))){
        element.isVisibleOfDeviceSign = false;
      }
    }
    List<MoWorkCenterModel> filterList = workCenterList.where(
            (element) => element.isVisibleOfDeviceSign).toList();
    this.workCenterFilterList.clear();
    this.workCenterFilterList.addAll(filterList);

    update();
  }

  Future<void> itemOnDoubleTap(MoWorkCenterModel item) async {
    Get.rootDelegate.toNamed(
      AppRoutes.WORK_CENTER_DETAIL_MAIN_PAGE,
      parameters: {
        'progId': progId.toString(),
        'workCenterId': item.id,
      }
    );
  }

  ///加工中心分配
  Future<void> wcAllocate(MoWorkCenterModel item) async {
    await DialogUtils.showCustomDialog<WorkCenterAllocateController, bool>(
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
    );
  }


  //region 搜索

  ///搜索框输入变化
  Future<void> searchTCOnSearch() async {
    _debounce(() async{
      searchFN.unfocus();
      await workCenterCodeSearch();
      update();
    });
  }

  ///搜索框清空
  Future<void> searchTCClear() async{
    searchTC.text = '';
    isSearchWidgetOpen = false;
    await workCenterCodeSearch();
    searchFN.unfocus();
    update();
  }

  ///根据加工中心编号搜索
  Future<void> workCenterCodeSearch() async{
    ProgressDialogUtil.showProgressDialog();
    List<MoWorkCenterModel> filterList = workCenterList.where(
            (element) => element.isVisibleOfDeviceSign
            && (element.lineCode ?? '').toLowerCase().contains(searchTC.text)).toList();
    this.workCenterFilterList.clear();
    this.workCenterFilterList.addAll(filterList);
    ProgressDialogUtil.update(value: 1, msg: '查询成功！');
  }

  //endregion


  @override
  void onClose() {
    _debounce.dispose();
    searchTC.dispose();
    searchFN.dispose();
    workCenterListController.dispose();
    super.onClose();
  }

}