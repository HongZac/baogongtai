import 'dart:math';
import 'package:uuid/uuid.dart';

import 'package:basement/item_model.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
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

///质量巡检 终检检验单（生产完工检验单）详情页（编辑 + 查看）
class FinalInspectionDetailFormController extends BaseFormController{

  ///报检单Id
  final String moInspectId;
  ///检验单Id
  final String moCheckId;
  ///派工单Id
  final String taskId;
  ///派工单生成的检验单类型， 1：来料检验 2：首检 4：巡检 8：末检 16：产品终检（该页面一定是终检） 32：自检
  final int taskToCheckVoucherCategory;

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
  ///数字、文字填报 TextEditingController 列表
  final List<TextEditingControllerKeyModel> tCList = [];
  ///单个检验项目的不合格数量TextEditingController 列表
  final List<TextEditingControllerKeyModel> defectQtyTCList = [];
  ///缺陷原因Adapter列表
  final List<AdapterKeyModel> comDefectsAdapterList = [];
  final ScrollController dataReportScrollController = ScrollController();
  ///提交人员选择Adapter
  PersonAdapter? personAdapter;

  ///表体展开框的控制器列表
  final List<ExpansibleController> expansionTileControllerList = [];

  final List<NumPadController> numPadCTList = [
    NumPadController(key: 'dTQuantity', zhName: '抽检数量', keyboardType: TextInputType.number),
    NumPadController(key: 'dTPassQty', zhName: '抽检合格数量', keyboardType: TextInputType.number),
    NumPadController(key: 'dTDisableQty', zhName: '抽检不合格数量', keyboardType: TextInputType.number),

    NumPadController(key: 'quantity', zhName: '检验数量', keyboardType: TextInputType.number),
    NumPadController(key: 'passQty', zhName: '合格数量', keyboardType: TextInputType.number),
    NumPadController(key: 'disabledQty', zhName: '质废数量', keyboardType: TextInputType.number),
    NumPadController(key: 'materialQty', zhName: '料废数量', keyboardType: TextInputType.number),
    NumPadController(key: 'concessionQty', zhName: '让步接收数量', keyboardType: TextInputType.number),
    NumPadController(key: 'lostQty', zhName: '遗失数量', keyboardType: TextInputType.number),

    NumPadController(key: 'desc', zhName: '备注', keyboardType: TextInputType.text),
  ];

  ///数据填报表单输入时启用时间防抖
  final Debounce debounce = Debounce(const Duration(milliseconds: 500));

  ///附件列表
  DMDocumentModel dMDocumentModel = DMDocumentModel();

  ///检验指标Adapter
  CheckGuideAdapter? checkGuideAdapter;

  final QualityInspectionController qualityInspectionController = Get.find<QualityInspectionController>();

  FinalInspectionDetailFormController({
    super.progId = 811032,
    required this.moInspectId,
    required this.moCheckId,
    required this.taskId,
    required this.taskToCheckVoucherCategory,
  });


  @override
  void onInit() {
    super.onInit();
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
    await getDefectQtyTCList();
    await getComDefectsAdapterList();
    await getPersonAdapter();
    await getCheckGuideAdapter();
    getECList();
    return res;
  }

