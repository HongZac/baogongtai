import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/check_record_interface.dart';
import 'package:desktop/app/ui/widget/input_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产单据的次品录入接口 811010
mixin MesCheckRecordInterface on CheckRecordInterface {

  EAMDeviceAdapter? deviceAdapter;
  EAMDeviceModel deviceModel = EAMDeviceModel();
  ///返修工序
  ProcessAdapter? reProcessAdapter;

  ///设备是否可以通过 Adapter 选单
  bool isDeviceHasAdapter = AppConfig.isDeviceHasAdapter;
  ///设备的筛选条件 设备的车间id
  List<dynamic> deviceDepIdList = [];
  ///设备的筛选条件 设备的类别id
  List<dynamic> deviceClassIdList = [];

  ///处理方式列表
  List<ChoiceChipModel> get disposeFlowList => List.unmodifiable(AppConfig.disposeFlowList);



  //region getAdapter

  ///获取设备Adapter
  Future<void> _getEAMDeviceAdapter() async{
    deviceAdapter = await AdapterHelper.getAsyncAdapter(
        'device',
        selectedItems: [PickerDataModel(id: checkRecordModel.deviceId),],
        queryData: {
          'DevClassId': deviceClassIdList.map((e) => e).join(','),
          'DepIds': deviceDepIdList.map((e) => e).join(','),
        }
    ) as EAMDeviceAdapter;
  }
  ///获取设备Adapter
  Future<void> Function() get getEAMDeviceAdapter => _getEAMDeviceAdapter;

  ///获取返修工序Adapter
  Future<void> _getREProcessAdapter({required String? wbId, required String? invId}) async {
    reProcessAdapter = await AdapterHelper.getAsyncAdapter(
      'process',
      queryData: {
        'wbId': wbId,
        'invId': invId,
        'needGetSOP': true,
        'isNeedGetPostFilter': true,
      },
      multipleSelection: false, ///返修工序只能选择单道
    ) as ProcessAdapter;
  }
  ///获取返修工序Adapter
  Future<void> Function({required String? wbId, required String? invId}) get getREProcessAdapter => _getREProcessAdapter;

  //endregion



  //region OnChanged

  ///生产设备选择变化
  void _deviceOnChanged(PickerDataModel model) {
    if (checkRecordModel.deviceId == model.id){ return; }
    checkRecordModel.deviceId = model.id;
    checkRecordModel.deviceCode = model.code;
    checkRecordModel.deviceName = model.name;
    update();
  }
  ///生产设备选择变化
  void Function(PickerDataModel model) get deviceOnChanged => _deviceOnChanged;

  ///返修工序选择变化
  void _reProcessOnChanged(PickerDataModel model) async {
    checkRecordModel.reWorkBillEntryId = model.id;
    update();
  }
  ///返修工序选择变化
  void Function(PickerDataModel model) get reProcessOnChanged => _reProcessOnChanged;

  ///处理方式 选择变化
  void _disposeFlowOnChanged(ChoiceChipModel item) {
    checkRecordModel.disposeFlow = item.sign;
    if (checkRecordModel.disposeFlow != 7){
      checkRecordModel.reWorkBillEntryId = null;
      reProcessAdapter?.clearSelection();
    }
    update();
  }
  ///处理方式 选择变化
  void Function(ChoiceChipModel item) get disposeFlowOnChanged => _disposeFlowOnChanged;

  //endregion



  ///次品记录提交前检查（生产任务单）
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
    if (checkRecordModel.progID == 811010){
      if (checkRecordModel.disposeFlow == null){
        return {false: '请选择处理方式！'};
      }
      if (checkRecordModel.disposeFlow == 7){
        if ((checkRecordModel.reWorkBillEntryId ?? '').isEmpty){
          return {false: '请选择返修工序！'};
        }
        MoWorkBillEntryModel op = reProcessAdapter!.dataList.firstWhereOrNull((element) => element.opId == checkRecordModel.opId)!;
        MoWorkBillEntryModel reOp = reProcessAdapter!.dataList.firstWhereOrNull((element) => element.isSelected)!;
        if ((op.sequ ?? 0) < ((reOp.sequ ?? 0))){
          ///返修工序 一定要小于等于 报次品工序
          return {false: '返修工序不能在报次品工序之后！'};
        }
      }
    }
    return {true: ''};
  }
  Map<bool, String> Function({
    required bool isPrint,
    required String? invCCode,
    String button,
  }) get checkRecordCheck => _checkRecordCheck;



  //region Widget

  Widget disposeFlowWidget(BuildContext context){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(disposeFlowList.length, (index) {
        ChoiceChipModel item = disposeFlowList[index];
        return InkWell(
          onTap: (){
            disposeFlowOnChanged(item);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioTheme(
                data: RadioThemeData(
                  splashRadius: 0,
                ),
                child: Radio(
                  value: item.sign,
                  groupValue: checkRecordModel.disposeFlow,
                  onChanged: (value){
                    disposeFlowOnChanged(item);
                  }
                )
              ),
              Text(
                item.title,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: item.sign == checkRecordModel.disposeFlow
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ), maxLines: 1, overflow: TextOverflow.ellipsis
              ),
              const SizedBox(width: 6,),
            ],
          ),
        );
      }).toList(),
    );
  }

  //region dataReportItem

  Widget deviceReportItem(BuildContext context){
    return reportItem(
      context,
      title: formTitleMap[AppConfig.deviceForm]!,
      customizeContent: isDeviceHasAdapter ?
      PickerInputWidget(
        adapter: deviceAdapter,
        maxLines: 2,
        onTap: (List<PickerDataModel> selectList) {
          if (selectList.isNotEmpty){
            deviceOnChanged(selectList[0]);
          }
          else {
            deviceOnChanged(PickerDataModel());
          }
        },
      ) :
      InputWidget(
        dataList: [deviceModel],
      ),
    );
  }

  Widget reProcessReportItem(BuildContext context){
    return reportItem(
        context,
        title: formTitleMap[AppConfig.reProcessForm]!,
        customizeContent: PickerInputWidget(
          adapter: reProcessAdapter,
          maxLines: 2,
          onTap: (List<PickerDataModel> selectList) {
            if (selectList.isNotEmpty){
              reProcessOnChanged(selectList[0]);
            }
            else {
              reProcessOnChanged(PickerDataModel());
            }
          },
        )
    );
  }

  //endregion

  //endregion

}