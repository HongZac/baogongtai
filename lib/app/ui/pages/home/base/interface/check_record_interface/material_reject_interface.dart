import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_interface.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';

///不良品上报接口 811013
///
///不需要选：设备、产线、模具、工序、处理方式。。。
mixin MaterialRejectInterface on CheckRecordInterface {

  List<ChoiceChipModel> get disposeFlowList => List.unmodifiable([]);

  @override
  List<ChoiceChipModel> get operationWayList => List.unmodifiable(AppConfig.mesTaskMROperationWayList);

  @override
  final Map<String, int?> formJudgeTypeMap = {
    'DepId': 4,
    'TeamId': 4,
    'EmpId': 4,
    'ComDefects': 4,
    'Qty': 116,
  };


  MoOpOrderModel? get mROrderModel => null;
  MoTaskModel? get mRTaskModel => null;

  ///物料清单明细（材料明细） Adapter
  MoBomEntryAdapter? bomEntryAdapter;

  String? invCCodeByBomEntry;



  //region getAdapter

  ///获取物料清单明细 Adapter
  ///
  /// [invId]：派工单 OR 任务单 的产品ID
  Future<void> _getBomEntryAdapter(String invId) async {
    if (invId.isNotEmpty) {
      bomEntryAdapter = await AdapterHelper.getAsyncAdapter(
        'bomEntry',
        selectedItems: [PickerDataModel(id: checkRecordModel.invId)],
        queryData: {
          'ProductId': invId,
        },
      ) as MoBomEntryAdapter;
    }
    else {
      bomEntryAdapter = null;
    }
  }
  ///获取物料清单明细 Adapter
  Future<void> Function(String invId) get getBomEntryAdapter => _getBomEntryAdapter;

  //endregion



  //region OnChanged

  ///物料清单明细选择变化
  void _bomEntryOnChanged(PickerDataModel model) {
    MoBomEntryModel item = MoBomEntryModel.fromJson(model.toJson());
    if (checkRecordModel.invId == item.invId){ return; }
    checkRecordModel.invId = item.invId;
    //todo 产品类别编码
    //invCCodeByBomEntry = item.invCCode;
    update();
  }
  ///物料清单明细选择变化
  void Function(PickerDataModel model) get bomEntryOnChanged => _bomEntryOnChanged;

  //endregion



  ///不良品上报数据赋值（第一次进入不良品上报页面时 OR 派工单改变时）
  ///
  ///此时，父类的[setCheckRecordDataAndAdapter]需要重写，执行该函数
  Future<void> _setMaterialRejectDataAndAdapter({
    required bool isInit,
    int? progId,
  }) async {
    assert((isInit && progId != null) || (!isInit));
    checkRecordModel.moOrderId = mROrderModel?.moOrderId ?? mRTaskModel?.moOrderId;
    checkRecordModel.taskId = mRTaskModel?.taskId;
    checkRecordModel.mtoNo = mROrderModel?.mtoNo ?? mRTaskModel?.mtoNo;
    checkRecordModel.mtoSeq = mROrderModel?.mtoSeq ?? mRTaskModel?.mtoSeq;
    checkRecordModel.soCode = mROrderModel?.soCode ?? mRTaskModel?.soCode;
    checkRecordModel.batch = mROrderModel?.batch ?? mRTaskModel?.batch;
    checkRecordModel.comUnitName = mROrderModel?.comUnitName ?? mRTaskModel?.comUnitName;
    if (isInit) {
      checkRecordModel.progID = progId!;
      checkRecordModel.sign = 0;
      checkRecordModel.status = '';
      checkRecordModel.serviceSign = 1;
      productDate = DateTime.now();
      checkRecordModel.productDate = DateTime.now();
      checkRecordModel.depId = getDepIdByDepGetWayIndex();
      checkRecordModel.depCode = getDepCodeByDepGetWayIndex();
      checkRecordModel.empId = mRTaskModel?.emploeeId;
      checkRecordModel.emploee = mRTaskModel?.personName;
      //region getAdapter
      if (isPsnHasAdapter){
        getPersonAdapter(
          sourceLineCode: mROrderModel?.lineCode ?? mRTaskModel?.lineCode
        ).then((value) {
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
      //todo
      getComDefectAdapter(invCCode: invCCodeByBomEntry).then((value) {
        update();
      });
      getBomEntryAdapter(mROrderModel?.productId ?? mRTaskModel?.invId ?? '').then((value) {
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
          await getPersonAdapter(
            sourceLineCode: mROrderModel?.lineCode ?? mRTaskModel?.lineCode
          );
        }
      }
      if ((checkRecordModel.empId ?? '').isEmpty){
        checkRecordModel.empId = mRTaskModel?.emploeeId;
        checkRecordModel.emploee = mRTaskModel?.personName;
        await personAdapter?.validModelValue(checkRecordModel.empId);
      }
      if (comDefectAdapter == null
          || !comDefectAdapter!.itemCode.contains('.${mROrderModel?.invCCode ?? mRTaskModel?.invCCode}')){
        checkRecordModel.comDefects = null;
        //todo
        //await getComDefectAdapter(invCCode: invCCodeByBomEntry);
      }

      checkRecordModel.invId = null;
      invCCodeByBomEntry = null;
      await getBomEntryAdapter(mROrderModel?.productId ?? mRTaskModel?.invId ?? '');
    }
  }
  ///不良品上报数据赋值（第一次进入不良品上报页面时 OR 派工单改变时）
  ///
  ///此时，父类的[setCheckRecordDataAndAdapter]需要重写，执行该函数
  Future<void> Function({
    required bool isInit,
    int? progId,
  }) get setMaterialRejectDataAndAdapter => _setMaterialRejectDataAndAdapter;



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
    if ((checkRecordModel.invId ?? '').isEmpty){
      return {false: '请选择不良材料！'};
    }
    return {true: ''};
  }
  Map<bool, String> Function({
    required bool isPrint,
    required String? invCCode,
    String button,
  }) get checkRecordCheck => _checkRecordCheck;



  void Function() get setCheckRecordDataBeforeSave => () {
    super.setCheckRecordDataBeforeSave();
    checkRecordModel.deviceId = null;
    checkRecordModel.deviceCode = null;
    checkRecordModel.deviceName = null;
    checkRecordModel.wcId = null;
    checkRecordModel.lineCode = null;
    checkRecordModel.lineName = null;
    checkRecordModel.workBillEntryId = null;
    checkRecordModel.opId = null;
    checkRecordModel.opName = null;
    checkRecordModel.reWorkBillEntryId = null;
    checkRecordModel.serialNumber = null;
  };



  ///不良品记录提交成功后，刷新数据填报区域的数据
  Future<void> _resetCheckRecordDataAfterSave() async {
    await super.resetCheckRecordDataAfterSave();
    checkRecordModel.invId = null;
    invCCodeByBomEntry = null;
    bomEntryAdapter?.clearSelection();
  }
  Future<void> Function() get resetCheckRecordDataAfterSave => _resetCheckRecordDataAfterSave;



  //region Widget

  Widget bomEntryInvFormReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.bomEntryInvForm]!,
      customizeContent: PickerInputWidget(
        adapter: bomEntryAdapter,
        maxLines: 2,
        onTap: (List<PickerDataModel> selectList) {
          if (selectList.isNotEmpty){
            bomEntryOnChanged(selectList[0]);
          }
          else {
            bomEntryOnChanged(MoBomEntryModel());
          }
        },
      ),
    );
  }

  //endregion

}