import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///调整模穴
class AdjustOutputController extends BaseDialogController {

  final double initOutput;

  ///调模原因是否必填
  final bool isNeedAdjustReason;

  late double output = initOutput;

  final List<TreeModel> adjustOutputReasonList = [];
  TreeModel? adjustOutputReasonSelectedItem = null;

  final TextEditingController descTC = TextEditingController();
  final FocusNode descFN = FocusNode();

  final Debounce debounce = Debounce(Duration(milliseconds: 800));


  AdjustOutputController({
    required this.initOutput,
    required this.isNeedAdjustReason,
  });


  @override
  Future<void> onReady() async {
    super.onReady();

    ProgressDialogUtil.showProgressDialog(msg: '正在获取调模原因列表');
    await getAdjustOutputReasonList();
    update();
    ProgressDialogUtil.update();
  }

  Future<void> getAdjustOutputReasonList() async {
    adjustOutputReasonList.clear();
    adjustOutputReasonSelectedItem = null;
    var res = await DataItemRepository().getDetailTree('MouldAdjustReason');
    if (res.isSuccess){
      adjustOutputReasonList.addAll(res.data);
    }
  }


  void adjustOutputReasonOnChanged(TreeModel item) {
    adjustOutputReasonSelectedItem = item;
    descTC.text = item.text ?? '';
    update();
  }


  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      if (isNeedAdjustReason && descTC.text.isEmpty){
        ToastNotification(Get.overlayContext!).error("请输入调模原因！");
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      return DialogReturnDataModel(
        isCanCloseDialog: true,
        data: {
          'output': output,
          'desc': descTC.text
        }
      );
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }


  @override
  void onClose() {
    descTC.dispose();
    descFN.dispose();
    super.onClose();
  }

}