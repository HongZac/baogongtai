import 'package:basement/picker.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';


///单据转单 / 开工  选择员工/设备
class TransferOrderController extends BaseDialogController {

  PersonAdapter? personAdapter;
  EAMDeviceAdapter? deviceAdapter;
  String? psnId;
  String? psnCode;
  String? psnName;
  String? deviceId;
  String? deviceCode;
  String? deviceName;


  TransferOrderController({
    required String? initPsnId,
    String? initPsnCode,
    String? initPsnName,
    required String? initDeviceId,
    String? initDeviceCode,
    String? initDeviceName,
  }){
    psnId = initPsnId;
    psnCode = initPsnCode;
    psnName = initPsnName;
    deviceId = initDeviceId;
    deviceCode = initDeviceCode;
    deviceName = initDeviceName;
  }


  @override
  Future<void> onReady() async {
    super.onReady();

    ProgressDialogUtil.showProgressDialog();
    await getPersonAdapter();
    await getDeviceAdapter();
    update();
    ProgressDialogUtil.update();
  }


  Future<void> getPersonAdapter() async {
    personAdapter = await AdapterHelper.getAsyncAdapter(
      'person',
      isNeedLoadData: true,
      queryData: {
        'Active': 0, ///Active:0不显示离职人员
      },
      selectedItems: (psnId ?? '').isEmpty
          ? []
          : [PickerDataModel(id: psnId)],
    ) as PersonAdapter;
  }

  Future<void> getDeviceAdapter() async {
    deviceAdapter = await AdapterHelper.getAsyncAdapter(
      'device',
      isNeedLoadData: true,
      selectedItems: (deviceId ?? '').isEmpty
          ? []
          : [PickerDataModel(id: deviceId)],
    ) as EAMDeviceAdapter;
  }



  Future<void> psnOnChanged(PickerDataModel item) async{
    psnId = item.id;
    psnCode = item.code;
    psnName = item.name;
    update();
  }

  Future<void> deviceOnChanged(PickerDataModel item) async{
    deviceId = item.id;
    deviceCode = item.code;
    deviceName = item.name;
    update();
  }


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      return DialogReturnDataModel(
        isCanCloseDialog: true,
        data: {
          'psnId': psnId,
          'psnCode': psnCode,
          'psnName': psnName,
          'deviceId': deviceId,
          'deviceCode': deviceCode,
          'deviceName': deviceName,
        }
      );
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

}