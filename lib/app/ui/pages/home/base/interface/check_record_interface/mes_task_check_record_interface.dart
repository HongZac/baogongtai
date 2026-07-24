import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/service.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/mes_check_record_interface.dart';
import 'package:desktop/app/utils/app_config.dart';


///生产派工单次品录入接口 811010
mixin MesTaskCheckRecordInterface
on CheckRecordInterface, MesCheckRecordInterface {

  ///要报工的派工单 初始值：上一个页面选中的派工单
  MoTaskModel taskModel = MoTaskModel();

  TaskAdapter? taskAdapter;

  @override
  List<ChoiceChipModel> get operationWayList => List.unmodifiable(AppConfig.mesTaskCROperationWayList);

  @override
  final Map<String, int?> formJudgeTypeMap = {
    'DepId': 4,
    'TeamId': 4,
    'wcId': null,
    'DeviceId': null,
    'EmpId': 4,
    'ComDefects': 4,
    'Qty': 116,
  };



  //region getAdapter

  ///获取派工单Adapter
  Future<void> _getTaskAdapter({String? deviceId}) async {
    taskAdapter = await AdapterHelper.getAsyncAdapter(
      'task',
      progid: 651011,
      isNeedLoadData: false,
      selectedItems: [PickerDataModel(id: checkRecordModel.taskId)],
      queryData: {
        'progId': 650011, ///生产
        'DeviceId': deviceId ?? checkRecordModel.deviceId,
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
    await setCheckRecordDataAndAdapter(
      isInit: false,
    );
    await getInventoryInfo(taskModel.invId ?? '');
    update();
  }

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



  ///次品数据赋值（第一次进入报次品页面时 OR 派工单改变时）
  Future<void> _setCheckRecordDataAndAdapter({
    required bool isInit,
    int? progId,
    String? workCenterId,
    String? deviceId,
    String? deviceCode,
    String? deviceName,
  }) async {
    assert((isInit && progId != null) || (!isInit));
    checkRecordModel.moOrderId = taskModel.moOrderId;
    checkRecordModel.taskId = taskModel.taskId;
    checkRecordModel.invId = taskModel.invId;
    checkRecordModel.mouldId = taskModel.mouldId;
    checkRecordModel.mtoNo = taskModel.mtoNo;
    checkRecordModel.mtoSeq = taskModel.mtoSeq;
    checkRecordModel.soCode = taskModel.soCode;
    checkRecordModel.batch = taskModel.batch;
    checkRecordModel.deviceId = deviceId;
    checkRecordModel.deviceCode = deviceCode;
    checkRecordModel.deviceName = deviceName;
    checkRecordModel.opId = taskModel.opId;
    checkRecordModel.opName = taskModel.opName;
    checkRecordModel.workBillEntryId = taskModel.moOpId;
    checkRecordModel.comUnitName = taskModel.comUnitName;
    if (isInit){
      checkRecordModel.progID = progId!;
      checkRecordModel.sign = 0;
      checkRecordModel.status = '';
      checkRecordModel.serviceSign = 1;
      productDate = DateTime.now();
      checkRecordModel.productDate = DateTime.now();
      checkRecordModel.depId = getDepIdByDepGetWayIndex();
      checkRecordModel.depCode = getDepCodeByDepGetWayIndex();
      checkRecordModel.deviceId = deviceId ?? taskModel.deviceId;
      checkRecordModel.deviceCode = deviceCode ?? taskModel.deviceCode;
      checkRecordModel.deviceName = deviceName ?? taskModel.deviceName;
      checkRecordModel.empId = taskModel.emploeeId;
      checkRecordModel.emploee = taskModel.personName;
      checkRecordModel.wcId = taskModel.wcId;
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
          deviceId: checkRecordModel.deviceId,
          depCode: checkRecordModel.depCode,
          depName: checkRecordModel.depName,
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
      getREProcessAdapter(wbId: taskModel.wbId, invId: taskModel.invId).then((value) {
        update();
      });
      getComDefectAdapter(invCCode: taskModel.invCCode).then((value) {
        update();
      });
      //endregion
    }
    else {
      if ((checkRecordModel.depId ?? '').isEmpty){
        checkRecordModel.depId = getDepIdByDepGetWayIndex();
        checkRecordModel.depCode = getDepCodeByDepGetWayIndex();
        await depAdapter?.validModelValue(checkRecordModel.depId);
        await getTeamAdapter();
        await getTeam();
        if (psnGetWayIndex == 1 && isPsnHasAdapter){
          checkRecordModel.empId = null;
          checkRecordModel.emploee = null;
          await getPersonAdapter();
        }
      }
      if ((checkRecordModel.wcId ?? '').isEmpty){
        checkRecordModel.wcId = taskModel.wcId;
        switch (wcDataReportType){
          //region
          case 0: ///产线
            await lineAdapter?.validModelValue(checkRecordModel.wcId);
            ///部分源单没有产线 Code，这里通过选单数据源获取
            List<MoBeltLineModel> selectedList = lineAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
            checkRecordModel.lineCode = selectedList.map((e) => e.code).join(',');
            checkRecordModel.lineName = selectedList.map((e) => e.name).join(',');
            break;
          case 1: ///加工中心
            await workCenterAdapter?.validModelValue(checkRecordModel.wcId);
            ///部分源单没有产线 Code，这里通过选单数据源获取
            List<MoWorkCenterModel> selectedList = workCenterAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
            checkRecordModel.lineCode = selectedList.map((e) => e.code).join(',');
            checkRecordModel.lineName = selectedList.map((e) => e.name).join(',');
            break;
          case 2: ///生产班组
            await teamGroupAdapter?.validModelValue(checkRecordModel.wcId);
            ///部分源单没有产线 Code，这里通过选单数据源获取
            List<MoBeltLineModel> selectedList = teamGroupAdapter?.dataList.where((element) => element.isSelected).toList() ?? [];
            checkRecordModel.lineCode = selectedList.map((e) => e.code).join(',');
            checkRecordModel.lineName = selectedList.map((e) => e.name).join(',');
            break;
          //endregion
        }
        if (psnGetWayIndex == 3 && wcDataReportType != 2 && isPsnHasAdapter){
          checkRecordModel.empId = null;
          checkRecordModel.emploee = null;
          await getPersonAdapter();
        }
      }
      if ((checkRecordModel.deviceId ?? '').isEmpty){
        checkRecordModel.deviceId = taskModel.deviceId;
        checkRecordModel.deviceCode = taskModel.deviceCode;
        checkRecordModel.deviceName = taskModel.deviceName;
        if (isDeviceHasAdapter) {
          await deviceAdapter?.validModelValue(checkRecordModel.deviceId);
        }
        else {
          deviceModel = EAMDeviceModel(
            deviceId: checkRecordModel.deviceId,
            depCode: checkRecordModel.depCode,
            depName: checkRecordModel.depName,
          );
        }
      }
      if ((checkRecordModel.empId ?? '').isEmpty){
        checkRecordModel.empId = taskModel.emploeeId;
        checkRecordModel.emploee = taskModel.personName;
        await personAdapter?.validModelValue(checkRecordModel.empId);
      }
      await getREProcessAdapter(wbId: taskModel.wbId, invId: taskModel.invId);
      if (comDefectAdapter == null
          || !comDefectAdapter!.itemCode.contains('.${taskModel.invCCode}')){
        checkRecordModel.comDefects = null;
        await getComDefectAdapter(invCCode: taskModel.invCCode);
      }
    }
  }
  ///次品数据赋值（第一次进入报次品页面时 OR 派工单改变时）
  Future<void> Function({
    required bool isInit,
    int? progId,
    String? workCenterId,
    String? deviceId,
    String? deviceCode,
    String? deviceName,
  }) get setCheckRecordDataAndAdapter => _setCheckRecordDataAndAdapter;



  ///报工提交前检查（生产派工单）
  /// [True]：通过； [False]：不通过
  ///
  /// [button]：提交按钮的权限名称，默认：btnadd
  Map<bool, String> _checkRecordCheck({
    required bool isPrint,
    required String? invCCode,
    String button = 'btnadd',
  }){
    Map<bool, String> res = super.checkRecordCheck(
      isPrint: isPrint,
      invCCode: invCCode,
      button: button,
    );
    if (res.containsKey(false)){
      return res;
    }
    if ((checkRecordModel.taskId ?? '').isEmpty){
      return {false: '派工单数据错误！'};
    }
    return {true: ''};
  }
  Map<bool, String> Function({
    required bool isPrint,
    required String? invCCode,
    String button,
  }) get checkRecordCheck => _checkRecordCheck;


}