// ignore_for_file: unnecessary_overrides, empty_catches

import 'dart:math';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:uuid/uuid.dart';

import 'package:basement/item_model.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/model/adapter_key_model.dart';
import 'package:desktop/app/model/text_edit_controller_key_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/wage_piece/quality_inspection_wage_piece_controller.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/wage_piece/quality_inspection_wage_piece_view.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/quality_inspection_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';


///质量巡检 首巡末检检验单详情页（编辑 + 查看）
class QualityInspectionDetailFormController extends BaseFormController{

  ///报检单Id
  final String moInspectId;
  ///检验单Id
  final String moCheckId;
  ///派工单Id（通过派工单ID，生成检验单）
  final String taskId;
  ///派工单生成的检验单类型， 1：来料检验 2：首检 4：巡检 8：末检 16：产品终检（该数据一定不会是 终检） 32：自检
  final int taskToCheckVoucherCategory;

  ///0：质量巡检； 1：注塑实时监测-设备详情
  final int openType;

  ///指标类型切换列表 sign 0 按单件；1 按批次；
  final List<ChoiceChipModel> chkGuidTypeList = [
    ChoiceChipModel(title: '按单件', keyName: 'bySingleItem', sign: 0),
    ChoiceChipModel(title: '按批次', keyName: 'byBatch', sign: 1),
  ];
  ///当前正在填报的指标类型 sign 0 按单件；1 按批次；
  late ChoiceChipModel chkGuidType = chkGuidTypeList[0];
  ///是否显示列表；
  ///切换显示指标类型时，暂时隐藏列表，重新分配 ExpansionTile.controller
  bool isShowList = true;

  ///检验单
  MoCheckVoucherItem checkVoucherItem = MoCheckVoucherItem();
  final ScrollController detailScrollController = ScrollController();
  ///当前检验单已完成数目
  int finishedNum = 0;
  ///当前检验单总数目
  int totalNum = 0;
  ///是否可以新增检验方案
  bool canAddCheckGuide = false;

  ///结论列表Adapter的列表
  final List<AdapterKeyModel> verdictOptionAdapterList = [];
  ///TextEditingController列表
  final List<TextEditingControllerKeyModel> tCList = [];
  ///缺陷原因Adapter列表
  final List<AdapterKeyModel> comDefectsAdapterList = [];
  ///按批次填报时的缺陷数量的TextEditingController列表
  final List<TextEditingControllerKeyModel> byBatchTCList = [];
  ///首检类别Adapter
  DataItemAdapter? checkVouchTypeAdapter;
  ///提交人员选择Adapter
  PersonAdapter? personAdapter;
  final ScrollController dataReportScrollController = ScrollController();

  ///表体展开框的控制器列表
  final Map<String, ExpansibleController> expansionTileControllerBySingleItemMap = {};
  final Map<String, bool> expansionSignBySingleItemMap = {};
  final Map<String, ExpansibleController> expansionTileControllerByBatchMap = {};
  final Map<String, bool> expansionSignByBatchMap = {};

  final List<NumPadController> numPadCTList = [
    NumPadController(key: 'desc', zhName: '备注', keyboardType: TextInputType.text),
  ];

  ///附件列表
  DMDocumentModel dMDocumentModel = DMDocumentModel();

  ///检验指标Adapter
  CheckGuideAdapter? checkGuideAdapter;

  QualityInspectionController? qualityInspectionController;


  QualityInspectionDetailFormController({
    super.progId = 811021,
    required this.moInspectId,
    required this.moCheckId,
    required this.taskId,
    required this.taskToCheckVoucherCategory,
    required this.openType,
  });


  @override
  void onInit() {
    super.onInit();
    try {
      qualityInspectionController = Get.find<QualityInspectionController>();
    } catch(e){}
  }

  @override
  Future<bool> initializeForm() async {
    bool res = await getCheckVoucherItem();
    await getOpDescription();
    await getCheckVoucherAttach();
    getDefaultVerdictOfCheckVoucherItem();
    getChkConclusionOfCheckVoucherItem();
    getNum();
    setDefaultNumPad();
    await getVerdictOptionAdapterList();
    await getTCList();
    await getComDefectsAdapterList();
    await getByBatchTCList();
    await getCheckVouchTypeAdapter();
    await getPersonAdapter();
    await getCheckGuideAdapter();
    getECList();
    return res;
  }

  @override
  Future<void> onReady() async {
    await super.onReady();

    for (var element in numPadCTList) {
      element.focusNode.addListener(() async {
        if (rootCtl.isKeyboardOpenAfterClickTC && element.focusNode.hasFocus && !kIsWeb && GetPlatform.isWindows){
          await rootCtl.openKeyboard();
        }
      });
    }
  }


