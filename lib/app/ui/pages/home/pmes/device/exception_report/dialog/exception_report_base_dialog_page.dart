
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_page.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'exception_report_base_dialog_controller.dart';


///工作流程-异常报告 填单窗体 基类
abstract class ExceptionReportBaseDialogPage <T extends ExceptionReportBaseDialogController> extends BaseFormPage<T> {

  Widget dataReportItem1({required String title, required Widget customizeContent, bool needMargin = true}){
    return TitleTextBoxWidget(
      title: title,
      customizeContent: customizeContent,
      titleWidth: 100, width: 2000, //580,
      titleStyle: Theme.of(Get.context!).textTheme.bodyLarge,
      crossAxisAlignment: CrossAxisAlignment.center,
      margin: needMargin ? const EdgeInsets.only(bottom: 12) : null,
    );
  }

}