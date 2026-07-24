
import 'package:basement/basement.dart';
import 'package:basement/item_model.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/pickers/picker_view/picker.dart';
import 'package:desktop/app/service/data_service.dart';
import 'package:desktop/app/theme/app_colors.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_print_barcode_interface.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/input_widget.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_button_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/prefix_text_field.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/form_util.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';


///报工接口
mixin SubmitInterface on SubmitPrintBarcodeInterface {

  final _dataService = Get.find<DataService>();

  ///获取的系统对象相关属性；
  ///
  /// 基类中重写
  EditFormItem objectItem = EditFormItem();

  final Map<String, AttributeEntity?> accInformationMap = {};

  ///当前报工单对应产品的产品档案
  ///
  /// 用来获取产品标准单重、标准装箱数==[taskModel.packingQty]、产品助记码……
  InventoryModel inventoryModel = InventoryModel();

  ///页面上显示报工提交按钮（可显示多个，index 相加）
  ///
  ///1：报工提交
  ///
  ///2：提交并打印
  int submitBtnIndex = AppConfig.submitBtnIndex;

  ///是否显示“需要检验”按钮
  bool isShowInspectFlagBtn = AppConfig.isShowInspectFlagBtn;
  ///是否可以点击修改“需要检验”按钮的值
  ///
  /// 不可以点击时：需要检验时，显示文本，反之，不显示任何内容
  bool isCanClickInspectFlagBtn = AppConfig.isShowInspectFlagBtn;
  ///“需要检验”按钮的选中状态的默认值
  ///
  /// [Null]：该默认值不起作用，取派工单/工序的值；[True]：默认强制选中；[False]：默认强制不选中；
  bool? inspectFlagDefaultValue = AppConfig.inspectFlagDefaultValue;

  ///未在生产中的单据不允许报工（报工的单据必须要在生产中）
  bool get cannotSubmitWhenNotInProduction => objectItem.attributeList.firstWhereOrNull(
          (element) => element.attribute == 'system' && element.code == 'inProductionSubmit')?.text == '1';

  ///未首检合格不允许报工（首检合格后才可以报工）
  ///
  ///[False]，则显示“首检单提示信息”
  bool get cannotSubmitWhenNotPassFirstInspection => objectItem.attributeList.firstWhereOrNull(
          (element) => element.attribute == 'system' && element.code == 'firstInspectionSubmit')?.text == '1';
  ///是否已生成首检报检单
  bool isHaveFirstInspection = false;
  ///首检检验单是否已合格
  ///
  ///[Null]：没有生成检验单，未进行首检检验
  bool? isFirstInspectionPassed;

  ///是否显示“补打”按钮（当报工日期受班次影响时，始终不显示该按钮）
  bool isShowMakeUpBtn = AppConfig.isShowMakeUpBtn;
  ///是否为补打单
  bool isMakeUp = false;

  ///是否显示“自检确认”按钮
  bool isShowSelfInspectionBtn = AppConfig.isShowSelfInspectionBtn;
  ///是否显示“互检确认”按钮
  bool isShowMutualInspectionBtn = AppConfig.isShowMutualInspectionBtn;

  ///报工记录提交成功后，是否返回到首页
  bool isGetBackAfterCommitSuccess = AppConfig.isGetBackAfterCommitSuccess;

  ///是否显示报工方式切换按钮
  bool isShowDataReportTypeBtn = AppConfig.isShowDataReportTypeBtn;
  ///报工方式
  String _submitType = AppConfig.qtySubmit;
  ///报工方式
  String get submitType => _submitType;
  ///报工方式
  set submitType(String str){
    _submitType = str;
    _operationWay = operationWayList.firstWhereOrNull((element) => element.keyName == _submitType);
  }
  ///报工方式
  ChoiceChipModel? _operationWay;
  ///报工方式
  ChoiceChipModel? get operationWay => _operationWay;
  ///报工方式列表
  List<ChoiceChipModel> get operationWayList => List.unmodifiable([]);

  ///报工完成后是否需要生成生成入库单
  bool get isNeedCreateStock => objectItem.attributeList.firstWhereOrNull(
          (element) => element.attribute == 'system' && element.code == 'createStock')?.text == '1';

  ///当报工方式是“按托报工”时，报工数据的计算方式
  ///
  ///0：填写“单箱数量”时，计算“单托箱数”、“尾箱数量”
  ///
  ///1：填写“单箱数量”时，计算“报工总数量”
  int calcRuleForPalletSubmitType = AppConfig.calcRuleForPalletSubmitType;

  ///表单数据填写项的数据校验
  final Map<String, int?> formJudgeTypeMap = {};
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

  ///报工数据
  final MoOpSubmitModel submitModel = MoOpSubmitModel();
  DepartmentAdapter? depAdapter;
  TeamAdapter? teamAdapter;
  PersonAdapter? personAdapter;
  MoWorkCenterWithNoPageAdapter? workCenterAdapter;
  MoBeltLineWithNoPageAdapter? lineAdapter;
  MoBeltLineWithNoPageAdapter? teamGroupAdapter;
  final List<PersonModel> personList = [];
  MoContainerWithNoPageAdapter? containerWithNoPageAdapter;
  ///SN码（产品序列号）选择器
  MoOrderSNAdapter? orderSNAdapter;
  ///工艺工序选单
  ProcessAdapter? processAdapter;

  ///数据填报表单输入时启用时间防抖
  final Debounce numPadDebounce = Debounce(const Duration(milliseconds: 500));
  ///表单数据（数字型）填写项列表
  final List<NumPadController> numPadCTList = [];

  ///自动获取焦点的输入框字段名
  String numPadFocusField = AppConfig.numPadFocusField;

  ///单列可显示的表单填写项的行数
  int? formRowMaxCountLimit = AppConfig.formRowMaxCountLimit;

  ///车间默认值获取方式 0: 单据车间  1: 登录账号所在车间
  int depGetWayIndex = AppConfig.depGetWayIndex;

  ///报工日期是否受班次影响（夜班班次时，要取昨日日期）
  bool get isBillDateChangedByNightTeam => objectItem.attributeList.firstWhereOrNull(
          (element) => element.attribute == 'system' && element.code == 'nightTeamBillDate')?.text == '1';
  ///实际的报工日期，区别于[submitModel.billDate]
  ///
  ///默认为当前时间，“补打”按钮点击后，可以根据选中的时间变化
  ///
  /// [submitModel.billDate]：可能会受到班次影响，夜班班次时，[submitModel.billDate]要取[billDate]的“昨日日期”
  DateTime billDate = DateTime.now();
  ///根据当前填写的报工数据，[submitModel.billDate]是否要取昨日日期
  bool isSubmitBillDateTakeFromYesterday = false;

  ///产线数据的填报类型：0产线 OR 1加工中心 OR 2生产班组
  ///
  ///（选2班组，不需要选员工； 选0产线，不需要选择设备）
  int wcDataReportType = AppConfig.wcDataReportType;

  ///人员是否可以通过 Adapter 选单
  bool isPsnHasAdapter = AppConfig.isPsnHasAdapter;
  ///生产人员是否可以多选
  bool isPsnMulti = AppConfig.isPsnMulti;
  ///生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间  3: 选中的产线  4: 固定产线
  int psnGetWayIndex = AppConfig.psnGetWayIndex;
  ///生产人员获取条件是固定车间时，固定车间的值
  String psnDepCode = AppConfig.psnDepCode;
  ///生产人员获取条件是固定产线时，固定产线的值
  String psnLineCode = AppConfig.psnLineCode;

  ///整箱箱数可以填写的上限
  int? numMaxCountLimit = AppConfig.numMaxCountLimit;

  ///单箱数量可以填写的下限
  double? singleBoxQtyMaxCountLimit = AppConfig.singleBoxQtyMaxCountLimit;

  ///是否自动写入实际单重数据
  bool isAutoWritePieceWeight = AppConfig.isAutoWritePieceWeight;

  ///按重量报工时，产品称重的数据是否加到报工总数据上
  bool weightIsAddPieceWeightToTotal = AppConfig.weightIsAddPieceWeightToTotal;

  ///按多箱报工时，是否显示称重消息传递过来的单箱重量、预计单箱数量
  bool isShowExpectSingleBoxQty = AppConfig.isShowExpectSingleBoxQty;
  ///保存了：按多箱报工时，称重消息传递过来的单箱重量
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
  ///保存了：按多箱报工时，预计单箱数量
  int? singleBoxQtyForExpect;
  ///不允许在预计单箱数量和实际单箱数量不一致的情况下报工（按多箱报工时，如果需要计算预计单箱数量，且预计单箱数量和实际单箱数量不一致时，是否允许报工）
  ///
  /// =0 允许（默认），=1 不允许，=2 报工时弹出提示框
  int get cannotSubmitWhenSingleBoxQtyDifferent => int.tryParse(objectItem.attributeList.firstWhereOrNull(
          (element) => element.attribute == 'system' && element.code == 'boxQty.submit')?.text ?? '') ?? 0;
  ///预计单箱数量和实际单箱数量可允许的误差百分比
  double get singleBoxQtyDifferentSubmitPercent => double.tryParse(objectItem.attributeList.firstWhereOrNull(
          (element) => element.attribute == 'system' && element.code == 'boxQty.percent')?.text ?? '') ?? 0;

  ///是否保存上次报工时选中的员工
  bool isSaveTheLastSelectedPsnId = AppConfig.isSaveTheLastSelectedPsnId;

  ///装箱说明（装箱容器）
  String containerPackingDescription = '';

  ///是否保存上次报工时填写的皮重、单箱数量数据（或选择的装箱容器数据）
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

  ///是否保存上一次填写的报工总数
  bool isSaveTheLastQtyData = AppConfig.isSaveTheLastQtyData;

  ///是否有“皮重”填写项
  bool get isHavePackingWeightReport => false;

  ///是否有“单箱数量”填写项
  bool get isHaveSingleBoxQtyReport => false;

  ///是否有“报工总数”填写项
  bool get isHaveQtyReport => true;

  ///序列号校验码
  List<String> get serialNumberCheckCodeList => [];

  ///必须符合全部条件（No：符合其中一个条件即可）
  bool get serialNumberIsAllConditionMustBeMet => AppConfig.isAllConditionMustBeMet;


  ///重量超额限制比例（标准单重与实际单重允许的偏差百分比）
  double get limitWeightDeviationValue => double.tryParse(accInformationMap['limit.weight']?.text?.toString() ?? '') ?? AppConfig.limitWeightDeviationValue;

  ///报工提交时是否弹出确认提示框
  bool get isShowSubmitConfirmationDialog => (objectItem.attributeList.firstWhereOrNull(
          (element) => element.attribute == 'system' && element.code == 'submit.dialog')?.text ?? '0') == '0';

  ///不允许在标准单重与实际单重偏差值超出指定量的情况下报工（在标准单重与实际单重偏差值超出指定量时，是否允许报工）
  ///
  /// =0 允许（默认），=1 不允许，=2 报工时弹出提示框
  int get cannotSubmitWhenLimitWeightError => int.tryParse(objectItem.attributeList.firstWhereOrNull(
          (element) => element.attribute == 'system' && element.code == 'submit.limitWeight')?.text ?? '2') ?? 0;

  ///标准单重与实际单重的偏差是否超过系统参数中设置的重量超额限制比例
  bool isWeightError = false;

  ///是否上架序列号
  ///如果 false 由服务器端参数去判断；
  ///true，则不需要在提交时判断序列号是否存在、是否报工。。。
  /// todo 先写死，后续加参数
  bool get isBMoSN => submitType == AppConfig.singleBoxSerialNumberSubmit;

  ///当报工方式是“按序列号报工”时，是否显示“自动提交”按钮
  bool isShowAutoCommitBtn = AppConfig.isShowAutoCommitBtn;
  ///当报工方式是“按序列号报工”时，扫描序列号并写入数据后，是否可以自动提交报工数据（按序列号报工时使用）
  bool autoCommitSubmit = AppConfig.autoCommitSubmit;
  ///当报工方式是“按单箱序列号报工”时，扫描序列号并写入数据后，是否自动提交报工数据（按单箱序列号报工时使用）
  bool get singleBoxSerialNumberSubmitAutoCommit {
    if (!autoCommitSubmit){
      return false;
    }
    String singleBoxQtyString = NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '';
    int? singleBoxQty = int.tryParse(singleBoxQtyString);
    String qtyString = NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '';
    int? qty = int.tryParse(qtyString);
    return singleBoxQty != null && singleBoxQty == qty;
  }
  ///自动提交是否成功
  ///
  /// 成功：需要绿色闪烁两秒；失败：红色闪烁两秒
  ///
  /// 两秒后赋值成 null
  bool? _isAutoCommitSuccess;
  ///自动提交是否成功
  ///
  /// 成功：需要绿色闪烁两秒；失败：红色闪烁两秒
  ///
  /// 两秒后赋值成 null
  bool? get isAutoCommitSuccess => _isAutoCommitSuccess;

  //region 生产序列号扫码信息
  ///通过扫码得到的产品序列号列表；
  ///key：产品序列号；
  ///
  ///value：是否成功写入到报工数据中
  ///
  ///200：成功；
  ///
  ///1：未通过检查，失败；
  ///
  ///2：获取服务器数据时出错，失败；
  ///
  ///3：查询不到该序列号，失败；
  ///
  ///4：该序列号未被分配到该任务单，失败；
  ///
  ///5：该序列号对应的工序已报工，失败；
  ///
  ///6： 不允许超上道报工，失败；
  ///
  ///7： 该序列号已失效（报废），失败；
  ///
  /// 8：该序列号与校验码不一致，失败
  final Map<String, int> serialNumberBarcodeMap = {};
  String get serialNumberBarcodeMsg {
    List<String> successList = [];
    List<String> failList = [];
    serialNumberBarcodeMap.forEach((key, value) {
      if (value == 200){
        successList.add(key);
      }
      else {
        failList.add(key);
      }
    });
    return '已扫${serialNumberBarcodeMap.length}条序列号条码，'
        '成功${successList.length}条，'
        '失败${failList.length}条！';
  }
  String get serialNumberBarcodeDetailMsg {
    List<String> successList = [];
    List<String> fail1List = [];
    List<String> fail2List = [];
    List<String> fail3List = [];
    List<String> fail4List = [];
    List<String> fail5List = [];
    List<String> fail6List = [];
    List<String> fail7List = [];
    List<String> fail8List = [];
    serialNumberBarcodeMap.forEach((key, value) {
      switch (value){
        case 200:
          successList.add(key);
          break;
        case 1:
          fail1List.add(key);
          break;
        case 2:
          fail2List.add(key);
          break;
        case 3:
          fail3List.add(key);
          break;
        case 4:
          fail4List.add(key);
          break;
        case 5:
          fail5List.add(key);
          break;
        case 6:
          fail6List.add(key);
          break;
        case 7:
          fail7List.add(key);
          break;
        case 8:
          fail8List.add(key);
          break;
      }
    });
    int failListLength = fail1List.length + fail2List.length + fail3List.length
        + fail4List.length + fail5List.length + fail6List.length
        + fail7List.length + fail8List.length;
    return '已扫${serialNumberBarcodeMap.length}条序列号条码，'
        '成功${successList.length}条，失败$failListLength条！'
        '${failListLength == 0 ? '' : '\n失败的条码如下：\n'}'
        '${fail1List.isEmpty ? '' : '未通过检查：${fail1List.join(',')}\n'}'
        '${fail2List.isEmpty ? '' : '从服务器中获取数据时出错：${fail2List.join(',')}\n'}'
        '${fail3List.isEmpty ? '' : '查询不到该序列号：${fail3List.join(',')}\n'}'
        '${fail4List.isEmpty ? '' : '未被分配任务单：${fail4List.join(',')}\n'}'
        '${fail5List.isEmpty ? '' : '对应的工序已报工的序列号：${fail5List.join(',')}\n'}'
        '${fail6List.isEmpty ? '' : '不允许超上道报工：${fail6List.join(',')}\n'}'
        '${fail7List.isEmpty ? '' : '该序列号已失效（报废）：${fail7List.join(',')}\n'}'
        '${fail8List.isEmpty ? '' : '该序列号与校验码不一致：${fail8List.join(',')}\n'}';
  }
  //endregion

  ///不允许超上道报工数（当前工序的报工数量不能大于上一道）
  ///
  /// 这里用来判断工序是否可以多选 AND 自动报工时，检查上道工序的报工情况
  bool get cannotOverThenTheLastOpSubmitQty => objectItem.attributeList.firstWhereOrNull(
          (element) => element.attribute == '报工状态' && element.code == '06')?.text == '1';
  ///不允许超上道报工（上一道工序的当前序列号，如果未报过工，则当前工序、当前序列号不能报工）
  ///
  /// 这里用来判断工序是否可以多选 AND 自动报工时，检查上道工序的报工情况
  bool get cannotOverThenTheLastOpS => objectItem.attributeList.firstWhereOrNull(
          (element) => element.attribute == '报工状态' && element.code == '07')?.text == '1';



  //region getAdapter

  ///获取车间Adapter
  Future<void> _getDepAdapter() async{
    depAdapter = await AdapterHelper.getAsyncAdapter(
        'dep',
        selectedItems: [PickerDataModel(id: submitModel.depId)]
    ) as DepartmentAdapter;
  }
  ///获取车间Adapter
  Future<void> Function() get getDepAdapter => _getDepAdapter;

  ///车间OR任务单OR日期选择后，获取班次Adapter
  Future<void> _getTeamAdapter() async{
    teamAdapter = await AdapterHelper.getAsyncAdapter(
        'team',
        queryData: {
          'depCode': submitModel.depCode,
          'dateTime': submitModel.billDate,
        },
        selectedItems: [PickerDataModel(id: submitModel.teamId)]
    ) as TeamAdapter;
  }
  ///车间OR任务单OR日期选择后，获取班次Adapter
  Future<void> Function() get getTeamAdapter => _getTeamAdapter;

  ///根据车间和报工时间计算默认的班次信息
  Future<void> _getTeam() async{
    if (teamAdapter != null) {
      teamAdapter!.clearSelection();
      String teamId = '';
      for (var element in teamAdapter!.dataList) {
        String dateString = DateUtil.getDateStrByDateTime(billDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? '';
        String beginTimeString = '$dateString ${element.tBeginTime ?? '00:00'}';
        String endTimeString = '$dateString ${element.tEndTime ?? '00:00'}';
        DateTime beginTime = DateTime.tryParse(beginTimeString)!;
        DateTime endTime = DateTime.tryParse(endTimeString)!;
        if (beginTime.isAfter(endTime)){ ///如果开始时间晚于结束时间：
          ///如果报工时间晚于开始时间，则结束时间加一天，反之开始时间减一天
          if (billDate.isAfter(beginTime)){
            endTime = endTime.add(const Duration(days: 1));
            isSubmitBillDateTakeFromYesterday = false;
          }
          else{
            beginTime = beginTime.add(const Duration(days: -1));
            isSubmitBillDateTakeFromYesterday = true;
          }
        }
        else if (beginTime.isAtSameMomentAs(endTime)){ ///如果开始时间和结束时间一样，则结束时间加一天
          endTime = endTime.add(const Duration(days: 1));
          isSubmitBillDateTakeFromYesterday = false;
        }
        else {
          isSubmitBillDateTakeFromYesterday = false;
        }
        if (billDate.isAfter(element.startDate ?? billDate)
            && billDate.isBefore(element.endDate ?? billDate)
            && billDate.isAfter(beginTime) && billDate.isBefore(endTime)){
          teamId = element.teamId;
          if (isBillDateChangedByNightTeam){
            if (isSubmitBillDateTakeFromYesterday){
              DateTime lastDate = billDate.add(const Duration(days: -1));
              submitModel.billDate = DateTime(lastDate.year, lastDate.month, lastDate.day);
            }
            else {
              submitModel.billDate = billDate;
            }
          }
          break;
        }
      }
      submitModel.teamId = teamId;
      teamAdapter!.validModelValue(submitModel.teamId);
    }
  }
  ///根据车间和报工时间计算默认的班次信息
  Future<void> Function() get getTeam => _getTeam;

  ///获取人员Adapter
  Future<void> _getPersonAdapter() async{
    //region 获取人员列表的车间筛选条件
    String? depCode;
    ///是否是产线筛选
    bool isLineFilter = false;
    String? lineCode;
    switch (psnGetWayIndex){
      case 1: ///选中的车间
        depCode = submitModel.depCode;
        break;
      case 2: ///固定车间
        depCode = psnDepCode;
        break;
      case 3: ///选中的产线
        isLineFilter = true;
        lineCode = submitModel.lineCode;
        break;
      case 4: ///固定产线
        isLineFilter = true;
        lineCode = psnLineCode;
        break;
      case 0: ///全部
      default:
        break;
    }
    //endregion
    List<PersonModel> lineCodeAllocateList = [];
    if (isLineFilter && lineCode != null && lineCode.isNotEmpty){
      ///获取分配给产线的员工列表
      var lineRes = await MoWorkCenterRepository().getFormData(
        '', '',
        {'LineCode': lineCode},
        0,
      );
      if (lineRes.isSuccess){
        lineCodeAllocateList.addAll(lineRes.data.entryList.where(
                (element) => element.objType == 200009).map(
                (e) => PersonModel(
                  id: e.objId,
                  code: e.objCode,
                  name: e.objName,
                  personID: e.objId,
                  psnNum: e.objCode,
                  psnName: e.objName,
                )));
      }
    }
    personAdapter = await AdapterHelper.getAsyncAdapter(
      'person',
      multipleSelection: isPsnMulti,
      isNeedLoadData: true,
      queryData: {
        'DepCode': depCode,
        'Active': 0, ///Active:0不显示离职人员
      },
      selectedItems: (submitModel.empId ?? '').isEmpty
          ? []
          : submitModel.empId!.split(',').map((e) => PickerDataModel(id: e)).toList(),
        fieldList: isLineFilter ? lineCodeAllocateList : null,
    ) as PersonAdapter;
  }
  ///获取人员Adapter
  Future<void> Function() get getPersonAdapter => _getPersonAdapter;

  ///获取生产班组Adapter
  Future<void> _getTeamGroupAdapter() async {
    teamGroupAdapter = await AdapterHelper.getAsyncAdapter(
      'line',
      title: '生产班组选择',
      queryData: {
        'LineClass': 2,
      },
      selectedItems: [PickerDataModel(id: submitModel.wcId)],
    ) as MoBeltLineWithNoPageAdapter;
    ///部分源单没有产线 Code，这里通过选单数据源获取
    List<MoBeltLineModel> selectedList = teamGroupAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
    submitModel.lineCode = selectedList.map((e) => e.code).join(',');
    submitModel.lineName = selectedList.map((e) => e.name).join(',');
  }
  ///获取生产班组Adapter
  Future<void> Function() get getTeamGroupAdapter => _getTeamGroupAdapter;

  ///获取加工中心Adapter
  Future<void> _getWorkCenterAdapter() async {
    workCenterAdapter = await AdapterHelper.getAsyncAdapter(
      'workCenter',
      selectedItems: [PickerDataModel(id: submitModel.wcId)],
    ) as MoWorkCenterWithNoPageAdapter;
    ///部分源单没有产线 Code，这里通过选单数据源获取
    List<MoWorkCenterModel> selectedList = workCenterAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
    submitModel.lineCode = selectedList.map((e) => e.code).join(',');
    submitModel.lineName = selectedList.map((e) => e.name).join(',');
  }
  ///获取加工中心Adapter
  Future<void> Function() get getWorkCenterAdapter => _getWorkCenterAdapter;

  ///获取产线Adapter
  Future<void> _getLineAdapter() async {
    lineAdapter = await AdapterHelper.getAsyncAdapter(
      'line',
      queryData: {
        'LineClass': 0,
      },
      selectedItems: [PickerDataModel(id: submitModel.wcId)],
    ) as MoBeltLineWithNoPageAdapter;
    ///部分源单没有产线 Code，这里通过选单数据源获取
    List<MoBeltLineModel> selectedList = lineAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
    submitModel.lineCode = selectedList.map((e) => e.code).join(',');
    submitModel.lineName = selectedList.map((e) => e.name).join(',');
  }
  ///获取产线Adapter
  Future<void> Function() get getLineAdapter => _getLineAdapter;

  ///获取装箱容器Adapter
  Future<void> _getContainerWithNoPageAdapter() async {
    containerWithNoPageAdapter = await AdapterHelper.getAsyncAdapter(
      'container',
      queryData: {'InvId': submitModel.invId},
    ) as MoContainerWithNoPageAdapter;
  }
  ///获取装箱容器Adapter
  Future<void> Function() get getContainerWithNoPageAdapter => _getContainerWithNoPageAdapter;

  Future<void> _geDefaultContainer() async {
    if (containerWithNoPageAdapter != null) {
      containerWithNoPageAdapter!.clearSelection();
      if (containerWithNoPageAdapter!.dataList.length == 1){
        MoContainerModel item = containerWithNoPageAdapter!.dataList[0];
        await containerWithNoPageAdapter!.validModelValue(item.id);
        containerOnChanged(item);
      }
    }
  }
  Future<void> Function() get geDefaultContainer => _geDefaultContainer;

  ///获取产品序列号Adapter
  Future<void> _getOrderSNAdapter() async {
    orderSNAdapter = await AdapterHelper.getAsyncAdapter(
      'orderSN',
      queryData: {
        'MoOrderId': submitModel.moOrderId,
        'Allocate': submitModel.moOrderId == null || submitModel.moOrderId!.isEmpty ? 0 : null,
      },
      isNeedLoadData: true,
      multipleSelection: true,
      selectedItems: (submitModel.serialNumber ?? '').isEmpty
          ? []
          : submitModel.serialNumber!.split(',').map(
              (e) => PickerDataModel(id: e)).toList(),
    ) as MoOrderSNAdapter;
    if ((submitModel.serialNumber ?? '').isNotEmpty){
      NumPadUtil().setText(NumPadUtil.qty, submitModel.serialNumber!.split(',').length.toString(), numPadCTList);
    }
  }
  ///获取产品序列号Adapter
  Future<void> Function() get getOrderSNAdapter => _getOrderSNAdapter;

  //endregion



  //region OnChanged

  ///报工方式切换 需要重写
  void submitTypeOnChanged(ChoiceChipModel item) {
    submitType = item.keyName;
    numPadCTListSetEnabled();
  }

  ///报工日期选择变化 （日期改变后班次Adapter重新读取）
  Future<void> _billDateOnChanged(DateTime? date) async {
    if (date == null){ return; }
    billDate = date;
    submitModel.billDate = billDate;
    await _getTeamAdapter();
    await _getTeam();
    update();
  }
  ///报工日期选择变化 （日期改变后班次Adapter重新读取）
  Future<void> Function(DateTime? date) get billDateOnChanged => _billDateOnChanged;

  ///报工车间选择变化 （车间改变后班次Adapter重新读取）
  Future<void> _depOnChanged(PickerDataModel model) async{
    if (submitModel.depId == model.id) { return; }
    submitModel.depId = model.id;
    submitModel.depCode = model.code;
    await _getTeamAdapter();
    await _getTeam();
    if (psnGetWayIndex == 1 && isPsnHasAdapter){
      submitModel.empId = null;
      submitModel.emploee = null;
      await _getPersonAdapter();
    }
    update();
  }
  ///报工车间选择变化 （车间改变后班次Adapter重新读取）
  Future<void> Function(PickerDataModel model) get depOnChanged => _depOnChanged;

  ///班次选择变化
  void _teamOnChanged(PickerDataModel model) {
    if (submitModel.teamId == model.id) { return; }
    if (isBillDateChangedByNightTeam){
      ///判断报工日期是否要取昨日日期
      MoTeamTimeModel teamTimeModel = MoTeamTimeModel.fromJson(model.toJson());
      String dateString = DateUtil.getDateStrByDateTime(billDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? '';
      String beginTimeString = '$dateString ${teamTimeModel.tBeginTime ?? '00:00'}';
      String endTimeString = '$dateString ${teamTimeModel.tEndTime ?? '00:00'}';
      DateTime beginTime = DateTime.tryParse(beginTimeString)!;
      DateTime endTime = DateTime.tryParse(endTimeString)!;
      if (beginTime.isAfter(endTime)){ ///如果开始时间晚于结束时间：
        ///如果报工时间晚于开始时间，则结束时间加一天，反之开始时间减一天
        if (billDate.isAfter(beginTime)){
          endTime = endTime.add(const Duration(days: 1));
          isSubmitBillDateTakeFromYesterday = false;
        }
        else{
          beginTime = beginTime.add(const Duration(days: -1));
          isSubmitBillDateTakeFromYesterday = true;
        }
      }
      else if (beginTime.isAtSameMomentAs(endTime)){ ///如果开始时间和结束时间一样，则结束时间加一天
        endTime = endTime.add(const Duration(days: 1));
        isSubmitBillDateTakeFromYesterday = false;
      }
      else {
        isSubmitBillDateTakeFromYesterday = false;
      }
      if (isBillDateChangedByNightTeam){
        if (isSubmitBillDateTakeFromYesterday){
          DateTime lastDate = billDate.add(const Duration(days: -1));
          submitModel.billDate = DateTime(lastDate.year, lastDate.month, lastDate.day);
        }
        else {
          submitModel.billDate = billDate;
        }
      }
    }
    submitModel.teamId = model.id;
    update();
  }
  ///班次选择变化
  void Function(PickerDataModel model) get teamOnChanged => _teamOnChanged;

  ///加工中选择变化
  Future<void> _workCenterOnChanged(PickerDataModel model) async {
    MoWorkCenterModel item = MoWorkCenterModel.fromJson(model.toJson());
    if (submitModel.wcId == item.id){ return; }
    submitModel.wcId = item.id;
    submitModel.lineCode = item.code;
    submitModel.lineName = item.name;
    ///如果当前还未选择车间，取当前加工中心所在的车间
    if (depAdapter != null
        && (submitModel.depId ?? '').isEmpty && (item.depId ?? '').isNotEmpty){
      await depAdapter!.validModelValue(item.depId);
      DepartmentModel depItem = depAdapter!.dataList.firstWhereOrNull(
              (element) => element.isSelected)!;
      await _depOnChanged(depItem);
    }
    if (psnGetWayIndex == 3 && isPsnHasAdapter){
      submitModel.empId = null;
      submitModel.emploee = null;
      await _getPersonAdapter();
    }
    update();
  }
  ///加工中选择变化
  Future<void> Function(PickerDataModel model) get workCenterOnChanged => _workCenterOnChanged;

  ///产线选择变化
  Future<void> _lineOnChanged(PickerDataModel model) async {
    MoBeltLineModel item = MoBeltLineModel.fromJson(model.toJson());
    if (submitModel.wcId == item.id){ return; }
    submitModel.wcId = item.id;
    submitModel.lineCode = item.code;
    submitModel.lineName = item.name;
    ///如果当前还未选择车间，取当前产线所在的车间
    if (depAdapter != null
        && (submitModel.depId ?? '').isEmpty && (item.depId ?? '').isNotEmpty){
      await depAdapter!.validModelValue(item.depId);
      DepartmentModel depItem = depAdapter!.dataList.firstWhereOrNull(
              (element) => element.isSelected)!;
      await _depOnChanged(depItem);
    }
    if (psnGetWayIndex == 3 && isPsnHasAdapter){
      submitModel.empId = null;
      submitModel.emploee = null;
      await _getPersonAdapter();
    }
    update();
  }
  ///产线选择变化
  Future<void> Function(PickerDataModel model) get lineOnChanged => _lineOnChanged;

  ///生产班组选择变化
  Future<void> _teamGroupOnChanged(PickerDataModel model) async {
    MoBeltLineModel item = MoBeltLineModel.fromJson(model.toJson());
    if (submitModel.wcId == item.id){ return; }
    submitModel.wcId = item.id;
    submitModel.lineCode = item.code;
    submitModel.lineName = item.name;
    ///如果当前还未选择车间，取当前班组所在的车间
    if (depAdapter != null
        && (submitModel.depId ?? '').isEmpty && (item.depId ?? '').isNotEmpty){
      await depAdapter!.validModelValue(item.depId);
      DepartmentModel depItem = depAdapter!.dataList.firstWhereOrNull(
              (element) => element.isSelected)!;
      await _depOnChanged(depItem);
    }
    ///班组，不需要选员工
    update();
  }
  ///生产班组选择变化
  Future<void> Function(PickerDataModel model) get teamGroupOnChanged => _teamGroupOnChanged;

  ///人员选择变化
  Future<void> psnOnChanged(List<PickerDataModel> list) async{
    submitModel.empId = list.map((e) => e.id).join(',');
    submitModel.emploee = list.map((e) => e.name).join(',');
    ///如果当前还未选择车间，则取当前人员所在的车间
    if (depAdapter != null
        && (submitModel.depId ?? '').isEmpty && list.isNotEmpty){
      List<String> depIdList = list.map((e) => (e as PersonModel).deptID ?? '').toSet().toList();
      if (depIdList.isNotEmpty){
        await depAdapter!.validModelValue(depIdList[0]);
        DepartmentModel depItem = depAdapter!.dataList.firstWhereOrNull(
                (element) => element.isSelected)!;
        await _depOnChanged(depItem);
      }
    }
    update();
  }

  ///装箱容器Adapter选择变化
  void containerOnChanged(PickerDataModel model) {
    MoContainerModel item = MoContainerModel.fromJson(model.toJson());
    if (isHavePackingWeightReport){
      NumPadUtil().setText(NumPadUtil.packingWeight, item.weight?.toString() ?? '', numPadCTList);
      calcQty(NumPadUtil.packingWeight);
    }
    if ((item.maxQty ?? 0) != 0){
      NumPadUtil().setText(NumPadUtil.singleBoxQty, item.maxQty?.toString() ?? '', numPadCTList);
      calcQty(NumPadUtil.singleBoxQty);
    }
    containerPackingDescription = item.description ?? '';
    update();
  }

  ///“补打”按钮选择变化
  Future<void> _makeUpOnChanged() async{
    isMakeUp = !isMakeUp;
    billDate = DateTime.now();
    submitModel.billDate = billDate;
    await _getTeamAdapter();
    await _getTeam();
    update();
  }
  ///“补打”按钮选择变化
  Future<void> Function() get makeUpOnChanged => _makeUpOnChanged;

  ///“需要检验”按钮点击变化
  void _inspectFlagOnChanged(){
    submitModel.inspectFlag = submitModel.inspectFlag == 1 ? 0 : 1;
    update();
  }
  ///“需要检验”按钮点击变化
  void Function() get inspectFlagOnChanged => _inspectFlagOnChanged;

  ///“自检确认”按钮选择变化
  void _selfInspectionBtnOnChanged() {
    if ((submitModel.sign ?? 0) & MoOpSubmitSign.zj.sign == MoOpSubmitSign.zj.sign){
      submitModel.sign = submitModel.sign! - MoOpSubmitSign.zj.sign;
    }
    else {
      submitModel.sign = submitModel.sign! + MoOpSubmitSign.zj.sign;
    }
    update();
  }
  ///“自检确认”按钮选择变化
  void Function() get selfInspectionBtnOnChanged => _selfInspectionBtnOnChanged;

  ///“互检确认”按钮选择变化
  void _mutualInspectionBtnOnChanged() {
    if ((submitModel.sign ?? 0) & MoOpSubmitSign.hj.sign == MoOpSubmitSign.hj.sign){
      submitModel.sign = submitModel.sign! - MoOpSubmitSign.hj.sign;
    }
    else {
      submitModel.sign = submitModel.sign! + MoOpSubmitSign.hj.sign;
    }
    update();
  }
  ///“自检确认”按钮选择变化
  void Function() get mutualInspectionBtnOnChanged => _mutualInspectionBtnOnChanged;

  ///“自动提交”按钮点击变化 需要重写
  void autoCommitSubmitOnChanged() {
    autoCommitSubmit = !autoCommitSubmit;
  }

  ///设置自动提交是否成功
  void _setIsAutoCommitSuccess(bool? boolValue) {
    if (autoCommitSubmit){
      _isAutoCommitSuccess = boolValue;
      update();
      if (_isAutoCommitSuccess != null){
        Future.delayed(const Duration(milliseconds: 2500), (){
          _isAutoCommitSuccess = null;
          update();
        });
      }
    }
  }
  ///设置自动提交是否成功
  void Function(bool? boolValue) get setIsAutoCommitSuccess => _setIsAutoCommitSuccess;

  ///产品序列号选择变化
  void _orderSNOnChanged(List<PickerDataModel> list) {
    submitModel.serialNumber = list.map((e) => e.id).join(',');
    NumPadUtil().setText(NumPadUtil.qty, list.length.toString(), numPadCTList);
    update();
  }
  ///产品序列号选择变化
  void Function(List<PickerDataModel> list) get orderSNOnChanged => _orderSNOnChanged;

  //endregion



  //region  NumPad SetEnabled + 计算

  ///设置数字输入框是否可修改
  void numPadCTListSetEnabled();

  ///数据填报后的计算
  void calcQty(String keyName);

  //endregion



  /// 获取默认的车间 Code 初始值
  ///
  /// 0: 单据车间 1: 登录账号所在车间
  String? getDepIdByDepGetWayIndex();
  /// 获取默认的车间 Id 初始值
  ///
  /// 0: 单据车间 1: 登录账号所在车间
  String? getDepCodeByDepGetWayIndex();



  ///获取当前报工单对应产品的产品档案
  Future<void> _getInventoryInfo(String invId) async {
    var res = await InventoryRepository().getFormData(invId);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取产品基本档案时出错：${res.message}！');
    }
    inventoryModel = res.data;
  }
  ///获取当前报工单对应产品的产品档案
  Future<void> Function(String invId) get getInventoryInfo => _getInventoryInfo;



  ///判断首检状态
  ///
  ///是否首检 & 首检是否已合格 不合格或未生成首检报检单，则弹窗+页面红色提示
  /// 1. 获取最近一张首检报检单；2. 判断该首检报检单是否生成检验单；3. 获取最近一张检验单，并判断是否合格
  Future<void> _getIsFirstInspectionPassed({required String preType, required String preId}) async{
    if (cannotSubmitWhenNotPassFirstInspection && preId.isNotEmpty){
      PageConfig inspectListPageConfig = PageConfig(
        page: 1,
        rows: 1,
        sord: 'desc',
        sidx: 'ProcessDate',
        queryData: {
          'category': IPQCCategory.sj.category, ///首检
          preType: preId
        },
      );
      var res1 = await MoInspectRepository().getPageList(inspectListPageConfig);
      if (!res1.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取报检单列表时出错：${res1.message}');
        return;
      }
      if (res1.rows.isEmpty){ ///未生成首检报检单 + 未生成首检检验单
        ToastNotification(Get.overlayContext!).warn('未生成首检报检单，不能报工！');
        isHaveFirstInspection = false;
        isFirstInspectionPassed = null;
      }
      else if (res1.rows[0].sign != MoInspectSign.yjy.sign) { ///已生成首检报检单 + 未生成（未完成）首检检验单
        ToastNotification(Get.overlayContext!).warn('未完成首检检验，不能报工！');
        isHaveFirstInspection = true;
        isFirstInspectionPassed = null;
      }
      else { ///已生成首检报检单 + 已生成首检检验单（判断是否合格）
        PageConfig checkVoucherListPageConfig = PageConfig(
          page: 1,
          rows: 1,
          sord: 'desc',
          sidx: 'CheckDate',
          queryData: {
            'category': IPQCCategory.sj.category, ///首检
            'MoInspectId': res1.rows[0].moInspectId,
          },
        );
        var res2 = await MoCheckVoucherRepository().getPageList(checkVoucherListPageConfig);
        if (!res2.isSuccess || res2.rows.isEmpty){
          ToastNotification(Get.overlayContext!).error('获取检验单列表时出错：${res2.message}');
          return;
        }
        else if (res2.rows.isNotEmpty && res2.rows[0].verdict != 1) { ///已生成首检报检单 + 已生成首检检验单（不合格）
          ToastNotification(Get.overlayContext!).warn('首检不合格，不能报工！');
          isHaveFirstInspection = true;
          isFirstInspectionPassed = false;
        }
        else { ///已生成首检报检单 + 已生成首检检验单（合格）
          isHaveFirstInspection = true;
          isFirstInspectionPassed = true;
        }
      }
    }
  }
  ///判断首检状态
  ///
  ///是否首检 & 首检是否已合格 不合格或未生成首检报检单，则弹窗+页面红色提示
  /// 1. 获取最近一张首检报检单；2. 判断该首检报检单是否生成检验单；3. 获取最近一张检验单，并判断是否合格
  Future<void> Function({required String preType, required String preId}) get getIsFirstInspectionPassed => _getIsFirstInspectionPassed;



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
    ///如果 == false 的话，[NumPadUtil.SingleBoxWeight]...使用 [Weight] 的 maxLength
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
  Future<void> _setTheLastPackingWeightData({
    required String? theLastContainerSelectedValue,
    required double? theLastPackingWeightValue,
    required double? theLastSingleBoxQty,
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
        if (theLastSingleBoxQty != null){
          NumPadUtil().setText(NumPadUtil.singleBoxQty, theLastSingleBoxQty.toInt().toString(), numPadCTList);
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
  Future<void> Function({
    required String? theLastContainerSelectedValue,
    required double? theLastPackingWeightValue,
    required double? theLastSingleBoxQty,
  }) get setTheLastPackingWeightData => _setTheLastPackingWeightData;

  ///写入历史选中的员工数据
  Future<void> _setTheLastSelectedPsnData(List<dynamic> theLastSelectedPsnList) async {
    List<PersonModel> psnList = [];
    ///这里这样写的原因是，因为以前的代码错误，保存在本地的[theLastSelectedPsnList]可能会有 List<Map>、List<PersonModel> 两种类型
    try {
      psnList.addAll(theLastSelectedPsnList.map((e) => PersonModel.fromJson(e)));
    } catch (e){}
    try {
      psnList.addAll(theLastSelectedPsnList.map((e) => e));
    } catch (e){}
    if (psnList.isNotEmpty){
      if (isPsnHasAdapter) {
        await personAdapter?.validViewValue(psnList);
        await psnOnChanged(psnList);
      }
      else {
        personList.clear();
        personList.addAll(psnList);
        await psnOnChanged(personList);
      }
    }
  }
  ///写入历史选中的员工数据
  Future<void> Function(List<dynamic> theLastSelectedPsnList) get setTheLastSelectedPsnData => _setTheLastSelectedPsnData;


  ///保存报工记录
  ///
  /// [byAutoSubmit]：是扫描序列号后的自动提交报工
  Future<void> saveSubmit(bool isPrint, {bool byAutoSubmit = false});



  ///报工提交前检查（通用的，之后还需要检查一遍[cannotSubmitWhenNotInProduction]）
  /// [True]：通过； [False]：不通过
  ///
  /// [button]：提交按钮的权限名称，默认：btnadd
  ///
  /// [needCheckQty]：是否需要检查报工总数的填报情况（任务单报工，扫描序列号，自动提交报工记录时，不检查报工总数）
  ///
  /// [needCheckOp]：是否需要检查工序的填报情况（任务单报工，扫描序列号，自动提交报工记录时，如果是扫码后跳转到新的任务单，则不检查工序）
  ///
  /// [needCheckSN]：是否需要检查序列号的填报情况（任务单报工，扫描序列号，自动提交报工记录时，不检查序列号）
  Map<bool, String> _submitCheck({
    required bool isPrint,
    required String? invCCode,
    String button = 'btnadd',
    bool needCheckQty = true,
    bool needCheckOp = true,
    bool needCheckSN = true, //todo
  }) {
    //region 权限权限
    if (_dataService.isEnableOperatePrivilege && objectItem.buttons?[button] == null){
      return {false: '没有操作的权限${BaseService.profile.isSystem == true ? '【${objectItem.progid}】【${button}】' : ''}！'};
    }
    //endregion
    //region 提交前检查
    if (cannotSubmitWhenNotPassFirstInspection){
      if (!isHaveFirstInspection){
        return {false: '请生成首检报检单，并进行首检检验！'};
      }
      else if (isFirstInspectionPassed == null){
        return {false: '请完成首检检验！'};
      }
      else if (!isFirstInspectionPassed!){
        return {false: '首检不合格，请再次生成首检报检单，并进行首检检验！'};
      }
    }
    if (cannotSubmitWhenSingleBoxQtyDifferent == 1){
      Map<bool, String> map = _singleBoxQtyCheck();
      if (map.containsKey(false)){
        return {false: '${map[false]}\n请重输！'};
      }
    }
    if (cannotSubmitWhenLimitWeightError == 1){
      Map<bool, String> map = _limitInvWeightCheck();
      if (map.containsKey(false)){
        return {false: '${map[false]}\n请重输！'};
      }
    }
    if (submitModel.billDate == null){
      return {false: '请选择报工日期！'};
    }
    if (FormUtil.isRequired(formJudgeTypeMap['DepId'])
        && (submitModel.depId ?? '').isEmpty){
      return {false: '请选择车间！'};
    }
    if (FormUtil.isRequired(formJudgeTypeMap['TeamId'])
        && (submitModel.teamId ?? '').isEmpty){
      return {false: '请选择班次！'};
    }
    if (FormUtil.isRequired(formJudgeTypeMap['wcId'])
        && (submitModel.wcId ?? '').isEmpty){
      String content = '';
      switch (wcDataReportType){
        //region
        case 0: ///产线
          content = '生产产线';
          break;
        case 1: ///加工中心
          content = '加工中心';
          break;
        case 2: ///生产班组
          content = '生产班组';
          break;
        //endregion
      }
      return {false: '请选择$content！'};
    }
    if (FormUtil.isRequired(formJudgeTypeMap['DeviceId'])
        && wcDataReportType != 0
        && (submitModel.deviceId ?? '').isEmpty){
      return {false: '请选择设备！'};
    }
    if (FormUtil.isRequired(formJudgeTypeMap['EmpId'])
        && wcDataReportType != 2
        && (submitModel.empId ?? '').isEmpty){
      return {false: '请选择生产人员！'};
    }
    if (needCheckOp){
      if ((submitType == AppConfig.serialNumberSubmit)
          && (submitModel.opId ?? '').isEmpty){
        return {false: '按序列号报工时，必须要选中一道工序，请检查！'};
      }
      if ((submitType == AppConfig.serialNumberSubmit || submitType == AppConfig.singleBoxSerialNumberSubmit)
          && (submitModel.opId ?? '').contains(',')){
        return {false: '按序列号报工时，单次只允许报一道工序，请检查！'};
      }
      if (FormUtil.isRequired(formJudgeTypeMap['OpId'])
          && (submitModel.opId ?? '').isEmpty){
        return {false: '请选择工序！'};
      }
    }
    if (needCheckSN){
      if ((submitType == AppConfig.serialNumberSubmit || submitType == AppConfig.singleBoxSerialNumberSubmit)
          && (submitModel.serialNumber ?? '').isEmpty){
        return {false: '按序列号报工时，必须要选中一条序列号，请检查！'};
      }
      if ((submitType == AppConfig.serialNumberSubmit || submitType == AppConfig.singleBoxSerialNumberSubmit)
          && serialNumberCheckCodeList.isNotEmpty){
        String? snRes = submitModel.serialNumber!.split(',').firstWhereOrNull((sn){
          String? sCCRes = serialNumberCheckCodeList.firstWhereOrNull((cc){
            if (cc.startsWith('%') || cc.endsWith('%')){
              String serialNumberCheckCode = cc.replaceAll('%', '');
              if (serialNumberCheckCode.isNotEmpty){
                if (cc.startsWith('%') && cc.endsWith('%') && sn.contains(serialNumberCheckCode)){
                  return true;
                }
                else if (cc.startsWith('%') && sn.endsWith(serialNumberCheckCode)){
                  return true;
                }
                else if (cc.endsWith('%') && sn.startsWith(serialNumberCheckCode)){
                  return true;
                }
                else if (!cc.startsWith('%') && !cc.endsWith('%') && sn == serialNumberCheckCode){
                  return true;
                }
                return false;
              }
              return false;
            }
            else {
              ///判断正则表达式
              RegExp pattern = RegExp(cc);
              return pattern.hasMatch(sn);
              return sn.contains(pattern);
            }
            return false;
          });
          return sCCRes == null;
        });
        if (snRes != null){
          return {false: '有序列号与校验码不一致，请检查！\n当前效验码：${serialNumberCheckCodeList.join(', ')}'};
        }
      }
    }
    //endregion
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
    ///多箱报工的时候，如果整箱箱数没有输入，就默认为 1 箱
    if ((submitType == AppConfig.qtyBoxSubmit || submitType == AppConfig.weightBoxSubmit || submitType == AppConfig.mesWeightBoxSubmit)
        && _numString.isNotEmpty
        && (_num == null || _num < 1)){
      return {false: '整箱箱数输入有误，请重输！'};
    }
    else if ((submitType == AppConfig.qtyBoxSubmit || submitType == AppConfig.weightBoxSubmit || submitType == AppConfig.mesWeightBoxSubmit)
        && _numString.isEmpty){
      _num = 1;
    }
    if ((submitType == AppConfig.qtyBoxSubmit || submitType == AppConfig.weightBoxSubmit || submitType == AppConfig.mesWeightBoxSubmit)
        && numMaxCountLimit != null && _num! > numMaxCountLimit!){
      return {false: '整箱箱数大于设置的上限值（$numMaxCountLimit），请重输！'};
    }

    String singleBoxQtyString = NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '';
    int? singleBoxQty = int.tryParse(singleBoxQtyString);
    if ((submitType == AppConfig.qtyBoxSubmit || submitType == AppConfig.palletSubmit)
        && (singleBoxQty == null || singleBoxQty < 1)){
      return {false: '单箱数量输入有误，请重输！'};
    }
    if ((submitType == AppConfig.qtyBoxSubmit || submitType == AppConfig.palletSubmit)
        && singleBoxQtyMaxCountLimit != null && singleBoxQty! < singleBoxQtyMaxCountLimit!){
      return {false: '单箱数量小于设置的下限值（$singleBoxQtyMaxCountLimit），请重输！'};
    }

    ///尾箱件数可以为空但是不能有特殊字符，不能大于单箱件数
    String lastBoxQtyString = NumPadUtil().getText(NumPadUtil.lastBoxQty, numPadCTList) ?? '';
    int? lastBoxQty = int.tryParse(lastBoxQtyString);
    if ((submitType == AppConfig.qtyBoxSubmit || submitType == AppConfig.palletSubmit)
        && lastBoxQtyString.isNotEmpty
        && (lastBoxQty == null || lastBoxQty < 0)){
      return {false: '尾箱数量输入有误，请重输！'};
    }
    if ((submitType == AppConfig.qtyBoxSubmit || submitType == AppConfig.palletSubmit)
        && lastBoxQtyString.isNotEmpty
        && lastBoxQty! >= singleBoxQty!){
      return {false: '尾箱数量不能大于等于单箱数量，请重输！'};
    }

    ///单托箱数可以为空但是不能有特殊字符（一箱都没有装满的情况）
    String boxNumOfPalletString = NumPadUtil().getText(NumPadUtil.boxNumOfPallet, numPadCTList) ?? '';
    int? boxNumOfPallet = int.tryParse(boxNumOfPalletString);
    if (submitType == AppConfig.palletSubmit
        && boxNumOfPalletString.isNotEmpty
        && (boxNumOfPallet == null || boxNumOfPallet < 1)){
      return {false: '单托箱数输入有误，请重输！'};
    }

    String singleBoxWeightString = NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '';
    double? singleBoxWeight = double.tryParse(singleBoxWeightString);
    if ((submitType == AppConfig.weightBoxSubmit || submitType == AppConfig.mesWeightBoxSubmit)
        && (singleBoxWeight == null || singleBoxWeight <= 0)){
      return {false: '单箱重量输入有误，请重输！'};
    }
    if ((submitType == AppConfig.weightBoxSubmit || submitType == AppConfig.mesWeightBoxSubmit)
        && FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.pieceWeight}'])
        && singleBoxWeight! < (pieceWeight! / 1000)){
      return {false: '单箱重量不能小于实际单重，请重输！'};
    }
    if ((submitType == AppConfig.weightBoxSubmit || submitType == AppConfig.mesWeightBoxSubmit)
        && packingWeightString.isNotEmpty
        && singleBoxWeight! <= packingWeight!){
      return {false: '单箱重量不能小于等于皮重，请重输！'};
    }

    String lastBoxWeightString = NumPadUtil().getText(NumPadUtil.lastBoxWeight, numPadCTList) ?? '';
    double? lastBoxWeight = double.tryParse(lastBoxWeightString);
    if ((submitType == AppConfig.weightBoxSubmit || submitType == AppConfig.mesWeightBoxSubmit)
        && lastBoxWeightString.isNotEmpty
        && (lastBoxWeight == null || lastBoxWeight < 0)){
      return {false: '尾箱重量不正确，请重输！'};
    }
    if ((submitType == AppConfig.weightBoxSubmit || submitType == AppConfig.mesWeightBoxSubmit)
        && lastBoxWeightString.isNotEmpty
        && lastBoxWeight! >= singleBoxWeight!){
      return {false: '尾箱重量不能大于等于单箱重量，请重输！'};
    }
    if ((submitType == AppConfig.weightBoxSubmit || submitType == AppConfig.mesWeightBoxSubmit)
        && FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.pieceWeight}'])
        && lastBoxWeightString.isNotEmpty
        && lastBoxWeight! < (pieceWeight! / 1000)){
      return {false: '尾箱重量不能小于实际单重，请重输！'};
    }
    if ((submitType == AppConfig.weightBoxSubmit || submitType == AppConfig.mesWeightBoxSubmit)
        && packingWeightString.isNotEmpty
        && lastBoxWeightString.isNotEmpty
        && lastBoxWeight! <= packingWeight!){
      return {false: '尾箱重量不能小于等于皮重，请重输！'};
    }

    String qtyString = NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '';
    int? qty = int.tryParse(qtyString);
    if (needCheckQty){
      if (submitType != AppConfig.mesWeightSubmit && submitType != AppConfig.mesWeightBoxSubmit){
        if ((FormUtil.isRequired(formJudgeTypeMap['Qty']) && qty == null)
            || (FormUtil.isCannotBeNegativeNum(formJudgeTypeMap['Qty']) && qty! <= 0)
            || (FormUtil.isInteger(formJudgeTypeMap['Qty']) && qty != qty!.toInt())
            || (FormUtil.isCannotBeZero(formJudgeTypeMap['Qty']) && qty == 0)){
          return {false: '报工总数量输入有误，请重输！'};
        }
      }
      if (needCheckSN){
        ///当产品序列号字段有数据时，报工总数量必须要等于产品序列号个数
        List<String> serialNumberList = (submitModel.serialNumber ?? '').isEmpty
            ? []
            : submitModel.serialNumber!.split(',').toList();
        if (serialNumberList.isNotEmpty && serialNumberList.length != qty){
          return {false: '序列号个数与报工总数量不符，请检查！'};
        }
      }
    }

    if (submitType == AppConfig.singleBoxSerialNumberSubmit){
      if (singleBoxQty == null || singleBoxQty < 1){
        return {false: '请输入单箱数量！'};
      }
      if (singleBoxQty != qty){
        return {false: '单箱数量和报工总数不相等，请检查！'};
      }
    }

    String _weightString = NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '';
    double? _weight = double.tryParse(_weightString);
    if ((submitType == AppConfig.weightSubmit || submitType == AppConfig.weightBoxSubmit
        || submitType == AppConfig.mesWeightSubmit || submitType == AppConfig.mesWeightBoxSubmit)
        && (_weight == null || _weight <= 0)){
      return {false: '报工总重输入有误，请重输！'};
    }

    String boxWeightString = NumPadUtil().getText(NumPadUtil.boxWeight, numPadCTList) ?? '';
    double? boxWeight = double.tryParse(boxWeightString);
    if (submitType == AppConfig.palletSubmit
        && boxWeightString.isNotEmpty && (boxWeight == null || boxWeight < 0)){
      return {false: '箱重输入有误，请重输！'};
    }
    //endregion
    if (isPrint){
      String frxName = invClassFrxNameMap[invCCode ?? ''] ?? this.frxName;
      if (frxName.isEmpty){
        return {false: '打印的模板名称为空，请在设置中修改！'};
      }
      if (submitType == AppConfig.serialNumberSubmit
          && (submitModel.serialNumber ?? '').isNotEmpty
          && submitModel.serialNumber!.contains(',')){
        return {false: '不能同时选择多条序列号进行报工并打印，请修改！'};
      }
      if ((submitModel.opId ?? '').isNotEmpty
          && submitModel.opId!.contains(',')){
        return {false: '不能同时选择多个工序进行报工并打印，请修改！'};
      }
    }
    return {true: ''};
  }
  ///报工提交前检查（通用的，之后还需要检查一遍[cannotSubmitWhenNotInProduction]）
  /// [True]：通过； [False]：不通过
  ///
  /// [button]：提交按钮的权限名称，默认：btnadd
  ///
  /// [needCheckQty]：是否需要检查报工总数的填报情况（任务单报工，扫描序列号，自动提交报工记录时，不检查报工总数）
  ///
  /// [needCheckOp]：是否需要检查工序的填报情况（任务单报工，扫描序列号，自动提交报工记录时，如果是扫码后跳转到新的任务单，则不检查工序）
  ///
  /// [needCheckSN]：是否需要检查序列号的填报情况（任务单报工，扫描序列号，自动提交报工记录时，不检查序列号）
  Map<bool, String> Function({
    required bool isPrint,
    required String? invCCode,
    String button,
    bool needCheckQty,
    bool needCheckOp,
    bool needCheckSN,
  }) get submitCheck => _submitCheck;



  ///超量报工判断
  /// [True]：通过； [False]：不通过
  ///
  /// [qty]：计划数量/派工数量
  ///
  /// [submitQty]：已报工数量
  ///
  /// [opQtyMap]：报工工序的生产情况 {"工序ID": "计划数量"}
  ///
  /// [opSubmitQtyMap]：报工工序的生产情况 {"工序ID": "已报工数量"}
  Future<bool> _overSubmitCheck({
    required double qty,
    required double submitQty,
    Map<String, double?>? opQtyMap,
    Map<String, double?>? opSubmitQtyMap,
  }) async {
    ///这里不判断了，提交数据后，后台会判断
    return true;

    assert(opQtyMap?.length == opSubmitQtyMap?.length);
    if (opQtyMap != null){
      opQtyMap.keys.forEach((element) {
        assert(opSubmitQtyMap!.containsKey(element));
      });
    }

    ///是否超量报工
    bool isOver = false;
    ///可以提交报工的数量
    double canSubmitQty = 0;
    ///是否允许超量报工（0 允许（否），1 不允许（是））
    bool isAllowedOverSubmit = objectItem.attributeList.firstWhereOrNull((e) => e.attribute == '报工状态' && e.code == '01')?.text != '1';
    String qtyString;
    if (submitType == AppConfig.mesWeightSubmit || submitType == AppConfig.mesWeightBoxSubmit){
      qtyString = NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '';
    }
    else {
      qtyString = NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '';
    }
    if (!isAllowedOverSubmit){
      ///可超量百分比
      double overPercent = double.tryParse(objectItem.attributeList.firstWhereOrNull((e) => e.attribute == '报工状态' && e.code == '02')?.text?.toString() ?? '') ?? 100;
      ///如果是工序报工，需要判断工序列表的生产情况，再判断任务单的生产情况
      if (opQtyMap != null && opSubmitQtyMap != null){
        for(var key in opQtyMap.keys) {
          ///可以提交报工的数量
          canSubmitQty = (1 + overPercent / 100) * (opQtyMap[key] ?? 0) - (opSubmitQtyMap[key] ?? 0);
          ///是否超量报工
          isOver = (canSubmitQty - double.tryParse(qtyString)!) < 0;
          if (isOver){
            break;
          }
        }
      }
      if (!isOver){
        canSubmitQty = (1 + overPercent / 100) * qty - submitQty;
        isOver = (canSubmitQty - double.tryParse(qtyString)!) < 0;
      }
    }
    if (isOver){
      await DialogUtils.showTipsDialog(
        Get.context!,
        contentWidget: Container(
          width: 500, height: 200,
          color: Theme.of(Get.context!).colorScheme.surface,
          child: Column(
            children: [
              Divider(
                indent: 0, endIndent: 0,
                color: Theme.of(Get.context!).dividerTheme.color!.withAlpha(102),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: SingleChildScrollView(
                    child: RichText(
                      text: TextSpan(
                        text: '已超量报工，请修改！\n当前报工数量：',
                        style: Theme.of(Get.context!).textTheme.bodyLarge,
                        children: [
                          TextSpan(
                              text: '$qtyString\n',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              )
                          ),
                          const TextSpan(text: '可报工数量：'),
                          TextSpan(
                              text: '${canSubmitQty <= 0 ? 0 : canSubmitQty.toStringAsFixed(0)}\n',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                indent: 0, endIndent: 0,
                color: Theme.of(Get.context!).dividerTheme.color!.withAlpha(102),
              ),
            ],
          ),
        ),
      );
    }
    return !isOver;
  }
  ///超量报工判断
  /// [True]：通过； [False]：不通过
  ///
  /// [qty]：计划数量/派工数量
  ///
  /// [submitQty]：已报工数量
  ///
  /// [opQtyMap]：报工工序的生产情况 {"工序ID": "计划数量"}
  ///
  /// [opSubmitQtyMap]：报工工序的生产情况 {"工序ID": "已报工数量"}
  Future<bool> Function({
    required double qty,
    required double submitQty,
    Map<String, double?>? opQtyMap,
    Map<String, double?>? opSubmitQtyMap,
  }) get overSubmitCheck => _overSubmitCheck;



  ///判断序列号是否报废
  Future<bool> _scrapCheck(String serialNumbers) async {
    List<String> serialNumberList = serialNumbers.split(',');
    bool isPass = true;
    for (var element in serialNumberList){
      var checkRecordRes = await MoCheckRecordRepository().getPageList(PageConfig(
        page: 1, rows: 1,
        queryData: {
          'SerialNumber': element,
          'Disposeflow': 1,
        },
      ));
      if (!checkRecordRes.isSuccess){
        TipsUtils.showTip(
          msg: '判断序列号是否报废失败：${checkRecordRes.message}！',
          toastType: ToastType.warn,
        );
        isPass = false;
        break; ///则跳出循环
      }
      if (checkRecordRes.rows.isNotEmpty){
        TipsUtils.showTip(
          msg: '该序列号处于报废状态：$element！\n'
              '报废时间：${DateUtil.getDateStrByDateTime(checkRecordRes.rows[0].productDate)}\n'
              '报废工序：${checkRecordRes.rows[0].opName ?? ''}\n'
              '报废人：${checkRecordRes.rows[0].emploee ?? ''}',
          toastType: ToastType.warn,
        );
        isPass = false;
        break; ///则跳出循环
      }
    }
    return isPass;
  }
  ///判断序列号是否报废
  Future<bool> Function(String serialNumbers) get scrapCheck => _scrapCheck;



  ///判断标准单重与实际单重偏差值是否超出指定量
  Map<bool, String> _limitInvWeightCheck() {
    if (cannotSubmitWhenLimitWeightError != 0){
      String pieceWeightStr = NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '';
      String msg = '';
      double? pieceWeight = double.tryParse(pieceWeightStr);
      if (pieceWeightStr.isNotEmpty
          && (inventoryModel.invWeight ?? 0) != 0
          && (inventoryModel.invWeight! / pieceWeight! - 1).abs() > (limitWeightDeviationValue / 100)){
        msg += '标准单重与实际单重偏差超过${NumFormatUtil.qtyFormatConverter(limitWeightDeviationValue.toString())}%！\n';
        msg += '标准单重：${NumFormatUtil.qtyFormatConverter((inventoryModel.invWeight ?? 0).toString())}g'
            '\u00A0\u00A0\u00A0实际单重：${NumFormatUtil.qtyFormatConverter(pieceWeightStr)}g';
      }
      if (msg.isNotEmpty){
        return {false: msg};
      }
    }
    return {true: ''};
  }



  ///判断预计单箱数量是否与标准单箱数量一致
  Map<bool, String> _singleBoxQtyCheck() {
    if (cannotSubmitWhenSingleBoxQtyDifferent != 0
        && (submitType == AppConfig.qtyBoxSubmit || submitType == AppConfig.weightBoxSubmit)){
      /// 先取输入框值，如果为空，则取 adapter.maxQty，如果为空，则取产品的标准装箱数
      double singleBoxQty = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '')
          ?? containerWithNoPageAdapter?.dataList.firstWhereOrNull((element) => element.isSelected)?.maxQty?.toDouble()
          ?? inventoryModel.packingQty
          ?? 0;
      ///允许误差值
      int allowErrorQty = (singleBoxQtyDifferentSubmitPercent / 100 * singleBoxQty).truncate();
      if (((singleBoxQtyForExpect ?? 0) - singleBoxQty).abs() > allowErrorQty){
        return {false: '预计单箱数量与标准单箱数量不一致！'};
      }
    }
    return {true: ''};
  }



  ///判断序列号的报工情况（这里会写入 [serialNumberBarcodeMap]）
  Future<bool> _checkOpSerialNumber(String serialNumber) async {
    //region 判断该序列号是否已经报过工
    PageConfig pageConfig = PageConfig(
        page: 1,
        rows: 1,
        queryData: {
          'MoOrderId': submitModel.moOrderId,
          'WorkBillEntryId': submitModel.workBillEntryId,
          'SerialNumber': serialNumber,
          'EnableMark': 1, ///取未失效的报工单，序列号报次品后，对应的报工单会失效
        }
    );
    var submitRes = await MoOpSubmitRepository().getPageList(pageConfig);
    if (!submitRes.isSuccess){
      serialNumberBarcodeMap.addAll({serialNumber: 2});
      TipsUtils.showTip(
        msg: '判断该序列号是否已经报过工时出错：${submitRes.message}！',
        toastType: ToastType.warn,
      );
      return false;
    }
    if (submitRes.rows.isNotEmpty){
      serialNumberBarcodeMap.addAll({serialNumber: 5});
      TipsUtils.showTip(
        msg: '该序列号对应的工序已报工，'
            '报工时间：${DateUtil.getDateStrByDateTime(submitRes.rows[0].billDate, format: DateFormat.NORMAL, dateSeparate: '-', timeSeparate: ':')}！',
        toastType: ToastType.warn,
      );
      return false;
    }
    //endregion
    //region 如果是>=第三道工序，且符合[cannotOverThenTheLastOpS]、[reportFlag]条件，则判断上一道工序的序列号是否已经报过工，如果没有，则该道工序不能报工
    if (cannotOverThenTheLastOpS){
      if (processAdapter != null){
        return false;
      }
      MoWorkBillEntryModel current = processAdapter!.dataList.firstWhereOrNull((element) => element.isSelected)!;
      if ((current.sequ ?? 0) >= 3 && current.reportFlag == 1){
        String theLastWorkBillEntryId = processAdapter!.noFilterDataList.firstWhereOrNull((element) => element.sequ == (current.sequ! - 1))?.id ?? '';
        PageConfig pageConfigLast = PageConfig(
            page: 1,
            rows: 1,
            queryData: {
              'MoOrderId': submitModel.moOrderId,
              'WorkBillEntryId': theLastWorkBillEntryId,
              'SerialNumber': serialNumber,
              'EnableMark': 1, ///取未失效的报工单，序列号报次品后，对应的报工单会失效
            }
        );
        var submitResLast = await MoOpSubmitRepository().getPageList(pageConfigLast);
        if (!submitResLast.isSuccess){
          serialNumberBarcodeMap.addAll({serialNumber: 2});
          TipsUtils.showTip(
            msg: '判断是否超上道报工时出错：${submitResLast.message}',
            toastType: ToastType.warn,
          );
          return false;
        }
        if (submitResLast.rows.isEmpty){
          serialNumberBarcodeMap.addAll({serialNumber: 6});
          TipsUtils.showTip(
            msg: '不允许超上道报工！',
            toastType: ToastType.warn,
          );
          return false;
        }
      }
    }
    //endregion
    return true;
  }
  ///判断序列号的报工情况（这里会写入 [serialNumberBarcodeMap]）
  Future<bool> Function(String serialNumber) get checkOpSerialNumber => _checkOpSerialNumber;



  ///报工提交时的确认提示框
  Future<bool> _submitSaveConfirmationDialog(bool isPrint, {bool byAutoSubmit = false}) async {
    String msg = '';

    Map<bool, String> limitInvWeightCheckRes = _limitInvWeightCheck();
    if (limitInvWeightCheckRes.containsKey(false)){
      msg += '${limitInvWeightCheckRes[false]}\n';
    }

    Map<bool, String> singleBoxQtyCheckRes = _singleBoxQtyCheck();
    if (singleBoxQtyCheckRes.containsKey(false)){
      msg += '${singleBoxQtyCheckRes[false]}\n';
    }

    if (msg.isNotEmpty || (isShowSubmitConfirmationDialog && !byAutoSubmit)){
      var dialogRes = await DialogUtils.showConfirmationDialog(
        Get.context!,
        msg: msg.isNotEmpty
            ? '$msg是否继续提交${isPrint ? '并打印' : ''}？'
            : '确认提交报工记录${isPrint ? '并打印' : ''}？',
        barrierDismissible: false,
      );
      if (dialogRes == null || !dialogRes){
        return false;
      }
    }
    return true;
  }
  ///报工提交时的确认提示框
  Future<bool> Function(bool isPrint, {bool byAutoSubmit}) get submitSaveConfirmationDialog => _submitSaveConfirmationDialog;



  ///报工记录提交时赋值
  ///
  /// [inventoryModel]：当前报工产品的信息，用来获取产品标准单重（按重量（多箱）报工时，可能要赋值实际单重）
  void _setSubmitDataBeforeSave({InventoryModel? inventoryModel}) {
    assert(submitType != AppConfig.weightBoxSubmit
        || (submitType == AppConfig.weightBoxSubmit && inventoryModel != null));

    submitModel.createDate = DateTime.now();
    if (!isMakeUp && !(isBillDateChangedByNightTeam && isSubmitBillDateTakeFromYesterday)){
      submitModel.billDate = DateTime.now();
    }
    //region
    double? eBWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.eBWeight, numPadCTList) ?? '')?.toPrecision(weightFormDecimalLengthMap[NumPadUtil.eBWeight]!);
    double? eBPiece = double.tryParse(NumPadUtil().getText(NumPadUtil.eBPiece, numPadCTList) ?? '');
    double? pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '')?.toPrecision(weightFormDecimalLengthMap[NumPadUtil.pieceWeight]!);
    double? packingWeight = isHavePackingWeightReport
        ? double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '')?.toPrecision(weightFormDecimalLengthMap[NumPadUtil.packingWeight]!)
        : 0;
    double? num = double.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '') ?? 1; ///多箱报工的时候，如果整箱箱数没有输入，就默认为 1 箱
    double? singleBoxQty = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '');
    double? lastBoxQty = double.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxQty, numPadCTList) ?? '');
    double? boxNumOfPallet = double.tryParse(NumPadUtil().getText(NumPadUtil.boxNumOfPallet, numPadCTList) ?? '');
    double? singleBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '')?.toPrecision(weightFormDecimalLengthMap[NumPadUtil.singleBoxWeight]!);
    double? lastBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxWeight, numPadCTList) ?? '')?.toPrecision(weightFormDecimalLengthMap[NumPadUtil.lastBoxWeight]!);
    double? qty = double.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '');
    double? weight = double.tryParse(NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '')?.toPrecision(weightFormDecimalLengthMap[NumPadUtil.weight]!);
    double? boxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.boxWeight, numPadCTList) ?? '')?.toPrecision(weightFormDecimalLengthMap[NumPadUtil.boxWeight]!);
    //endregion
    if (FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.eBWeight}']) || pieceWeight != null){
      submitModel.eBWeight = eBWeight ?? ((weight ?? 0) * 1000);
      submitModel.eBWeightUnit = 'g';
    }
    if (FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.eBPiece}']) || pieceWeight != null){
      submitModel.eBPiece = eBPiece?.toInt() ?? qty?.toInt();
    }
    if (FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.pieceWeight}']) || pieceWeight != null){
      submitModel.pieceWeight = pieceWeight;
    }
    submitModel.packingWeight = packingWeight;
    if (submitType == AppConfig.qtySubmit){
      submitModel.boxQty = qty;
      submitModel.num = 1;
      submitModel.qty = qty;
      submitModel.weight = weight;
    }
    else if (submitType == AppConfig.qtyBoxSubmit){
      submitModel.boxQty = singleBoxQty;
      submitModel.num = num + (lastBoxQty != null ? 1 : 0);
      submitModel.qty = qty;
      submitModel.weight = weight;
    }
    else if (submitType == AppConfig.palletSubmit){
      submitModel.boxQty = qty;
      submitModel.num = (boxNumOfPallet ?? 0) + (lastBoxQty != null ? 1 : 0);
      submitModel.qty = qty;
      submitModel.boxWeight = boxWeight;
      submitModel.weight = weight;
    }
    else if (submitType == AppConfig.weightSubmit){
      submitModel.boxQty = qty;
      submitModel.num = 1;
      submitModel.qty = (qty ?? 0) + (weightIsAddPieceWeightToTotal ? (eBPiece ?? 0) : 0);
      submitModel.weight = (weight ?? 0) + ((weightIsAddPieceWeightToTotal ? (eBWeight ?? 0) : 0) / 1000).toPrecision(weightFormDecimalLengthMap[NumPadUtil.weight]!);
    }
    else if (submitType == AppConfig.weightBoxSubmit){
      ///单箱重量（不含皮重）
      double _singleBoxWeightWithNoPacking = singleBoxWeight! - (packingWeight ?? 0);
      ///单重
      double _pieceWeight = (FormUtil.isRequired(formJudgeTypeMap['local-${NumPadUtil.pieceWeight}'])
          ? pieceWeight
          : inventoryModel!.invWeight) ?? 0;
      double? boxQty = pieceWeight == 0
          ? null
          : (_singleBoxWeightWithNoPacking * 1000 / _pieceWeight).ceilToDouble();
      boxQty = boxQty != null && boxQty < 0 ? null : boxQty;
      submitModel.boxQty = boxQty;
      submitModel.num = num + (lastBoxWeight != null ? 1 : 0);
      submitModel.qty = qty;
      submitModel.weight = weight;
    }
    else if (submitType == AppConfig.mesWeightSubmit){
      submitModel.boxQty = weight;
      submitModel.num = 1;
      submitModel.qty = weight;
    }
    else if (submitType == AppConfig.mesWeightBoxSubmit){
      submitModel.boxQty = singleBoxWeight;
      submitModel.num = num + (lastBoxWeight != null ? 1 : 0);
      submitModel.qty = weight;
    }
    else if (submitType == AppConfig.serialNumberSubmit){
      submitModel.boxQty = qty;
      submitModel.num = 1;
      submitModel.qty = qty;
      submitModel.weight = weight;
    }
    else if (submitType == AppConfig.singleBoxSerialNumberSubmit){
      submitModel.boxQty = singleBoxQty;
      submitModel.num = 1;
      submitModel.qty = qty;
      submitModel.weight = weight;
    }

    if (submitModel.inspectFlag != 1){
      if (submitType == AppConfig.serialNumberSubmit){
        ///当按产品序列号报工时（个数一定等于报工总数量），[qualifiedQty、acceptQty]都赋值成 1
        submitModel.qualifiedQty = 1;
        submitModel.acceptQty = 1;
      }
      else {
        submitModel.qualifiedQty = submitModel.qty;
        submitModel.acceptQty = submitModel.qty;
      }
    }
  }
  ///报工记录提交时赋值
  ///
  /// [inventoryModel]：当前报工产品的信息（按重量（多箱）报工时，可能要赋值实际单重）
  void Function({InventoryModel? inventoryModel}) get setSubmitDataBeforeSave => _setSubmitDataBeforeSave;

  ///生成报工单和报工条码后，生成生产入库单
  Future<Map<bool, String>> _createStock(String submitId) async {
    if (isNeedCreateStock){
      var res = await MoStockBillRepository().createStock(submitId);
      if (res.isSuccess){
        return {true: '生产入库单生成成功！'};
      }
      else {
        return {false: '生产入库单生成失败！\n${res.message}'};
      }
    }
    return {false: '生产入库单生成失败！'};
  }
  ///生成报工单和报工条码后，生成生产入库单
  Future<Map<bool, String>> Function(String submitId) get createStock => _createStock;

  ///报工提交成功后，刷新报工填报区域的数据
  Future<void> _resetSubmitDataAfterSave({bool byAutoSubmit = false}) async {
    if (!isSaveTheLastSelectedPsnId){
      submitModel.empId = null;
      submitModel.emploee = null;
      personAdapter?.clearSelection();
      personList.clear();
    }
    submitModel.eBWeight = null;
    submitModel.eBWeightUnit = null;
    submitModel.eBPiece = null;
    submitModel.pieceWeight = null;
    submitModel.boxQty = null;
    submitModel.num = null;
    submitModel.qty = null;
    submitModel.weight = null;
    submitModel.boxWeight = null;
    submitModel.qualifiedQty = null;
    submitModel.acceptQty = null;
    submitModel.description = null;
    submitModel.content = null;
    submitModel.packingWeight = null;
    numPadCTList.forEach((element) {
      element.controller.clear();
    });
    if (isUsePackingPicker){
      containerWithNoPageAdapter?.clearSelection();
    }
  }
  ///报工提交成功后，刷新报工填报区域的数据
  Future<void> Function({bool byAutoSubmit}) get resetSubmitDataAfterSave => _resetSubmitDataAfterSave;



  ///实际单重保存（保存为模具产品关系中的单重）
  Future<void> weightOnSave() async {  }



  ///实际单重保存前检查（通用的，之后还需要检查一遍）
  /// [True]：通过； [False]：不通过
  ///
  /// [button]：提交按钮的权限名称，默认：btnChangeWeight
  Map<bool, String> _weightOnSaveCheck({
    String button = 'btnChangeWeight',
  }) {
    //region 权限权限
    if (_dataService.isEnableOperatePrivilege && objectItem.buttons?[button] == null){
      return {false: '没有操作的权限${BaseService.profile.isSystem == true ? '【${objectItem.progid}】【${button}】' : ''}！'};
    }
    //endregion
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
    //endregion
    return {true: ''};
  }
  ///实际单重保存前检查（通用的，之后还需要检查一遍）
  /// [True]：通过； [False]：不通过
  ///
  /// [button]：提交按钮的权限名称，默认：btnChangeWeight
  Map<bool, String> Function({
    String button,
  }) get weightOnSaveCheck => _weightOnSaveCheck;



  //region Widget

  ///报工方式选择控件
  Widget operationWayWidget(BuildContext context){
    return MenuBar(
      children: [
        SubmenuButton(
          menuChildren: operationWayList.map((e) {
            return MenuItemButton(
              onPressed: () {
                submitTypeOnChanged(e);
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
                operationWay?.title ?? '（请选择报工方式）',
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

  ///“补打”按钮
  Widget makeUpBtnWidget(BuildContext context){
    return InkWell(
      onTap: () async{
        makeUpOnChanged();
      },
      child: Padding(
        padding: kIsWeb || GetPlatform.isWindows
            ? const EdgeInsets.symmetric(vertical: 8)
            : const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isMakeUp,
              activeColor: AppColors.errorColor,
              onChanged: (bool? bool) async{
                makeUpOnChanged();
              },
            ),
            Text(
              '补打 ',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
                color: isMakeUp
                    ? AppColors.errorColor
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ), maxLines: 1, overflow: TextOverflow.ellipsis
            ),
          ],
        ),
      ),
    );
  }

  ///“需要检验”按钮
  Widget inspectFlagBtnWidget(BuildContext context){
    return InkWell(
      onTap: isCanClickInspectFlagBtn ? () {
        inspectFlagOnChanged();
      } : null,
      child: Padding(
        padding: kIsWeb || GetPlatform.isWindows
            ? const EdgeInsets.symmetric(vertical: 8)
            : const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: submitModel.inspectFlag == 1,
              activeColor: AppColors.errorColor,
              onChanged: isCanClickInspectFlagBtn ? (bool? boolValue) {
                inspectFlagOnChanged();
              } : null,
            ),
            Text(
              '需要检验 ',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
                color: submitModel.inspectFlag == 1
                    ? AppColors.errorColor
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ), maxLines: 1, overflow: TextOverflow.ellipsis
            ),
          ],
        ),
      ),
    );
  }

  ///“需要检验”文本框
  Widget inspectFlagStrWidget(BuildContext context){
    if (submitModel.inspectFlag == 1){
      return Text(
        '需要检验',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w600,
          color: submitModel.inspectFlag == 1
              ? AppColors.errorColor
              : Theme.of(context).textTheme.bodyLarge!.color,
        ), maxLines: 1, overflow: TextOverflow.ellipsis
      );
    }
    else {
      return const SizedBox.shrink();
    }
  }

  ///“自检确认”按钮
  Widget selfInspectionBtnWidget(BuildContext context){
    return InkWell(
      onTap: () {
        selfInspectionBtnOnChanged();
      },
      child: Padding(
        padding: kIsWeb || GetPlatform.isWindows
            ? const EdgeInsets.symmetric(vertical: 8)
            : const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: (submitModel.sign ?? 0) & MoOpSubmitSign.zj.sign == MoOpSubmitSign.zj.sign,
              activeColor: AppColors.errorColor,
              onChanged: (bool? bool) {
                selfInspectionBtnOnChanged();
              },
            ),
            Text(
              '自检确认',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
                color: (submitModel.sign ?? 0) & MoOpSubmitSign.zj.sign == MoOpSubmitSign.zj.sign
                    ? AppColors.errorColor
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ), maxLines: 1, overflow: TextOverflow.ellipsis
            ),
          ],
        ),
      ),
    );
  }

  ///“互检确认”按钮
  Widget mutualInspectionBtnWidget(BuildContext context){
    return InkWell(
      onTap: () {
        mutualInspectionBtnOnChanged();
      },
      child: Padding(
        padding: kIsWeb || GetPlatform.isWindows
            ? const EdgeInsets.symmetric(vertical: 8)
            : const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: (submitModel.sign ?? 0) & MoOpSubmitSign.hj.sign == MoOpSubmitSign.hj.sign,
              activeColor: AppColors.errorColor,
              onChanged: (bool? bool) {
                mutualInspectionBtnOnChanged();
              },
            ),
            Text(
              '互检确认',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
                color: (submitModel.sign ?? 0) & MoOpSubmitSign.hj.sign == MoOpSubmitSign.hj.sign
                    ? AppColors.errorColor
                    : Theme.of(context).textTheme.bodyLarge!.color,
              ), maxLines: 1, overflow: TextOverflow.ellipsis
            ),
          ],
        ),
      ),
    );
  }

  ///首检检验提示
  Widget firstInspectionWidget(BuildContext context){
    return Text(
      isHaveFirstInspection
          ? isFirstInspectionPassed == null
          ? '未完成首检检验，不能报工！'
          :  isFirstInspectionPassed!
          ? ''
          : '首检不合格，不能报工！'
          : '未生成首检报检单，不能报工！',
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.errorColor,
      ), maxLines: 1, overflow: TextOverflow.ellipsis
    );
  }

  ///报工填单区域（包括数字键盘、提交按钮）
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
              Expanded(
                child: numPadAreaWidget(context),
              ),
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

  Widget billDateReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.billDateForm]!,
      customizeContent: PrefixTextField(
        object: 1, readOnly: true,
        initText: DateUtil.formatDateTime(
            (submitModel.billDate ?? '').toString(),
            DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE
        ),
        valueOnChanged: (String string) async{
          await billDateOnChanged(DateTime.tryParse(string));
        },
      )
    );
  }

  Widget depReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.depForm]!,
      customizeContent: PickerInputWidget(
        adapter: depAdapter,
        maxLines: 2,
        onTap: (List<PickerDataModel> selectList) async{
          if (selectList.isNotEmpty){
            await depOnChanged(selectList[0]);
          }
          else {
            await depOnChanged(PickerDataModel());
          }
        },
      )
    );
  }

  Widget teamReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.teamForm]!,
      customizeContent: PickerInputWidget(
        adapter: teamAdapter,
        maxLines: 2,
        pickerChoiceType: PickerChoiceType.chip,
        onTap: (List<PickerDataModel> selectList) {
          if (selectList.isNotEmpty){
            teamOnChanged(selectList[0]);
          }
          else {
            teamOnChanged(PickerDataModel());
          }
        },
      )
    );
  }

  Widget lineReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.lineForm]!,
      customizeContent: PickerInputWidget(
        adapter: lineAdapter,
        maxLines: 2,
        pickerChoiceType: PickerChoiceType.chip,
        onTap: (List<PickerDataModel> selectList) async {
          if (selectList.isNotEmpty){
            await lineOnChanged(selectList[0]);
          }
          else {
            await lineOnChanged(MoBeltLineModel());
          }
        },
      )
    );
  }

  Widget workCenterReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.workCenterForm]!,
      customizeContent: PickerInputWidget(
        adapter: workCenterAdapter,
        maxLines: 2,
        pickerChoiceType: PickerChoiceType.chip,
        onTap: (List<PickerDataModel> selectList) async {
          if (selectList.isNotEmpty){
            await workCenterOnChanged(selectList[0]);
          }
          else {
            await workCenterOnChanged(MoWorkCenterModel());
          }
        },
      )
    );
  }

  Widget teamGroupReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.teamGroupForm]!,
      customizeContent: PickerInputWidget(
        adapter: teamGroupAdapter,
        maxLines: 2,
        pickerChoiceType: PickerChoiceType.chip,
        onTap: (List<PickerDataModel> selectList) async {
          if (selectList.isNotEmpty){
            await teamGroupOnChanged(selectList[0]);
          }
          else {
            await teamGroupOnChanged(MoBeltLineModel());
          }
        },
      )
    );
  }

  Widget personReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.personForm]!,
      customizeContent: isPsnHasAdapter ?
      PickerInputWidget(
        adapter: personAdapter,
        maxLines: 2,
        pickerChoiceType: PickerChoiceType.chip,
        onTap: (List<PickerDataModel> selectList) async {
          await psnOnChanged(selectList);
        },
      ) :
      InputWidget(
        dataList: personList,
      ),
    );
  }

  Widget containerReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[NumPadUtil.packingWeight]!,
      titleTip: containerPackingDescription,
      customizeContent: isUsePackingPicker ?
      PickerInputWidget(
        adapter: containerWithNoPageAdapter,
        maxLines: 2,
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
          return '${item.name} ${item.weight ?? 0}kg${item.maxQty == null ? '' : ' ${item.maxQty!}每箱'}';
        },
      ) :
      NumPadTextField(
        numPadController: NumPadUtil().getNumPadController(NumPadUtil.packingWeight, numPadCTList)!,
        hintText: '选填', measurement: '(kg)',
        onChanged: (String str){
          calcQty(NumPadUtil.packingWeight);
        },
      )
    );
  }

  Widget singleBoxQtyReportItem(BuildContext context){
    //!isUsePackingPicker; ///填写框
    //isUsePackingPicker && isSingleBoxQtyOnlyChangedByContainer && isHavePackingWeightReport; ///填写框，只读
    //isUsePackingPicker && isSingleBoxQtyOnlyChangedByContainer && !isHavePackingWeightReport; ///显示装箱容器选择器
    //isUsePackingPicker && !isSingleBoxQtyOnlyChangedByContainer && isHavePackingWeightReport; ///填写框
    //isUsePackingPicker && !isSingleBoxQtyOnlyChangedByContainer && !isHavePackingWeightReport; ///填写框，左侧显示装箱容器选择按钮
    return reportItem(
      context,
      title: formTitleMap[NumPadUtil.singleBoxQty]!,
      titleTip: containerPackingDescription,
      customizeContent: isUsePackingPicker && isSingleBoxQtyOnlyChangedByContainer && !isHavePackingWeightReport ?
      PickerInputWidget(
        adapter: containerWithNoPageAdapter,
        maxLines: 2,
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

  Widget orderSNReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.orderSNForm]!,
      customizeContent: PickerInputWidget(
        adapter: orderSNAdapter,
        maxLines: 2,
        hint: autoCommitSubmit ? '请扫描序列号条码' : '',
        isReadOnly: autoCommitSubmit,
        pickerChoiceType: PickerChoiceType.checkboxListTile,
        customContent: (PickerDataModel item) {
          item as MoOrderSNModel;
          return '${item.code}';
        },
        onTap: (List<PickerDataModel> selectList) {
          orderSNOnChanged(selectList);
        },
      ),
    );
  }

  Widget numPadReportItem(BuildContext context, String numPadKey, {
    String? hintText,
  }){
    String measurement = '';

    if (hintText == null){
      if (numPadKey == NumPadUtil.packingWeight
          || numPadKey == NumPadUtil.lastBoxQty
          || numPadKey == NumPadUtil.lastBoxWeight){
        hintText = '选填';
      }
      else if (numPadKey == NumPadUtil.num){
        hintText = '选填（不填写时，默认一箱）';
      }
    }

    if (numPadKey == NumPadUtil.weight
        && submitType == AppConfig.weightSubmit
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
    if (submitType != AppConfig.serialNumberSubmit
        && submitType != AppConfig.singleBoxSerialNumberSubmit){
      return Column(
        children: [
          NumPad(
            width: 300, height: 300,
            nPCList: numPadCTList,
            defaultNumPadKey: numPadFocusField,
            onPressed: (String val, String keyName, String text){
              calcQty(keyName);
            }
          ),
          const Expanded(child: SizedBox.shrink()),
        ],
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
    if ((submitType == AppConfig.serialNumberSubmit
        || submitType == AppConfig.singleBoxSerialNumberSubmit)
        && autoCommitSubmit){
      return [];
    }
    List<Widget> widgetList = [];
    AppConfig.submitBtnList.forEach((element) {
      if (submitBtnIndex & element.sign == element.sign){
        widgetList.addAll([
          const SizedBox(height: 8,),
          FilledButton(
            onPressed: () async{
              if (element.sign == 1){
                await saveSubmit(false);
              }
              else if (element.sign == 2){
                await saveSubmit(true);
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

  ///“自动提交”按钮
  Widget autoCommitSubmitBtnWidget(BuildContext context){
    return InkWell(
      onTap: () {
        autoCommitSubmitOnChanged();
      },
      child: Padding(
        padding: kIsWeb || GetPlatform.isWindows
            ? const EdgeInsets.symmetric(vertical: 8)
            : const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: autoCommitSubmit,
              onChanged: (bool? bool) async{
                autoCommitSubmitOnChanged();
              },
            ),
            Text(
                '自动提交 ',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ), maxLines: 1, overflow: TextOverflow.ellipsis
            ),
          ],
        ),
      ),
    );
  }

  Widget snViewWidget(BuildContext context){
    List<MoOrderSNModel> list = orderSNAdapter == null
        ? []
        : orderSNAdapter!.dataList.where((element) => element.isSelected).toList();
    return CardWidget(
      margin: EdgeInsets.zero,
      content: orderSNAdapter == null ?
      SpinKitCircle(
        color: Colors.grey,
        size: 28,
      ) :
      SingleChildScrollView(
        padding: const EdgeInsets.only(right: 42),
        child: Container(
          padding: const EdgeInsetsGeometry.all(6),
          alignment: Alignment.topLeft,
          child: Wrap(
            runSpacing: 6, spacing: 6,
            children: list.map((e){
              return RawChip(
                padding: const EdgeInsetsGeometry.only(
                    left: 4, right: 10, top: 12, bottom: 12
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceTint.withAlpha(30),
                side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1
                ),
                label: Text(
                  e.id,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onDeleted: () async {
                  serialNumberBarcodeMap.remove(e.id);
                  List<MoOrderSNModel> list = orderSNAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
                  list.removeWhere((element) => element.id == e.id);
                  await orderSNAdapter?.validViewValue(list);
                  orderSNOnChanged(list);
                },
                deleteIcon: Icon(
                  FluentIcons.delete_16_regular,
                  size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.43,
                ),
                deleteButtonTooltipMessage: '移除',
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  ///序列号扫码历史提示信息
  Widget serialNumberBarcodeMsgWidget(BuildContext context){
    return Tooltip(
      message: serialNumberBarcodeDetailMsg,
      child: Text(
          serialNumberBarcodeMsg,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.errorColor,
          ), maxLines: 1, overflow: TextOverflow.ellipsis
      ),
    );
  }

  //endregion

}