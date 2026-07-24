

import 'package:basement/item_model.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/service/data_service.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_barcode_interface/inv_barcode_print_interface.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/form_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///物料条码新增接口 230004
mixin InvBarcodeInterface on InvBarcodePrintInterface {

  final _dataService = Get.find<DataService>();

  ///获取的系统对象相关属性；
  ///
  /// 基类中重写
  EditFormItem objectItem = EditFormItem();

  ///要提交条码记录的产品信息 初始值：上一个页面选中的派工单
  InventoryModel inventoryModel = InventoryModel();

  ///页面上显示物料条码提交按钮（可显示多个，index 相加）
  ///
  ///1：条码提交
  ///
  ///2：提交并打印
  int invBarcodeSaveBtnIndex = AppConfig.invBarcodeSaveBtnIndex;

  ///物料条码提交提交成功后，是否返回到首页
  bool isGetBackAfterSaveSuccess = AppConfig.isGetBackAfterCommitSuccess;

  ///是否显示物料条码填报方式切换按钮
  bool isShowSaveTypeBtn = AppConfig.isShowDataReportTypeBtn;
  ///物料条码填报方式
  String _saveType = AppConfig.qtySubmit;
  ///物料条码填报方式
  String get saveType => _saveType;
  ///物料条码填报方式
  set saveType(String str){
    _saveType = str;
    _operationWay = operationWayList.firstWhereOrNull((element) => element.keyName == _saveType);
  }
  ///物料条码填报方式
  ChoiceChipModel? _operationWay;
  ///物料条码填报方式
  ChoiceChipModel? get operationWay => _operationWay;
  ///物料条码填报方式列表
  List<ChoiceChipModel> get operationWayList => List.unmodifiable(AppConfig.invBarcodeOperationWayList);

  ///当填报方式是“按托填报”时，填报数据的计算方式
  ///
  ///0：填写“单箱数量”时，计算“单托箱数”、“尾箱数量”
  ///
  ///1：填写“单箱数量”时，计算“总数量”
  int calcRuleForPalletSaveType = AppConfig.calcRuleForPalletSubmitType;

  ///表单数据填写项的数据校验
  late final Map<String, int?> formJudgeTypeMap = {
    /*'local-${NumPadUtil.eBWeight}': (saveType == AppConfig.qtySubmit && qtyIsNeedPieceWeight)
        || (saveType == AppConfig.qtyBoxSubmit && qtyBoxIsNeedPieceWeight)
        || (saveType == AppConfig.palletSubmit && palletIsNeedPieceWeight)
        || (saveType == AppConfig.weightSubmit && weightIsNeedPieceWeight)
        || (saveType == AppConfig.weightBoxSubmit && weightBoxIsNeedPieceWeight) ? 4 : null,
    'local-${NumPadUtil.eBPiece}': (saveType == AppConfig.qtySubmit && qtyIsNeedPieceWeight)
        || (saveType == AppConfig.qtyBoxSubmit && qtyBoxIsNeedPieceWeight)
        || (saveType == AppConfig.palletSubmit && palletIsNeedPieceWeight)
        || (saveType == AppConfig.weightSubmit && weightIsNeedPieceWeight)
        || (saveType == AppConfig.weightBoxSubmit && weightBoxIsNeedPieceWeight) ? 4 : null,
    'local-${NumPadUtil.pieceWeight}': (saveType == AppConfig.qtySubmit && qtyIsNeedPieceWeight)
        || (saveType == AppConfig.qtyBoxSubmit && qtyBoxIsNeedPieceWeight)
        || (saveType == AppConfig.palletSubmit && palletIsNeedPieceWeight)
        || (saveType == AppConfig.weightSubmit && weightIsNeedPieceWeight)
        || (saveType == AppConfig.weightBoxSubmit && weightBoxIsNeedPieceWeight) ? 4 : null,*/

    'local-${NumPadUtil.eBWeight}': 4,
    'local-${NumPadUtil.eBPiece}': 4,
    'local-${NumPadUtil.pieceWeight}': 4,
    'Qty': 116,
  };
  ///重量表单填写项的小数位长度
  final Map<String, int> weightFormDecimalLengthMap = {
    NumPadUtil.eBWeight: 4,
    NumPadUtil.pieceWeight: 4,
    NumPadUtil.packingWeight: 4,
    NumPadUtil.singleBoxWeight: 4,
    NumPadUtil.lastBoxWeight: 4,
    NumPadUtil.weight: 4,
    NumPadUtil.boxWeight: 4,
  };
  ///表单数据填写项的标题名称
  final Map<String, String> formTitleMap = {};
  ///表单数据填写项的样式
  final Map<String, Map<String, dynamic>> formStyleMap = {};

  ///物料条码数据
  final BarcodeEntity barcodeEntity = BarcodeEntity();
  MoContainerWithNoPageAdapter? containerWithNoPageAdapter;

  ///数据填报表单输入时启用时间防抖
  final Debounce numPadDebounce = Debounce(const Duration(milliseconds: 500));
  ///表单数据（数字型）填写项列表
  final List<NumPadController> numPadCTList = [];

  ///自动获取焦点的输入框字段名
  String numPadFocusField = AppConfig.numPadFocusField;

  ///单列可显示的表单填写项的行数
  int? formRowMaxCountLimit = AppConfig.formRowMaxCountLimit;

  ///整箱箱数可以填写的上限
  int? numMaxCountLimit = AppConfig.numMaxCountLimit;

  ///单箱数量可以填写的下限
  double? singleBoxQtyMaxCountLimit = AppConfig.singleBoxQtyMaxCountLimit;

  ///按重量填报时，产品称重的数据是否加到填报总数据上
  bool weightIsAddPieceWeightToTotal = AppConfig.weightIsAddPieceWeightToTotal;

  ///标准单重与实际单重的偏差是否超过20%
  bool isWeightError = false;

  ///按数量（多箱）填报时，是否显示称重消息传递过来的单箱重量、预计单箱数量
  bool isShowExpectSingleBoxQty = AppConfig.isShowExpectSingleBoxQty;
  ///保存了：按数量（多箱）填报时，称重消息传递过来的单箱重量
  double? _singleBoxWeightForExpect;
  ///保存了：按多箱报工时，称重消息传递过来的单箱重量
  double? get singleBoxWeightForExpect => _singleBoxWeightForExpect;
  ///保存了：按多箱报工时，称重消息传递过来的单箱重量
  set singleBoxWeightForExpect(double? value){
    _singleBoxWeightForExpect = value;
    double pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList).toString()) ?? 0;
    double packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList).toString()) ?? 0;
    int boxQty = pieceWeight == 0
        ? 0
        : (_singleBoxWeightForExpect! - packingWeight) * 1000 ~/ pieceWeight;
    singleBoxQtyForExpect = boxQty <= 0 ? null : boxQty;
    update();
  }
  ///保存了：按数量（多箱）填报时，预计单箱数量
  int? singleBoxQtyForExpect;

  ///装箱说明（装箱容器）
  String containerPackingDescription = '';

  ///是否保存上次提交物料条码时的填写的皮重数据或选择的装箱容器数据
  bool isSaveTheLastPackingWeightData = AppConfig.isSaveTheLastPackingWeightData;

  ///是否通过选择装箱容器，自动填充皮重、单箱数量
  bool isUsePackingPicker = AppConfig.isUsePackingPicker;

  ///“单箱数量”是否只能通过选择装箱容器来赋值，而不是手动输入
  ///
  /// [isUsePackingPicker] == [True]时，该值才会起作用；（通过选择装箱容器，自动填充皮重、单箱数量）
  ///
  /// [True]：
  ///
  /// 当有“皮重”填写项时，“皮重”显示装箱容器选择器，“单箱数量”显示填写框、只读；
  ///
  /// 当没有“皮重”填写项时，“单箱数量”显示装箱容器选择器；
  ///
  /// [False]：
  ///
  /// 当有“皮重”填写项时，显示“单箱数量”填写框；
  ///
  /// 当没有“皮重”填写项时，显示“单箱数量”填写框，左侧显示装箱容器选择按钮；
  bool isSingleBoxQtyOnlyChangedByContainer = AppConfig.isSingleBoxQtyOnlyChangedByContainer;

  ///是否有“皮重”填写项
  bool get isHavePackingWeightReport => false;

  ///是否有“单箱数量”填写项
  bool get isHaveSingleBoxQtyReport => saveType == AppConfig.qtyBoxSubmit
      || saveType == AppConfig.palletSubmit
      || saveType == AppConfig.weightBoxSubmit;

  final WeightMsgConnectService _weightMsgConnectService = Get.find<WeightMsgConnectService>();
  ///称重监听列表
  @Deprecated('计划不再使用')
  late final List<WeightMsgConnectModel> connectList = _weightMsgConnectService.connectList.where(
          (element) => /*element.key == WeightMsgConnectService.dSEBWeight
          || element.key == WeightMsgConnectService.dSEBWeightForWeightSubmitType
          || element.key == WeightMsgConnectService.dSPackingWeight
          || */element.key == WeightMsgConnectService.dSSingleBoxWeight
          || element.key == WeightMsgConnectService.dSLastBoxWeight
          || element.key == WeightMsgConnectService.dSWeight).toList();



  //region Adapter

  ///获取装箱容器Adapter
  Future<void> _getContainerWithNoPageAdapter() async {
    containerWithNoPageAdapter = await AdapterHelper.getAsyncAdapter(
      'container',
      queryData: {'InvId': inventoryModel.invID},
    ) as MoContainerWithNoPageAdapter;
  }
  ///获取装箱容器Adapter
  Future<void> Function() get getContainerWithNoPageAdapter => _getContainerWithNoPageAdapter;


  Future<void> _geDefaultContainer() async {
    if (containerWithNoPageAdapter != null){
      containerWithNoPageAdapter!.clearSelection();
      if (containerWithNoPageAdapter!.dataList.length == 1){
        MoContainerModel item = containerWithNoPageAdapter!.dataList[0];
        await containerWithNoPageAdapter?.validModelValue(item.id);
        containerOnChanged(item);
      }
    }
  }
  Future<void> Function() get geDefaultContainer => _geDefaultContainer;

  //endregion



  //region OnChanged

  ///填报方式切换 需要重写
  void saveTypeOnChanged(ChoiceChipModel item) {
    saveType = item.keyName;
    numPadCTListSetEnabled();
  }


  ///装箱容器Adapter选择变化
  void containerOnChanged(PickerDataModel model) {
    MoContainerModel item = MoContainerModel.fromJson(model.toJson());
    if (isHavePackingWeightReport){
      NumPadUtil().setText(NumPadUtil.packingWeight, item.weight?.toString() ?? '', numPadCTList);
      calcQty(NumPadUtil.packingWeight);
    }
    if (isHaveSingleBoxQtyReport && (item.maxQty ?? 0) != 0){
      NumPadUtil().setText(NumPadUtil.singleBoxQty, item.maxQty?.toString() ?? '', numPadCTList);
      calcQty(NumPadUtil.singleBoxQty);
    }
    containerPackingDescription = item.description ?? '';
    update();
  }

  //endregion



  //region  NumPad SetEnabled + 计算

  ///设置数字输入框是否可修改
  void numPadCTListSetEnabled();

  ///数据填报后的计算
  void calcQty(String keyName);

  //endregion



  ///以系统对象中的表单数据填写项的数据校验为标准，更新[formJudgeTypeMap]
  void _setFormJudgeTypeMap({String groupName = '#form'}) {
    objectItem.queryList.forEach((element) {
      if (element.groupName == groupName && element.id != null
          && formJudgeTypeMap.containsKey(element.id)){
        formJudgeTypeMap[element.id!] = element.judgeType;
      }
    });
  }
  ///以系统对象中的表单数据填写项的数据校验为标准，更新[formJudgeTypeMap]
  void Function({String groupName}) get setFormJudgeTypeMap => _setFormJudgeTypeMap;



  ///以系统对象中的列视图的小数位长度为标准，更新[weightFormDecimalLengthMap]
  void _setWeightFormDecimalLengthMap({String groupName = '#gridPager'}) {
    Map<String, String> lowerKeyMap = {};
    weightFormDecimalLengthMap.forEach((key, value) {
      lowerKeyMap.addAll({key.toLowerCase(): key});
    });
    ///如果 == false 的话，[SingleBoxWeight]...使用 [Weight] 的 maxLength
    bool hasSingleBoxWeight = false;
    bool hasLastBoxWeight = false;
    objectItem.colModel.forEach((element) {
      if (element.groupName == groupName
          && element.name != null
          && lowerKeyMap.containsKey(element.name!.toLowerCase())
          && element.maxLength != null){
        if (element.name!.toLowerCase() == NumPadUtil.singleBoxWeight.toLowerCase()){
          hasSingleBoxWeight = true;
        }
        else if (element.name!.toLowerCase() == NumPadUtil.lastBoxWeight.toLowerCase()){
          hasLastBoxWeight = true;
        }
        weightFormDecimalLengthMap[lowerKeyMap[element.name!.toLowerCase()]!] = element.maxLength!;
      }
    });
    if (!hasSingleBoxWeight){
      weightFormDecimalLengthMap[NumPadUtil.singleBoxWeight] = weightFormDecimalLengthMap[NumPadUtil.weight]!;
    }
    if (!hasLastBoxWeight){
      weightFormDecimalLengthMap[NumPadUtil.lastBoxWeight] = weightFormDecimalLengthMap[NumPadUtil.weight]!;
    }
  }
  ///以系统对象中的列视图的小数位长度为标准，更新[weightFormDecimalLengthMap]
  void Function({String groupName}) get setWeightFormDecimalLengthMap => _setWeightFormDecimalLengthMap;



  ///历史皮重数据赋值
  ///
  /// [theLastContainerSelectedValue]：上一次选中的装箱容器 ID
  ///
  /// [theLastPackingWeightValue]：上一次填写的皮重数据
  ///
  /// [theLastSingleBoxQtyValue]：上一次填写的单箱数量数据
  Future<void> _setTheLastPackingWeightData({
    required String? theLastContainerSelectedValue,
    required double? theLastPackingWeightValue,
    required double? theLastSingleBoxQtyValue,
  }) async {
    if (isUsePackingPicker){
      if (theLastContainerSelectedValue != null){
        await containerWithNoPageAdapter?.validModelValue(theLastContainerSelectedValue);
        MoContainerModel? item = containerWithNoPageAdapter?.dataList.firstWhereOrNull((element) => element.isSelected);
        if (item != null){
          containerOnChanged(item);
        }
      }
    }
    else {
      if (isHavePackingWeightReport) {
        if (theLastPackingWeightValue != null){
          NumPadUtil().setText(NumPadUtil.packingWeight, theLastPackingWeightValue.toString(), numPadCTList);
          calcQty(NumPadUtil.packingWeight);
        }
      }
      if (isHaveSingleBoxQtyReport){
        if (theLastSingleBoxQtyValue != null){
          NumPadUtil().setText(NumPadUtil.singleBoxQty, theLastSingleBoxQtyValue.toInt().toString(), numPadCTList);
          calcQty(NumPadUtil.singleBoxQty);
        }
      }
    }
  }
  ///历史皮重数据赋值
  ///
  /// [theLastContainerSelectedValue]：上一次选中的装箱容器 ID
  ///
  /// [theLastPackingWeightValue]：上一次填写的皮重数据
  ///
  /// [theLastSingleBoxQtyValue]：上一次填写的单箱数量数据
  Future<void> Function({
    required String? theLastContainerSelectedValue,
    required double? theLastPackingWeightValue,
    required double? theLastSingleBoxQtyValue,
  }) get setTheLastPackingWeightData => _setTheLastPackingWeightData;



  ///填报数据赋值（第一次进入填报页面时 OR 产品改变时）
  Future<void> _setSaveDataAndAdapter({
    required bool isInit,
    int? progId,
  }) async {
    assert((isInit && progId != null) || (!isInit));
    barcodeEntity.invID = inventoryModel.invID;
    barcodeEntity.invCode = inventoryModel.invCode;
    barcodeEntity.invName = inventoryModel.invName;
    barcodeEntity.invStd = inventoryModel.invStd;
    //todo barcodeEntity.free
    barcodeEntity.billCode = inventoryModel.invCode;
    if ((inventoryModel.packingQty ?? 0) > 0
        && double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') != inventoryModel.packingQty){
      NumPadUtil().setText(NumPadUtil.singleBoxQty, (inventoryModel.packingQty ?? 0).toStringAsFixed(0), numPadCTList);
      calcQty(NumPadUtil.singleBoxQty);
    }
    if (isInit){
      barcodeEntity.progid = progId;
      if (isUsePackingPicker){
        getContainerWithNoPageAdapter().then((value) async {
          await geDefaultContainer();
          update();
        });
      }
    }
    else {
      if (isUsePackingPicker){
        NumPadUtil().setText(NumPadUtil.packingWeight, '', numPadCTList);
        calcQty(NumPadUtil.packingWeight);
        await getContainerWithNoPageAdapter();
        await geDefaultContainer();
      }
    }
  }
  ///填报数据赋值（第一次进入填报页面时 OR 产品改变时）
  Future<void> Function({
    required bool isInit,
    int? progId,
  }) get setSaveDataAndAdapter => _setSaveDataAndAdapter;



  ///保存物料条码
  Future<void> saveInvBarcode(bool isPrint);



  ///物料条码提交前检查（通用的，之后还需要检查一遍[cannotSubmitWhenNotInProduction]）
  /// [True]：通过； [False]：不通过
  ///
  /// [button]：提交按钮的权限名称，默认：btnadd
  Map<bool, String> _saveInvBarcodeCheck({
    required bool isPrint,
    String button = 'btnadd',
  }){
    //region 权限权限
    if (_dataService.isEnableOperatePrivilege && objectItem.buttons?[button] == null){
      return {false: '没有操作的权限${BaseService.profile.isSystem == true ? '【${objectItem.progid}】【${button}】' : ''}！'};
    }
    //endregion
    if ((barcodeEntity.invID ?? '').isEmpty){
      return {false: '产品数据错误！'};
    }
    //region [numPadCTList] 填写项检查
    String eBWeightString = NumPadUtil().getText(NumPadUtil.eBWeight, numPadCTList) ?? '';
    double? eBWeight = double.tryParse(eBWeightString);
    if (FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.eBWeight}'])
        && (eBWeight == null || eBWeight <= 0)){
      return {false: '称重重量输入有误，请重输！'};
    }
    String eBPieceString = NumPadUtil().getText(NumPadUtil.eBPiece, numPadCTList) ?? '';
    int? eBPiece = int.tryParse(eBPieceString);
    if (FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.eBPiece}'])
        && (eBPiece == null || eBPiece < 1)){
      return {false: '称重件数输入有误，请重输！'};
    }

    String pieceWeightString = NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '';
    double? pieceWeight = double.tryParse(pieceWeightString);
    if (FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.pieceWeight}'])
        && (pieceWeight == null || pieceWeight <= 0)){
      return {false: '实际单重输入有误，请重输！'};
    }

    String packingWeightString = NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '';
    double? packingWeight = double.tryParse(packingWeightString);
    if (packingWeightString.isNotEmpty
        && (packingWeight == null || packingWeight < 0)){
      String warnMsg = '';
      if (isUsePackingPicker){
        warnMsg = '当前选择的装箱容器的重量不正确，请检查！';
      }
      else {
        warnMsg = '单箱皮重不正确，请重输！';
      }
      return {false: warnMsg};
    }

    String _numString = NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '';
    int? _num = int.tryParse(_numString);
    ///多箱填报的时候，如果整箱箱数没有输入，就默认为 1 箱
    if ((saveType == AppConfig.qtyBoxSubmit || saveType == AppConfig.weightBoxSubmit || saveType == AppConfig.mesWeightBoxSubmit)
        && _numString.isNotEmpty
        && (_num == null || _num < 1)){
      return {false: '整箱箱数输入有误，请重输！'};
    }
    else if ((saveType == AppConfig.qtyBoxSubmit || saveType == AppConfig.weightBoxSubmit || saveType == AppConfig.mesWeightBoxSubmit)
        && _numString.isEmpty){
      _num = 1;
    }
    if ((saveType == AppConfig.qtyBoxSubmit || saveType == AppConfig.weightBoxSubmit || saveType == AppConfig.mesWeightBoxSubmit)
        && numMaxCountLimit != null && _num! > numMaxCountLimit!){
      return {false: '整箱箱数大于设置的上限值（$numMaxCountLimit），请重输！'};
    }

    String singleBoxQtyString = NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '';
    int? singleBoxQty = int.tryParse(singleBoxQtyString);
    if ((saveType == AppConfig.qtyBoxSubmit || saveType == AppConfig.palletSubmit)
        && (singleBoxQty == null || singleBoxQty < 1)){
      return {false: '单箱数量输入有误，请重输！'};
    }
    if ((saveType == AppConfig.qtyBoxSubmit || saveType == AppConfig.palletSubmit)
        && singleBoxQtyMaxCountLimit != null && singleBoxQty! < singleBoxQtyMaxCountLimit!){
      return {false: '单箱数量小于设置的下限值（$singleBoxQtyMaxCountLimit），请重输！'};
    }

    ///尾箱件数可以为空但是不能有特殊字符，不能大于单箱件数
    String lastBoxQtyString = NumPadUtil().getText(NumPadUtil.lastBoxQty, numPadCTList) ?? '';
    int? lastBoxQty = int.tryParse(lastBoxQtyString);
    if ((saveType == AppConfig.qtyBoxSubmit || saveType == AppConfig.palletSubmit)
        && lastBoxQtyString.isNotEmpty
        && (lastBoxQty == null || lastBoxQty < 0)){
      return {false: '尾箱数量输入有误，请重输！'};
    }
    if ((saveType == AppConfig.qtyBoxSubmit || saveType == AppConfig.palletSubmit)
        && lastBoxQtyString.isNotEmpty
        && lastBoxQty! >= singleBoxQty!){
      return {false: '尾箱数量不能大于等于单箱数量，请重输！'};
    }

    ///单托箱数可以为空但是不能有特殊字符（一箱都没有装满的情况）
    String boxNumOfPalletString = NumPadUtil().getText(NumPadUtil.boxNumOfPallet, numPadCTList) ?? '';
    int? boxNumOfPallet = int.tryParse(boxNumOfPalletString);
    if (saveType == AppConfig.palletSubmit
        && boxNumOfPalletString.isNotEmpty
        && (boxNumOfPallet == null || boxNumOfPallet < 1)){
      return {false: '单托箱数输入有误，请重输！'};
    }

    String singleBoxWeightString = NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '';
    double? singleBoxWeight = double.tryParse(singleBoxWeightString);
    if ((saveType == AppConfig.weightBoxSubmit || saveType == AppConfig.mesWeightBoxSubmit)
        && (singleBoxWeight == null || singleBoxWeight <= 0)){
      return {false: '单箱重量输入有误，请重输！'};
    }
    if ((saveType == AppConfig.weightBoxSubmit || saveType == AppConfig.mesWeightBoxSubmit)
        && FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.pieceWeight}'])
        && singleBoxWeight! < (pieceWeight! / 1000)){
      return {false: '单箱重量不能小于实际单重，请重输！'};
    }
    if ((saveType == AppConfig.weightBoxSubmit || saveType == AppConfig.mesWeightBoxSubmit)
        && packingWeightString.isNotEmpty
        && singleBoxWeight! <= packingWeight!){
      return {false: '单箱重量不能小于等于皮重，请重输！'};
    }

    String lastBoxWeightString = NumPadUtil().getText(NumPadUtil.lastBoxWeight, numPadCTList) ?? '';
    double? lastBoxWeight = double.tryParse(lastBoxWeightString);
    if ((saveType == AppConfig.weightBoxSubmit || saveType == AppConfig.mesWeightBoxSubmit)
        && lastBoxWeightString.isNotEmpty
        && (lastBoxWeight == null || lastBoxWeight < 0)){
      return {false: '尾箱重量不正确，请重输！'};
    }
    if ((saveType == AppConfig.weightBoxSubmit || saveType == AppConfig.mesWeightBoxSubmit)
        && lastBoxWeightString.isNotEmpty
        && lastBoxWeight! >= singleBoxWeight!){
      return {false: '尾箱重量不能大于等于单箱重量，请重输！'};
    }
    if ((saveType == AppConfig.weightBoxSubmit || saveType == AppConfig.mesWeightBoxSubmit)
        && FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.pieceWeight}'])
        && lastBoxWeightString.isNotEmpty
        && lastBoxWeight! < (pieceWeight! / 1000)){
      return {false: '尾箱重量不能小于单重，请重输！'};
    }
    if ((saveType == AppConfig.weightBoxSubmit || saveType == AppConfig.mesWeightBoxSubmit)
        && packingWeightString.isNotEmpty
        && lastBoxWeightString.isNotEmpty
        && lastBoxWeight! <= packingWeight!){
      return {false: '尾箱重量不能小于等于皮重，请重输！'};
    }

    String qtyString = NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '';
    int? qty = int.tryParse(qtyString);
    if ((FormUtil.isRequired(formJudgeTypeMap['Qty']) && qty == null)
        || (FormUtil.isCannotBeNegativeNum(formJudgeTypeMap['Qty']) && qty! <= 0)
        || (FormUtil.isInteger(formJudgeTypeMap['Qty']) && qty != qty!.toInt())
        || (FormUtil.isCannotBeZero(formJudgeTypeMap['Qty']) && qty == 0)){
      return {false: '总数量输入有误，请重输！'};
    }

    String _weightString = NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '';
    double? _weight = double.tryParse(_weightString);
    if ((saveType == AppConfig.weightSubmit || saveType == AppConfig.weightBoxSubmit
        || saveType == AppConfig.mesWeightSubmit || saveType == AppConfig.mesWeightBoxSubmit)
        && (_weight == null || _weight <= 0)){
      return {false: '总重输入有误，请重输！'};
    }

    String boxWeightString = NumPadUtil().getText(NumPadUtil.boxWeight, numPadCTList) ?? '';
    double? boxWeight = double.tryParse(boxWeightString);
    if (saveType == AppConfig.palletSubmit
        && boxWeightString.isNotEmpty && (boxWeight == null || boxWeight < 0)){
      return {false: '箱重输入有误，请重输！'};
    }
    //endregion
    if (isPrint){
      String frxName = invClassFrxNameMap[inventoryModel.invCCode ?? ''] ?? this.frxName;
      if (frxName.isEmpty){
        return {false: '打印的模板名称为空，请在设置中修改！'};
      }
    }
    return {true: ''};
  }
  ///物料条码提交前检查（通用的，之后还需要检查一遍[cannotSubmitWhenNotInProduction]）
  /// [True]：通过； [False]：不通过
  ///
  /// [button]：提交按钮的权限名称，默认：btnadd
  Map<bool, String> Function({
    required bool isPrint,
    String button,
  }) get saveInvBarcodeCheck => _saveInvBarcodeCheck;



  ///物料条码提交时赋值
  void _setInvBarcodeDataBeforeSave() {
    //region
    double? eBWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.eBWeight, numPadCTList) ?? '');
    double? eBPiece = double.tryParse(NumPadUtil().getText(NumPadUtil.eBPiece, numPadCTList) ?? '');
    double? pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '');
    double? packingWeight = isHavePackingWeightReport
        ? double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '')
        : 0;
    double? num = double.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '') ?? 1; ///多箱填报的时候，如果整箱箱数没有输入，就默认为 1 箱
    double? singleBoxQty = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '');
    double? lastBoxQty = double.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxQty, numPadCTList) ?? '');
    double? boxNumOfPallet = double.tryParse(NumPadUtil().getText(NumPadUtil.boxNumOfPallet, numPadCTList) ?? '');
    double? singleBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '');
    double? lastBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxWeight, numPadCTList) ?? '');
    double? qty = double.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '');
    double? weight = double.tryParse(NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '');
    double? boxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.boxWeight, numPadCTList) ?? '');
    //endregion
    //region
    ///皮重
    double? packingWeightSave;
    ///箱数：整箱箱数 + 1(如果有尾箱) OR 按托填报时：代表每托箱数，一托里面装多少小箱
    double? numSave;
    ///总数量
    double? qtySave;
    ///实际单重
    double? pieceWeightSave;
    ///总重量
    double? weightSave;
    ///单箱件数，一个箱子装多少件产品 OR 单托件数，代表一托装多少个产品
    double? boxQtySave;
    ///箱重（按托填报时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重） (kg)
    double? boxWeightSave;
    if (FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.pieceWeight}'])){
      pieceWeightSave = pieceWeight;
    }
    packingWeightSave = packingWeight;
    if (saveType == AppConfig.qtySubmit){
      boxQtySave = qty;
      numSave = 1;
      qtySave = qty;
      weightSave = weight;
    }
    else if (saveType == AppConfig.qtyBoxSubmit){
      boxQtySave = singleBoxQty;
      numSave = num + (lastBoxQty != null ? 1 : 0);
      qtySave = qty;
      weightSave = weight;
    }
    else if (saveType == AppConfig.palletSubmit){
      boxQtySave = qty;
      numSave = (boxNumOfPallet ?? 0) + (lastBoxQty != null ? 1 : 0);
      qtySave = qty;
      boxWeightSave = boxWeight;
      weightSave = weight;
    }
    else if (saveType == AppConfig.weightSubmit){
      boxQtySave = qty;
      numSave = 1;
      qtySave = (qty ?? 0) + (weightIsAddPieceWeightToTotal ? (eBPiece ?? 0) : 0);
      weightSave = (weight ?? 0) + (weightIsAddPieceWeightToTotal ? (eBWeight ?? 0) : 0) / 1000;
    }
    else if (saveType == AppConfig.weightBoxSubmit){
      ///单箱重量（不含皮重）
      double _singleBoxWeightWithNoPacking = singleBoxWeight! - (packingWeight ?? 0);
      ///单重
      double _pieceWeight = (FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.pieceWeight}'])
          ? pieceWeight
          : inventoryModel.invWeight) ?? 0;
      double? boxQty = pieceWeight == 0
          ? null
          : (_singleBoxWeightWithNoPacking * 1000 / _pieceWeight).ceilToDouble();
      boxQty = boxQty != null && boxQty < 0 ? null : boxQty;
      boxQtySave = boxQty;
      numSave = num + (lastBoxWeight != null ? 1 : 0);
      qtySave = qty;
      weightSave = weight;
    }
    //endregion
    barcodeEntity.memo = numSave?.toString(); //箱数：整箱箱数 + 1(如果有尾箱) OR 按托填报时：代表每托箱数，一托里面装多少小箱
    barcodeEntity.quantity = qtySave ?? 0;
    barcodeEntity.pieceWeight = pieceWeightSave;
    barcodeEntity.weight = weightSave ?? 0;
    barcodeEntity.boxQuantity = boxQtySave ?? 0; //单箱件数，一个箱子装多少件产品 OR 单托件数，代表一托装多少个产品
    barcodeEntity.singleBoxWeight = (pieceWeightSave ?? 0) * (boxQtySave ?? 0); //单箱净重
    barcodeEntity.piece = qtySave ?? 0; //总件数
    if (saveType == AppConfig.palletSubmit){
      barcodeEntity.prnCount = 1; //打印的条码总数
    }
    else {
      barcodeEntity.prnCount = (numSave ?? 0).toInt(); //打印的条码总数
    }
    barcodeEntity.productDate = DateTime.now();
  }
  ///物料条码提交时赋值
  void Function() get setInvBarcodeDataBeforeSave => _setInvBarcodeDataBeforeSave;



  ///物料条码提交成功后，刷新填报区域的数据
  Future<void> _resetInvBarcodeDataAfterSave() async {
    barcodeEntity.memo = null;
    barcodeEntity.quantity = null;
    barcodeEntity.pieceWeight = null;
    barcodeEntity.weight = null;
    barcodeEntity.boxQuantity = null;
    barcodeEntity.singleBoxWeight = null;
    barcodeEntity.piece = null;
    barcodeEntity.prnCount = null;
    barcodeEntity.productDate = null;
    numPadCTList.forEach((element) {
      element.controller.clear();
    });
    containerWithNoPageAdapter?.clearSelection();
  }
  ///物料条码提交成功后，刷新填报区域的数据
  Future<void> Function() get resetInvBarcodeDataAfterSave => _resetInvBarcodeDataAfterSave;



  //region Widget

  ///报工方式选择控件
  Widget operationWayWidget(BuildContext context){
    return MenuBar(
      children: [
        SubmenuButton(
          menuChildren: operationWayList.map((e) {
            return MenuItemButton(
              onPressed: () {
                saveTypeOnChanged(e);
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 18, left: 12, right: 44),
                child: Text(
                  e.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }).toList(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 4,),
              Text(
                operationWay?.title ?? '（请选择填报方式）',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: operationWay?.title == null
                      ? AppColors.errorColor
                      : null,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              Icon(
                Icons.arrow_drop_down,
                size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///填单区域（包括数字键盘、提交按钮）
  Widget submitAreaWidget(BuildContext context){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: dataReportAreaWidget(context),
        ),
        const SizedBox(width: 4,),
        SizedBox(
          width: 300,
          child: Column(
            children: [
              numPadAreaWidget(context),
              const Expanded(child: SizedBox.shrink()),
              ...submitBtnWidget(context),
            ],
          ),
        )
      ],
    );
  }

  ///报工填单区域
  Widget dataReportAreaWidget(BuildContext context);

  //region dataReportItem

  Widget reportItem(BuildContext context, {
    required String title,
    required Widget customizeContent,
    bool needMargin = true,
    double width = 580,
    double titleWidth = 100,
    String titleTip = '',
  }) {
    return TitleTextBoxWidget(
      title: title,
      customizeContent: customizeContent,
      titleWidth: titleWidth,
      width: width,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
      margin: needMargin ? const EdgeInsets.only(bottom: 6) : null,
      titleTip: titleTip,
    );
  }

  Widget singleBoxQtyReportItem(BuildContext context){
    !isUsePackingPicker; ///填写框
    isUsePackingPicker && isSingleBoxQtyOnlyChangedByContainer && isHavePackingWeightReport; ///填写框，只读
    isUsePackingPicker && isSingleBoxQtyOnlyChangedByContainer && !isHavePackingWeightReport; ///显示装箱容器选择器
    isUsePackingPicker && !isSingleBoxQtyOnlyChangedByContainer && isHavePackingWeightReport; ///填写框
    isUsePackingPicker && !isSingleBoxQtyOnlyChangedByContainer && !isHavePackingWeightReport; ///填写框，左侧显示装箱容器选择按钮
    return reportItem(
      context,
      title: formTitleMap[NumPadUtil.singleBoxQty]!,
      titleTip: containerPackingDescription,
      customizeContent: isUsePackingPicker && isSingleBoxQtyOnlyChangedByContainer && !isHavePackingWeightReport ?
      PickerInputWidget(
        adapter: containerWithNoPageAdapter,
        pickerChoiceType: PickerChoiceType.chip,
        onTap: (List<PickerDataModel> selectList) {
          if (selectList.isNotEmpty){
            containerOnChanged(selectList[0]);
          }
          else {
            containerOnChanged(PickerDataModel());
          }
        },
        customContent: (PickerDataModel item) {
          item as MoContainerModel;
          return '${item.name} ${item.maxQty?.toString() ?? ''}';
        },
      ) :
      NumPadTextField(
        numPadController: NumPadUtil().getNumPadController(NumPadUtil.singleBoxQty, numPadCTList)!,
        onChanged: (String str){
          calcQty(NumPadUtil.singleBoxQty);
        },
        prefixIcon: isUsePackingPicker && !isSingleBoxQtyOnlyChangedByContainer && !isHavePackingWeightReport ?
        PickerButtonWidget(
          adapter: containerWithNoPageAdapter,
          pickerChoiceType: PickerChoiceType.chip,
          isNeedLoadStr: false,
          pickerButtonType: PickerButtonType.text,
          onTap: (List<PickerDataModel> selectList) {
            if (selectList.isNotEmpty){
              containerOnChanged(selectList[0]);
            }
            else {
              containerOnChanged(PickerDataModel());
            }
          },
          buttonStyle: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
              vertical: 24,
            )),
          ),
          child: Icon(
            Icons.library_books,
            size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
            color: IconTheme.of(context).color,
          ),
        ) :
        null,
      ),
    );
  }

  Widget numPadReportItem(BuildContext context, String numPadKey){
    String hintText = '';
    String measurement = '';
    if (numPadKey == NumPadUtil.packingWeight
        || numPadKey == NumPadUtil.lastBoxQty
        || numPadKey == NumPadUtil.lastBoxWeight){
      hintText = '选填';
    }
    else if (numPadKey == NumPadUtil.num){
      hintText = '选填（不填写时，默认一箱）';
    }

    if (numPadKey == NumPadUtil.weight
        && saveType == AppConfig.weightSubmit
        && weightIsAddPieceWeightToTotal){
      measurement = '+${NumPadUtil().getText(NumPadUtil.eBWeight, numPadCTList) ?? '0'}g  (kg)';
    }
    else if (numPadKey == NumPadUtil.packingWeight
        || numPadKey == NumPadUtil.singleBoxWeight
        || numPadKey == NumPadUtil.lastBoxWeight
        || numPadKey == NumPadUtil.weight
        || numPadKey == NumPadUtil.boxWeight){
      measurement = '(kg)';
    }
    else if (numPadKey == NumPadUtil.eBWeight || numPadKey == NumPadUtil.pieceWeight){
      measurement = '(g)';
    }
    return reportItem(
      context,
      title: formTitleMap[numPadKey]!,
      customizeContent: NumPadTextField(
        numPadController: NumPadUtil().getNumPadController(numPadKey, numPadCTList)!,
        hintText: hintText,
        measurement: measurement,
        onChanged: (String str){
          calcQty(numPadKey);
        },
      ),
    );
  }

  //endregion

  Widget numPadAreaWidget(BuildContext context){
    if (saveType != AppConfig.serialNumberSubmit){
      return NumPad(
        width: 300, height: 300,
        nPCList: numPadCTList,
        defaultNumPadKey: numPadFocusField,
        onPressed: (String val, String keyName, String text){
          calcQty(keyName);
        },
      );
    }
    else {
      return Container(
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return ScrollbarTheme(
                  data: ScrollbarThemeData(
                    interactive: false,
                    thumbVisibility: WidgetStateProperty.all(false),
                    trackVisibility: WidgetStateProperty.all(false),
                    thumbColor: WidgetStateProperty.all(Colors.transparent),
                    trackColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: submitInfoWidget(context, constraints),
                    ),
                  )
              );
            }
        ),
      );
    }
  }

  List<Widget> submitInfoWidget(BuildContext context, BoxConstraints constraints){
    return [];
  }

  ///提交按钮组
  List<Widget> submitBtnWidget(BuildContext context){
    List<Widget> widgetList = [];
    AppConfig.submitBtnList.forEach((element) {
      if (invBarcodeSaveBtnIndex & element.sign == element.sign){
        widgetList.addAll([
          const SizedBox(height: 8,),
          FilledButton(
            onPressed: () async{
              if (element.sign == 1){
                await saveInvBarcode(false);
              }
              else if (element.sign == 2){
                await saveInvBarcode(true);
              }
            },
            style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.only()),
              minimumSize: WidgetStateProperty.all(
                  kIsWeb || GetPlatform.isWindows
                      ? const Size(310, 72)
                      : const Size(310, 60)
              ),
              backgroundColor: element.sign == 2 ? WidgetStateProperty.all(
                  Theme.of(context).colorScheme.secondary
              ) : null,
            ),
            child: Text(
              element.title,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              ),
            ),
          ),
        ]);
      }
    });
    return widgetList;
  }

  ///按多箱报工时，是否显示称重消息传递过来的单箱重量、预计单箱数量
  Widget expectSingleBoxQtyWidget(BuildContext context){
    return RichText(
      text: TextSpan(
        text: '单箱重量：',
        style: Theme.of(context).textTheme.bodyLarge,
        children: [
          TextSpan(
              text: '${singleBoxWeightForExpect == null ? '' : singleBoxWeightForExpect!.toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.singleBoxWeight]!)}',
              style: TextStyle(
                color: AppColors.errorColor,
                fontWeight: FontWeight.w600,
              )
          ),
          TextSpan(text: 'kg\u00A0\u00A0\u00A0\u00A0'),
          TextSpan(text: '预计单箱数量：${singleBoxQtyForExpect == null ? '' : singleBoxQtyForExpect!.toString()}'),
        ],
      ),
      maxLines: 1, overflow: TextOverflow.ellipsis,
    );
  }

  //endregion

}