  ///获取检验单
  Future<bool> getCheckVoucherItem() async {
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

  Future<void> getCheckVoucherAttach() async {
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
            (element) => (element.verdictType == 0 && (element.verdict ?? 0) > 0)
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
    NumPadUtil().setText(
      'dTQuantity', 
      (checkVoucherItem.dTQuantity ?? checkVoucherItem.quantity)?.toString() ?? '',
      numPadCTList
    );
    NumPadUtil().setText('dTPassQty', checkVoucherItem.dTPassQty?.toString() ?? '', numPadCTList);
    NumPadUtil().setText('dTDisableQty', checkVoucherItem.dTDisableQty?.toString() ?? '', numPadCTList);
    NumPadUtil().setText('quantity', checkVoucherItem.quantity?.toString() ?? '', numPadCTList);
    NumPadUtil().setText('passQty', checkVoucherItem.passQty?.toString() ?? '', numPadCTList);
    NumPadUtil().setText('disabledQty', checkVoucherItem.disabledQty?.toString() ?? '', numPadCTList);
    NumPadUtil().setText('materialQty', checkVoucherItem.materialQty?.toString() ?? '', numPadCTList);
    NumPadUtil().setText('concessionQty', checkVoucherItem.concessionQty?.toString() ?? '', numPadCTList);
    NumPadUtil().setText('lostQty', checkVoucherItem.lostQty?.toString() ?? '', numPadCTList);
    NumPadUtil().setText('desc', checkVoucherItem.description ?? '', numPadCTList);
    NumPadUtil().setEnabled('lostQty', false, numPadCTList);
  }

  ///获取 verdict 的默认值（检验方案列表）
  void getDefaultVerdictOfCheckVoucherItem() {
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    for (var element in checkVoucherItem.entryList) {
      if (element.verdictType == 0) {
        element.verdict = (element.verdict != null && element.verdict != 0)
            ? element.verdict
            : element.verdictDefault == '良' ? 1 : element.verdictDefault == '次' ? 2 : 0;
      }
    }
  }

  ///获取 chkConclusion 的默认值（检验方案列表）
  void getChkConclusionOfCheckVoucherItem() {
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    for (var element in checkVoucherItem.entryList) {
      if (element.verdictType == 1 || element.verdictType == 2 || element.verdictType == 3) {
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
            AdapterKeyModel(keyName: '${element.rowNo}', adapter: optionAdapter)
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
              keyName: '${element.rowNo}',
              tCType: element.verdictType == 2 ? TCType.text : TCType.double,
              tC: TextEditingController(text: element.chkConclusion),
              fn: FocusNode(),
            )
        );
      }
    }
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
          AdapterKeyModel(keyName: '${element.rowNo}', adapter: comDefectsAdapter)
      );
    }
  }

  ///获取单个检验项目的不合格数量TextEditingController 列表
  Future<void> getDefectQtyTCList() async {
    if (checkVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    for (var element in checkVoucherItem.entryList) {
      defectQtyTCList.add(
        TextEditingControllerKeyModel(
          keyName: '${element.rowNo}',
          tC: TextEditingController(text: element.defectQty?.toString()),
          tCType: TCType.double,
          fn: FocusNode(),
        )
      );
    }
  }


  ///获取展开框控制器列表
  Future<void> getECList() async {
    expansionTileControllerList.clear();
    expansionTileControllerList.addAll(checkVoucherItem.entryList.map((e) => ExpansibleController()));
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

  ///表体检验结论变化后，重置缺陷原因、缺陷数量
  void resetDefectQtyAndComDefects(MoCheckVoucherEntryModel item) {
    if (!item.isUnqualifiedData){
      item.defectQty = null;
      TextEditingControllerKeyModel? textEditingControllerKeyModel = defectQtyTCList.firstWhereOrNull((element) => element.keyName == '${item.rowNo}');
      if (textEditingControllerKeyModel != null){
        textEditingControllerKeyModel.tC.clear();
      }
      item.comDefects = null;
      AdapterKeyModel? adapterKeyModel = comDefectsAdapterList.firstWhereOrNull((element) => element.keyName == '${item.rowNo}');
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


  ///提交人员选择变化
  Future<void> personOnChanged(PickerDataModel item) async{
    checkVoucherItem.inspector = item.name;
    update();
  }

  ///全部展开/收起
  void eCExpanded() {
    bool isAllExpanded = expansionTileControllerList.firstWhereOrNull((element) => !element.isExpanded) == null;
    if (isAllExpanded){
      for (var element in expansionTileControllerList) {
        element.collapse();
      }
    }
    else {
      for (var element in expansionTileControllerList) {
        element.expand();
      }
    }
    update();
  }

  ///单个展开/收起
  void itemExpandedOnChanged(int index){
    if (expansionTileControllerList[index].isExpanded){
      expansionTileControllerList[index].collapse();
    }
    else {
      expansionTileControllerList[index].expand();
    }
    update();
  }

  //endregion


  //region 检验指标

  ///增加检验指标
  Future<void> checkGuideOnChanged(List<PickerDataModel> list) async {
    if (list.isEmpty){
      return;
    }
    List<String> chkGuideIDList = checkVoucherItem.entryList.map((e) => e.chkGuideID ?? '').toSet().toList();
    List<PickerDataModel> newAddList = list.where((element){
      element as QMCheckGuideModel;
      return !chkGuideIDList.contains(element.chkGuideID);
    }).toList();
    List<int> rowNoList = checkVoucherItem.entryList.map((e) => e.rowNo ?? 0).toSet().toList();
    int rowNo = rowNoList.isEmpty ? -1 : rowNoList.reduce(max);
    List<MoCheckVoucherEntryModel> itemList = [];
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
        dTQuantity: double.tryParse(NumPadUtil().getText('dTQuantity', numPadCTList) ?? ''),
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
        invNo: 0,
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
      //region 获取 verdict 的默认值
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
      itemList.add(moCheckVoucherEntryModel);
      //region 增加缺陷Adapter、增加结论Adapter、增加TextEditingController、增加单个检验项目的不合格数量TextEditingController
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
          keyName: '${moCheckVoucherEntryModel.rowNo}',
          adapter: comDefectsAdapter
      );
      comDefectsAdapterList.add(adapterKeyModel);

      TextEditingControllerKeyModel defectQtyTCKModel = TextEditingControllerKeyModel(
        keyName: '${moCheckVoucherEntryModel.rowNo}',
        tC: TextEditingController(text: moCheckVoucherEntryModel.defectQty?.toString()),
        tCType: TCType.double,
        fn: FocusNode(),
      );
      defectQtyTCList.add(defectQtyTCKModel);

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
            keyName: '${moCheckVoucherEntryModel.rowNo}',
            adapter: optionAdapter
        );
        verdictOptionAdapterList.add(adapterKeyModel);
      }
      else if (moCheckVoucherEntryModel.verdictType == 2 || moCheckVoucherEntryModel.verdictType == 3){
        TextEditingControllerKeyModel textEditingControllerKeyModel = TextEditingControllerKeyModel(
          keyName: '${moCheckVoucherEntryModel.rowNo}',
          tCType: moCheckVoucherEntryModel.verdictType == 2 ? TCType.text : TCType.double,
          tC: TextEditingController(text: moCheckVoucherEntryModel.chkConclusion),
          fn: FocusNode(),
        );
        tCList.add(textEditingControllerKeyModel);
      }
      //endregion
    }
    checkVoucherItem.entryList.addAll(itemList);
    expansionTileControllerList.addAll(itemList.map((e) => ExpansibleController()));
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
    expansionTileControllerList.removeLast();
    comDefectsAdapterList.removeWhere((element){
      bool res = element.keyName == '${item.rowNo}';
      return res;
    });

    defectQtyTCList.removeWhere((element){
      bool res = element.keyName == '${item.rowNo}';
      return res;
    });

    if (item.verdictType == 1){
      verdictOptionAdapterList.removeWhere((element){
        bool res = element.keyName == '${item.rowNo}';
        return res;
      });
    }
    else if (item.verdictType == 2 || item.verdictType == 3){
      tCList.removeWhere((element){
        bool res = element.keyName == '${item.rowNo}';
        return res;
      });
    }

    for (var element in checkVoucherItem.entryList) {
      if (element.rowNo! > item.rowNo!){
        element.rowNo = element.rowNo! - 1;
      }
    }
    for (var element in comDefectsAdapterList) {
      int key = int.parse(element.keyName);
      if (key > item.rowNo!){
        key = key - 1;
      }
      element.keyName = '$key';
    }
    for (var element in defectQtyTCList) {
      int key = int.parse(element.keyName);
      if (key > item.rowNo!){
        key = key - 1;
      }
      element.keyName = '$key';
    }
    for (var element in verdictOptionAdapterList) {
      int key = int.parse(element.keyName);
      if (key > item.rowNo!){
        key = key - 1;
      }
      element.keyName = '$key';
    }
    for (var element in tCList) {
      int key = int.parse(element.keyName);
      if (key > item.rowNo!){
        key = key - 1;
      }
      element.keyName = '$key';
    }

    getNum();
    update();
  }

  //endregion


  //region NumPad

  void calcQty(String keyName) {
    debounce(() {
      switch (keyName){
        case 'dTQuantity':
          //region 抽检数量
          double dTQuantity = double.tryParse(NumPadUtil().getText('dTQuantity', numPadCTList) ?? '') ?? 0;
          double dTDisableQty = double.tryParse(NumPadUtil().getText('dTDisableQty', numPadCTList) ?? '') ?? 0;
          double dTPassQty = dTQuantity - dTDisableQty;
          String dTPassQtyStr = dTPassQty.toString();
          NumPadUtil().setText('dTPassQty', dTPassQtyStr, numPadCTList);
          //endregion
          break;
        case 'dTPassQty':
          //region 抽检合格数量
          //endregion
          break;
        case 'dTDisableQty':
          //region 抽检不合格数量
          double dTQuantity = double.tryParse(NumPadUtil().getText('dTQuantity', numPadCTList) ?? '') ?? 0;
          double dTDisableQty = double.tryParse(NumPadUtil().getText('dTDisableQty', numPadCTList) ?? '') ?? 0;
          double dTPassQty = dTQuantity - dTDisableQty;
          String dTPassQtyStr = dTPassQty.toString();
          NumPadUtil().setText('dTPassQty', dTPassQtyStr, numPadCTList);
          //endregion
          break;

        case 'quantity':
          //region 检验数量
          double quantity = double.tryParse(NumPadUtil().getText('quantity', numPadCTList) ?? '') ?? 0;
          double disabledQty = double.tryParse(NumPadUtil().getText('disabledQty', numPadCTList) ?? '') ?? 0;
          double materialQty = double.tryParse(NumPadUtil().getText('materialQty', numPadCTList) ?? '') ?? 0;
          double concessionQty = double.tryParse(NumPadUtil().getText('concessionQty', numPadCTList) ?? '') ?? 0;
          double passQty = quantity - disabledQty - materialQty - concessionQty;
          String passQtyStr = passQty.toString();
          NumPadUtil().setText('passQty', passQtyStr, numPadCTList);
          double lostQty = (checkVoucherItem.inspectionQty ?? 0) > quantity
              ? (checkVoucherItem.inspectionQty ?? 0) - quantity
              : 0;
          String lostQtyStr = lostQty.toString();
          NumPadUtil().setText('lostQty', lostQtyStr, numPadCTList);
          //endregion
          break;
        case 'passQty':
          //region 合格数量
          //endregion
          break;
        case 'disabledQty':
          //region 质废数量
          double quantity = double.tryParse(NumPadUtil().getText('quantity', numPadCTList) ?? '') ?? 0;
          double disabledQty = double.tryParse(NumPadUtil().getText('disabledQty', numPadCTList) ?? '') ?? 0;
          double materialQty = double.tryParse(NumPadUtil().getText('materialQty', numPadCTList) ?? '') ?? 0;
          double concessionQty = double.tryParse(NumPadUtil().getText('concessionQty', numPadCTList) ?? '') ?? 0;
          double passQty = quantity - disabledQty - materialQty - concessionQty;
          String passQtyStr = passQty.toString();
          NumPadUtil().setText('passQty', passQtyStr, numPadCTList);
          //endregion
          break;
        case 'materialQty':
          //region 料废数量
          double quantity = double.tryParse(NumPadUtil().getText('quantity', numPadCTList) ?? '') ?? 0;
          double disabledQty = double.tryParse(NumPadUtil().getText('disabledQty', numPadCTList) ?? '') ?? 0;
          double materialQty = double.tryParse(NumPadUtil().getText('materialQty', numPadCTList) ?? '') ?? 0;
          double concessionQty = double.tryParse(NumPadUtil().getText('concessionQty', numPadCTList) ?? '') ?? 0;
          double passQty = quantity - disabledQty - materialQty - concessionQty;
          String passQtyStr = passQty.toString();
          NumPadUtil().setText('passQty', passQtyStr, numPadCTList);
          //endregion
          break;
        case 'concessionQty':
          //region 让步接收数量
          double quantity = double.tryParse(NumPadUtil().getText('quantity', numPadCTList) ?? '') ?? 0;
          double disabledQty = double.tryParse(NumPadUtil().getText('disabledQty', numPadCTList) ?? '') ?? 0;
          double materialQty = double.tryParse(NumPadUtil().getText('materialQty', numPadCTList) ?? '') ?? 0;
          double concessionQty = double.tryParse(NumPadUtil().getText('concessionQty', numPadCTList) ?? '') ?? 0;
          double passQty = quantity - disabledQty - materialQty - concessionQty;
          String passQtyStr = passQty.toString();
          NumPadUtil().setText('passQty', passQtyStr, numPadCTList);
          //endregion
          break;
      }
    });
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
    String dTQuantityStr = NumPadUtil().getText("dTQuantity", numPadCTList) ?? '';
    String dTPassQtyStr = NumPadUtil().getText("dTPassQty", numPadCTList) ?? '';
    String dTDisableQtyStr = NumPadUtil().getText("dTDisableQty", numPadCTList) ?? '';
    String quantityStr = NumPadUtil().getText("quantity", numPadCTList) ?? '';
    String passQtyStr = NumPadUtil().getText("passQty", numPadCTList) ?? '';
    String disabledQtyStr = NumPadUtil().getText("disabledQty", numPadCTList) ?? '';
    String materialQtyStr = NumPadUtil().getText("materialQty", numPadCTList) ?? '';
    String concessionQtyStr = NumPadUtil().getText("concessionQty", numPadCTList) ?? '';
    String lostQtyStr = NumPadUtil().getText("lostQty", numPadCTList) ?? '';
    double? dTQuantity = double.tryParse(dTQuantityStr);
    double? dTPassQty = double.tryParse(dTPassQtyStr);
    double? dTDisableQty = double.tryParse(dTDisableQtyStr);
    double? quantity = double.tryParse(quantityStr);
    double? passQty = double.tryParse(passQtyStr);
    double? disabledQty = double.tryParse(disabledQtyStr);
    double? materialQty = double.tryParse(materialQtyStr);
    double? concessionQty = double.tryParse(concessionQtyStr);
    double? lostQty = double.tryParse(lostQtyStr);
    if (dTQuantityStr.isNotEmpty && (dTQuantity == null || dTQuantity < 0)){
      ToastNotification(Get.overlayContext!).warn("抽检数量输入错误！");
      isLoading = false;
      return;
    }
    if (dTPassQtyStr.isNotEmpty && (dTPassQty == null || dTPassQty < 0)){
      ToastNotification(Get.overlayContext!).warn("抽检合格数量输入错误！");
      isLoading = false;
      return;
    }
    if (dTDisableQtyStr.isNotEmpty && (dTDisableQty == null || dTDisableQty < 0)){
      ToastNotification(Get.overlayContext!).warn("抽检不合格数量输入错误！");
      isLoading = false;
      return;
    }
    if (quantityStr.isNotEmpty && (quantity == null || quantity < 0)){
      ToastNotification(Get.overlayContext!).warn("检验数量输入错误！");
      isLoading = false;
      return;
    }
    if (passQtyStr.isNotEmpty && (passQty == null || passQty < 0)){
      ToastNotification(Get.overlayContext!).warn("合格数量输入错误！");
      isLoading = false;
      return;
    }
    if (disabledQtyStr.isNotEmpty && (disabledQty == null || disabledQty < 0)){
      ToastNotification(Get.overlayContext!).warn("质废数量输入错误！");
      isLoading = false;
      return;
    }
    if (materialQtyStr.isNotEmpty && (materialQty == null || materialQty < 0)){
      ToastNotification(Get.overlayContext!).warn("料废数量输入错误！");
      isLoading = false;
      return;
    }
    if (concessionQtyStr.isNotEmpty && (concessionQty == null || concessionQty < 0)){
      ToastNotification(Get.overlayContext!).warn("让步接收数量输入错误！");
      isLoading = false;
      return;
    }
    double dtRemainder = (dTQuantity ?? 0) - (dTPassQty ?? 0) - (dTDisableQty ?? 0);
    if (dtRemainder != 0 && dtRemainder != dTQuantity){
      ToastNotification(Get.overlayContext!).warn("抽检数量和其余数量不能配平，请检查！");
      isLoading = false;
      return;
    }
    double remainder = (quantity ?? 0) - (passQty ?? 0) - (disabledQty ?? 0) - (materialQty ?? 0) - (concessionQty ?? 0);
    if (remainder != 0 && remainder != quantity){
      ToastNotification(Get.overlayContext!).warn("检验数量和其余数量不能配平，请检查！");
      isLoading = false;
      return;
    }
    if ((dTQuantity ?? 0) > (quantity ?? 0)){
      ToastNotification(Get.overlayContext!).warn("抽检数量大于检验数量，请检查！");
      isLoading = false;
      return;
    }
    MoCheckVoucherEntryModel? model3 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.verdictType == 3
                && element.chkConclusion != null && double.tryParse(element.chkConclusion!) == null);
    MoCheckVoucherEntryModel? model4 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.isUnqualifiedData
                && element.chkGuideComDefects != null && element.chkGuideComDefects!.isNotEmpty
                && (element.comDefects == null || element.comDefects!.isEmpty));
    MoCheckVoucherEntryModel? model5 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.isUnqualifiedData
                && (element.defectQty == null || element.defectQty! <= 0));
    if (model3 != null){
      ToastNotification(Get.overlayContext!).warn("“${model3.chkItemName ?? ''}-${model3.chkGuideName ?? ''}”的检验结论输入有误！");
      isLoading = false;
      return;
    }
    if (model4 != null){
      ToastNotification(Get.overlayContext!).warn("“${model4.chkItemName ?? ''}-${model4.chkGuideName ?? ''}”未选择缺陷原因！");
      isLoading = false;
      return;
    }
    if (model5 != null){
      ToastNotification(Get.overlayContext!).warn("“${model5.chkItemName ?? ''}-${model5.chkGuideName ?? ''}”未填写不合格数量，或输入有误！");
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
    checkVoucherItem.dTQuantity = dTQuantityStr.isEmpty ? null : dTQuantity;
    checkVoucherItem.dTPassQty = dTPassQtyStr.isEmpty ? null : dTPassQty;
    checkVoucherItem.dTDisableQty = dTDisableQtyStr.isEmpty ? null : dTDisableQty;
    checkVoucherItem.quantity = quantityStr.isEmpty ? null : quantity;
    checkVoucherItem.lostQty = lostQtyStr.isEmpty ? null : lostQty;
    checkVoucherItem.passQty = passQtyStr.isEmpty ? null : passQty;
    checkVoucherItem.disabledQty = disabledQtyStr.isEmpty ? null : disabledQty;
    checkVoucherItem.materialQty = materialQtyStr.isEmpty ? null : materialQty;
    checkVoucherItem.concessionQty = concessionQtyStr.isEmpty ? null : concessionQty;
    checkVoucherItem.description = NumPadUtil().getText('desc', numPadCTList);
    for (var element in checkVoucherItem.entryList) {
      if (!element.isUnqualifiedData){
        element.defectQty = null;
        element.comDefects = null;
      }
    }
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
    if (taskId.isEmpty){
      ///检验单类型一定相同
      if (qualityInspectionController.selectedTaskSignModel.sign == 0){ ///待检验（移除数据）
        qualityInspectionController.inspectList.removeWhere((element) => element.moInspectId == checkVoucherItem.moInspectId);
        qualityInspectionController.total --;
      }
      else if (qualityInspectionController.selectedTaskSignModel.sign == 1){ ///待判定（更新数据）
        MoCheckVoucherModel? checkVoucherModel = qualityInspectionController.checkVoucherList.firstWhereOrNull(
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
      if (qualityInspectionController.selectedTaskSignModel.sign == 1
          && qualityInspectionController.selectedTaskCategoryModel.sign == checkVoucherItem.category){ ///待判定 & 检验单类型相同（新增数据）
        MoCheckVoucherModel model = MoCheckVoucherModel.fromJson(checkVoucherItem.toJson());
        qualityInspectionController.checkVoucherList.insert(0, model);
        qualityInspectionController.total ++;
      }
    }
    qualityInspectionController.update();
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
    String dTQuantityStr = NumPadUtil().getText("dTQuantity", numPadCTList) ?? '';
    String dTPassQtyStr = NumPadUtil().getText("dTPassQty", numPadCTList) ?? '';
    String dTDisableQtyStr = NumPadUtil().getText("dTDisableQty", numPadCTList) ?? '';
    String quantityStr = NumPadUtil().getText("quantity", numPadCTList) ?? '';
    String passQtyStr = NumPadUtil().getText("passQty", numPadCTList) ?? '';
    String disabledQtyStr = NumPadUtil().getText("disabledQty", numPadCTList) ?? '';
    String materialQtyStr = NumPadUtil().getText("materialQty", numPadCTList) ?? '';
    String concessionQtyStr = NumPadUtil().getText("concessionQty", numPadCTList) ?? '';
    String lostQtyStr = NumPadUtil().getText("lostQty", numPadCTList) ?? '';
    double? dTQuantity = double.tryParse(dTQuantityStr);
    double? dTPassQty = double.tryParse(dTPassQtyStr);
    double? dTDisableQty = double.tryParse(dTDisableQtyStr);
    double? quantity = double.tryParse(quantityStr);
    double? passQty = double.tryParse(passQtyStr);
    double? disabledQty = double.tryParse(disabledQtyStr);
    double? materialQty = double.tryParse(materialQtyStr);
    double? concessionQty = double.tryParse(concessionQtyStr);
    double? lostQty = double.tryParse(lostQtyStr);
    if (dTQuantity == null || dTQuantity <= 0){
      ToastNotification(Get.overlayContext!).warn("抽检数量输入错误！");
      isLoading = false;
      return;
    }
    if (dTPassQtyStr.isNotEmpty && (dTPassQty == null || dTPassQty < 0)){
      ToastNotification(Get.overlayContext!).warn("抽检合格数量输入错误！");
      isLoading = false;
      return;
    }
    if (dTDisableQtyStr.isNotEmpty && (dTDisableQty == null || dTDisableQty < 0)){
      ToastNotification(Get.overlayContext!).warn("抽检不合格数量输入错误！");
      isLoading = false;
      return;
    }
    if (quantity == null || quantity <= 0){
      ToastNotification(Get.overlayContext!).warn("检验数量输入错误！");
      isLoading = false;
      return;
    }
    if (passQtyStr.isNotEmpty && (passQty == null || passQty < 0)){
      ToastNotification(Get.overlayContext!).warn("合格数量输入错误！");
      isLoading = false;
      return;
    }
    if (disabledQtyStr.isNotEmpty && (disabledQty == null || disabledQty < 0)){
      ToastNotification(Get.overlayContext!).warn("质废数量输入错误！");
      isLoading = false;
      return;
    }
    if (materialQtyStr.isNotEmpty && (materialQty == null || materialQty < 0)){
      ToastNotification(Get.overlayContext!).warn("料废数量输入错误！");
      isLoading = false;
      return;
    }
    if (concessionQtyStr.isNotEmpty && (concessionQty == null || concessionQty < 0)){
      ToastNotification(Get.overlayContext!).warn("让步接收数量输入错误！");
      isLoading = false;
      return;
    }
    double dtRemainder = dTQuantity - (dTPassQty ?? 0) - (dTDisableQty ?? 0);
    if (dtRemainder != 0){
      ToastNotification(Get.overlayContext!).warn("抽检数量和其余数量不能配平，请检查！");
      isLoading = false;
      return;
    }
    double remainder = quantity - (passQty ?? 0) - (disabledQty ?? 0) - (materialQty ?? 0) - (concessionQty ?? 0);
    if (remainder != 0){
      ToastNotification(Get.overlayContext!).warn("检验数量和其余数量不能配平，请检查！");
      isLoading = false;
      return;
    }
    if (dTQuantity > quantity){
      ToastNotification(Get.overlayContext!).warn("抽检数量大于检验数量，请检查！");
      isLoading = false;
      return;
    }
    MoCheckVoucherEntryModel? model0 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.verdictType == 0 && (element.verdict == null || element.verdict == 0));
    MoCheckVoucherEntryModel? model1 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.verdictType == 1 && (element.chkConclusion == null || element.chkConclusion!.isEmpty));
    MoCheckVoucherEntryModel? model2 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.verdictType == 2 && (element.chkConclusion == null || element.chkConclusion!.isEmpty));
    MoCheckVoucherEntryModel? model3 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.verdictType == 3 && (element.chkConclusion == null || element.chkConclusion!.isEmpty || double.tryParse(element.chkConclusion!) == null));
    MoCheckVoucherEntryModel? model4 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.isUnqualifiedData
                && element.chkGuideComDefects != null && element.chkGuideComDefects!.isNotEmpty
                && (element.comDefects == null || element.comDefects!.isEmpty));
    MoCheckVoucherEntryModel? model5 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.isUnqualifiedData
                && (element.defectQty == null || element.defectQty! <= 0));
    MoCheckVoucherEntryModel? model6 = checkVoucherItem.entryList.firstWhereOrNull(
            (element) => element.isUnqualifiedData);
    if (model0 != null){
      ToastNotification(Get.overlayContext!).warn("请选择“${model0.chkItemName ?? ''}-${model0.chkGuideName ?? ''}”的检验结论！");
      isLoading = false;
      return;
    }
    if (model1 != null){
      ToastNotification(Get.overlayContext!).warn("请选择“${model1.chkItemName ?? ''}-${model1.chkGuideName ?? ''}”的检验结论！");
      isLoading = false;
      return;
    }
    if (model2 != null){
      ToastNotification(Get.overlayContext!).warn("请输入“${model2.chkItemName ?? ''}-${model2.chkGuideName ?? ''}”的检验结论！");
      isLoading = false;
      return;
    }
    if (model3 != null){
      ToastNotification(Get.overlayContext!).warn("请输入“${model3.chkItemName ?? ''}-${model3.chkGuideName ?? ''}”的检验结论，或输入有误！");
      isLoading = false;
      return;
    }
    if (model4 != null){
      ToastNotification(Get.overlayContext!).warn("“${model4.chkItemName ?? ''}-${model4.chkGuideName ?? ''}”未选择缺陷原因！");
      isLoading = false;
      return;
    }
    if (model5 != null){
      ToastNotification(Get.overlayContext!).warn("“${model5.chkItemName ?? ''}-${model5.chkGuideName ?? ''}”未填写不合格数量，或输入有误！");
      isLoading = false;
      return;
    }
    if (((dTDisableQty ?? 0) != 0 || (disabledQty ?? 0) != 0 || (materialQty ?? 0) != 0 || (concessionQty ?? 0) != 0) && model6 == null){
      ToastNotification(Get.overlayContext!).warn("有不合格产品，但是检验项目中没有缺陷项目，请检查！");
      isLoading = false;
      return;
    }
    if (checkVoucherItem.inspector == null || checkVoucherItem.inspector!.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择提交人员！");
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
    checkVoucherItem.sign = MoCheckVoucherSign.ywg.sign; ///已检验
    checkVoucherItem.dTQuantity = dTQuantityStr.isEmpty ? null : dTQuantity;
    checkVoucherItem.dTPassQty = dTPassQtyStr.isEmpty ? null : dTPassQty;
    checkVoucherItem.dTDisableQty = dTDisableQtyStr.isEmpty ? null : dTDisableQty;
    checkVoucherItem.quantity = quantityStr.isEmpty ? null : quantity;

    checkVoucherItem.lostQty = lostQtyStr.isEmpty ? null : lostQty;
    checkVoucherItem.passQty = passQtyStr.isEmpty ? null : passQty;
    checkVoucherItem.disabledQty = disabledQtyStr.isEmpty ? null : disabledQty;
    checkVoucherItem.materialQty = materialQtyStr.isEmpty ? null : materialQty;
    checkVoucherItem.concessionQty = concessionQtyStr.isEmpty ? null : concessionQty;
    checkVoucherItem.description = NumPadUtil().getText('desc', numPadCTList) ?? '';
    for (var element in checkVoucherItem.entryList) {
      if (!element.isUnqualifiedData){
        element.defectQty = null;
        element.comDefects = null;
      }
    }
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
    if (taskId.isEmpty){
      ///检验单类型一定相同
      if (qualityInspectionController.selectedTaskSignModel.sign == 0){ ///待检验（移除数据）
        qualityInspectionController.inspectList.removeWhere((element) => element.moInspectId == checkVoucherItem.moInspectId);
        qualityInspectionController.total --;
      }
      else if (qualityInspectionController.selectedTaskSignModel.sign == 1){ ///待判定（移除数据）
        qualityInspectionController.checkVoucherList.removeWhere((element) => element.moInspectId == checkVoucherItem.moInspectId);
        qualityInspectionController.total --;
      }
    }
    else {
      if (qualityInspectionController.selectedTaskSignModel.sign == 256){ ///已检验（新增数据）
        MoCheckVoucherModel model = MoCheckVoucherModel.fromJson(checkVoucherItem.toJson());
        qualityInspectionController.checkVoucherList.insert(0, model);
        qualityInspectionController.total ++;
      }
    }
    qualityInspectionController.update();
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
      AppRoutes.IPQC_QUALITY_INSPECTION_FINAL_INSPECTION_DETAIL_ATTACH_PAGE,
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
      AppRoutes.IPQC_QUALITY_INSPECTION_FINAL_INSPECTION_DETAIL_ATTACH_PAGE,
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
    AppRoutes.IPQC_QUALITY_INSPECTION_FINAL_INSPECTION_DETAIL_ATTACH_PAGE,
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
    debounce.dispose();
    dataReportScrollController.dispose();
    detailScrollController.dispose();
    for (var element in numPadCTList) {
      element.dispose();
    }
    super.onClose();
  }

}