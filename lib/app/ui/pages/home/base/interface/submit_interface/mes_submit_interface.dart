
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_interface.dart';
import 'package:desktop/app/ui/widget/input_widget.dart';
import 'package:desktop/app/ui/widget/picker_widget/picker_input_widget.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:flutter/material.dart';


///生产单据的报工接口（650041）
mixin MesSubmitInterface on SubmitInterface {

  EAMDeviceAdapter? deviceAdapter;
  EAMDeviceModel deviceModel = EAMDeviceModel();

  ///设备是否可以通过 Adapter 选单
  bool isDeviceHasAdapter = AppConfig.isDeviceHasAdapter;
  ///设备的筛选条件 设备的车间id
  List<dynamic> deviceDepIdList = [];
  ///设备的筛选条件 设备的类别id
  List<dynamic> deviceClassIdList = [];



  //region getAdapter

  ///获取设备Adapter
  Future<void> _getEAMDeviceAdapter() async{
    deviceAdapter = await AdapterHelper.getAsyncAdapter(
        'device',
        selectedItems: [PickerDataModel(id: submitModel.deviceId),],
        queryData: {
          'DevClassId': deviceClassIdList.map((e) => e).join(','),
          'DepIds': deviceDepIdList.map((e) => e).join(','),
        }
    ) as EAMDeviceAdapter;
  }
  ///获取设备Adapter
  Future<void> Function() get getEAMDeviceAdapter => _getEAMDeviceAdapter;

  //endregion



  //region OnChanged

  ///生产设备选择变化
  void _deviceOnChanged(PickerDataModel model) {
    if (submitModel.deviceId == model.id){ return; }
    submitModel.deviceId = model.id;
    submitModel.deviceCode = model.code;
    submitModel.deviceName = model.name;
    update();
  }
  void Function(PickerDataModel model) get deviceOnChanged => _deviceOnChanged;


  //endregion



  //region Widget

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

  //endregion

  //endregion

}