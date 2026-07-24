import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/work_center_allocate/work_center_allocate_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/work_center_allocate/work_center_allocate_view.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///产线管理 660003；加工中心 660022; 生产班组 660021 ; 生产工位 660025 ;
class BeltLineController extends BaseFormController {

  late final String typeTitle = progId == 660003
      ? '生产产线'
      : progId == 660021
      ? '生产班组'
      : progId == 660025
      ? '生产工位'
      : '';
  ///产线分类 0:生产线，1:加工中心，2 生产班组,3 生产工位
  late final int lineClass = progId == 660003
      ? 0
      : progId == 660021
      ? 2
      : progId == 660025
      ? 3
      : -1;

  ///Item 高度固定
  final double itemHeight = 84;
  double itemWidth = 0;
  double itemAspectRatio = 2.7;

  ///产线列表-原始数组
  final List<MoBeltLineModel> beltLineList = [];
  ///产线列表-过滤后的数组
  final List<MoBeltLineModel> beltLineFilterList = [];
  final ScrollController beltLineListController = ScrollController();

  //region 搜索
  final TextEditingController searchTC = TextEditingController();
  final FocusNode searchFN = FocusNode();
  ///搜索时启用时间防抖，超过一定时间不输入才正式搜索数据
  final Debounce _debounce = Debounce(Duration(milliseconds: 1500));
  //endregion


  BeltLineController({
    required super.progId,
  });

  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    await super.onReady();
    searchFN.addListener(() async {
      if (rootCtl.isKeyboardOpenAfterClickTC && searchFN.hasFocus && !kIsWeb && GetPlatform.isWindows){
        await rootCtl.openKeyboard();
      }
      update();
    });
  }

  Future<bool> initializeForm() async {
    bool res = await geBeltLineList();
    return res;
  }

  Future<bool> geBeltLineList() async {
    PageConfig pageConfig = PageConfig(
      page: 1,
      rows: 1000,
      sord: 'desc',
      queryData: {
        'LineClass': lineClass,
      },
    );
    var res = await MoBeltLineRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取$typeTitle列表时出错：${res.message}');
      return false;
    }
    beltLineList.clear();
    beltLineList.addAll(res.rows);
    beltLineFilterList.clear();
    beltLineFilterList.addAll(beltLineList);
    return true;
  }


  Future<void> itemOnDoubleTap(MoBeltLineModel item) async {
    String route = '';
    if (progId == 660003){
      route = AppRoutes.BELT_LINE_DETAIL_MAIN_PAGE;
    }
    else if (progId == 660021){
      route = AppRoutes.TEAM_GROUP_DETAIL_MAIN_PAGE;
    }
    Get.rootDelegate.toNamed(
      route,
      parameters: {
        'progId': progId.toString(),
        'workCenterId': item.id,
      }
    );
  }

  ///分配
  Future<void> blAllocate(MoBeltLineModel item) async {
    await DialogUtils.showCustomDialog<WorkCenterAllocateController, bool>(
      Get.context!, title: '$typeTitle分配',
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
      await beltLineCodeSearch();
      update();
    });
  }

  ///搜索框清空
  Future<void> searchTCClear() async{
    searchTC.text = '';
    await beltLineCodeSearch();
    update();
  }

  ///根据产线编号搜索
  Future<void> beltLineCodeSearch() async{
    ProgressDialogUtil.showProgressDialog();
    List<MoBeltLineModel> filterList = beltLineList.where(
            (element) => (element.lineCode ?? '').toLowerCase().contains(searchTC.text)).toList();
    this.beltLineFilterList.clear();
    this.beltLineFilterList.addAll(filterList);
    ProgressDialogUtil.update(value: 1, msg: '查询成功！');
  }

  //endregion



  @override
  void onClose() {
    _debounce.dispose();
    searchTC.dispose();
    searchFN.dispose();
    beltLineListController.dispose();
    super.onClose();
  }

}