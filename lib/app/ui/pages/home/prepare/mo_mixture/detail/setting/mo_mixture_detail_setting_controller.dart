import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/detail_tab/mo_mixture_detail_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/submit/mo_mixture_submit_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/submit_list/mo_mixture_submit_list_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///拌料单 OR 粉料单 详情页 设置页面
class MoMixtureDetailSettingController extends BaseSettingController {

  ///主页面的 progId
  final mainProgId;
  late final String typeTitle = mainProgId == 651071 ? '拌料' : mainProgId == 651076 ? '粉料' : '';

  @override
  late final String title = '$typeTitle单详情设置';

  @override
  late final List<ChoiceChipModel> tabValueList = [
    ChoiceChipModel(icon: Icons.view_array_rounded, title: '默认选项卡', keyName: 'tab'),

    ChoiceChipModel(icon: Icons.assignment, title: '报工设置', keyName: 'submit'),
   ];

  //region 默认选项卡
  late final MoMixtureDetailTabController? mixtureDetailTabController;
  late int initialTabIndex = ShareStorageUtil.instance?.read(
      ShareKeyUtil().getMoPowderSharedPreferencesKey(
          mainProgId,
          SharedPreferencesKeys.MO_MIXTURE_DETAIL_INITIAL_INDEX_KEY
      )
  ) ?? AppConfig.initialIndex;
  final List<ChoiceChipModel> detailTabList = [];
  //endregion

  //region 报工设置
  ///报工 人员是否可以通过 Adapter 选单
  late bool isSubmitPsnHasAdapter = ShareStorageUtil.instance?.read(
      ShareKeyUtil().getMoPowderSharedPreferencesKey(
          mainProgId,
          SharedPreferencesKeys.MO_MIXTURE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY
      )
  ) ?? AppConfig.isPsnHasAdapter;

  ///报工生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间
  late int submitPsnGetWayIndex = ShareStorageUtil.instance?.read(
    ShareKeyUtil().getMoPowderSharedPreferencesKey(
        mainProgId,
        SharedPreferencesKeys.MO_MIXTURE_SUBMIT_PSN_GET_WAY_INDEX_KEY
    )
  ) ?? AppConfig.psnGetWayIndex;
  ///报工生产人员获取条件 车间固定值
  late final String submitPsnDepCode = ShareStorageUtil.instance?.read(
    ShareKeyUtil().getMoPowderSharedPreferencesKey(
        mainProgId,
        SharedPreferencesKeys.MO_MIXTURE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY
    )
  ) ?? AppConfig.psnDepCode;
  ///报工生产人员获取条件 车间固定值
  late final TextEditingController submitPsnDepCodeTC = TextEditingController(text: submitPsnDepCode.toString());
  ///报工生产人员获取条件 车间固定值
  final FocusNode submitPsnDepCodeFN = FocusNode();

  ///报工单删除时间限制
  late int? submitLimitTime = ShareStorageUtil.instance?.read(
      ShareKeyUtil().getMoPowderSharedPreferencesKey(
          mainProgId,
          SharedPreferencesKeys.MO_MIXTURE_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY
      )
  ) ?? AppConfig.limitTime;
  ///报工单删除时间限制
  late final TextEditingController submitLimitTimeTC = TextEditingController(text: (submitLimitTime ?? '').toString());
  ///报工单删除时间限制
  final FocusNode submitLimitTimeFN = FocusNode();

  ///报工 打印模板名称
  late String submitPrinterFrxName = ShareStorageUtil.instance?.read(
      ShareKeyUtil().getMoPowderSharedPreferencesKey(
          mainProgId,
          SharedPreferencesKeys.MO_MIXTURE_SUBMIT_TEMPLATE_FILENAME_KEY
      )
  ) ?? AppConfigUtil().getMoPowderAppConfig(mainProgId, AppConfig.moMixtureSubmitPrintFileName);
  ///报工 打印模板名称
  late final TextEditingController submitPrinterFrxNameTC = TextEditingController(text: submitPrinterFrxName);
  ///报工 打印模板名称
  final FocusNode submitPrinterFrxNameFN = FocusNode();
  //endregion

  MoMixtureSubmitController? mixtureSubmitController;
  MoMixtureSubmitListController? mixtureSubmitListController;


  MoMixtureDetailSettingController({
    super.progId = -1,
    required this.mainProgId,
  });


  @override
  void onInit() {
    super.onInit();
    try{
      mixtureSubmitController = Get.find<MoMixtureSubmitController>();
    } catch (e){}
    try{
      mixtureSubmitListController = Get.find<MoMixtureSubmitListController>();
    } catch (e){}
  }

