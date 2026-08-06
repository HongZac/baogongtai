
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/service/data_service.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_interface.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///注塑派工单的报工接口 651051
mixin PMesTaskSubmitInterface on SubmitInterface {

  final _dataService = Get.find<DataService>();

  ///要报工的派工单单数据（初始值：上一个页面选中的派工单）
  MoTaskModel taskModel = MoTaskModel();

  TaskAdapter? taskAdapter;

  @override
  List<ChoiceChipModel> get operationWayList => List.unmodifiable(AppConfig.pMesTaskSubmitOperationWayList);

  final WeightMsgConnectService _weightMsgConnectService = Get.find<WeightMsgConnectService>();
  ///称重监听列表
  late final List<WeightMsgConnectModel> connectList = _weightMsgConnectService.connectList.where(
          (element) => true).toList();

  ///显示“获取实际单重”按钮
  bool isShowGetPieceWeightBtn = AppConfig.isShowGetPieceWeightBtn;

  ///按数量报工时，是否需要产品重量检验
  bool qtyIsNeedPieceWeight = AppConfig.isNeedPieceWeight;
  ///按数量报工时，如果没有实际单重数据，是否可以根据标准单重计算总重
  bool qtyCanWeightCalcByStandWeight = AppConfig.canWeightCalcByStandWeight;

  ///按数量（多箱）报工时，是否需要产品重量检验
  bool qtyBoxIsNeedPieceWeight = AppConfig.isNeedPieceWeight;
  ///按数量（多箱）报工时，如果没有实际单重数据，是否可以根据标准单重计算总重
  bool qtyBoxCanWeightCalcByStandWeight = AppConfig.canWeightCalcByStandWeight;

  ///按托报工时，是否需要产品重量检验
  bool palletIsNeedPieceWeight = AppConfig.isNeedPieceWeight;
  ///按托报工时，如果没有实际单重数据，是否可以根据标准单重计算总重
  bool palletCanWeightCalcByStandWeight = AppConfig.canWeightCalcByStandWeight;

  ///按重量报工时，是否需要产品重量检验
  bool weightIsNeedPieceWeight = AppConfig.isNeedPieceWeight;

  ///按重量（多箱）报工时，是否需要产品重量检验
  bool weightBoxIsNeedPieceWeight = AppConfig.isNeedPieceWeight;


  @override
  late final Map<String, int?> formJudgeTypeMap = {
    'local-${NumPadUtil.eBWeight}': (submitType == AppConfig.qtySubmit && qtyIsNeedPieceWeight)
        || (submitType == AppConfig.qtyBoxSubmit && qtyBoxIsNeedPieceWeight)
        || (submitType == AppConfig.palletSubmit && palletIsNeedPieceWeight)
        || (submitType == AppConfig.weightSubmit && weightIsNeedPieceWeight)
        || (submitType == AppConfig.weightBoxSubmit && weightBoxIsNeedPieceWeight) ? 4 : null,
    'local-${NumPadUtil.eBPiece}': (submitType == AppConfig.qtySubmit && qtyIsNeedPieceWeight)
        || (submitType == AppConfig.qtyBoxSubmit && qtyBoxIsNeedPieceWeight)
        || (submitType == AppConfig.palletSubmit && palletIsNeedPieceWeight)
        || (submitType == AppConfig.weightSubmit && weightIsNeedPieceWeight)
        || (submitType == AppConfig.weightBoxSubmit && weightBoxIsNeedPieceWeight) ? 4 : null,
    'local-${NumPadUtil.pieceWeight}': (submitType == AppConfig.qtySubmit && qtyIsNeedPieceWeight)
        || (submitType == AppConfig.qtyBoxSubmit && qtyBoxIsNeedPieceWeight)
        || (submitType == AppConfig.palletSubmit && palletIsNeedPieceWeight)
        || (submitType == AppConfig.weightSubmit && weightIsNeedPieceWeight)
        || (submitType == AppConfig.weightBoxSubmit && weightBoxIsNeedPieceWeight) ? 4 : null,
    'DepId': 4,
    'TeamId': 4,
    'wcId': null,
    'DeviceId': null,
    'EmpId': 4,
    'Qty': 116,
  };



  //region getAdapter

  ///获取派工单Adapter
  Future<void> _getTaskAdapter({String? deviceId}) async {
    taskAdapter = await AdapterHelper.getAsyncAdapter(
      'task',
      progid: 651011,
      isNeedLoadData: false,
      selectedItems: [PickerDataModel(id: submitModel.taskId)],
      queryData: {
        'progId': 651011, ///注塑
        'DeviceId': deviceId ?? submitModel.deviceId,
        'ExtOpFlag': 0, ///ExtOpFlag=0 去除委外工序
      },
    ) as TaskAdapter;
  }
  ///获取派工单Adapter
  Future<void> Function({String? deviceId}) get getTaskAdapter => _getTaskAdapter;

  //endregion



  //region OnChanged

  ///派工单 Adapter 选择变化
  Future<void> taskOnChanged(PickerDataModel model) async {
    MoTaskModel item = MoTaskModel.fromJson(model.toJson());
    if (taskModel.taskId == item.taskId){ return; }
    taskModel = item;
    await _setSubmitDataAndAdapter(
      isInit: false,
    );
    await getInventoryInfo(taskModel.invId ?? '');
    update();
  }

  ///“获取实际单重”按钮点击回调（只有报工时可以点击）（获取模具产品关系中的单重）
  void _getPieceWeightBtnOnTap() {
    if ((submitType == AppConfig.qtySubmit && qtyIsNeedPieceWeight)
        || (submitType == AppConfig.qtyBoxSubmit && qtyBoxIsNeedPieceWeight)
        || (submitType == AppConfig.weightSubmit && weightIsNeedPieceWeight)
        || (submitType == AppConfig.weightBoxSubmit && weightBoxIsNeedPieceWeight)
        || (submitType == AppConfig.palletSubmit && palletIsNeedPieceWeight)){
      if (taskModel.weight == null || taskModel.weight! < 0){
        ToastNotification(Get.overlayContext!).error("未查询到实际单重！");
        return;
      }
      NumPadUtil().setText(NumPadUtil.eBWeight, taskModel.weight!.toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.eBWeight]!), numPadCTList);
      NumPadUtil().setText(NumPadUtil.eBPiece, '1', numPadCTList);
      NumPadUtil().setText(NumPadUtil.pieceWeight, taskModel.weight!.toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.pieceWeight]!), numPadCTList);
      isWeightError = ((inventoryModel.invWeight ?? 0) / (taskModel.weight ?? 0) - 1).abs() > (limitWeightDeviationValue / 100);
      calcQty(NumPadUtil.eBWeight);
      update();
    }
  }
  ///“获取实际单重”按钮点击回调（只有报工时可以点击）（获取模具产品关系中的单重）
  void Function() get getPieceWeightBtnOnTap => _getPieceWeightBtnOnTap;

  //endregion



  @override
  String? getDepIdByDepGetWayIndex(){
    switch (depGetWayIndex){
      case 0:
        return taskModel.depId;
      case 1:
        return BaseService.profile.departmentId;
      default:
        return '';
    }
  }
  @override
  String? getDepCodeByDepGetWayIndex() {
    switch (depGetWayIndex){
      case 0:
        return taskModel.depCode;
      case 1:
        return BaseService.profile.depCode;
      default:
        return '';
    }
  }



  void _updateFormJudgeTypeMap() {
    formJudgeTypeMap.addAll({
      'local-${NumPadUtil.eBWeight}': (submitType == AppConfig.qtySubmit && qtyIsNeedPieceWeight)
          || (submitType == AppConfig.qtyBoxSubmit && qtyBoxIsNeedPieceWeight)
          || (submitType == AppConfig.palletSubmit && palletIsNeedPieceWeight)
          || (submitType == AppConfig.weightSubmit && weightIsNeedPieceWeight)
          || (submitType == AppConfig.weightBoxSubmit && weightBoxIsNeedPieceWeight) ? 4 : null,
      'local-${NumPadUtil.eBPiece}': (submitType == AppConfig.qtySubmit && qtyIsNeedPieceWeight)
          || (submitType == AppConfig.qtyBoxSubmit && qtyBoxIsNeedPieceWeight)
          || (submitType == AppConfig.palletSubmit && palletIsNeedPieceWeight)
          || (submitType == AppConfig.weightSubmit && weightIsNeedPieceWeight)
          || (submitType == AppConfig.weightBoxSubmit && weightBoxIsNeedPieceWeight) ? 4 : null,
      'local-${NumPadUtil.pieceWeight}': (submitType == AppConfig.qtySubmit && qtyIsNeedPieceWeight)
          || (submitType == AppConfig.qtyBoxSubmit && qtyBoxIsNeedPieceWeight)
          || (submitType == AppConfig.palletSubmit && palletIsNeedPieceWeight)
          || (submitType == AppConfig.weightSubmit && weightIsNeedPieceWeight)
          || (submitType == AppConfig.weightBoxSubmit && weightBoxIsNeedPieceWeight) ? 4 : null,
    });
  }
  void Function() get updateFormJudgeTypeMap => _updateFormJudgeTypeMap;



  ///报工数据赋值（第一次进入报工页面时 OR 派工单改变时）
  Future<void> _setSubmitDataAndAdapter({
    required bool isInit,
    int? progId,
  }) async {
    assert((isInit && progId != null) || (!isInit));
    submitModel.moOrderId = taskModel.moOrderId;
    submitModel.taskId = taskModel.taskId;
    submitModel.invId = taskModel.invId;
    submitModel.mouldId = taskModel.mouldId;
    submitModel.deviceId = taskModel.deviceId;
    submitModel.deviceCode = taskModel.deviceCode;
    submitModel.deviceName = taskModel.deviceName;
    submitModel.mtoNo = taskModel.mtoNo;
    submitModel.mtoSeq = taskModel.mtoSeq;
    submitModel.soCode = taskModel.soCode;
    submitModel.batch = taskModel.batch;
    submitModel.inspectFlag = inspectFlagDefaultValue != null
        ? inspectFlagDefaultValue!
        ? 1
        : 0
        : taskModel.inspectFlag;
    submitModel.comUnitName = taskModel.comUnitName;
    submitModel.pieceRate = taskModel.pieceRate;
    if ((taskModel.packingQty ?? 0) > 0
        && double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') != taskModel.packingQty){
      NumPadUtil().setText(NumPadUtil.singleBoxQty, (taskModel.packingQty ?? 0).toStringAsFixed(0), numPadCTList);
      calcQty(NumPadUtil.singleBoxQty);
    }
    if (isInit){
      submitModel.progid = progId;
      submitModel.sign = MoOpSubmitSign.td.sign;
      submitModel.status = '';
      submitModel.enableMark = 1;
      submitModel.deleteMark = 0;
      billDate = DateTime.now();
      submitModel.billDate = DateTime.now();
      submitModel.depId = getDepIdByDepGetWayIndex();
      submitModel.depCode = getDepCodeByDepGetWayIndex();
      submitModel.empId = taskModel.emploeeId;
      submitModel.emploee = taskModel.personName;
      submitModel.wcId = taskModel.wcId;
      //region getAdapter
      ///获取员工选单数据源可能需要用到 lineCode，该值是通过产线数据源获取的
      switch (wcDataReportType){
        //region
        case 0: ///产线
          await getLineAdapter();
          break;
        case 1: ///加工中心
          await getWorkCenterAdapter();
          break;
        case 2: ///生产班组
          await getTeamGroupAdapter();
          break;
        //endregion
      }
      if (isPsnHasAdapter){
        getPersonAdapter().then((value) {
          update();
        });
      }
      else {
        personList.clear();
      }
      getDepAdapter().then((value) {
        update();
      });
      getTeamAdapter().then((value) async {
        await getTeam();
        update();
      });
      if (isUsePackingPicker){
        getContainerWithNoPageAdapter().then((value) async {
          await geDefaultContainer();
          update();
        });
      }
      //endregion
      getIsFirstInspectionPassed(preType: 'TaskId', preId: submitModel.taskId!).then((value) {
        update();
      });
    }
    else {
      if ((submitModel.depId ?? '').isEmpty){
        submitModel.depId = getDepIdByDepGetWayIndex();
        submitModel.depCode = getDepCodeByDepGetWayIndex();
        await depAdapter?.validModelValue(submitModel.depId);
        await getTeamAdapter();
        await getTeam();
        if (psnGetWayIndex == 1 && isPsnHasAdapter){
          submitModel.empId = null;
          submitModel.emploee = null;
          await getPersonAdapter();
        }
      }
      if ((submitModel.wcId ?? '').isEmpty){
        submitModel.wcId = taskModel.wcId;
        switch (wcDataReportType){
          //region
          case 0: ///产线
            await lineAdapter?.validModelValue(submitModel.wcId);
            ///部分源单没有产线 Code，这里通过选单数据源获取
            List<MoBeltLineModel> selectedList = lineAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
            submitModel.lineCode = selectedList.map((e) => e.code).join(',');
            submitModel.lineName = selectedList.map((e) => e.name).join(',');
            break;
          case 1: ///加工中心
            await workCenterAdapter?.validModelValue(submitModel.wcId);
            ///部分源单没有产线 Code，这里通过选单数据源获取
            List<MoWorkCenterModel> selectedList = workCenterAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
            submitModel.lineCode = selectedList.map((e) => e.code).join(',');
            submitModel.lineName = selectedList.map((e) => e.name).join(',');
            break;
          case 2: ///生产班组
            await teamGroupAdapter?.validModelValue(submitModel.wcId);
            ///部分源单没有产线 Code，这里通过选单数据源获取
            List<MoBeltLineModel> selectedList = teamGroupAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
            submitModel.lineCode = selectedList.map((e) => e.code).join(',');
            submitModel.lineName = selectedList.map((e) => e.name).join(',');
            break;
          //endregion
        }
        if (psnGetWayIndex == 3 && wcDataReportType != 2 && isPsnHasAdapter){
          submitModel.empId = null;
          submitModel.emploee = null;
          await getPersonAdapter();
        }
      }
      if ((submitModel.empId ?? '').isEmpty){
        submitModel.empId = taskModel.emploeeId;
        submitModel.emploee = taskModel.personName;
        await personAdapter?.validModelValue(submitModel.empId);
      }
      if (isUsePackingPicker){
        NumPadUtil().setText(NumPadUtil.packingWeight, '', numPadCTList);
        calcQty(NumPadUtil.packingWeight);
        await getContainerWithNoPageAdapter();
        await geDefaultContainer();
      }
      await getIsFirstInspectionPassed(preType: 'TaskId', preId: submitModel.taskId!);
    }
  }
  ///报工数据赋值（第一次进入报工页面时 OR 派工单改变时）
  Future<void> Function({
    required bool isInit,
    int? progId,
  }) get setSubmitDataAndAdapter => _setSubmitDataAndAdapter;



  ///实际单重数据提交前检查
  /// [True]：通过； [False]：不通过
  Map<bool, String> _weightSaveCheck(){
    //region 权限权限
    if (_dataService.isEnableOperatePrivilege && objectItem.buttons?['btnupdateweight'] == null){
      return {false: '没有操作的权限${BaseService.profile.isSystem == true ? '【${objectItem.progid}】【btnupdateweight】' : ''}！'};
    }
    //endregion
    //region 提交前检查
    if (taskModel.taskId.isEmpty){
      return {false: '派工单为空，不能提交！'};
    }
    if (taskModel.mouldId == null || taskModel.mouldId!.isEmpty){
      return {false: '派工单的模具为空，不能提交！'};
    }
    if (taskModel.invId == null || taskModel.invId!.isEmpty){
      return {false: '派工单的产品为空，不能提交！'};
    }
    String _eBWeightString = NumPadUtil().getText(NumPadUtil.eBWeight, numPadCTList) ?? '';
    double? _eBWeight = double.tryParse(_eBWeightString);
    if (_eBWeight == null || _eBWeight <= 0){
      return {false: '称重重量输入有误，请重输！'};
    }
    String _eBPieceString = NumPadUtil().getText(NumPadUtil.eBPiece, numPadCTList) ?? '';
    int? _eBPiece = int.tryParse(_eBPieceString);
    if (_eBPiece == null || _eBPiece < 1){
      return {false: '称重数量输入有误，请重输！'};
    }
    String _pieceWeightString = NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '';
    double? _pieceWeight = double.tryParse(_pieceWeightString);
    if (_pieceWeight == null || _pieceWeight <= 0){
      return {false: '实际单重不正确，请重输！'};
    }
    //endregion
    return {true: ''};
  }
  ///实际单重数据提交前检查
  /// [True]：通过； [False]：不通过
  Map<bool, String> Function() get weightSaveCheck => _weightSaveCheck;



  ///报工提交前检查（生产任务单）
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
    bool needCheckOp = false,
    bool needCheckSN = false,
  }){
    Map<bool, String> res = super.submitCheck(
      isPrint: isPrint,
      invCCode: invCCode,
      button: button,
      needCheckQty: needCheckQty,
      needCheckOp: needCheckOp,
      needCheckSN: needCheckSN,
    );
    if (res.containsKey(false)){
      return res;
    }
    if ((submitModel.taskId ?? '').isEmpty){
      return {false: '派工单数据错误！'};
    }
    if (cannotSubmitWhenNotInProduction
        && ((taskModel.sign ?? 0) < MoTaskSign.scz.sign || (taskModel.sign ?? 0) >= MoTaskSign.ysc.sign)){
      return {false: '该派工单未在生产中，不能报工！'};
    }
    return {true: ''};
  }
  Map<bool, String> Function({
    required bool isPrint,
    required String? invCCode,
    String button,
    bool needCheckQty,
    bool needCheckOp,
    bool needCheckSN,
  }) get submitCheck => _submitCheck;



  //region Weight

  @override
  List<Widget> submitBtnWidget(BuildContext context){
    if (submitType == AppConfig.weight){
      return [
        FilledButton(
          onPressed: () async{
            await weightOnSave();
          },
          style: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.only()),
            minimumSize: WidgetStateProperty.all(
                kIsWeb || GetPlatform.isWindows
                    ? const Size(310, 72)
                    : const Size(310, 60)
            ),
          ),
          child: Text(
            '单重提交',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
          ),
        ),
      ];
    }
    return super.submitBtnWidget(context);
  }

  Widget pieceWeightBtn(BuildContext context){
    return TextButton(
      onPressed: () async{
        _getPieceWeightBtnOnTap();
      },
      style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(150, 50))
      ),
      child: Text(
        '获取实际单重数据',
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  //endregion

}
