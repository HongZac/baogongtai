


import 'package:desktop/app/model/assignment_form_model.dart';
import 'package:desktop/app/ui/pages/home/base/interface/assignment_interface/assignment_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/assignment_interface/assignment_form_page.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///任务说明接口
mixin AssignmentInterface on GetxController {

  final List<AssignmentFormModel> formList = [];

  ///是否没有修改任务说明的权限
  bool get noPermissionForAssignment => false;
  String get permissionInfoForAssignment => '';

  @override
  void onInit(){
    super.onInit();
    formList.forEach((element) {
      element.reset();
    });
  }

  Future<void> setAssignment() async {
    var res = await DialogUtils.showCustomDialog<AssignmentFormController, bool>(
      Get.context!,
      title: '编辑任务说明',
      barrierDismissible: false,
      isMaximize: true,
      contentPadding: const EdgeInsets.all(12),
      content: AssignmentFormPage(),
      controller: AssignmentFormController(
        formList: formList,
        noPermission: noPermissionForAssignment,
        permissionInfo: permissionInfoForAssignment,
      ),
    );
    if (res != null && res){
      formList.forEach((element) {
        element.reset();
      });
      update();
    }
  }

}