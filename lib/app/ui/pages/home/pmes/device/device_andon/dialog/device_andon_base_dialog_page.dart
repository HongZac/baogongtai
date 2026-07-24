import 'package:desktop/app/ui/pages/home/pmes/device/device_andon/dialog/device_andon_base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_page.dart';
import 'package:desktop/app/ui/widget/title_textbox_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///工作流程-全场呼叫 填单窗体 基类
abstract class DeviceAndonBaseDialogPage <T extends DeviceAndonBaseDialogController> extends BaseDialogPage<T> {

  Widget dataReportItem({required String title, required Widget customizeContent, bool needMargin = true}){
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