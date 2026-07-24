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

///质量巡检 来料检验单详情页（编辑 + 查看）
class QMInspectionDetailFormController extends BaseFormController {

  ///报检单明细Id
  final String inspectMxID;
  ///检验单Id
  final String moCheckId;
  ///派工单Id（通过派工单ID，生成检验单）
  final String taskId;
  ///派工单生成的检验单类型， 1：来料检验 2：首检 4：巡检 8：末检 16：产品终检（该数据一定不会是 终检） 32：自检
  final int taskToCheckVoucherCategory;

  ///检验单
  QMCheckVoucherItem qmCheckVoucherItem = QMCheckVoucherItem();
  final ScrollController detailScrollController = ScrollController();
  ///当前检验单已完成数目
  int finishedNum = 0;
  ///当前检验单总数目
  int totalNum = 0;
  ///是否可以新增检验方案
  bool canAddCheckGuide = false;

  ///单个检验项目的不合格数量TextEditingController 列表
  final List<TextEditingControllerKeyModel> quideDisQuantityTCList = [];
  ///缺陷原因Adapter列表
  final List<AdapterKeyModel> comDefectsAdapterList = [];
  ///提交人员选择Adapter
  PersonAdapter? personAdapter;
  final ScrollController dataReportScrollController = ScrollController();

  ///表体展开框的控制器列表
  final List<ExpansibleController> expansionTileControllerList = [];

  final List<NumPadController> numPadCTList = [
    NumPadController(key: 'dTQuantity', zhName: '检验数量', keyboardType: TextInputType.number),
    NumPadController(key: 'regQuantity', zhName: '合格数量', keyboardType: TextInputType.number),
    NumPadController(key: 'conQuantiy', zhName: '让步接收数量', keyboardType: TextInputType.number),
    NumPadController(key: 'disQuantity', zhName: '不合格数', keyboardType: TextInputType.number),
    NumPadController(key: 'desc', zhName: '备注', keyboardType: TextInputType.text),
  ];

  ///数据填报表单输入时启用时间防抖
  final Debounce debounce = Debounce(const Duration(milliseconds: 500));

  ///附件列表
  DMDocumentModel dMDocumentModel = DMDocumentModel();

  ///检验指标Adapter
  CheckGuideAdapter? checkGuideAdapter;

  final QualityInspectionController qualityInspectionController = Get.find<QualityInspectionController>();


  QMInspectionDetailFormController({
    super.progId = 810023,
    required this.inspectMxID,
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
    await getCheckVoucherItem();
    await getCheckVoucherAttach();
    getNum();
    setDefaultNumPad();
    await getQuideDisQuantityTCList();
    await getComDefectsAdapterList();
    await getPersonAdapter();
    await getCheckGuideAdapter();
    getECList();
    return true;
  }

  ///获取检验单
  Future<bool> getCheckVoucherItem() async{
    if (moCheckId.isNotEmpty){ ///有检验单，直接从检验单中读取数据
      var res = await QMCheckVoucherRepository().getFormData(moCheckId, '', null, 0);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取检验单数据时出错：${res.message}');
        return false;
      }
      qmCheckVoucherItem = res.data;
    }
    else if (inspectMxID.isNotEmpty) { ///没有检验单，报检单生成检验单，从报检单中生成数据
      var res1 = await QMCheckVoucherRepository().isCanInspectMxToCheckVoucher(inspectMxID, 1);
      if (!res1.isSuccess){
        ToastNotification(Get.overlayContext!).error('不能生成检验单：${res1.message}');
        return false;
      }
      var res2 = await QMCheckVoucherRepository().inspectMxToCheckVoucher(inspectMxID, 1);
      if (!res2.isSuccess){
        ToastNotification(Get.overlayContext!).error('根据报检单ID获取或生成检验单时出错：${res2.message}');
        return false;
      }
      qmCheckVoucherItem = res2.data;
    }
    else if (taskId.isNotEmpty){ ///通过派工单ID，生成检验单
      /*var res = await MoTaskRepository().checkVoucher(taskId, taskToCheckVoucherCategory);
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('根据派工单ID获取或生成检验单时出错：${res.message}');
        return false;
      }
      qmCheckVoucherItem = res.data;*/
    }

    canAddCheckGuide = qmCheckVoucherItem.checkID.isEmpty && qmCheckVoucherItem.entryList.isEmpty;

    return true;
  }

