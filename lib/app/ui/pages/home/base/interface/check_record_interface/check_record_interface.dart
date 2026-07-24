
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
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_print_barcode_interface.dart';
import 'package:desktop/app/ui/widget/card_widget.dart';
import 'package:desktop/app/ui/widget/input_widget.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_text_field.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/ui/widget/prefix_text_field.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/form_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';


///次品录入接口 811010
mixin CheckRecordInterface on CheckRecordPrintBarcodeInterface {

  final _dataService = Get.find<DataService>();

  ///获取的系统对象相关属性；
  ///
  /// 基类中重写
  EditFormItem objectItem = EditFormItem();

  ///当前报工单对应产品的产品档案
  ///
  /// 用来获取产品标准单重、标准装箱数==[taskModel.packingQty]、产品助记码……
  InventoryModel inventoryModel = InventoryModel();

  ///页面上显示次品提交按钮（可显示多个，index 相加）
  ///
  ///1：次品提交
  ///
  ///2：提交并打印
  int checkRecordBtnIndex = AppConfig.checkRecordBtnIndex;

  ///是否显示“补打”按钮（当生产日期受班次影响时，始终不显示该按钮）
  bool isShowMakeUpBtn = AppConfig.isShowMakeUpBtn;
  ///是否为补打单
  bool isMakeUp = false;

  ///次品记录提交成功后，是否返回到首页
  bool isGetBackAfterCommitSuccess = AppConfig.isGetBackAfterCommitSuccess;

  ///是否显示报次品方式切换按钮
  bool isShowDataReportTypeBtn = AppConfig.isShowDataReportTypeBtn;
  ///报次品方式
  String _checkRecordType = AppConfig.qtyCheckRecord;
  ///报次品方式
  String get checkRecordType => _checkRecordType;
  ///报次品方式
  set checkRecordType(String str){
    _checkRecordType = str;
    _operationWay = operationWayList.firstWhereOrNull((element) => element.keyName == _checkRecordType);
  }
  ///报次品方式
  ChoiceChipModel? _operationWay;
  ///报次品方式
  ChoiceChipModel? get operationWay => _operationWay;
  ///报次品方式列表
  List<ChoiceChipModel> get operationWayList => List.unmodifiable([]);

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

  ///要提交的次品数据
  final MoCheckRecordModel checkRecordModel = MoCheckRecordModel();
  DepartmentAdapter? depAdapter;
  TeamAdapter? teamAdapter;
  PersonAdapter? personAdapter;
  MoWorkCenterWithNoPageAdapter? workCenterAdapter;
  MoBeltLineWithNoPageAdapter? lineAdapter;
  MoBeltLineWithNoPageAdapter? teamGroupAdapter;
  final List<PersonModel> personList = [];
  DataItemAdapter? comDefectAdapter;

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

  ///生产日期日期是否受班次影响（夜班班次时，要取昨日日期）
  bool get isProductDateChangedByNightTeam => objectItem.attributeList.firstWhereOrNull(
          (element) => element.attribute == 'system' && element.code == 'nightTeamBillDate')?.text == '1';
  ///实际的生产日期，区别于[checkRecordModel.productDate]
  ///
  ///默认为当前时间，“补打”按钮点击后，可以根据选中的时间变化
  ///
  /// [checkRecordModel.productDate]：可能会受到班次影响，夜班班次时，[checkRecordModel.productDate]要取[productDate]的“昨日日期”
  DateTime productDate = DateTime.now();
  ///根据当前填写的次品录入数据，[checkRecordModel.productDate]是否要取昨日日期
  bool isCRProductDateTakeFromYesterday = false;

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

  ///是否保存上次报次品时选中的员工
  bool isSaveTheLastSelectedPsnId = AppConfig.isSaveTheLastSelectedPsnId;

  ///序列号校验码
  List<String> get serialNumberCheckCodeList => [];

  ///必须符合全部条件（No：符合其中一个条件即可）
  bool get serialNumberIsAllConditionMustBeMet => AppConfig.isAllConditionMustBeMet;

  ///报次品提交时是否弹出确认提示框
  bool get isShowCheckRecordConfirmationDialog => (objectItem.attributeList.firstWhereOrNull(
          (element) => element.attribute == 'system' && element.code == 'checkRecord.dialog')?.text ?? '0') == '0';



  //region getAdapter

  ///获取车间Adapter
  Future<void> _getDepAdapter() async{
    depAdapter = await AdapterHelper.getAsyncAdapter(
        'dep',
        selectedItems: [PickerDataModel(id: checkRecordModel.depId)]
    ) as DepartmentAdapter;
  }
  ///获取车间Adapter
  Future<void> Function() get getDepAdapter => _getDepAdapter;

  ///车间OR任务单OR日期选择后，获取班次Adapter
  Future<void> _getTeamAdapter() async{
    teamAdapter = await AdapterHelper.getAsyncAdapter(
        'team',
        queryData: {
          'depCode': checkRecordModel.depCode,
          'dateTime': checkRecordModel.productDate,
        },
        selectedItems: [PickerDataModel(id: checkRecordModel.teamId)]
    ) as TeamAdapter;
  }
  ///车间OR任务单OR日期选择后，获取班次Adapter
  Future<void> Function() get getTeamAdapter => _getTeamAdapter;

  ///根据车间和报次品时间计算默认的班次信息
  Future<void> _getTeam() async{
    if (teamAdapter != null){
      teamAdapter?.clearSelection();
      String teamId = '';
      for (var element in teamAdapter!.dataList) {
        String dateString = DateUtil.getDateStrByDateTime(productDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? '';
        String beginTimeString = '$dateString ${element.tBeginTime ?? '00:00'}';
        String endTimeString = '$dateString ${element.tEndTime ?? '00:00'}';
        DateTime beginTime = DateTime.tryParse(beginTimeString)!;
        DateTime endTime = DateTime.tryParse(endTimeString)!;
        if (beginTime.isAfter(endTime)){ ///如果开始时间晚于结束时间：
          ///如果生产时间晚于开始时间，则结束时间加一天，反之开始时间减一天
          if (productDate.isAfter(beginTime)){
            endTime = endTime.add(const Duration(days: 1));
            isCRProductDateTakeFromYesterday = false;
          }
          else{
            beginTime = beginTime.add(const Duration(days: -1));
            isCRProductDateTakeFromYesterday = true;
          }
        }
        else if (beginTime.isAtSameMomentAs(endTime)){ ///如果开始时间和结束时间一样，则结束时间加一天
          endTime = endTime.add(const Duration(days: 1));
          isCRProductDateTakeFromYesterday = false;
        }
        else {
          isCRProductDateTakeFromYesterday = false;
        }
        if (productDate.isAfter(element.startDate ?? productDate)
            && productDate.isBefore(element.endDate ?? productDate)
            && productDate.isAfter(beginTime) && productDate.isBefore(endTime)){
          teamId = element.teamId;
          if (isProductDateChangedByNightTeam){
            if (isCRProductDateTakeFromYesterday){
              DateTime lastDate = productDate.add(const Duration(days: -1));
              checkRecordModel.productDate = DateTime(lastDate.year, lastDate.month, lastDate.day);
            }
            else {
              checkRecordModel.productDate = productDate;
            }
          }
          break;
        }
      }
      checkRecordModel.teamId = teamId;
      teamAdapter?.validModelValue(checkRecordModel.teamId);
    }
  }
  ///根据车间和生产时间计算默认的班次信息
  Future<void> Function() get getTeam => _getTeam;

  ///获取人员Adapter
  ///
  /// [sourceLineCode]：不良品上报时，如果员工数据源需要按选中的产线筛选，则取派工单/任务单的产线 Code
  Future<void> _getPersonAdapter({String? sourceLineCode}) async{
    //region 获取人员列表的车间筛选条件
    String? depCode;
    ///是否是产线筛选
    bool isLineFilter = false;
    String? lineCode;
    switch (psnGetWayIndex){
      case 1: ///选中的车间
        depCode = checkRecordModel.depCode;
        break;
      case 2: ///固定车间
        depCode = psnDepCode;
        break;
      case 3: ///选中的产线
        isLineFilter = true;
        lineCode = sourceLineCode ?? checkRecordModel.lineCode;
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
      selectedItems: (checkRecordModel.empId ?? '').isEmpty
          ? []
          : checkRecordModel.empId!.split(',').map((e) => PickerDataModel(id: e)).toList(),
      fieldList: isLineFilter ? lineCodeAllocateList : null,
    ) as PersonAdapter;
  }
  ///获取人员Adapter
  ///
  /// [sourceLineCode]：不良品上报时，如果员工数据源需要按选中的产线筛选，则取派工单/任务单的产线 Code
  Future<void> Function({String? sourceLineCode}) get getPersonAdapter => _getPersonAdapter;

  ///获取生产班组Adapter
  Future<void> _getTeamGroupAdapter() async {
    teamGroupAdapter = await AdapterHelper.getAsyncAdapter(
      'line',
      title: '生产班组选择',
      queryData: {
        'LineClass': 2,
      },
      selectedItems: [PickerDataModel(id: checkRecordModel.wcId)],
    ) as MoBeltLineWithNoPageAdapter;
    ///部分源单没有产线 Code，这里通过选单数据源获取
    List<MoBeltLineModel> selectedList = teamGroupAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
    checkRecordModel.lineCode = selectedList.map((e) => e.code).join(',');
    checkRecordModel.lineName = selectedList.map((e) => e.name).join(',');
  }
  ///获取生产班组Adapter
  Future<void> Function() get getTeamGroupAdapter => _getTeamGroupAdapter;

  ///获取加工中心Adapter
  Future<void> _getWorkCenterAdapter() async {
    workCenterAdapter = await AdapterHelper.getAsyncAdapter(
      'workCenter',
      selectedItems: [PickerDataModel(id: checkRecordModel.wcId)],
    ) as MoWorkCenterWithNoPageAdapter;
    ///部分源单没有产线 Code，这里通过选单数据源获取
    List<MoWorkCenterModel> selectedList = workCenterAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
    checkRecordModel.lineCode = selectedList.map((e) => e.code).join(',');
    checkRecordModel.lineName = selectedList.map((e) => e.name).join(',');
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
      selectedItems: [PickerDataModel(id: checkRecordModel.wcId)],
    ) as MoBeltLineWithNoPageAdapter;
    ///部分源单没有产线 Code，这里通过选单数据源获取
    List<MoBeltLineModel> selectedList = lineAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
    checkRecordModel.lineCode = selectedList.map((e) => e.code).join(',');
    checkRecordModel.lineName = selectedList.map((e) => e.name).join(',');
  }
  ///获取产线Adapter
  Future<void> Function() get getLineAdapter => _getLineAdapter;

  ///获取次品原因Adapter
  Future<void> _getComDefectAdapter({String? invCCode}) async{
    comDefectAdapter = await AdapterHelper.getAsyncAdapter(
      'comDefect',
      multipleSelection: true,
      queryData: {
        'itemCode': invCCode != null
            ? 'ComDefects.$invCCode,ComDefects'
            : 'ComDefects',
      },
    ) as DataItemAdapter;
  }
  ///获取次品原因Adapter
  Future<void> Function({String? invCCode}) get getComDefectAdapter => _getComDefectAdapter;

  //endregion



  //region OnChanged

  ///报次品方式切换 需要重写
  void checkRecordTypeOnChanged(ChoiceChipModel item) {
    checkRecordType = item.keyName;
    numPadCTListSetEnabled();
  }

  ///生产日期选择变化 （日期改变后班次Adapter重新读取）
  Future<void> _productDateOnChanged(DateTime? date) async {
    if (date == null){ return; }
    productDate = date;
    checkRecordModel.productDate = productDate;
    await _getTeamAdapter();
    await _getTeam();
    update();
  }
  ///生产日期选择变化 （日期改变后班次Adapter重新读取）
  Future<void> Function(DateTime? date) get productDateOnChanged => _productDateOnChanged;

  ///报次品车间选择变化 （车间改变后班次Adapter重新读取）
  Future<void> _depOnChanged(PickerDataModel model) async{
    if (checkRecordModel.depId == model.id) { return; }
    checkRecordModel.depId = model.id;
    checkRecordModel.depCode = model.code;
    await _getTeamAdapter();
    await _getTeam();
    if (psnGetWayIndex == 1 && isPsnHasAdapter){
      checkRecordModel.empId = null;
      checkRecordModel.emploee = null;
      await _getPersonAdapter();
    }
    update();
  }
  ///报次品车间选择变化 （车间改变后班次Adapter重新读取）
  Future<void> Function(PickerDataModel model) get depOnChanged => _depOnChanged;

  ///班次选择变化
  void _teamOnChanged(PickerDataModel model) {
    if (checkRecordModel.teamId == model.id) { return; }
    if (isProductDateChangedByNightTeam){
      ///判断生产日期是否要取昨日日期
      MoTeamTimeModel teamTimeModel = MoTeamTimeModel.fromJson(model.toJson());
      String dateString = DateUtil.getDateStrByDateTime(productDate, format: DateFormat.YEAR_MONTH_DAY, dateSeparate: '-', timeSeparate: ':') ?? '';
      String beginTimeString = '$dateString ${teamTimeModel.tBeginTime ?? '00:00'}';
      String endTimeString = '$dateString ${teamTimeModel.tEndTime ?? '00:00'}';
      DateTime beginTime = DateTime.tryParse(beginTimeString)!;
      DateTime endTime = DateTime.tryParse(endTimeString)!;
      if (beginTime.isAfter(endTime)){ ///如果开始时间晚于结束时间：
        ///如果生产时间晚于开始时间，则结束时间加一天，反之开始时间减一天
        if (productDate.isAfter(beginTime)){
          endTime = endTime.add(const Duration(days: 1));
          isCRProductDateTakeFromYesterday = false;
        }
        else{
          beginTime = beginTime.add(const Duration(days: -1));
          isCRProductDateTakeFromYesterday = true;
        }
      }
      else if (beginTime.isAtSameMomentAs(endTime)){ ///如果开始时间和结束时间一样，则结束时间加一天
        endTime = endTime.add(const Duration(days: 1));
        isCRProductDateTakeFromYesterday = false;
      }
      else {
        isCRProductDateTakeFromYesterday = false;
      }
      if (isProductDateChangedByNightTeam){
        if (isCRProductDateTakeFromYesterday){
          DateTime lastDate = productDate.add(const Duration(days: -1));
          checkRecordModel.productDate = DateTime(lastDate.year, lastDate.month, lastDate.day);
        }
        else {
          checkRecordModel.productDate = productDate;
        }
      }
    }
    checkRecordModel.teamId = model.id;
    update();
  }
  ///班次选择变化
  void Function(PickerDataModel model) get teamOnChanged => _teamOnChanged;

  ///加工中选择变化
  Future<void> _workCenterOnChanged(PickerDataModel model) async {
    MoWorkCenterModel item = MoWorkCenterModel.fromJson(model.toJson());
    if (checkRecordModel.wcId == item.id){ return; }
    checkRecordModel.wcId = item.id;
    checkRecordModel.lineCode = item.code;
    checkRecordModel.lineName = item.name;
    ///如果当前还未选择车间，取当前加工中心所在的车间
    if (depAdapter != null
        && (checkRecordModel.depId ?? '').isEmpty && (item.depId ?? '').isNotEmpty){
      await depAdapter!.validModelValue(item.depId);
      DepartmentModel depItem = depAdapter!.dataList.firstWhereOrNull(
              (element) => element.isSelected)!;
      await _depOnChanged(depItem);
    }
    if (psnGetWayIndex == 3 && isPsnHasAdapter){
      checkRecordModel.empId = null;
      checkRecordModel.emploee = null;
      await _getPersonAdapter();
    }
    update();
  }
  ///加工中选择变化
  Future<void> Function(PickerDataModel model) get workCenterOnChanged => _workCenterOnChanged;

  ///产线选择变化
  Future<void> _lineOnChanged(PickerDataModel model) async {
    MoBeltLineModel item = MoBeltLineModel.fromJson(model.toJson());
    if (checkRecordModel.wcId == item.id){ return; }
    checkRecordModel.wcId = item.id;
    checkRecordModel.lineCode = item.code;
    checkRecordModel.lineName = item.name;
    ///如果当前还未选择车间，取当前产线所在的车间
    if (depAdapter != null
        && (checkRecordModel.depId ?? '').isEmpty && (item.depId ?? '').isNotEmpty){
      await depAdapter!.validModelValue(item.depId);
      DepartmentModel depItem = depAdapter!.dataList.firstWhereOrNull(
              (element) => element.isSelected)!;
      await _depOnChanged(depItem);
    }
    if (psnGetWayIndex == 3 && isPsnHasAdapter){
      checkRecordModel.empId = null;
      checkRecordModel.emploee = null;
      await _getPersonAdapter();
    }
    update();
  }
  ///产线选择变化
  Future<void> Function(PickerDataModel model) get lineOnChanged => _lineOnChanged;

  ///生产班组选择变化
  Future<void> _teamGroupOnChanged(PickerDataModel model) async {
    MoBeltLineModel item = MoBeltLineModel.fromJson(model.toJson());
    if (checkRecordModel.wcId == item.id){ return; }
    checkRecordModel.wcId = item.id;
    checkRecordModel.lineCode = item.code;
    checkRecordModel.lineName = item.name;
    ///如果当前还未选择车间，取当前班组所在的车间
    if (depAdapter != null
        && (checkRecordModel.depId ?? '').isEmpty && (item.depId ?? '').isNotEmpty){
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
    checkRecordModel.empId = list.map((e) => e.id).join(',');
    checkRecordModel.emploee = list.map((e) => e.name).join(',');
    ///如果当前还未选择车间，则取当前人员所在的车间
    if (depAdapter != null
        && (checkRecordModel.depId ?? '').isEmpty && list.isNotEmpty){
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

  ///次品原因选择变化（列表选择）
  Future<void> _comDefectOnChanged(PickerDataModel model) async{
    List<PickerDataModel> list = comDefectAdapter?.dataList.where(
            (element) => element.isSelected || element.id == model.id).toList() ?? [];
    if (model.isSelected){
      list.removeWhere((element) => element.id == model.id);
    }
    await comDefectAdapter?.validViewValue(list);
    _comDefectOnChangedByAdapter(list);
    update();
  }
  ///次品原因选择变化（列表选择）
  Future<void> Function(PickerDataModel model) get comDefectOnChanged => _comDefectOnChanged;

  ///次品原因选择变化（Adapter 选择）
  void _comDefectOnChangedByAdapter(List<PickerDataModel> list) {
    checkRecordModel.comDefects = list.map((e) => e.name).join(',');
    update();
  }
  ///次品原因选择变化（Adapter 选择）
  void Function(List<PickerDataModel> list) get comDefectOnChangedByAdapter => _comDefectOnChangedByAdapter;

  ///“补打”按钮选择变化
  Future<void> _makeUpOnChanged() async{
    isMakeUp = !isMakeUp;
    productDate = DateTime.now();
    checkRecordModel.productDate = productDate;
    await _getTeamAdapter();
    await _getTeam();
    update();
  }
  ///“补打”按钮选择变化
  Future<void> Function() get makeUpOnChanged => _makeUpOnChanged;

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



  ///保存次品记录
  Future<void> saveCheckRecord(bool isPrint);



  ///次品记录提交前检查（通用的）
  /// [True]：通过； [False]：不通过
  ///
  /// [button]：提交按钮的权限名称，默认：btnadd
  Map<bool, String> _checkRecordCheck({
    required bool isPrint,
    required String? invCCode,
    String button = 'btnadd',
  }){
    //region 权限权限
    if (_dataService.isEnableOperatePrivilege && objectItem.buttons?[button] == null){
      return {false: '没有操作的权限${BaseService.profile.isSystem == true ? '【${objectItem.progid}】【${button}】' : ''}！'};
    }
    //endregion
    //region 提交前检查
    if (checkRecordModel.productDate == null){
      return {false: objectItem.progid == 811010 ? '请选择生产日期！' : '请选择上报日期！'};
    }
    if (FormUtil.isRequired(formJudgeTypeMap['DepId'])
        && (checkRecordModel.depId ?? '').isEmpty){
      return {false: '请选择车间！'};
    }
    if (FormUtil.isRequired(formJudgeTypeMap['TeamId'])
        && (checkRecordModel.teamId ?? '').isEmpty){
      return {false: '请选择班次！'};
    }
    if (FormUtil.isRequired(formJudgeTypeMap['wcId'])
        && (checkRecordModel.wcId ?? '').isEmpty){
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
        && (checkRecordModel.deviceId ?? '').isEmpty){
      return {false: '请选择设备！'};
    }
    if (FormUtil.isRequired(formJudgeTypeMap['EmpId'])
        && wcDataReportType != 2
        && (checkRecordModel.empId ?? '').isEmpty){
      return {false: objectItem.progid == 811010 ? '请选择生产人员！' : '请选择上报人员！'};
    }
    if (checkRecordType == AppConfig.serialNumberCheckRecord
        && (checkRecordModel.opId ?? '').isEmpty){
      return {false: '按序列号报次品时，必须要选中一道工序，请检查！'};
    }
    if (checkRecordType == AppConfig.serialNumberCheckRecord
        && (checkRecordModel.opId ?? '').contains(',')){
      return {false: '按序列号报次品时，单次只允许报一道工序，请检查！'};
    }
    if (FormUtil.isRequired(formJudgeTypeMap['OpId'])
        && (checkRecordModel.opId ?? '').isEmpty){
      return {false: '请选择工序！'};
    }
    if (checkRecordType == AppConfig.serialNumberCheckRecord
        && (checkRecordModel.serialNumber ?? '').isEmpty){
      return {false: '按序列号报次品时，必须要选中一条序列号，请检查！'};
    }
    if (checkRecordType == AppConfig.serialNumberCheckRecord
        && serialNumberCheckCodeList.isNotEmpty){
      String? snRes = checkRecordModel.serialNumber!.split(',').firstWhereOrNull((sn){
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
    if (FormUtil.isRequired(formJudgeTypeMap['ComDefects'])
        && (checkRecordModel.comDefects ?? '').isEmpty){
      return {false: objectItem.progid == 811010 ? '请选择次品原因！' : '请选择不良原因！'};
    }
    //endregion
    //region [numPadCTList] 填写项检查
    String qtyString = NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '';
    int? qty = int.tryParse(qtyString);
    if ((FormUtil.isRequired(formJudgeTypeMap['Qty']) && qty == null)
        || (FormUtil.isCannotBeNegativeNum(formJudgeTypeMap['Qty']) && qty! <= 0)
        || (FormUtil.isInteger(formJudgeTypeMap['Qty']) && qty != qty!.toInt())
        || (FormUtil.isCannotBeZero(formJudgeTypeMap['Qty']) && qty == 0)){
      return {false: objectItem.progid == 811010 ? '次品总数量输入有误，请重输！' : '不良总数量输入有误，请重输！'};
    }
    ///当产品序列号字段有数据时，次品总数量必须要等于产品序列号个数
    List<String> serialNumberList = (checkRecordModel.serialNumber ?? '').isEmpty
        ? []
        : checkRecordModel.serialNumber!.split(',').toList();
    if (serialNumberList.isNotEmpty && serialNumberList.length != qty){
      return {false: '序列号个数与次品总数量不符，请检查！'};
    }

    String weightString = NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '';
    double? weight = double.tryParse(weightString);
    if (checkRecordType == AppConfig.weightCheckRecord
        && (weight == null || weight <= 0)){
      return {false: '次品总重输入有误，请重输！'};
    }
    //endregion
    if (isPrint){
      String frxName = invClassFrxNameMap[invCCode ?? ''] ?? this.frxName;
      if (frxName.isEmpty){
        return {false: '打印的模板名称为空，请在设置中修改！'};
      }
      if ((checkRecordModel.serialNumber ?? '').isNotEmpty
          && checkRecordModel.serialNumber!.contains(',')){
        return {false: '不能同时选择多条序列号进行报次品并打印，请修改！'};
      }
      if ((checkRecordModel.opId ?? '').isNotEmpty
          && checkRecordModel.opId!.contains(',')){
        return {false: '不能同时选择多个工序进行报次品并打印，请修改！'};
      }
    }
    return {true: ''};
  }
  ///次品记录提交前检查（通用的）
  /// [True]：通过； [False]：不通过
  ///
  /// [button]：提交按钮的权限名称，默认：btnadd
  Map<bool, String> Function({
    required bool isPrint,
    required String? invCCode,
    String button,
  }) get checkRecordCheck => _checkRecordCheck;



  ///次品提交时的确认提示框
  Future<bool> _checkRecordSaveConfirmationDialog(bool isPrint) async {
    if (isShowCheckRecordConfirmationDialog){
      var dialogRes = await DialogUtils.showConfirmationDialog(
        Get.context!,
        msg: objectItem.progid == 811010
            ? '确认提交次品记录${isPrint ? '并打印' : ''}？'
            : '确认提交材料不良记录${isPrint ? '并打印' : ''}？',
        barrierDismissible: false,
      );
      if (dialogRes == null || !dialogRes){
        return false;
      }
    }
    return true;
  }
  ///次品提交时的确认提示框
  Future<bool> Function(bool isPrint) get checkRecordSaveConfirmationDialog => _checkRecordSaveConfirmationDialog;



  ///次品记录提交时赋值
  void _setCheckRecordDataBeforeSave() {
    checkRecordModel.recordDate = DateTime.now();
    checkRecordModel.createDate = DateTime.now();
    if (!isMakeUp && !(isProductDateChangedByNightTeam && isCRProductDateTakeFromYesterday)){
      checkRecordModel.productDate = DateTime.now();
    }
    double? qty = double.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '');
    checkRecordModel.disabledQty = qty;
    if (checkRecordType == AppConfig.weightCheckRecord){
      double? weight = double.tryParse(NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '')?.toPrecision(weightFormDecimalLengthMap[NumPadUtil.weight]!);
      checkRecordModel.disabledNum = weight;
    }
  }
  ///次品记录提交时赋值
  void Function() get setCheckRecordDataBeforeSave => _setCheckRecordDataBeforeSave;



  ///次品记录提交成功后，刷新数据填报区域的数据
  Future<void> _resetCheckRecordDataAfterSave() async {
    checkRecordModel.empId = null;
    checkRecordModel.emploee = null;
    personAdapter?.clearSelection();
    personList.clear();
    checkRecordModel.comDefects = null;
    comDefectAdapter?.clearSelection();
    checkRecordModel.disposeFlow = null;
    checkRecordModel.disabledQty = null;
    checkRecordModel.disabledNum = null;
    numPadCTList.forEach((element) {
      element.controller.clear();
    });
  }
  ///次品记录提交成功后，刷新数据填报区域的数据
  Future<void> Function() get resetCheckRecordDataAfterSave => _resetCheckRecordDataAfterSave;



  //region Widget

  ///报次品方式选择控件
  Widget operationWayWidget(BuildContext context, {
    String hintStr = '（请选择次品方式）',
  }){
    return MenuBar(
      children: [
        SubmenuButton(
          menuChildren: operationWayList.map((e) {
            return MenuItemButton(
              onPressed: () {
                checkRecordTypeOnChanged(e);
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
                operationWay?.title ?? hintStr,
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

  ///次品录入填单区域（包括数字键盘、提交按钮）
  Widget checkRecordAreaWidget(BuildContext context){
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
              ...checkRecordBtnWidget(context),
            ],
          ),
        )
      ],
    );
  }

  ///次品录入填单区域
  Widget dataReportAreaWidget(BuildContext context);

  //region dataReportItem

  Widget reportItem(BuildContext context, {
    required String title,
    required Widget customizeContent,
    bool needMargin = true,
    double width = 580,
    double titleWidth = 100,
  }) {
    return TitleTextBoxWidget(
      title: title,
      customizeContent: customizeContent,
      titleWidth: titleWidth,
      width: width,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
      margin: needMargin ? const EdgeInsets.only(bottom: 6) : null,
    );
  }

  Widget productDateReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.productDateForm]!,
      customizeContent: PrefixTextField(
        object: 1, readOnly: true,
        initText: DateUtil.formatDateTime(
            (checkRecordModel.productDate ?? '').toString(),
            DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE
        ),
        valueOnChanged: (String string) async{
          await productDateOnChanged(DateTime.tryParse(string));
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

  Widget comDefectReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.comDefectForm]!,
      customizeContent: PickerInputWidget(
        adapter: comDefectAdapter,
        maxLines: 2,
        pickerChoiceType: PickerChoiceType.chip,
        onTap: (List<PickerDataModel> selectList) {
          comDefectOnChangedByAdapter(selectList);
        },
      ),
    );
  }

  Widget numPadReportItem(BuildContext context, String numPadKey){
    return reportItem(
      context,
      title: formTitleMap[numPadKey]!,
      customizeContent: NumPadTextField(
        numPadController: NumPadUtil().getNumPadController(numPadKey, numPadCTList)!,
        hintText: numPadKey == NumPadUtil.weight
            ? '称总重前请先手动去皮重'
            : '',
        measurement: numPadKey == NumPadUtil.weight
            ? '(kg)'
            : '',
        onChanged: (String str){
          calcQty(numPadKey);
        },
      ),
    );
  }

  //endregion

  Widget numPadAreaWidget(BuildContext context){
    if (checkRecordType != AppConfig.serialNumberCheckRecord){
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
                      children: checkRecordInfoWidget(context, constraints),
                    ),
                  )
              );
            }
        ),
      );
    }
  }

  List<Widget> checkRecordInfoWidget(BuildContext context, BoxConstraints constraints){
    return [];
  }

  ///提交按钮组
  List<Widget> checkRecordBtnWidget(BuildContext context){
    List<Widget> widgetList = [];
    (objectItem.progid == 811010
        ? AppConfig.checkRecordBtnList
        : AppConfig.materialRejectBtnList).forEach((element) {
      if (checkRecordBtnIndex & element.sign == element.sign){
        widgetList.addAll([
          const SizedBox(height: 8,),
          FilledButton(
            onPressed: () async{
              if (element.sign == 1){
                await saveCheckRecord(false);
              }
              else if (element.sign == 2){
                await saveCheckRecord(true);
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

  Widget comDefectViewWidget(BuildContext context){
    return CardWidget(
      margin: EdgeInsets.zero,
      content: comDefectAdapter == null ?
      SpinKitCircle(
        color: Colors.grey,
        size: 28,
      ) :
      Padding(
        padding: const EdgeInsets.all(4),
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topLeft,
            child: comDefectAdapter == null ?
            const SizedBox.shrink() :
            Wrap(
              runSpacing: 6, spacing: 6,
              children: List.generate(comDefectAdapter!.dataList.length, (index) {
                PickerDataModel item = comDefectAdapter!.dataList[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async{
                      await comDefectOnChanged(item);
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 150, height: 60,
                      padding: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: item.isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        border: item.isSelected ? null : Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (item.isSelected)
                              Icon(
                                Icons.done,
                                size: Theme.of(context).textTheme.bodySmall!.fontSize! * 1.43,
                              ),
                            if (item.isSelected)
                              const SizedBox(width: 4,),
                            Text(
                              item.name.isNotEmpty ? item.name : ' ',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    )
                  )
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  //endregion

}