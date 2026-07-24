import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';

///选择工序计划单的明细工序
class WorkBillOpChoiceController extends BaseDialogController{

  ///工序计划单ID
  final String wbId;

  ///工序计划单明细列表
  final List<MoWorkBillEntryModel> workBillEntryList = [];

  WorkBillOpChoiceController({required this.wbId});


  @override
  Future<void> onReady() async {
    super.onReady();
    ProgressDialogUtil.showProgressDialog();
    var res = await MoWorkBillRepository().getFormData(wbId, '', {}, 0);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取工序计划单时出错：${res.message}');
      ProgressDialogUtil.close();
      return;
    }
    workBillEntryList.clear();
    workBillEntryList.addAll(res.data.entryList);
    update();
    ProgressDialogUtil.update();
  }


  void choiceOnChanged(MoWorkBillEntryModel item) {
    workBillEntryList.forEach((element) {
      if (element.wbMxId == item.wbMxId){
        element.isChoice = true;
      }
      else {
        element.isChoice = false;
      }
    });
    update();
  }

  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      MoWorkBillEntryModel? item = workBillEntryList.firstWhereOrNull((element) => element.isChoice);
      return DialogReturnDataModel(isCanCloseDialog: true, data: item?.wbMxId ?? '');
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

}