  Future<void> getCheckVoucherAttach() async {
    if (qmCheckVoucherItem.checkID.isEmpty){
      return;
    }
    dMDocumentModel = DMDocumentModel();
    var res = await FormRepository().getDocument('image', progId, qmCheckVoucherItem.checkID);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取检验单图片附件时出错：${res.message}');
      return;
    }
    dMDocumentModel = res.data;
  }

  ///获取进度
  void getNum() {
    finishedNum = qmCheckVoucherItem.entryList.where(
            (element) => (element.verdict ?? 0) != 0
    ).length;
    totalNum = qmCheckVoucherItem.entryList.length;
  }

  void setDefaultNumPad() {
    if (qmCheckVoucherItem.checkID.isNotEmpty){ ///已检验
      return;
    }
    //region 获取检验数量
    switch (qmCheckVoucherItem.testStyle){
      case 0: ///全检
        NumPadUtil().setText('dTQuantity', qmCheckVoucherItem.quantity?.toString() ?? '', numPadCTList);
        break;
      case 1: ///免检
        NumPadUtil().setText('dTQuantity', '0', numPadCTList);
        break;
      case 2: ///破坏性抽检
      case 3: ///非破坏性抽检
        NumPadUtil().setText('dTQuantity', qmCheckVoucherItem.dTQuantity?.toString()?? '', numPadCTList);
        break;
    }
    //endregion
    NumPadUtil().setText('desc', qmCheckVoucherItem.memo ?? '', numPadCTList);
  }

  ///获取缺陷原因列表（检验方案列表）
  Future<void> getComDefectsAdapterList() async{
    if (qmCheckVoucherItem.checkID.isNotEmpty){ ///已检验
      return;
    }
    comDefectsAdapterList.clear();
    for (var element in qmCheckVoucherItem.entryList) {
      List<String> comDefectsList = element.comDefects == null || element.comDefects!.isEmpty ? [] : element.comDefects!.split(',');
      List<PickerDataModel> fieldList = comDefectsList.map((e) => PickerDataModel(id: PinyinHelper.getShortPinyin(e), name: e)).toList();
      List<String> selectedContentList = (element.defectsQtys ?? '').split(',').map((e) => e.split(':').first).toList();
      List<PickerDataModel> selectedList = selectedContentList.map((e) => PickerDataModel(id: PinyinHelper.getShortPinyin(e), name: e)).toList();
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
  Future<void> getQuideDisQuantityTCList() async {
    if (qmCheckVoucherItem.checkID.isNotEmpty){ ///已检验
      return;
    }
    for (var element in qmCheckVoucherItem.entryList) {
      quideDisQuantityTCList.add(
        TextEditingControllerKeyModel(
          keyName: '${element.rowNo}',
          tC: TextEditingController(text: element.quideDisQuantity?.toString()),
          tCType: TCType.double,
          fn: FocusNode(),
        )
      );
    }
  }


  ///获取展开框控制器列表
  Future<void> getECList() async {
    expansionTileControllerList.clear();
    expansionTileControllerList.addAll(qmCheckVoucherItem.entryList.map((e) => ExpansibleController()));
  }

  ///获取提交人Adapter
  Future<void> getPersonAdapter() async {
    if (qmCheckVoucherItem.sign == MoCheckVoucherSign.ywg.sign){ ///已检验
      return;
    }
    personAdapter = await AdapterHelper.getAsyncAdapter(
      'person',
      isNeedLoadData: true,
    ) as PersonAdapter;
  }

  ///获取检验指标Adapter
  Future<void> getCheckGuideAdapter() async {
    if (qmCheckVoucherItem.checkID.isNotEmpty){ ///已检验
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
  void resetDefectQtyAndComDefects(QMCheckVouchersModel item) {
    if (!item.isUnqualifiedData){
      item.quideDisQuantity = null;
      TextEditingControllerKeyModel? textEditingControllerKeyModel = quideDisQuantityTCList.firstWhereOrNull((element) => element.keyName == '${item.rowNo}');
      if (textEditingControllerKeyModel != null){
        textEditingControllerKeyModel.tC.clear();
      }
      item.defectsQtys = null;
      AdapterKeyModel? adapterKeyModel = comDefectsAdapterList.firstWhereOrNull((element) => element.keyName == '${item.rowNo}');
      if (adapterKeyModel != null){
        for (var element in adapterKeyModel.adapter.dataList) { element.isSelected = false; }
      }
    }
  }

  ///检验结果选择变化 0-未检 1-OK  2-NG
  Future<void> verdictOnChanged(QMCheckVouchersModel item, int index) async{
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

  ///数字、文字填报变化
  Future<void> verdictType23OnChanged(QMCheckVouchersModel item, String str) async {
    item.quideDisQuantity = double.tryParse(str);
    resetDefectQtyAndComDefects(item);
    getNum();
    update();
  }

  ///缺陷原因选择变化
  Future<void> comDefectsOnChanged(QMCheckVouchersModel item, List<PickerDataModel> list) async{
    item.defectsQtys = list.map((e) => e.name).join(',');
    update();
  }

  ///总结论选择变化
  Future<void> overAllVerdictOnChanged(int index) async {
    if (qmCheckVoucherItem.batchChkResult == index){
      qmCheckVoucherItem.batchChkResult = null;
    }
    else {
      qmCheckVoucherItem.batchChkResult = index;
    }
    update();
  }

  ///提交人员选择变化
  Future<void> personOnChanged(PickerDataModel item) async{
    qmCheckVoucherItem.checkPersonID = item.id;
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
    List<String> chkGuideIDList = qmCheckVoucherItem.entryList.map((e) => e.chkGuideID ?? '').toSet().toList();
    List<PickerDataModel> newAddList = list.where((element){
      element as QMCheckGuideModel;
      return !chkGuideIDList.contains(element.chkGuideID);
    }).toList();
    List<int> rowNoList = qmCheckVoucherItem.entryList.map((e) => e.rowNo ?? 0).toSet().toList();
    int rowNo = rowNoList.isEmpty ? -1 : rowNoList.reduce(max);
    List<QMCheckVouchersModel> itemList = [];
    for (var element in newAddList) {
      element as QMCheckGuideModel;
      rowNo ++;
      QMCheckVouchersModel qmCheckVouchersModel = QMCheckVouchersModel(
        checkMxID: '',
        checkID: '',
        chkGuideName: element.chkGuideName,
        bugGrade: element.bugGrade,
        comDefects: element.comDefects,
        bMemo: element.memo,
        chkStandardProvision: element.chkStandardProvision,
        iDTmethod: element.chkMethod,
        ruleID: element.ruleID,
        ruleCode: element.ruleCode,
        ruleName: element.ruleName,
        chkItemCode: element.chkItemCode,
        chkItemName: element.chkItemName,
        rowNo: rowNo,
        sign: 0,
        status: '',
        chkItemID: element.chkItemID,
        chkGuideID: element.chkGuideID,
        inportGrade: element.inPortGrade,
        standardValue: element.standardValue,
        upperLimit: element.upperLimit,
        lowerLimit: element.lowerLimit,
        chkGuidType: int.tryParse(element.chkGuidType.toString()) ?? 0,
        unitName: element.unitName,
        fAQL: element.fAql,
        // ac RE
      );
      itemList.add(qmCheckVouchersModel);
      //region 增加缺陷Adapter
      List<String> comDefectsList = qmCheckVouchersModel.comDefects == null || qmCheckVouchersModel.comDefects!.isEmpty
          ? []
          : qmCheckVouchersModel.comDefects!.split(',');
      List<PickerDataModel> fieldList = comDefectsList.map((e) => PickerDataModel(id: PinyinHelper.getShortPinyin(e), name: e)).toList();
      CustomAdapter comDefectsAdapter = await AdapterHelper.getAsyncAdapter(
        'custom',
        multipleSelection: true,
        title: '缺陷',
        fieldList: fieldList,
      ) as CustomAdapter;
      AdapterKeyModel adapterKeyModel = AdapterKeyModel(
          keyName: '${qmCheckVouchersModel.rowNo}',
          adapter: comDefectsAdapter
      );
      comDefectsAdapterList.add(adapterKeyModel);

      TextEditingControllerKeyModel quideDisQuantityTCKModel = TextEditingControllerKeyModel(
        keyName: '${qmCheckVouchersModel.rowNo}',
        tC: TextEditingController(text: qmCheckVouchersModel.quideDisQuantity?.toString()),
        tCType: TCType.double,
        fn: FocusNode(),
      );
      quideDisQuantityTCList.add(quideDisQuantityTCKModel);
      //endregion
    }
    qmCheckVoucherItem.entryList.addAll(itemList);
    expansionTileControllerList.addAll(itemList.map((e) => ExpansibleController()));
    getNum();
    update();
  }

  ///移除检验指标
  Future<void> removeCheckGuide(QMCheckVouchersModel item) async {
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认移除检验指标？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      return;
    }
    checkGuideAdapter?.dataList.firstWhereOrNull((element) => element.chkGuideID == item.chkGuideID)?.isSelected = false;
    qmCheckVoucherItem.entryList.removeWhere((element) => element.chkGuideID == item.chkGuideID);
    expansionTileControllerList.removeLast();
    comDefectsAdapterList.removeWhere((element){
      bool res = element.keyName == '${item.rowNo}';
      return res;
    });

    quideDisQuantityTCList.removeWhere((element){
      bool res = element.keyName == '${item.rowNo}';
      return res;
    });

    for (var element in qmCheckVoucherItem.entryList) {
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
    for (var element in quideDisQuantityTCList) {
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


  void calcQty(String keyName) {
    debounce((){
      switch (keyName){
        case 'dTQuantity': ///检验数量
          double dTQuantity = double.tryParse(NumPadUtil().getText("dTQuantity", numPadCTList) ?? '') ?? 0;
          double conQuantiy = double.tryParse(NumPadUtil().getText("conQuantiy", numPadCTList) ?? '') ?? 0;
          double disQuantity = double.tryParse(NumPadUtil().getText("disQuantity", numPadCTList) ?? '') ?? 0;
          double regQuantity = dTQuantity - conQuantiy - disQuantity;
          String regQuantityStr = regQuantity.toString();
          NumPadUtil().setText('regQuantity', regQuantityStr, numPadCTList);
          break;
        case 'regQuantity': ///合格数量
          break;
        case 'conQuantiy': ///让步接收数量
          double dTQuantity = double.tryParse(NumPadUtil().getText("dTQuantity", numPadCTList) ?? '') ?? 0;
          double conQuantiy = double.tryParse(NumPadUtil().getText("conQuantiy", numPadCTList) ?? '') ?? 0;
          double disQuantity = double.tryParse(NumPadUtil().getText("disQuantity", numPadCTList) ?? '') ?? 0;
          double regQuantity = dTQuantity - conQuantiy - disQuantity;
          String regQuantityStr = regQuantity.toString();
          NumPadUtil().setText('regQuantity', regQuantityStr, numPadCTList);
          break;
        case 'disQuantity': ///不合格数
          double dTQuantity = double.tryParse(NumPadUtil().getText("dTQuantity", numPadCTList) ?? '') ?? 0;
          double conQuantiy = double.tryParse(NumPadUtil().getText("conQuantiy", numPadCTList) ?? '') ?? 0;
          double disQuantity = double.tryParse(NumPadUtil().getText("disQuantity", numPadCTList) ?? '') ?? 0;
          double regQuantity = dTQuantity - conQuantiy - disQuantity;
          String regQuantityStr = regQuantity.toString();
          NumPadUtil().setText('regQuantity', regQuantityStr, numPadCTList);
          break;
      }
    });
  }


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
      qmCheckVoucherItem.images_tou.add({'key': key, 'file': element.path});
    });
    update();
    isLoading = false;
  }

  ///删除[checkVoucherItem]的要上传的图片
  Future<void> deleteCheckVoucherAttach(String key) async {
    qmCheckVoucherItem.images_tou.removeWhere((element) => element['key'] == key);
    update();
  }

  //endregion


  ///提交
  Future<void> onSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 提交前检查
    if (qmCheckVoucherItem.entryList.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请增加检验项目！");
      isLoading = false;
      return;
    }
    String dTQuantityStr = NumPadUtil().getText("dTQuantity", numPadCTList) ?? '';
    String regQuantityStr = NumPadUtil().getText("regQuantity", numPadCTList) ?? '';
    String conQuantiyStr = NumPadUtil().getText("conQuantiy", numPadCTList) ?? '';
    String disQuantityStr = NumPadUtil().getText("disQuantity", numPadCTList) ?? '';
    double? dTQuantity = double.tryParse(dTQuantityStr);
    double? regQuantity = double.tryParse(regQuantityStr);
    double? conQuantiy = double.tryParse(conQuantiyStr);
    double? disQuantity = double.tryParse(disQuantityStr);
    if (dTQuantity == null || dTQuantity <= 0){
      ToastNotification(Get.overlayContext!).warn("检验数量输入错误！");
      isLoading = false;
      return;
    }
    if (regQuantityStr.isNotEmpty && (regQuantity == null || regQuantity < 0)){
      ToastNotification(Get.overlayContext!).warn("合格数量输入错误！");
      isLoading = false;
      return;
    }
    if (conQuantiyStr.isNotEmpty && (conQuantiy == null || conQuantiy < 0)){
      ToastNotification(Get.overlayContext!).warn("让步接收数量输入错误！");
      isLoading = false;
      return;
    }
    if (disQuantityStr.isNotEmpty && (disQuantity == null || disQuantity < 0)){
      ToastNotification(Get.overlayContext!).warn("不合格数量输入错误！");
      isLoading = false;
      return;
    }
    double remainder = dTQuantity - (regQuantity ?? 0) - (conQuantiy ?? 0) - (disQuantity ?? 0);
    if (remainder != 0){
      ToastNotification(Get.overlayContext!).warn("检验数量和其余数量不能配平，请检查！");
      isLoading = false;
      return;
    }
    QMCheckVouchersModel? model0 = qmCheckVoucherItem.entryList.firstWhereOrNull(
            (element) => element.verdict == null || element.verdict == 0);
    QMCheckVouchersModel? model4 = qmCheckVoucherItem.entryList.firstWhereOrNull(
            (element) => element.isUnqualifiedData
                && element.comDefects != null && element.comDefects!.isNotEmpty
                && (element.defectsQtys == null || element.defectsQtys!.isEmpty));
    QMCheckVouchersModel? model5 = qmCheckVoucherItem.entryList.firstWhereOrNull(
            (element) => element.isUnqualifiedData
                && (element.quideDisQuantity == null || element.quideDisQuantity! <= 0));
    QMCheckVouchersModel? model6 = qmCheckVoucherItem.entryList.firstWhereOrNull(
            (element) => element.isUnqualifiedData);
    if (model0 != null){
      ToastNotification(Get.overlayContext!).warn("请选择“${model0.chkItemName ?? ''}-${model0.chkGuideName ?? ''}”的检验结论！");
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
    if (qmCheckVoucherItem.checkPersonID == null || qmCheckVoucherItem.checkPersonID!.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择提交人员！");
      isLoading = false;
      return;
    }
    if ((conQuantiy != null || disQuantity != null) && model6 == null){
      ToastNotification(Get.overlayContext!).warn("有不合格产品，但是检验项目中没有缺陷项目，请检查！");
      isLoading = false;
      return;
    }
    if (qmCheckVoucherItem.batchChkResult == null){
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
    qmCheckVoucherItem.progID = progId;
    qmCheckVoucherItem.dTQuantity = dTQuantity;
    qmCheckVoucherItem.regQuantity = regQuantity;
    qmCheckVoucherItem.conQuantiy = conQuantiy;
    qmCheckVoucherItem.disQuantity = disQuantity;
    qmCheckVoucherItem.memo = NumPadUtil().getText('desc', numPadCTList) ?? '';
    var res = await QMCheckVoucherRepository().saveVoucher('', qmCheckVoucherItem);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('检验记录提交失败！${res.message}');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '检验记录提交成功，正在刷新数据！');
    //endregion
    //region 刷新页面
    var newDataRes = await QMCheckVoucherRepository().getFormData(res.data.data ?? '', '', null, 0);
    if (!newDataRes.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取刷新数据失败,请手动刷新！${newDataRes.message}');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    qmCheckVoucherItem = newDataRes.data;
    await getCheckVoucherAttach();
    canAddCheckGuide = qmCheckVoucherItem.checkID.isEmpty && qmCheckVoucherItem.entryList.isEmpty;
    if (taskId.isEmpty){
      ///检验单类型一定相同
      if (qualityInspectionController.selectedTaskSignModel.sign == 0){ ///待检验（移除数据）
        qualityInspectionController.qmInspectList.removeWhere((element) => element.inspectMxID == qmCheckVoucherItem.inspectMxID);
        qualityInspectionController.total --;
      }
    }
    else {
      if (qualityInspectionController.selectedTaskSignModel.sign == 256){ ///已检验（新增数据）
        QMCheckVoucherModel model = QMCheckVoucherModel.fromJson(qmCheckVoucherItem.toJson());
        qualityInspectionController.qmCheckVoucherList.insert(0, model);
        qualityInspectionController.total ++;
      }
    }
    qualityInspectionController.update();
    //endregion
    update();
    ProgressDialogUtil.update(value: 2);
    isLoading = false;
  }


  //region 附件

  ///查看附件
  Future<void> getAttach() async{
    if (qmCheckVoucherItem.projectID == null || qmCheckVoucherItem.projectID!.isEmpty){
      ToastNotification(Get.overlayContext!).warn('未关联检验方案！');
      return;
    }
    Get.rootDelegate.toNamed(
        AppRoutes.IPQC_QUALITY_INSPECTION_QM_INSPECTION_DETAIL_ATTACH_PAGE,
        parameters: {
          'pageTitle': '检验方案附件',
          'id': qmCheckVoucherItem.projectID!,
          'progId': '810003',
          'category': 'attach',
        }
    );
  }

  ///查看产品附件
  Future<void> getInvAttach() async{
    if (qmCheckVoucherItem.invID == null || qmCheckVoucherItem.invID!.isEmpty){
      ToastNotification(Get.overlayContext!).error('该检验单没有产品！');
      return;
    }
    Get.rootDelegate.toNamed(
        AppRoutes.IPQC_QUALITY_INSPECTION_QM_INSPECTION_DETAIL_ATTACH_PAGE,
        parameters: {
          'pageTitle': '产品附件-${qmCheckVoucherItem.invName}',
          'id': qmCheckVoucherItem.invID!,
          'progId': '200025',
          'category': 'attach',
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