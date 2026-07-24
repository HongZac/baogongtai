import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/mes_submit_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_interface.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:get/get.dart';


///生产派工单报工接口 650041
mixin MesTaskSubmitInterface
on SubmitInterface, MesSubmitInterface {

  ///要报工的派工单 初始值：上一个页面选中的派工单
  MoTaskModel taskModel = MoTaskModel();

  TaskAdapter? taskAdapter;

  @override
  List<ChoiceChipModel> get operationWayList => List.unmodifiable(AppConfig.mesTaskSubmitOperationWayList);

  final WeightMsgConnectService _weightMsgConnectService = Get.find<WeightMsgConnectService>();
  ///称重监听列表
  @Deprecated('计划不再使用')
  late final List<WeightMsgConnectModel> connectList = _weightMsgConnectService.connectList.where(
          (element) => element.key == WeightMsgConnectService.dSWeight).toList();

  @override
  final Map<String, int?> formJudgeTypeMap = {
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
        'progId': 650011, ///生产
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
  Future<void> taskOnChanged(PickerDataModel model);
  ///弃用
  //Future<void> taskOnChanged(PickerDataModel model) async {
  //  MoTaskModel item = MoTaskModel.fromJson(model.toJson());
  //  if (taskModel.taskId == item.taskId){ return; }
  //  taskModel = item;
  //  await _setSubmitDataAndAdapter(
  //    isInit: false,
  //  );
  //  await getInventoryInfo(taskModel.invId ?? '');
  //  update();
  //}

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



  ///报工数据赋值（第一次进入报工页面时 OR 派工单改变时）
  ///
  /// [deviceId]、[deviceCode]、[deviceName]：设备对应生产派工单报工时的设备数据（部分派工单可能未指定设备）
  Future<void> _setSubmitDataAndAdapter({
    required bool isInit,
    int? progId,
    String? deviceId,
    String? deviceCode,
    String? deviceName,
    required bool isNeedSetSingleBoxQty,
  }) async {
    assert((isInit && progId != null) || (!isInit));
    submitModel.moOrderId = taskModel.moOrderId;
    submitModel.taskId = taskModel.taskId;
    submitModel.invId = taskModel.invId;
    submitModel.mouldId = taskModel.mouldId;
    submitModel.mtoNo = taskModel.mtoNo;
    submitModel.mtoSeq = taskModel.mtoSeq;
    submitModel.soCode = taskModel.soCode;
    submitModel.batch = taskModel.batch;
    submitModel.deviceId = deviceId;
    submitModel.deviceCode = deviceCode;
    submitModel.deviceName = deviceName;
    submitModel.opId = taskModel.opId;
    submitModel.opName = taskModel.opName;
    submitModel.workBillEntryId = taskModel.moOpId;
    submitModel.inspectFlag = inspectFlagDefaultValue != null
        ? inspectFlagDefaultValue!
        ? 1
        : 0
        : taskModel.inspectFlag;
    submitModel.comUnitName = taskModel.comUnitName;
    submitModel.pieceRate = taskModel.pieceRate;
    if (isNeedSetSingleBoxQty
        && (taskModel.packingQty ?? 0) > 0
        && double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') != taskModel.packingQty){
      NumPadUtil().setText(NumPadUtil.singleBoxQty, (taskModel.packingQty ?? 0).toStringAsFixed(0), numPadCTList);
      calcQty(NumPadUtil.singleBoxQty);
    }
    submitModel.serialNumber = null;
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
      submitModel.deviceId = deviceId ?? taskModel.deviceId;
      submitModel.deviceCode = deviceCode ?? taskModel.deviceCode;
      submitModel.deviceName = deviceName ?? taskModel.deviceName;
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
      if (isDeviceHasAdapter){
        getEAMDeviceAdapter().then((value) {
          update();
        });
      }
      else {
        deviceModel = EAMDeviceModel(
          deviceId: submitModel.deviceId,
          depCode: submitModel.depCode,
          depName: submitModel.depName,
        );
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
      getOrderSNAdapter().then((value) {
        update();
      });
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
      if ((submitModel.deviceId ?? '').isEmpty){
        submitModel.deviceId = taskModel.deviceId;
        submitModel.deviceCode = taskModel.deviceCode;
        submitModel.deviceName = taskModel.deviceName;
        if (isDeviceHasAdapter) {
          await deviceAdapter?.validModelValue(submitModel.deviceId);
        }
        else {
          deviceModel = EAMDeviceModel(
            deviceId: submitModel.deviceId,
            depCode: submitModel.depCode,
            depName: submitModel.depName,
          );
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
      await getOrderSNAdapter();
      await getIsFirstInspectionPassed(preType: 'TaskId', preId: submitModel.taskId!);
    }
  }
  ///报工数据赋值（第一次进入报工页面时 OR 派工单改变时）
  Future<void> Function({
    required bool isInit,
    int? progId,
    String? deviceId,
    String? deviceCode,
    String? deviceName,
    required bool isNeedSetSingleBoxQty,
  }) get setSubmitDataAndAdapter => _setSubmitDataAndAdapter;



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
    bool needCheckOp = true,
    bool needCheckSN = true,
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



  ///报工提交成功后，刷新报工填报区域的数据
  Future<void> _resetSubmitDataAfterSave({bool byAutoSubmit = false}) async {
    await super.resetSubmitDataAfterSave();
    submitModel.serialNumber = null;
    orderSNAdapter?.clearSelection();
    serialNumberBarcodeMap.clear();
  }
  Future<void> Function({bool byAutoSubmit}) get resetSubmitDataAfterSave => _resetSubmitDataAfterSave;


}