  @override
  Future<bool> initializeForm() async {
    bool res1;
    try {
      mixtureDetailTabController = Get.find<MoMixtureDetailTabController>();
      detailTabList.clear();
      for (int index = 0; index < mixtureDetailTabController!.tabValueList.length; index ++) {
        detailTabList.add(
            ChoiceChipModel(title: mixtureDetailTabController!.tabValueList[index])
        );
      }
      res1 = true;
    } catch (e){
      mixtureDetailTabController = null;
      ToastNotification(Get.overlayContext!).error('获取选项卡列表时出错：');
      res1 = false;
    }
    update();

    return res1;
  }


  //region OnChanged

  ///默认选项卡Item选择变化
  void initialIndexOnChanged(int index) {
    initialTabIndex = index;
    update();
  }

  ///报工 人员是否可以通过 Adapter 选单
  void isSubmitPsnHasAdapterOnChanged(){
    isSubmitPsnHasAdapter = !isSubmitPsnHasAdapter;
    update();
  }

  ///报工 生产人员获取条件的Key
  void submitPsnGetWayIndexOnChanged(int index){
    submitPsnGetWayIndex = index;
    update();
  }

  //endregion


  //region OnSave

  ///默认选项卡保存
  Future<void> initialIndexSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 1, msg: '正在保存', completedMsg: '数据保存成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(
        ShareKeyUtil().getMoPowderSharedPreferencesKey(
            mainProgId,
            SharedPreferencesKeys.MO_MIXTURE_DETAIL_INITIAL_INDEX_KEY
        ),
        initialTabIndex
    );
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 1);
  }

  ///报工设置保存
  Future<void> submitSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;

    int? submitLimitTime = int.tryParse(submitLimitTimeTC.text);
    if (submitLimitTime == null && submitLimitTimeTC.text.isNotEmpty){ ///submitLimitTimeTC.text = ''; 为空代表无限制
      ToastNotification(Get.overlayContext!).error('“报工单可删除的时间限制”输入有误！');
      isLoading = false;
      return;
    }

    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(
        ShareKeyUtil().getMoPowderSharedPreferencesKey(
            mainProgId,
            SharedPreferencesKeys.MO_MIXTURE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY
        ),
        isSubmitPsnHasAdapter
    );
    ShareStorageUtil.instance?.write(
        ShareKeyUtil().getMoPowderSharedPreferencesKey(
            mainProgId,
            SharedPreferencesKeys.MO_MIXTURE_SUBMIT_PSN_GET_WAY_INDEX_KEY
        ),
        submitPsnGetWayIndex
    );
    ShareStorageUtil.instance?.write(
        ShareKeyUtil().getMoPowderSharedPreferencesKey(
            mainProgId,
            SharedPreferencesKeys.MO_MIXTURE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY
        ),
        submitPsnDepCodeTC.text
    );
    ShareStorageUtil.instance?.write(
        ShareKeyUtil().getMoPowderSharedPreferencesKey(
            mainProgId,
            SharedPreferencesKeys.MO_MIXTURE_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY
        ),
        submitLimitTime
    );
    ShareStorageUtil.instance?.write(
        ShareKeyUtil().getMoPowderSharedPreferencesKey(
            mainProgId,
            SharedPreferencesKeys.MO_MIXTURE_SUBMIT_TEMPLATE_FILENAME_KEY
        ),
        submitPrinterFrxNameTC.text
    );
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '数据保存成功，正在刷新！');

    //region 数据刷新
    if (mixtureSubmitController != null){
      bool isNeedGetPersonAdapter = false;
      if (mixtureSubmitController!.isPsnHasAdapter != isSubmitPsnHasAdapter){
        mixtureSubmitController!.mixSubmitModel.empId = '';
        mixtureSubmitController!.mixSubmitModel.employee = '';
        mixtureSubmitController!.isPsnHasAdapter = isSubmitPsnHasAdapter;
        if (mixtureSubmitController!.isPsnHasAdapter){
          isNeedGetPersonAdapter = true;
        }
        else {
          mixtureSubmitController!.personModel = PersonModel();
        }
      }
      if (mixtureSubmitController!.psnGetWayIndex != submitPsnGetWayIndex
          || mixtureSubmitController!.psnDepCode != submitPsnDepCodeTC.text){
        mixtureSubmitController!.mixSubmitModel.empId = '';
        mixtureSubmitController!.mixSubmitModel.employee = '';
        mixtureSubmitController!.psnGetWayIndex = submitPsnGetWayIndex;
        mixtureSubmitController!.psnDepCode = submitPsnDepCodeTC.text;
        if (mixtureSubmitController!.isPsnHasAdapter){
          isNeedGetPersonAdapter = true;
        }
      }
      if (isNeedGetPersonAdapter){
        await mixtureSubmitController!.getPersonAdapter();
      }
      mixtureSubmitController!.update();
    }
    if (mixtureSubmitListController != null){
      mixtureSubmitListController!.limitTime = submitLimitTime;
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  //endregion




  @override
  void onClose() {
    super.onClose();
  }

}