  ///获取检验单
  Future<bool> getCheckVoucherItem() async{
    if (moCheckId.isNotEmpty){ ///有检验单，直接从检验单中读取数据
      var res = await MoCheckVoucherRepository().getFormData(moCheckId, '', {}, 0);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取检验单数据时出错：${res.message}');
        return false;
      }
      checkVoucherItem = res.data;
    }
    else if (moInspectId.isNotEmpty) { ///没有检验单，报检单生成检验单，从报检单中生成数据
      var res1 = await MoInspectRepository().getMoIsCanCheckVoucher(moInspectId);
      if (!res1.isSuccess){
        ToastNotification(Get.overlayContext!).error('不能生成检验单：${res1.message}');
        return false;
      }
      var res2 = await MoInspectRepository().postMoCheckVoucher(moInspectId);
      if (!res2.isSuccess){
        ToastNotification(Get.overlayContext!).error('根据报检单ID获取或生成检验单时出错：${res2.message}');
        return false;
      }
      checkVoucherItem = res2.data;
    }
    else if (taskId.isNotEmpty){ ///通过派工单ID，生成检验单
      var res = await MoTaskRepository().checkVoucher(taskId, taskToCheckVoucherCategory);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('根据派工单ID获取或生成检验单时出错：${res.message}');
        return false;
      }
      checkVoucherItem = res.data;
    }

    canAddCheckGuide = checkVoucherItem.moCheckId.isEmpty && checkVoucherItem.entryList.isEmpty;

    return true;
  }

  ///获取工艺说明
  Future<void> getOpDescription() async {
    var res = await MoWorkBillEntryRepository().getMoWorkBillEntry(checkVoucherItem.workBillEntryId ?? '');
    checkVoucherItem.opDescription = res.data.opDescription ?? '';
  }

  Future<void> getCheckVoucherAttach() async{
    if (checkVoucherItem.moCheckId.isEmpty){
      return;
    }
    dMDocumentModel = DMDocumentModel();
    var res = await FormRepository().getDocument('image', progId, checkVoucherItem.moCheckId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取检验单图片附件时出错：${res.message}');
      return;
    }
    dMDocumentModel = res.data;
  }

  ///获取进度
  void getNum() {
    finishedNum = checkVoucherItem.entryList.where(
            (element) => (element.chkGuidType == 1 && (element.defectQty ?? 0) > 0)
            || (element.verdictType == 0 && (element.verdict ?? 0) > 0)
            || (element.verdictType == 1 && (element.chkConclusion != null && element.chkConclusion!.isNotEmpty && element.chkConclusion != '待选择'))
            || (element.verdictType == 2 && (element.chkConclusion != null && element.chkConclusion!.isNotEmpty))
            || (element.verdictType == 3 && (element.chkConclusion != null && element.chkConclusion!.isNotEmpty))
    ).length;
    totalNum = checkVoucherItem.entryList.length;
  }

  void setDefaultNumPad() {
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    NumPadUtil().setText('desc', checkVoucherItem.description ?? '', numPadCTList);
  }

  ///获取 verdict 的默认值
  void getDefaultVerdictOfCheckVoucherItem() {
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    for (var element in checkVoucherItem.entryList) {
      if ((element.chkGuidType ?? 0) == 0 && element.verdictType == 0) {
        element.verdict = (element.verdict != null && element.verdict != 0)
            ? element.verdict
            : element.verdictDefault == '良' ? 1 : element.verdictDefault == '次' ? 2 : 0;
      }
    }
  }

  ///获取 chkConclusion 的默认值
  void getChkConclusionOfCheckVoucherItem() {
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    for (var element in checkVoucherItem.entryList) {
      if ((element.chkGuidType ?? 0) == 0 && (element.verdictType == 1 || element.verdictType == 2 || element.verdictType == 3)) {
        element.chkConclusion = (element.chkConclusion != null && element.chkConclusion!.isNotEmpty)
            ? element.chkConclusion
            : element.verdictDefault;
      }
    }
  }

  ///获取检验结论 Adapter 列表（检验方案列表）
  Future<void> getVerdictOptionAdapterList() async{
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    for (var element in checkVoucherItem.entryList) {
      if (element.verdictType == 1){
        List<String> optionList = (element.verdictOption ?? '').split(',');
        List<PickerDataModel> fieldList = optionList.map((e) => PickerDataModel(id: PinyinHelper.getShortPinyin(e), name: e)).toList();
        CustomAdapter optionAdapter = await AdapterHelper.getAsyncAdapter(
          'custom',
          title: '结论',
          selectedItems: [PickerDataModel(id: PinyinHelper.getShortPinyin(element.chkConclusion ?? ''))],
          fieldList: fieldList,
        ) as CustomAdapter;
        verdictOptionAdapterList.add(
            AdapterKeyModel(keyName: '${element.invNo}-${element.rowNo}', adapter: optionAdapter)
        );
      }
    }
  }

  ///获取检验结论输入框控制器列表（检验方案列表）
  Future<void> getTCList() async{
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    for (var element in checkVoucherItem.entryList) {
      if (element.verdictType == 2 || element.verdictType == 3){
        tCList.add(
          TextEditingControllerKeyModel(
            keyName: '${element.invNo}-${element.rowNo}',
            tCType: element.verdictType == 2 ? TCType.text : TCType.double,
            tC: TextEditingController(text: element.chkConclusion),
            fn: FocusNode(),
          )
        );
      }
    }
  }

  Future<void> getByBatchTCList() async {
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    checkVoucherItem.entryList.forEach((element) {
      if (element.chkGuidType == 1){
        byBatchTCList.add(
            TextEditingControllerKeyModel(
              keyName: '${element.rowNo}',
              tCType: TCType.double,
              tC: TextEditingController(),
              fn: FocusNode(),
            )
        );
      }
    });
  }

  ///获取缺陷原因列表（检验方案列表）
  Future<void> getComDefectsAdapterList() async{
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    for (var element in checkVoucherItem.entryList) {
      List<String> comDefectsList = element.chkGuideComDefects == null || element.chkGuideComDefects!.isEmpty ? [] : element.chkGuideComDefects!.split(',');
      List<PickerDataModel> fieldList = comDefectsList.map((e) => PickerDataModel(id: PinyinHelper.getShortPinyin(e), name: e)).toList();
      List<PickerDataModel> selectedList = (element.comDefects ?? '').split(',').map((e) => PickerDataModel(id: PinyinHelper.getShortPinyin(e), name: e)).toList();
      CustomAdapter comDefectsAdapter = await AdapterHelper.getAsyncAdapter(
        'custom',
        multipleSelection: true,
        title: '缺陷',
        selectedItems: selectedList,
        fieldList: fieldList,
      ) as CustomAdapter;
      comDefectsAdapterList.add(
          AdapterKeyModel(keyName: '${element.invNo}-${element.rowNo}', adapter: comDefectsAdapter)
      );
    }
  }

  ///获取展开框控制器列表
  Future<void> getECList() async {
    expansionTileControllerBySingleItemMap.clear();
    expansionSignBySingleItemMap.clear();
    expansionTileControllerByBatchMap.clear();
    expansionSignByBatchMap.clear();
    checkVoucherItem.entryList.forEach((element) {
      if (element.chkGuidType == 1){
        expansionTileControllerByBatchMap.addAll({element.chkGuideID ?? '': ExpansibleController()});
        expansionSignByBatchMap.addAll({element.chkGuideID ?? '': false});
      }
      else if (element.invNo == 0) {
        expansionTileControllerBySingleItemMap.addAll({element.chkGuideID ?? '': ExpansibleController()});
        expansionSignBySingleItemMap.addAll({element.chkGuideID ?? '': false});
      }
    });
  }

  ///获取首检类别Adapter
  Future<void> getCheckVouchTypeAdapter() async{
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    checkVouchTypeAdapter = await AdapterHelper.getAsyncAdapter(
      'checkVouchType',
      isNeedLoadData: true,
    ) as DataItemAdapter;
    if (checkVouchTypeAdapter?.dataList.length == 1){
      checkVouchTypeAdapter?.dataList[0].isSelected = true;
      checkVoucherItem.property = checkVouchTypeAdapter?.dataList[0].name;
    }
  }

  ///获取提交人Adapter
  Future<void> getPersonAdapter() async {
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    personAdapter = await AdapterHelper.getAsyncAdapter(
      'person',
      isNeedLoadData: true,
    ) as PersonAdapter;
  }

  ///获取检验指标Adapter
  Future<void> getCheckGuideAdapter() async {
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    checkGuideAdapter = await AdapterHelper.getAsyncAdapter(
      'checkGuide',
      isNeedLoadData: false,
      multipleSelection: true,
    ) as CheckGuideAdapter;
  }

  //region onChanged

  ///表体检验结论变化后，重置缺陷原因
  void resetDefectQtyAndComDefects(MoCheckVoucherEntryModel item) {
    if (!item.isUnqualifiedData){
      item.comDefects = null;
      AdapterKeyModel? adapterKeyModel = comDefectsAdapterList.firstWhereOrNull((element) => element.keyName == '${item.invNo}-${item.rowNo}');
      if (adapterKeyModel != null){
        for (var element in adapterKeyModel.adapter.dataList) { element.isSelected = false; }
      }
    }
  }

  ///良次选择变化
  Future<void> verdictType0OnChanged(MoCheckVoucherEntryModel item, int index) async{
    if (item.verdict == index){
      item.verdict = 0;
    }
    else {
      item.verdict = index;
    }
    resetDefectQtyAndComDefects(item);
    getNum();
    update();
  }

  ///选项选择变化
  Future<void> verdictType1OnChanged(MoCheckVoucherEntryModel item, PickerDataModel pickerDataModel) async{
    item.chkConclusion = pickerDataModel.name;
    getNum();
    update();
  }

  ///数字、文字填报变化
  Future<void> verdictType23OnChanged(MoCheckVoucherEntryModel item, String str) async {
    item.chkConclusion = str;
    resetDefectQtyAndComDefects(item);
    getNum();
    update();
  }

  ///缺陷原因选择变化
  Future<void> comDefectsOnChanged(MoCheckVoucherEntryModel item, List<PickerDataModel> list) async{
    item.comDefects = list.map((e) => e.name).join(',');
    update();
  }

  ///按批次填报，缺陷数量填报变化
  Future<void> defectQtyOnChanged(MoCheckVoucherEntryModel item, String str) async {
    item.defectQty = double.tryParse(str);
    resetDefectQtyAndComDefects(item);
    getNum();
    update();
  }

  ///总结论选择变化
  Future<void> overAllVerdictOnChanged(int index) async {
    if (checkVoucherItem.verdict == index){
      checkVoucherItem.verdict = null;
    }
    else {
      checkVoucherItem.verdict = index;
    }
    update();
  }

  ///首检类别选择变化
  Future<void> checkVouchTypeOnChanged(PickerDataModel item) async{
    checkVoucherItem.property = item.name;
    update();
  }

  ///提交人员选择变化
  Future<void> personOnChanged(PickerDataModel item) async{
    checkVoucherItem.inspector = item.name;
    update();
  }

  ///全部展开/收起
  void eCExpanded({bool? expanded}) {
    List<ExpansibleController> list;
    if (chkGuidType.sign == 0){
      list = expansionTileControllerBySingleItemMap.values.toList();
    }
    else {
      list = expansionTileControllerByBatchMap.values.toList();
    }
    bool isAllExpanded = expanded ?? list.firstWhereOrNull((element) => !element.isExpanded) == null;
    if (isAllExpanded){
      for (var element in list) {
        element.collapse();
      }
    }
    else {
      for (var element in list) {
        element.expand();
      }
    }

    if (chkGuidType.sign == 0) {
      expansionSignBySingleItemMap.forEach((key, value) {
        value = !isAllExpanded;
      });
    }
    else {
      expansionSignByBatchMap.forEach((key, value) {
        value = !isAllExpanded;
      });
    }

    update();
  }

  ///单个展开/收起
  void itemExpandedOnChanged(String chkGuideID){
    if (chkGuidType.sign == 0){
      if (expansionTileControllerBySingleItemMap[chkGuideID]?.isExpanded ?? false){
        expansionTileControllerBySingleItemMap[chkGuideID]?.collapse();
        expansionSignBySingleItemMap[chkGuideID] = false;
      }
      else {
        expansionTileControllerBySingleItemMap[chkGuideID]?.expand();
        expansionSignBySingleItemMap[chkGuideID] = true;
      }
    }
    else {
      if (expansionTileControllerByBatchMap[chkGuideID]?.isExpanded ?? false){
        expansionTileControllerByBatchMap[chkGuideID]?.collapse();
        expansionSignByBatchMap[chkGuideID] = false;
      }
      else {
        expansionTileControllerByBatchMap[chkGuideID]?.expand();
        expansionSignByBatchMap[chkGuideID] = true;
      }
    }

    update();
  }

  //endregion


  //region 检验数据

  ///上一件
  Future<void> changeToLastIndex() async{
    if (checkVoucherItem.num == null || checkVoucherItem.num == 0 || checkVoucherItem.index == 0){
      ToastNotification(Get.overlayContext!).warn('已经是第一件！');
      return;
    }
    checkVoucherItem.index -= 1;
    update();
  }

  ///下一件
  Future<void> changeToNextIndex() async{
    if (checkVoucherItem.num == null || checkVoucherItem.num == 0 || checkVoucherItem.index == (checkVoucherItem.num! - 1)){
      ToastNotification(Get.overlayContext!).warn('已经是最后一件！');
      return;
    }
    checkVoucherItem.index += 1;
    update();
  }

  ///删除当前检验数据
  Future<void> deleteNum(int index) async{
    if (checkVoucherItem.num == null || checkVoucherItem.num! <= 1){
      ToastNotification(Get.overlayContext!).warn('不能删除数据！');
      return;
    }
    if (index > (checkVoucherItem.num! - 1) || index < 0){
      ToastNotification(Get.overlayContext!).warn('删除的数据错误！');
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认删除当前检验数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      return;
    }

    checkVoucherItem.entryList.removeWhere((element) => (element.chkGuidType ?? 0) == 0 && element.invNo == index);
    verdictOptionAdapterList.removeWhere((element){
      bool res = element.keyName.startsWith('$index-', 0);
      return res;
    });
    tCList.removeWhere((element){
      bool res = element.keyName.startsWith('$index-', 0);
      return res;
    });
    comDefectsAdapterList.removeWhere((element){
      bool res = element.keyName.startsWith('$index-', 0);
      return res;
    });

    for (var element in checkVoucherItem.entryList) {
      if (element.invNo! > index){
        element.invNo = element.invNo! - 1;
      }
    }
    for (var element in verdictOptionAdapterList) {
      List<int?> keyList = element.keyName.split('-').map((e) => int.tryParse(e)).toList();
      if (keyList[0]! > index){
        keyList[0] = keyList[0]! - 1;
      }
      element.keyName = keyList.join('-');
    }
    for (var element in tCList) {
      List<int?> keyList = element.keyName.split('-').map((e) => int.tryParse(e)).toList();
      if (keyList[0]! > index){
        keyList[0] = keyList[0]! - 1;
      }
      element.keyName = keyList.join('-');
    }
    for (var element in comDefectsAdapterList){
      List<int?> keyList = element.keyName.split('-').map((e) => int.tryParse(e)).toList();
      if (keyList[0]! > index){
        keyList[0] = keyList[0]! - 1;
      }
      element.keyName = keyList.join('-');
    }
    checkVoucherItem.num = checkVoucherItem.num! - 1;
    if (checkVoucherItem.index == checkVoucherItem.num){ ///如果删除的是最后一条数据
      checkVoucherItem.index -= 1;
    }
    getNum();
    update();
  }

  ///增加检验数据
  Future<void> addNum() async{
    if (checkVoucherItem.num == null){
      ToastNotification(Get.overlayContext!).warn('不能增加检验数据！');
      return;
    }
    List<MoCheckVoucherEntryModel> list = checkVoucherItem.entryList.where((element) => (element.chkGuidType ?? 0) == 0 && element.invNo == 0).toList();
    for (var element in list) {
      MoCheckVoucherEntryModel entryModel = MoCheckVoucherEntryModel();
      entryModel.fromJson(element.toJson());
      entryModel.id = '';
      entryModel.clear();
      entryModel.invNo = checkVoucherItem.num;
      if ((element.chkGuidType ?? 0) == 0){
        if (entryModel.verdictType == 0) { ///获取 verdict 的默认值
          entryModel.verdict = (entryModel.verdict != null && entryModel.verdict != 0)
              ? entryModel.verdict
              : entryModel.verdictDefault == '良' ? 1 : entryModel.verdictDefault == '次' ? 2 : 0;
        }
        else if (entryModel.verdictType == 1 || entryModel.verdictType == 2 || entryModel.verdictType == 3) { ///获取 chkConclusion 的默认值
          entryModel.chkConclusion = (entryModel.chkConclusion != null && entryModel.chkConclusion!.isNotEmpty)
              ? entryModel.chkConclusion
              : entryModel.verdictDefault;
        }
      }
      checkVoucherItem.entryList.add(entryModel);
      //region
      ///增加结论Adapter
      if (entryModel.verdictType == 1){
        List<String> optionList = (entryModel.verdictOption ?? '').split(',');
        List<PickerDataModel> fieldList = optionList.map((e) => PickerDataModel(id: PinyinHelper.getShortPinyin(e), name: e)).toList();
        CustomAdapter optionAdapter = await AdapterHelper.getAsyncAdapter(
          'custom',
          title: '结论',
          selectedItems: [PickerDataModel(id: PinyinHelper.getShortPinyin(entryModel.chkConclusion ?? ''))],
          fieldList: fieldList,
        ) as CustomAdapter;
        AdapterKeyModel adapterKeyModel = AdapterKeyModel(keyName: '${entryModel.invNo}-${entryModel.rowNo}', adapter: optionAdapter);
        verdictOptionAdapterList.add(adapterKeyModel);
      }

      ///增加TextEditingController
      if (entryModel.verdictType == 2 || entryModel.verdictType == 3){
        TextEditingControllerKeyModel textEditingControllerKeyModel = TextEditingControllerKeyModel(
          keyName: '${entryModel.invNo}-${entryModel.rowNo}',
          tCType: entryModel.verdictType == 2 ? TCType.text : TCType.double,
          tC: TextEditingController(text: entryModel.chkConclusion),
          fn: FocusNode(),
        );
        tCList.add(textEditingControllerKeyModel);
      }

      ///增加缺陷Adapter
      List<String> comDefectsList = entryModel.chkGuideComDefects == null || entryModel.chkGuideComDefects!.isEmpty ? [] : entryModel.chkGuideComDefects!.split(',');
      List<PickerDataModel> fieldList = comDefectsList.map((e) => PickerDataModel(id: PinyinHelper.getShortPinyin(e), name: e)).toList();
      CustomAdapter comDefectsAdapter = await AdapterHelper.getAsyncAdapter(
        'custom',
        multipleSelection: true,
        title: '缺陷',
        fieldList: fieldList,
      ) as CustomAdapter;
      AdapterKeyModel adapterKeyModel = AdapterKeyModel(keyName: '${entryModel.invNo}-${entryModel.rowNo}', adapter: comDefectsAdapter);
      comDefectsAdapterList.add(adapterKeyModel);
      //endregion
    }
    checkVoucherItem.num = checkVoucherItem.num! + 1;
    checkVoucherItem.index = checkVoucherItem.num! - 1;
    getNum();
    update();
  }

  //endregion


  //region 检验指标

  ///增加检验指标
  Future<void> checkGuideOnChanged(List<PickerDataModel> list) async {
    if (list.isEmpty){
      return;
    }
    if (checkVoucherItem.num == null){
      ToastNotification(Get.overlayContext!).error('请先增加检验件数！');
      return;
    }
    List<String> chkGuideIDList = checkVoucherItem.entryList.map((e) => e.chkGuideID ?? '').toSet().toList();
    List<PickerDataModel> newAddList = list.where((element){
      element as QMCheckGuideModel;
      return !chkGuideIDList.contains(element.chkGuideID);
    }).toList();

    List<int> rowNoList = checkVoucherItem.entryList.map((e) => e.rowNo ?? 0).toSet().toList();
    int rowNo = rowNoList.isEmpty ? -1 : rowNoList.reduce(max);
    List<MoCheckVoucherEntryModel> bySingleItemList = [];
    List<MoCheckVoucherEntryModel> byBatchList = [];
    for (var element in newAddList) {
      element as QMCheckGuideModel;
      rowNo ++;
      MoCheckVoucherEntryModel moCheckVoucherEntryModel = MoCheckVoucherEntryModel(
        id: '',
        chkGuideName: element.chkGuideName,
        bugGrade: element.bugGrade,
        chkGuideComDefects: element.comDefects,
        chkGuideMemo: element.memo,
        chkStandardProvision: element.chkStandardProvision,
        attachs: '[]',
        dTQuantity: element.dtQuantity,
        verdictType: element.verdictType,
        verdictOption: element.verdictOption,
        verdictDefault: element.verdictDefault,
        isNeedConclusion: element.isNeedConclusion,
        isDefaultLast: element.isDefaultLast,
        isNeedPicture: element.isNeedPicture,
        chkMethod: element.chkMethod,
        chkItemCode: element.chkItemCode,
        chkItemName: element.chkItemName,
        symbol: element.symbol,
        invNo: null,
        rowNo: rowNo,
        sign: 0,
        status: '',
        chkItemID: element.chkItemID,
        chkGuideID: element.chkGuideID,
        standardValue: element.standardValue,
        upperLimit: element.upperLimit,
        lowerLimit: element.lowerLimit,
        chkGuidType: int.tryParse(element.chkGuidType.toString()) ?? 0,
        unitName: element.unitName,
      );
      if (moCheckVoucherEntryModel.chkGuidType == 1){
        moCheckVoucherEntryModel.invNo = 0;
        byBatchList.add(moCheckVoucherEntryModel);
        //region 增加 缺陷Adapter、缺陷数量TextEditingController
        List<String> comDefectsList = moCheckVoucherEntryModel.chkGuideComDefects == null || moCheckVoucherEntryModel.chkGuideComDefects!.isEmpty
            ? []
            : moCheckVoucherEntryModel.chkGuideComDefects!.split(',');
        List<PickerDataModel> fieldList = comDefectsList.map((e) => PickerDataModel(id: PinyinHelper.getShortPinyin(e), name: e)).toList();
        CustomAdapter comDefectsAdapter = await AdapterHelper.getAsyncAdapter(
          'custom',
          multipleSelection: true,
          title: '缺陷',
          fieldList: fieldList,
        ) as CustomAdapter;
        AdapterKeyModel adapterKeyModel = AdapterKeyModel(
            keyName: '${moCheckVoucherEntryModel.invNo}-${moCheckVoucherEntryModel.rowNo}',
            adapter: comDefectsAdapter
        );
        comDefectsAdapterList.add(adapterKeyModel);

        TextEditingControllerKeyModel textEditingControllerKeyModel = TextEditingControllerKeyModel(
          keyName: '${moCheckVoucherEntryModel.rowNo}',
          tCType: TCType.double,
          tC: TextEditingController(),
          fn: FocusNode(),
        );
        byBatchTCList.add(textEditingControllerKeyModel);
        //endregion
      }
      else {
        for (int index = 0; index < checkVoucherItem.num!; index ++){
          moCheckVoucherEntryModel.invNo = index;
          //region 获取 verdict chkConclusion 的默认值
          if (moCheckVoucherEntryModel.verdictType == 0){
            moCheckVoucherEntryModel.verdict = moCheckVoucherEntryModel.verdictDefault == '良'
                ? 1
                : moCheckVoucherEntryModel.verdictDefault == '次'
                ? 2
                : 0;
          }
          else if (moCheckVoucherEntryModel.verdictType == 1
              || moCheckVoucherEntryModel.verdictType == 2
              || moCheckVoucherEntryModel.verdictType == 3){
            moCheckVoucherEntryModel.chkConclusion = moCheckVoucherEntryModel.verdictDefault;
          }
          //endregion
          bySingleItemList.add(moCheckVoucherEntryModel);
          //region 增加缺陷Adapter、增加结论Adapter、增加TextEditingController
          List<String> comDefectsList = moCheckVoucherEntryModel.chkGuideComDefects == null || moCheckVoucherEntryModel.chkGuideComDefects!.isEmpty
              ? []
              : moCheckVoucherEntryModel.chkGuideComDefects!.split(',');
          List<PickerDataModel> fieldList = comDefectsList.map((e) => PickerDataModel(id: PinyinHelper.getShortPinyin(e), name: e)).toList();
          CustomAdapter comDefectsAdapter = await AdapterHelper.getAsyncAdapter(
            'custom',
            multipleSelection: true,
            title: '缺陷',
            fieldList: fieldList,
          ) as CustomAdapter;
          AdapterKeyModel adapterKeyModel = AdapterKeyModel(
              keyName: '${moCheckVoucherEntryModel.invNo}-${moCheckVoucherEntryModel.rowNo}',
              adapter: comDefectsAdapter
          );
          comDefectsAdapterList.add(adapterKeyModel);

          if (moCheckVoucherEntryModel.verdictType == 1){
            List<String> optionList = (moCheckVoucherEntryModel.verdictOption ?? '').split(',');
            List<PickerDataModel> fieldList = optionList.map((e) => PickerDataModel(id: PinyinHelper.getShortPinyin(e), name: e)).toList();
            CustomAdapter optionAdapter = await AdapterHelper.getAsyncAdapter(
              'custom',
              title: '结论',
              selectedItems: [PickerDataModel(id: PinyinHelper.getShortPinyin(moCheckVoucherEntryModel.chkConclusion ?? ''))],
              fieldList: fieldList,
            ) as CustomAdapter;
            AdapterKeyModel adapterKeyModel = AdapterKeyModel(
                keyName: '${moCheckVoucherEntryModel.invNo}-${moCheckVoucherEntryModel.rowNo}',
                adapter: optionAdapter
            );
            verdictOptionAdapterList.add(adapterKeyModel);
          }
          else if (moCheckVoucherEntryModel.verdictType == 2 || moCheckVoucherEntryModel.verdictType == 3){
            TextEditingControllerKeyModel textEditingControllerKeyModel = TextEditingControllerKeyModel(
              keyName: '${moCheckVoucherEntryModel.invNo}-${moCheckVoucherEntryModel.rowNo}',
              tCType: moCheckVoucherEntryModel.verdictType == 2 ? TCType.text : TCType.double,
              tC: TextEditingController(text: moCheckVoucherEntryModel.chkConclusion),
              fn: FocusNode(),
            );
            tCList.add(textEditingControllerKeyModel);
          }
          //endregion
        }
      }
    }
    checkVoucherItem.entryList.addAll(bySingleItemList);
    checkVoucherItem.entryList.addAll(byBatchList);
    bySingleItemList.forEach((element) {
      expansionTileControllerBySingleItemMap.addAll({element.chkGuideID ?? '': ExpansibleController()});
      expansionSignBySingleItemMap.addAll({element.chkGuideID ?? '': false});
    });
    byBatchList.forEach((element) {
      expansionTileControllerByBatchMap.addAll({element.chkGuideID ?? '': ExpansibleController()});
      expansionSignByBatchMap.addAll({element.chkGuideID ?? '': false});
    });
    getNum();
    update();
  }

  ///移除检验指标
  Future<void> removeCheckGuide(MoCheckVoucherEntryModel item) async {
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认移除检验指标？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      return;
    }

    checkGuideAdapter?.dataList.firstWhereOrNull((element) => element.chkGuideID == item.chkGuideID)?.isSelected = false;
    checkVoucherItem.entryList.removeWhere((element) => element.chkGuideID == item.chkGuideID);
    if (item.chkGuidType == 1){
      expansionTileControllerByBatchMap.remove(item.chkGuideID);
      expansionSignByBatchMap.remove(item.chkGuideID);
    }
    else {
      expansionTileControllerBySingleItemMap.remove(item.chkGuideID);
      expansionSignBySingleItemMap.remove(item.chkGuideID);
    }
    comDefectsAdapterList.removeWhere((element){
      bool res = element.keyName.endsWith('-${item.rowNo}');
      return res;
    });
    if (item.verdictType == 1){
      verdictOptionAdapterList.removeWhere((element){
        bool res = element.keyName.endsWith('-${item.rowNo}');
        return res;
      });
    }
    else if (item.verdictType == 2 || item.verdictType == 3){
      tCList.removeWhere((element){
        bool res = element.keyName.endsWith('-${item.rowNo}');
        return res;
      });
    }
    if (item.chkGuidType == 1){
      byBatchTCList.removeWhere((element){
        bool res = element.keyName.contains('${item.rowNo}');
        return res;
      });
    }

    for (var element in checkVoucherItem.entryList) {
      if (element.rowNo! > item.rowNo!){
        element.rowNo = element.rowNo! - 1;
      }
    }
    for (var element in comDefectsAdapterList) {
      List<int?> keyList = element.keyName.split('-').map((e) => int.tryParse(e)).toList();
      if (keyList[1]! > item.rowNo!){
        keyList[1] = keyList[1]! - 1;
      }
      element.keyName = keyList.join('-');
    }
    for (var element in verdictOptionAdapterList) {
      List<int?> keyList = element.keyName.split('-').map((e) => int.tryParse(e)).toList();
      if (keyList[1]! > item.rowNo!){
        keyList[1] = keyList[1]! - 1;
      }
      element.keyName = keyList.join('-');
    }
    for (var element in tCList) {
      List<int?> keyList = element.keyName.split('-').map((e) => int.tryParse(e)).toList();
      if (keyList[1]! > item.rowNo!){
        keyList[1] = keyList[1]! - 1;
      }
      element.keyName = keyList.join('-');
    }
    for (var element in byBatchTCList) {
      int? keyInt = int.tryParse(element.keyName) ?? 0;
      if (keyInt > item.rowNo!){
        keyInt = keyInt - 1;
      }
      element.keyName = keyInt.toString();
    }

    getNum();
    update();
  }

  //endregion


  //region 指标类型切换

  Future<void> chkGuidTypeOnChanged(ChoiceChipModel item) async {
    isShowList = false;
    update();
    await Future.delayed(const Duration(milliseconds: 100));
    chkGuidType = item;
    isShowList = true;
    update();
  }

  //endregion


  //region 附件图片选择添加移除

  ///增加[checkVoucherItem]的要上传的图片
  Future<void> addCheckVoucherAttach() async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn("正在处理数据……");
      return;
    }
    isLoading = true;
    FilePickerResult? filePickerResult;
    if (!kIsWeb){
      filePickerResult = await FilePicker.pickFiles(
        dialogTitle: '文件选择（按住 Ctrl键 可以选择多个文件）',
        allowMultiple: true,
        withReadStream: true,
        type: FileType.image,
      );
    }
    if (filePickerResult == null){
      isLoading = false;
      return;
    }
    filePickerResult.files.forEach((element) {
      String key = Uuid().v4();
      checkVoucherItem.images_tou.add({'key': key, 'file': element.path});
    });
    update();
    isLoading = false;
  }

  ///删除[checkVoucherItem]的要上传的图片
  Future<void> deleteCheckVoucherAttach(String key) async {
    checkVoucherItem.images_tou.removeWhere((element) => element['key'] == key);
    update();
  }

  //endregion


  ///保存草稿（保存为检验中数据）
  Future<void> draftSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 提交前检查
    if (checkVoucherItem.entryList.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请增加检验项目！");
      isLoading = false;
      return;
    }
    MoCheckVoucherEntryModel? model3 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => (element.chkGuidType ?? 0) == 0
                && element.verdictType == 3 && element.chkConclusion != null && element.chkConclusion!.isNotEmpty
                && double.tryParse(element.chkConclusion!) == null);
    MoCheckVoucherEntryModel? model4 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => (element.chkGuidType ?? 0) == 0
                && element.isUnqualifiedData
                && element.chkGuideComDefects != null && element.chkGuideComDefects!.isNotEmpty
                && (element.comDefects == null || element.comDefects!.isEmpty));
    MoCheckVoucherEntryModel? model5 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.chkGuidType == 1
                && ((element.defectQty ?? 0) < 0 || (element.defectQty ?? 0) > (checkVoucherItem.num ?? 0)));
    MoCheckVoucherEntryModel? model6 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.chkGuidType == 1
                && (element.defectQty ?? 0) > 0
                && element.chkGuideComDefects != null && element.chkGuideComDefects!.isNotEmpty
                && (element.comDefects == null || element.comDefects!.isEmpty));
    if (model3 != null){
      ToastNotification(Get.overlayContext!).warn("第${model3.invNo! + 1}件“${model3.chkItemName ?? ''}-${model3.chkGuideName ?? ''}”的检验结论输入有误！");
      isLoading = false;
      return;
    }
    if (model4 != null){
      ToastNotification(Get.overlayContext!).warn("第${model4.invNo! + 1}件“${model4.chkItemName ?? ''}-${model4.chkGuideName ?? ''}”未选择缺陷原因！");
      isLoading = false;
      return;
    }
    if (model5 != null){
      ToastNotification(Get.overlayContext!).warn("按批次：“${model5.chkItemName ?? ''}-${model5.chkGuideName ?? ''}”的缺陷数量输入有误！");
      isLoading = false;
      return;
    }
    if (model6 != null){
      ToastNotification(Get.overlayContext!).warn("按批次：${model6.chkItemName ?? ''}-${model6.chkGuideName ?? ''}”未选择缺陷原因！");
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存检验记录？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存检验记录', completedMsg: '数据刷新成功！');
    //region 保存
    checkVoucherItem.progid = progId;
    checkVoucherItem.sign = MoCheckVoucherSign.ysh.sign;
    checkVoucherItem.description = NumPadUtil().getText('desc', numPadCTList) ?? '';
    var res = await MoCheckVoucherRepository().postVoucher(checkVoucherItem.moCheckId, checkVoucherItem);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('检验记录提交失败！${res.message}');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '检验记录保存成功，正在刷新数据！');
    //endregion
    //region 刷新页面
    var newDataRes = await MoCheckVoucherRepository().getFormData(res.data.data ?? '', '', {}, 0);
    if (!newDataRes.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取刷新数据失败,请手动刷新！${newDataRes.message}');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    checkVoucherItem = newDataRes.data;
    await getCheckVoucherAttach();
    canAddCheckGuide = checkVoucherItem.moCheckId.isEmpty && checkVoucherItem.entryList.isEmpty;
    if (qualityInspectionController != null){
      if (taskId.isEmpty){
        ///检验单类型一定相同
        if (qualityInspectionController!.selectedTaskSignModel.sign == 0){ ///待检验（移除数据）
          qualityInspectionController!.inspectList.removeWhere((element) => element.moInspectId == checkVoucherItem.moInspectId);
          qualityInspectionController!.total --;
        }
        else if (qualityInspectionController!.selectedTaskSignModel.sign == 1){ ///待判定（更新数据）
          MoCheckVoucherModel? checkVoucherModel = qualityInspectionController!.checkVoucherList.firstWhereOrNull(
                  (element) => element.moInspectId == checkVoucherItem.moInspectId);
          if (checkVoucherModel != null){
            var newDataRes = await MoCheckVoucherRepository().getFormData(res.data.data ?? '', '', {}, 0);
            if (!newDataRes.isSuccess){
              ToastNotification(Get.overlayContext!).error('获取刷新数据失败,请手动刷新！${newDataRes.message}');
              ProgressDialogUtil.close();
              isLoading = false;
              return;
            }
            checkVoucherModel.fromJson(newDataRes.data.toJson());
          }
        }
      }
      else {
        if (qualityInspectionController!.selectedTaskSignModel.sign == 1
            && qualityInspectionController!.selectedTaskCategoryModel.sign == checkVoucherItem.category){ ///待判定 & 检验单类型相同（新增数据）
          MoCheckVoucherModel model = MoCheckVoucherModel.fromJson(checkVoucherItem.toJson());
          qualityInspectionController!.checkVoucherList.insert(0, model);
          qualityInspectionController!.total ++;
        }
      }
      qualityInspectionController!.update();
    }
    //endregion
    update();
    ProgressDialogUtil.update(value: 2);
    isLoading = false;
  }

  ///提交
  Future<void> save() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 提交前检查
    MoCheckVoucherEntryModel? model0 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => (element.chkGuidType ?? 0) == 0
                && element.verdictType == 0 && (element.verdict == null || element.verdict == 0));
    MoCheckVoucherEntryModel? model1 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => (element.chkGuidType ?? 0) == 0
                && element.verdictType == 1 && (element.chkConclusion == null || element.chkConclusion!.isEmpty));
    MoCheckVoucherEntryModel? model2 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => (element.chkGuidType ?? 0) == 0
                && element.verdictType == 2 && (element.chkConclusion == null || element.chkConclusion!.isEmpty));
    MoCheckVoucherEntryModel? model3 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => (element.chkGuidType ?? 0) == 0
                && element.verdictType == 3 && (element.chkConclusion == null || element.chkConclusion!.isEmpty || double.tryParse(element.chkConclusion!) == null));
    MoCheckVoucherEntryModel? model4 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => (element.chkGuidType ?? 0) == 0
                && element.isUnqualifiedData
                && element.chkGuideComDefects != null && element.chkGuideComDefects!.isNotEmpty
                && (element.comDefects == null || element.comDefects!.isEmpty));
    MoCheckVoucherEntryModel? model5 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.chkGuidType == 1
                && ((element.defectQty ?? 0) < 0 || (element.defectQty ?? 0) > (checkVoucherItem.num ?? 0)));
    MoCheckVoucherEntryModel? model6 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.chkGuidType == 1
            && (element.defectQty ?? 0) > 0
            && element.chkGuideComDefects != null && element.chkGuideComDefects!.isNotEmpty
            && (element.comDefects == null || element.comDefects!.isEmpty));
    if (model0 != null){
      ToastNotification(Get.overlayContext!).warn("请选择第${model0.invNo! + 1}件“${model0.chkItemName ?? ''}-${model0.chkGuideName ?? ''}”的检验结论！");
      isLoading = false;
      return;
    }
    if (model1 != null){
      ToastNotification(Get.overlayContext!).warn("请选择第${model1.invNo! + 1}件“${model1.chkItemName ?? ''}-${model1.chkGuideName ?? ''}”的检验结论！");
      isLoading = false;
      return;
    }
    if (model2 != null){
      ToastNotification(Get.overlayContext!).warn("请输入第${model2.invNo! + 1}件“${model2.chkItemName ?? ''}-${model2.chkGuideName ?? ''}”的检验结论！");
      isLoading = false;
      return;
    }
    if (model3 != null){
      ToastNotification(Get.overlayContext!).warn("请输入第${model3.invNo! + 1}件“${model3.chkItemName ?? ''}-${model3.chkGuideName ?? ''}”的检验结论，或输入有误！");
      isLoading = false;
      return;
    }
    if (model4 != null){
      ToastNotification(Get.overlayContext!).warn("第${model4.invNo! + 1}件“${model4.chkItemName ?? ''}-${model4.chkGuideName ?? ''}”未选择缺陷原因！");
      isLoading = false;
      return;
    }
    if (model5 != null){
      ToastNotification(Get.overlayContext!).warn("按批次：“${model5.chkItemName ?? ''}-${model5.chkGuideName ?? ''}”的缺陷数量输入有误！");
      isLoading = false;
      return;
    }
    if (model6 != null){
      ToastNotification(Get.overlayContext!).warn("按批次：${model6.chkItemName ?? ''}-${model6.chkGuideName ?? ''}”未选择缺陷原因！");
      isLoading = false;
      return;
    }
    if (checkVoucherItem.inspector == null || checkVoucherItem.inspector!.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择提交人员！");
      isLoading = false;
      return;
    }
    if (checkVoucherItem.category == 2 && (checkVoucherItem.property == null || checkVoucherItem.property!.isEmpty)){
      ToastNotification(Get.overlayContext!).warn("请选择首检类别！");
      isLoading = false;
      return;
    }
    if (checkVoucherItem.verdict == null || checkVoucherItem.verdict == 0){
      ToastNotification(Get.overlayContext!).warn("请选择检验结论！");
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认提交检验记录？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交检验记录', completedMsg: '数据刷新成功！');
    //region 提交
    checkVoucherItem.progid = progId;
    checkVoucherItem.description = NumPadUtil().getText('desc', numPadCTList) ?? '';
    checkVoucherItem.sign = MoCheckVoucherSign.ywg.sign; ///已检验：sign 条件改为 256
    var res = await MoCheckVoucherRepository().postVoucher(checkVoucherItem.moCheckId, checkVoucherItem);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('检验记录提交失败！${res.message}');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '检验记录提交成功，正在刷新数据！');
    //endregion
    //region 刷新页面
    var newDataRes = await MoCheckVoucherRepository().getFormData(res.data.data ?? '', '', {}, 0);
    if (!newDataRes.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取刷新数据失败,请手动刷新！${newDataRes.message}');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    checkVoucherItem = newDataRes.data;
    await getCheckVoucherAttach();
    canAddCheckGuide = checkVoucherItem.moCheckId.isEmpty && checkVoucherItem.entryList.isEmpty;
    if (qualityInspectionController != null){
      if (taskId.isEmpty){
        ///检验单类型一定相同
        if (qualityInspectionController!.selectedTaskSignModel.sign == 0){ ///待检验（移除数据）
          qualityInspectionController!.inspectList.removeWhere((element) => element.moInspectId == checkVoucherItem.moInspectId);
          qualityInspectionController!.total --;
        }
        else if (qualityInspectionController!.selectedTaskSignModel.sign == 1){ ///待判定（移除数据）
          qualityInspectionController!.checkVoucherList.removeWhere((element) => element.moInspectId == checkVoucherItem.moInspectId);
          qualityInspectionController!.total --;
        }
      }
      else {
        if (qualityInspectionController!.selectedTaskSignModel.sign == 256){ ///已检验（新增数据）
          MoCheckVoucherModel model = MoCheckVoucherModel.fromJson(checkVoucherItem.toJson());
          qualityInspectionController!.checkVoucherList.insert(0, model);
          qualityInspectionController!.total ++;
        }
      }
      qualityInspectionController!.update();
    }
    //endregion
    update();
    ProgressDialogUtil.update(value: 2);
    isLoading = false;
  }


  //region 查看附件……

  ///查看附件
  Future<void> getAttach() async{
    if (checkVoucherItem.inspId == null || checkVoucherItem.inspId!.isEmpty){
      ToastNotification(Get.overlayContext!).warn('未关联检验方案！');
      return;
    }
    Get.rootDelegate.toNamed(
        openType == 0
            ? AppRoutes.IPQC_QUALITY_INSPECTION_DETAIL_ATTACH_PAGE
            : openType == 1
            ? AppRoutes.PMES_REAL_TIME_MONITOR_DETAIL_IPQC_QUALITY_INSPECTION_ATTACH_PAGE
            : '',
        parameters: {
          'pageTitle': '检验方案附件',
          'id': checkVoucherItem.inspId!,
          'progId': '810003',
          'category': 'attach',
        }
    );
  }

  ///查看产品附件
  Future<void> getInvAttach() async{
    if (checkVoucherItem.invId == null || checkVoucherItem.invId!.isEmpty){
      ToastNotification(Get.overlayContext!).error('该检验单没有产品！');
      return;
    }
    Get.rootDelegate.toNamed(
        openType == 0
            ? AppRoutes.IPQC_QUALITY_INSPECTION_DETAIL_ATTACH_PAGE
            : openType == 1
            ? AppRoutes.PMES_REAL_TIME_MONITOR_DETAIL_IPQC_QUALITY_INSPECTION_ATTACH_PAGE
            : '',
        parameters: {
          'pageTitle': '产品附件-${checkVoucherItem.invName}',
          'id': checkVoucherItem.invId!,
          'progId': '200025',
          'category': 'attach',
        }
    );
  }

  ///工序计划单 (工序工资计件)
  Future<void> getWagePiece() async{
    if (checkVoucherItem.moOrderId == null || checkVoucherItem.moOrderId!.isEmpty){
      ToastNotification(Get.overlayContext!).error('该检验单没有任务单，无法获取工序计划单！');
      return;
    }
    if (checkVoucherItem.opId == null || checkVoucherItem.opId!.isEmpty){
      ToastNotification(Get.overlayContext!).error('该检验单没有工序，无法获取工序计划单！');
      return;
    }
    await DialogUtils.showCustomDialog<QualityInspectionWagePieceController, bool>(
      Get.context!,
      isMaximize: true,
      isNeedConfirmBtn: false,
      title: '工序计划单', onCancelName: '关闭',
      contentPadding: const EdgeInsets.all(12),
      content: const QualityInspectionWagePieceView(),
      controller: QualityInspectionWagePieceController(
        moOrderId: checkVoucherItem.moOrderId!,
        opId: checkVoucherItem.opId ?? '',
        qualifiedQty: checkVoucherItem.orderQty ?? 0,
      ),
    );
  }

  ///查看工序图纸
  Future<void> getOpAttach() async{
    ///产品id对应的工艺路线列表
    final List<MoRoutingEntryModel> routingByInvIdList = [];
    var res = await MoRoutingRepository().getRoutingByInvId(checkVoucherItem.invId ?? '');
    if (res.isSuccess && res.data.entryList.isNotEmpty){
      routingByInvIdList.addAll(res.data.entryList);
    }
    MoRoutingEntryModel? routingEntryModel = routingByInvIdList.firstWhereOrNull((element) => element.opId == checkVoucherItem.opId);
    if (routingEntryModel == null || routingEntryModel.routingDId.isEmpty){
      ToastNotification(Get.overlayContext!).warn('无法获取工序图纸！');
      return;
    }

    Get.rootDelegate.toNamed(
        openType == 0
            ? AppRoutes.IPQC_QUALITY_INSPECTION_DETAIL_ATTACH_PAGE
            : openType == 1
            ? AppRoutes.PMES_REAL_TIME_MONITOR_DETAIL_IPQC_QUALITY_INSPECTION_ATTACH_PAGE
            : '',
        parameters: {
          'pageTitle': '技术指导书-${checkVoucherItem.opName ?? ''}',
          'id': routingEntryModel.routingDId,
          'progId': '660011',
          'category': 'sop',
        }
    );
  }

  //endregion


  @override
  void onClose() {
    dataReportScrollController.dispose();
    detailScrollController.dispose();
    for (var element in numPadCTList) {
      element.dispose();
    }
    super.onClose();
  }

}