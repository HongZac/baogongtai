import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/assignment_form_model.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/assignment_interface/assignment_add_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/assignment_interface/assignment_add_form_page.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///任务说明编辑页面
class AssignmentFormController extends BaseDialogController {

  final List<AssignmentFormModel> formList = [];

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  AssignmentFormController({
    required List<AssignmentFormModel> formList,
    required this.noPermission,
    required this.permissionInfo,
  }){
    this.formList.addAll(formList);
  }


  Future<void> addNewData(AssignmentFormModel item) async {
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      return;
    }
    var res = await DialogUtils.showCustomDialog<AssignmentAddFormController, List>(
      Get.context!,
      title: '新增',
      onConfirmName: '确认',
      barrierDismissible: false,
      initialWidth: 550, initialHeight: 260,
      contentPadding: const EdgeInsets.all(12),
      content: AssignmentAddFormPage(),
      controller: AssignmentAddFormController(
        model: item,
      ),
    );
    if (res != null && res.isNotEmpty){
      item.dataList.addAll(res);
      update();
    }
  }

  void removeData(AssignmentFormModel item, dynamic data) {
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      return;
    }
    item.dataList.remove(data);
    update();
  }

  void isAllConditionMustBeMetOnChanged(AssignmentFormModel item){
    item.isAllConditionMustBeMet = !item.isAllConditionMustBeMet;
    update();
  }



  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      if (noPermission){
        ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      formList.forEach((element) {
        ShareStorageUtil.instance?.write(element.sharedKey, element.dataList.map((e) => e).toList());
        ShareStorageUtil.instance?.write(element.sharedKey + '-isAllConditionMustBeMet', element.isAllConditionMustBeMet);
      });
      return DialogReturnDataModel(isCanCloseDialog: true, data: true);
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

  @override
  void onClose() {
    super.onClose();
  }

}