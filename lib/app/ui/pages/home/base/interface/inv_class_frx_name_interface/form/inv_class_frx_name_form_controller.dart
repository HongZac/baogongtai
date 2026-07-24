import 'package:basement/picker.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/pickers/adapter_helper.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///新增/编辑 根据产品类别编码区分的打印模板
class InvClassFrxNameFormController extends BaseDialogController {

  ///已经存在模板数据的产品类别列表
  final List<String> existInvClassList;
  final String oldInvClassCode;
  final String oldFrxName;

  InvClassAdapter? invClassAdapter;
  late List<String> invClassCodeList = [oldInvClassCode];
  final List<NumPadController> numPadCTList = [
    NumPadController(key: 'frxName', keyboardType: TextInputType.text), ///模板名称
  ];


  InvClassFrxNameFormController({
    required this.existInvClassList,
    this.oldInvClassCode = '',
    this.oldFrxName = '',
  }) : assert(oldInvClassCode.isEmpty == oldFrxName.isEmpty);


  @override
  void onInit() {
    super.onInit();
    NumPadUtil().setText('frxName', oldFrxName, numPadCTList);
  }

  @override
  Future<void> onReady() async {
    super.onReady();

    invClassAdapter = await AdapterHelper.getAsyncAdapter(
      'invClass',
      multipleSelection: true,
      selectedItems: oldInvClassCode.isEmpty ? [] : [PickerDataModel(id: oldInvClassCode)]
    ) as InvClassAdapter;

    update();
  }


  void invClassOnChanged(List<PickerDataModel> list) {
    invClassCodeList.clear();
    invClassCodeList.addAll(list.map((e) => e.code));
    update();
  }


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async {
    if (actionName == DialogButtonActionEnum.confirm) {
      String frxName = NumPadUtil().getText('frxName', numPadCTList) ?? '';
      if (invClassCodeList.isEmpty){
        ToastNotification(Get.overlayContext!).error('请选择产品类别！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      if (frxName.isEmpty){
        ToastNotification(Get.overlayContext!).error('请输入模板名称！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      String? key = existInvClassList.firstWhereOrNull(
              (element) => element != oldInvClassCode
                  && invClassCodeList.contains(element));
      if (key != null){
        ToastNotification(Get.overlayContext!).error('选择的产品类别【$key】已存在！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }

      Map<String, String> dataMap = {};
      invClassCodeList.forEach((element) {
        dataMap.addAll({element: frxName});
      });
      return DialogReturnDataModel(isCanCloseDialog: true, data: dataMap);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

  }