import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/detail/edit/mo_issuance_edit_controller.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///发料单 详情页 设置页面
class MoIssuanceDetailSettingController extends BaseSettingController {

  @override
  final String title = '发料单详情设置';

  @override
  late final List<ChoiceChipModel> tabValueList = [
    //ChoiceChipModel(icon: Icons.filter_alt_sharp, title: '默认选项卡', keyName: 'tab'),

    ChoiceChipModel(icon: Icons.assignment, title: '报工设置', keyName: 'submit'),
  ];

  /*//region 默认选项卡
  late final MoIssuanceDetailTabController? issuanceDetailTabController;
  int initialTabIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MO_ISSUANCE_DETAIL_INITIAL_INDEX_KEY) ?? AppConfig.initialIndex;
  final List<ChoiceChipModel> detailTabList = [];
  //endregion*/

  //region 打印设置
  ///打印 人员是否可以通过 Adapter 选单
  bool isSubmitPsnHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MO_ISSUANCE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;

  ///发料人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间
  int submitPsnGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MO_ISSUANCE_SUBMIT_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
  ///发料人员人员获取条件 车间固定值
  final String submitPsnDepCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MO_ISSUANCE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
  ///发料人员人员获取条件 车间固定值
  late final TextEditingController submitPsnDepCodeTC = TextEditingController(text: submitPsnDepCode.toString());
  ///发料人员人员获取条件 车间固定值
  final FocusNode submitPsnDepCodeFN = FocusNode();

  ///报工 打印模板名称
  String submitPrinterFrxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MO_ISSUANCE_SUBMIT_TEMPLATE_FILENAME_KEY) ?? AppConfig.moIssuancePrintFileName;
  ///报工 打印模板名称
  late final TextEditingController submitPrinterFrxNameTC = TextEditingController(text: submitPrinterFrxName);
  ///报工 打印模板名称
  final FocusNode submitPrinterFrxNameFN = FocusNode();
  //endregion

  MoIssuanceEditController? issuanceEditController;


  MoIssuanceDetailSettingController({
    super.progId = -1,
  });


  @override
  void onInit() {
    super.onInit();
    try{
      issuanceEditController = Get.find<MoIssuanceEditController>();
    } catch (e){}
  }

  @override
  Future<bool> initializeForm() async {
    /*bool res1;
    try {
      issuanceDetailTabController = Get.find<MoIssuanceDetailTabController>();
      detailTabList.clear();
      for (int index = 0; index < issuanceDetailTabController!.tabValueList.length; index ++) {
        detailTabList.add(
            ChoiceChipModel(title: issuanceDetailTabController!.tabValueList[index])
        );
      }
      res1 = true;
    } catch (e){
      issuanceDetailTabController = null;
      ToastNotification(Get.overlayContext!).error('获取选项卡列表时出错：');
      res1 = false;
    }
    update();

    return res1;*/
    return true;
  }


  //region OnChanged

  /*///默认选项卡Item选择变化
  void initialIndexOnChanged(int index) {
    initialTabIndex = index;
    update();
  }*/

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

  ///报工设置保存
  Future<void> submitSave() async{
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
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MO_ISSUANCE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY, isSubmitPsnHasAdapter);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MO_ISSUANCE_SUBMIT_PSN_GET_WAY_INDEX_KEY, submitPsnGetWayIndex);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MO_ISSUANCE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY, submitPsnDepCodeTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MO_ISSUANCE_SUBMIT_TEMPLATE_FILENAME_KEY, submitPrinterFrxNameTC.text);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '数据保存成功，正在刷新！');

    //region 数据刷新
    if (issuanceEditController != null){
      bool isNeedGetPersonAdapter = false;
      if (issuanceEditController!.isPsnHasAdapter != isSubmitPsnHasAdapter){
        issuanceEditController!.editIssuanceModel.issuer = '';
        issuanceEditController!.isPsnHasAdapter = isSubmitPsnHasAdapter;
        if (issuanceEditController!.isPsnHasAdapter){
          isNeedGetPersonAdapter = true;
        }
        else {
          issuanceEditController!.personModel = PersonModel();
        }
      }
      if (issuanceEditController!.psnGetWayIndex != submitPsnGetWayIndex
          || issuanceEditController!.psnDepCode != submitPsnDepCodeTC.text){
        issuanceEditController!.editIssuanceModel.issuer = '';
        issuanceEditController!.psnGetWayIndex = submitPsnGetWayIndex;
        issuanceEditController!.psnDepCode = submitPsnDepCodeTC.text;
        if (issuanceEditController!.isPsnHasAdapter){
          isNeedGetPersonAdapter = true;
        }
      }
      if (isNeedGetPersonAdapter){
        await issuanceEditController!.getPersonAdapter();
      }
      issuanceEditController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  //endregion



}