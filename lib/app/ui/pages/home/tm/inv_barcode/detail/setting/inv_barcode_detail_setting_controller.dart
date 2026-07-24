import 'dart:convert';

import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/add_form/inv_barcode_add_form_controller.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/detail_tab/inv_barcode_detail_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/list/inv_barcode_list_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///物料条码新增查看 详情页 设置页面
class InvBarcodeDetailSettingController
    extends BaseSettingController
    with InvClassFrxNameInterface,
        InfoFormInterface,
        FormInterface,
        InterfaceUtil {

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  final InvBarcodeDetailTabController invBarcodeDetailTabController = Get.find<InvBarcodeDetailTabController>();
  InvBarcodeAddFormController? invBarcodeAddFormController;
  InvBarcodeListController? invBarcodeListController;

  final String type;

  @override
  final String title = '物料条码详情设置';

  @override
  late final List<ChoiceChipModel> tabValueList = [
    if (type == 'tab')
      ChoiceChipModel(icon: Icons.view_array_rounded, title: '默认选项卡', keyName: 'tab'),
    if (type == 'tab' || type == 'save')
      ...[
        ChoiceChipModel(
          icon: Icons.assignment, title: '条码新增', keyName: 'invBarcode',
          children: [
            ChoiceChipModel(title: '产品信息显示设置', keyName: 'invInfoForm'),
            ChoiceChipModel(title: '按钮显示设置', keyName: 'invBarcodeBtn'),
            ChoiceChipModel(title: '表单填写项显示设置', keyName: 'invBarcodeForm'),
            ChoiceChipModel(title: '表单填写设置', keyName: 'invBarcodeFormSetting'),
            ChoiceChipModel(title: '产品类别打印模板设置', keyName: 'invBarcodeInvClassTemplate')
          ]
        ),
      ],
    if (type == 'tab' || type == 'list')
      ...[
        ChoiceChipModel(icon: Icons.list, title: '条码列表设置', keyName: 'invBarcodeList'),
      ],
  ];

  //region 默认选项卡
  late int initialTabIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_DETAIL_INITIAL_INDEX_KEY) ?? AppConfig.initialIndex;

  late final List<ChoiceChipModel> detailTabList = invBarcodeDetailTabController.tabValueList.map(
          (e) => ChoiceChipModel(title: e)).toList();
  //endregion

  //region 条码新增-产品信息显示设置
  final List<InfoFormModel> invInfoFormList = [];
  //endregion

  //region 条码新增-按钮显示设置
  ///是否显示物料条码填报方式切换按钮
  bool isShowSaveTypeBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
  ///物料条码填报方式
  String saveType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_TYPE_KEY) ?? AppConfig.qtySubmit;
  ///页面上显示提交按钮（可显示多个，index 相加）
  int invBarcodeSaveBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_SAVE_BTN_INDEX_KEY) ?? AppConfig.invBarcodeSaveBtnIndex;
  //endregion

  //region 条码新增-表单填写项显示设置
  final ScrollController formScrollController = ScrollController();
  ///表单数据填写项的标题名称（排序以该 map 为准）
  final Map<String, String> formTitleMap = {};
  ///表单数据填写项的样式
  final Map<String, Map<String, dynamic>> formStyleMap = {};
  ///自动获取焦点的输入框字段名
  String numPadFocusField = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
  ///单列可显示的表单填写项的行数
  final int? formRowMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_FORM_ROW_MAX_COUNT_LIMIT_KEY) ?? AppConfig.formRowMaxCountLimit;
  late final TextEditingController formRowMaxCountLimitTC = TextEditingController(text: formRowMaxCountLimit?.toString() ?? '');
  final FocusNode formRowMaxCountLimitFN = FocusNode();
  //endregion

  //region 条码新增-表单填写设置
  ///整箱箱数可以填写的上限
  final int? numMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_NUM_MAX_COUNT_LIMIT_KEY) ?? AppConfig.numMaxCountLimit;
  late final TextEditingController numMaxCountLimitTC = TextEditingController(text: numMaxCountLimit?.toString() ?? '');
  final FocusNode numMaxCountLimitFN = FocusNode();
  ///“单箱数量”可以填写的下限 int?
  final double? singleBoxQtyMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_SINGLE_BOX_QTY_MAX_COUNT_LIMIT_KEY) ?? AppConfig.singleBoxQtyMaxCountLimit;
  late final TextEditingController singleBoxQtyMaxCountLimitTC = TextEditingController(text: singleBoxQtyMaxCountLimit?.toString() ?? '');
  final FocusNode singleBoxQtyMaxCountLimitFN = FocusNode();
  ///按重量填报时 产品称重的数据是否加到填报总数据上
  bool weightIsAddPieceWeightToTotal = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_WEIGHT_IS_ADD_PIECE_WEIGHT_TO_TOTAL_KEY) ?? AppConfig.weightIsAddPieceWeightToTotal;
  ///当填报方式是“按托填报”时，填报数据的计算方式
  ///
  ///0：填写“单箱数量”时，计算“单托箱数”、“尾箱数量”
  ///
  ///1：填写“单箱数量”时，计算“总数量”
  int calcRuleForPalletSaveType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_CALC_RULE_FOR_PALLET_SAVE_TYPE_KEY) ?? AppConfig.calcRuleForPalletSubmitType;
  ///是否保存上次提交物料条码时的填写的皮重数据或选择的装箱容器数据
  bool isSaveTheLastPackingWeightData = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY) ?? AppConfig.isSaveTheLastPackingWeightData;
  ///是否通过选择装箱容器，自动填充皮重、单箱数量
  bool isUsePackingPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_IS_USE_PACKING_PICKER_KEY) ?? AppConfig.isUsePackingPicker;
  ///“单箱数量”是否只能通过选择装箱容器来赋值，而不是手动输入
  late bool isSingleBoxQtyOnlyChangedByContainer = !isUsePackingPicker
      ? false
      : (ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY) ?? AppConfig.isSingleBoxQtyOnlyChangedByContainer);
  final String frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_TEMPLATE_FILENAME_KEY) ?? AppConfig.invBarcodePrintFileName;
  late final TextEditingController frxNameTC = TextEditingController(text: frxName);
  final FocusNode frxNameFN = FocusNode();
  ///物料条码提交提交成功后，是否返回到首页
  bool isGetBackAfterSaveSuccess = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
  //endregion

  //region 条码新增-产品类别打印模板设置
  ///根据产品类别编码区分的打印模板名称列表
  final Map<String, String> invClassFrxNameMap = {};
  //endregion

  //region 条码列表设置
  final ScrollController invBarcodeListScrollController = ScrollController();
  ///条码列表的单页显示记录数
  int pageConfigRows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
  ///物料条码删除时间限制
  final int? limitTime = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
  late final TextEditingController limitTimeTC = TextEditingController(text: limitTime?.toString() ?? '');
  final FocusNode limitTimeFN = FocusNode();
  ///物料条码信息显示设置
  final Map<int, List<InfoFormModel>> invBarcodeListInfoFormListMap = {};
  //endregion


  InvBarcodeDetailSettingController({
    super.progId = -1,
    required this.type,
    this.noPermission = false,
    this.permissionInfo = '',
  });


  @override
  void onInit() {
    super.onInit();

    //region TabView Get.find
    try {
      invBarcodeAddFormController = Get.find<InvBarcodeAddFormController>();
    } catch (e){}
    try {
      invBarcodeListController = Get.find<InvBarcodeListController>();
    } catch (e){}
    //endregion

    //region 条码新增-产品信息显示设置
    List<dynamic> invInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_INFO_FORM_LIST_KEY) ?? [];
    invInfoFormList.clear();
    invInfoFormList.addAll(
        getInfoFormListByStorage(
            invInfoFormMapList,
            AppConfig.invBarcodeInvFormInfoFormList
        )
    );
    //endregion

    //region 条码新增-表单填写项显示设置
    String formTitleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_FORM_TITLE_MAP_KEY) ?? '';
    formTitleMap.clear();
    formTitleMap.addAll(getFormTitleMapByStorage(formTitleMapStr, AppConfig.invBarcodeFormFormTitleMap));
    String formStyleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_FORM_STYLE_MAP_KEY) ?? '';
    formStyleMap.clear();
    formStyleMap.addAll(getFormStyleMapByStorage(formStyleMapStr, AppConfig.invBarcodeFormFormStyleMap));
    //endregion

    //region 条码新增-产品类别打印模板设置
    invClassFrxNameMap;
    String invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMap.clear();
    invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));
    //endregion

    //region 物料条码信息显示设置
    List<dynamic> invBarcodeListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_LIST_INFO_FORM_LIST_KEY) ?? [];
    invBarcodeListInfoFormListMap.clear();
    invBarcodeListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                invBarcodeListInfoFormMapList,
                AppConfig.invBarcodeListInfoFormList
            )
        )
    );
    //endregion
  }


  //region OnChanged

  //region 默认选项卡

  ///默认选项卡Item选择变化
  void initialIndexOnChanged(int index) {
    initialTabIndex = index;
    update();
  }

  //endregion

  //region 条码新增-按钮显示设置

  void isShowSaveTypeBtnOnChanged(){
    isShowSaveTypeBtn = !isShowSaveTypeBtn;
    update();
  }

  void saveTypeOnChanged(ChoiceChipModel item) {
    saveType = item.keyName;
    update();
  }

  void invBarcodeSaveBtnIndexOnChanged(int sign) {
    if (invBarcodeSaveBtnIndex & sign == sign){
      invBarcodeSaveBtnIndex -= sign;
    }
    else {
      invBarcodeSaveBtnIndex += sign;
    }
    update();
  }

  //endregion

  //region 条码新增-表单填写设置

  void weightIsAddPieceWeightToTotalOnChanged() {
    weightIsAddPieceWeightToTotal = !weightIsAddPieceWeightToTotal;
    update();
  }

  void calcRuleForPalletSaveTypeOnChanged(int index) {
    calcRuleForPalletSaveType = index;
    update();
  }

  void isSaveTheLastPackingWeightDataOnChanged() {
    isSaveTheLastPackingWeightData = !isSaveTheLastPackingWeightData;
    update();
  }

  void isUsePackingPickerOnChanged() {
    isUsePackingPicker = !isUsePackingPicker;
    if (!isUsePackingPicker){
      isSingleBoxQtyOnlyChangedByContainer = false;
    }
    update();
  }

  void isSingleBoxQtyOnlyChangedByContainerOnChanged() {
    if (!isUsePackingPicker){
      isSingleBoxQtyOnlyChangedByContainer = false;
    }
    else {
      isSingleBoxQtyOnlyChangedByContainer = !isSingleBoxQtyOnlyChangedByContainer;
    }
    update();
  }

  void isGetBackAfterSaveSuccessOnChanged(){
    isGetBackAfterSaveSuccess = !isGetBackAfterSaveSuccess;
    update();
  }

  //endregion

  //region 条码列表设置

  ///单页显示记录数 点击变化
  void pageConfigRowsOnChanged(int intValue) {
    pageConfigRows = intValue;
    update();
  }

  //endregion

  //endregion


  //region OnSave

  Future<void> initialIndexSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 1, msg: '正在保存', completedMsg: '数据保存成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_DETAIL_INITIAL_INDEX_KEY, initialTabIndex);
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 1);
  }

  Future<void> infoFormSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    List<Map<String, dynamic>> mapList = [];
    mapList.addAll(invInfoFormList.map((e) => e.toJson()));
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (invBarcodeAddFormController != null){
      invBarcodeAddFormController!.invInfoFormList.clear();
      invBarcodeAddFormController!.invInfoFormList.addAll(invInfoFormList);
      invBarcodeAddFormController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  Future<void> btnSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_IS_SHOW_TYPE_BTN_KEY, isShowSaveTypeBtn);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_TYPE_KEY, saveType);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_SAVE_BTN_INDEX_KEY, invBarcodeSaveBtnIndex);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (invBarcodeAddFormController != null){
      invBarcodeAddFormController!.isShowSaveTypeBtn = isShowSaveTypeBtn;
      invBarcodeAddFormController!.saveType = saveType;
      invBarcodeAddFormController!.numPadCTListSetEnabled();
      invBarcodeAddFormController!.invBarcodeSaveBtnIndex = invBarcodeSaveBtnIndex;
      invBarcodeAddFormController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  Future<void> reportFormSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    //region 提交前校验
    int? formRowMaxCountLimitTCInt = int.tryParse(formRowMaxCountLimitTC.text);
    if (formRowMaxCountLimitTC.text.isNotEmpty
        && (formRowMaxCountLimitTCInt == null || formRowMaxCountLimitTCInt < 1)){
      ToastNotification(Get.overlayContext!).warn('“单列可显示的表单填写项的行数”输入错误，请检查！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    String str = jsonEncode(formTitleMap);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_FORM_TITLE_MAP_KEY, str);
    String styleStr = jsonEncode(formStyleMap);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_FORM_STYLE_MAP_KEY, styleStr);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_NUM_PAD_FOCUS_FIELD_KEY, numPadFocusField);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_FORM_ROW_MAX_COUNT_LIMIT_KEY, formRowMaxCountLimitTCInt);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (invBarcodeAddFormController != null){
      invBarcodeAddFormController!.formTitleMap.clear();
      invBarcodeAddFormController!.formTitleMap.addAll(formTitleMap);
      invBarcodeAddFormController!.numPadCTList.sort((a, b){
        return numPadCTListSortVoidCallback.call(invBarcodeAddFormController!.formTitleMap, a, b);
      });
      invBarcodeAddFormController!.formStyleMap.clear();
      invBarcodeAddFormController!.formStyleMap.addAll(formStyleMap);
      invBarcodeAddFormController!.numPadCTList.forEach((element) {
        element.styleMap.clear();
        if (invBarcodeAddFormController!.formStyleMap.containsKey(element.key)){
          element.styleMap.addAll(invBarcodeAddFormController!.formStyleMap[element.key]!);
        }
      });
      invBarcodeAddFormController!.numPadFocusField = numPadFocusField;
      invBarcodeAddFormController!.formRowMaxCountLimit = formRowMaxCountLimitTCInt;
      invBarcodeAddFormController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  Future<void> reportFormSettingSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    //region 提交前校验
    int? numMaxCountLimitTCInt = int.tryParse(numMaxCountLimitTC.text);
    if (numMaxCountLimitTC.text.isNotEmpty
        && (numMaxCountLimitTCInt == null || numMaxCountLimitTCInt < 2)){
      ToastNotification(Get.overlayContext!).warn('“整箱箱数”的上限输入错误，请检查！');
      isLoading = false;
      return;
    }
    double? singleBoxQtyMaxCountLimitDouble = double.tryParse(singleBoxQtyMaxCountLimitTC.text);
    if (singleBoxQtyMaxCountLimitTC.text.isNotEmpty
        && (singleBoxQtyMaxCountLimitDouble == null || singleBoxQtyMaxCountLimitDouble <= 0)){
      ToastNotification(Get.overlayContext!).warn('“单箱数量”的下限输入错误，请检查！');
      isLoading = false;
      return;
    }
    if (frxNameTC.text.isEmpty){
      ToastNotification(Get.overlayContext!).warn('物料条码打印模板文件名称不能为空，请检查！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_NUM_MAX_COUNT_LIMIT_KEY, numMaxCountLimitTCInt);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_SINGLE_BOX_QTY_MAX_COUNT_LIMIT_KEY, singleBoxQtyMaxCountLimitDouble);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_WEIGHT_IS_ADD_PIECE_WEIGHT_TO_TOTAL_KEY, weightIsAddPieceWeightToTotal);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_CALC_RULE_FOR_PALLET_SAVE_TYPE_KEY, calcRuleForPalletSaveType);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY, isSaveTheLastPackingWeightData);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_IS_USE_PACKING_PICKER_KEY, isUsePackingPicker);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY, isSingleBoxQtyOnlyChangedByContainer);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_TEMPLATE_FILENAME_KEY, frxNameTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY, isGetBackAfterSaveSuccess);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (invBarcodeAddFormController != null){
      invBarcodeAddFormController!.numMaxCountLimit = numMaxCountLimitTCInt;
      invBarcodeAddFormController!.singleBoxQtyMaxCountLimit = singleBoxQtyMaxCountLimitDouble;
      invBarcodeAddFormController!.weightIsAddPieceWeightToTotal = weightIsAddPieceWeightToTotal;
      invBarcodeAddFormController!.calcRuleForPalletSaveType = calcRuleForPalletSaveType;
      invBarcodeAddFormController!.isSaveTheLastPackingWeightData = isSaveTheLastPackingWeightData;
      if (invBarcodeAddFormController!.isUsePackingPicker != isUsePackingPicker){
        invBarcodeAddFormController!.isUsePackingPicker = isUsePackingPicker;
        if (invBarcodeAddFormController!.isUsePackingPicker){
          NumPadUtil().setText(NumPadUtil.packingWeight, '', invBarcodeAddFormController!.numPadCTList);
          invBarcodeAddFormController!.calcQty(NumPadUtil.packingWeight);
          if (invBarcodeAddFormController!.containerWithNoPageAdapter == null){
            await invBarcodeAddFormController!.getContainerWithNoPageAdapter();
          }
          else {
            invBarcodeAddFormController!.containerWithNoPageAdapter?.clearSelection();
          }
        }
      }
      if (invBarcodeAddFormController!.isSingleBoxQtyOnlyChangedByContainer != isSingleBoxQtyOnlyChangedByContainer){
        invBarcodeAddFormController!.isSingleBoxQtyOnlyChangedByContainer = isSingleBoxQtyOnlyChangedByContainer;
        if (invBarcodeAddFormController!.isSingleBoxQtyOnlyChangedByContainer){
          NumPadUtil().setText(NumPadUtil.packingWeight, '', invBarcodeAddFormController!.numPadCTList);
          invBarcodeAddFormController!.calcQty(NumPadUtil.packingWeight);
          if (invBarcodeAddFormController!.containerWithNoPageAdapter == null){
            await invBarcodeAddFormController!.getContainerWithNoPageAdapter();
          }
          else {
            invBarcodeAddFormController!.containerWithNoPageAdapter?.clearSelection();
          }
        }
      }
      invBarcodeAddFormController!.frxName = frxNameTC.text;
      invBarcodeAddFormController!.isGetBackAfterSaveSuccess = isGetBackAfterSaveSuccess;
      invBarcodeAddFormController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  Future<void> invClassTemplateSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    String invClassFrxNameMapStr = json.encode(invClassFrxNameMap);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY, invClassFrxNameMapStr);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (invBarcodeAddFormController != null){
      invBarcodeAddFormController!.invClassFrxNameMap.clear();
      invBarcodeAddFormController!.invClassFrxNameMap.addAll(invClassFrxNameMap);
      invBarcodeAddFormController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  Future<void> invBarcodeListSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    //region 提交前校验
    int? limitTimeTCInt = int.tryParse(limitTimeTC.text);
    if (limitTimeTC.text.isNotEmpty
        && (limitTimeTCInt == null || limitTimeTCInt < 0)){
      ToastNotification(Get.overlayContext!).warn('“报工记录可删除的时间限制”输入错误，请检查！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_LIST_PAGE_CONFIG_ROWS_KEY, pageConfigRows);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_LIST_DELETE_LIMIT_TIME_KEY, int.tryParse(limitTimeTC.text));
    List<Map<String, dynamic>> mapList = [];
    invBarcodeListInfoFormListMap.forEach((key, value) {
      mapList.addAll(value.map((e) => e.toJson()));
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_LIST_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (invBarcodeListController != null){
      if (invBarcodeListController!.dataListPageConfig.rows != pageConfigRows){
        invBarcodeListController!.dataListPageConfig.rows = pageConfigRows;
        await invBarcodeListController!.pageChanged(showLoading: false);
      }
      invBarcodeListController!.limitTime = int.tryParse(limitTimeTC.text);
      invBarcodeListController!.invBarcodeListInfoFormListMap.clear();
      invBarcodeListController!.invBarcodeListInfoFormListMap.addAll(invBarcodeListInfoFormListMap);
      invBarcodeListController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  //endregion


  @override
  void onClose() {
    numMaxCountLimitTC.dispose();
    singleBoxQtyMaxCountLimitTC.dispose();
    frxNameTC.dispose();
    limitTimeTC.dispose();
    numMaxCountLimitFN.dispose();
    singleBoxQtyMaxCountLimitFN.dispose();
    frxNameFN.dispose();
    limitTimeFN.dispose();

    formRowMaxCountLimitTC.dispose();
    formRowMaxCountLimitFN.dispose();

    formScrollController.dispose();
    formScrollController.dispose();

    super.onClose();
  }

}