import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/service/app_print_service/app_print_service.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';


///APP 远程打印服务 参数修改页面
class AppPrintServiceFormController extends BaseDialogController {

  ///工作台名称（唯一性） 要修改的打印机信息的原数据
  final String oldWorkBench;
  ///打印机名称 要修改的打印机信息的原数据
  final String oldPrinterName;

  final appPrintService = Get.find<AppPrintService>();

  final List<Printer> printerList = [];

  ///工作台名称（唯一性）
  late final TextEditingController workBenchTC = TextEditingController(text: oldWorkBench);
  final FocusNode workBenchFN = FocusNode();
  ///打印机名称
  late String printerName = oldPrinterName;
  /// android 端，打印机名称需要手动输入
  late final TextEditingController printerNameTC = TextEditingController(text: oldPrinterName);
  final FocusNode printerNameFN = FocusNode();


  AppPrintServiceFormController({
    this.oldWorkBench = '',
    this.oldPrinterName = '',
  });



  @override
  Future<void> onReady() async {
    super.onReady();
    ProgressDialogUtil.showProgressDialog();
    if (!kIsWeb && GetPlatform.isWindows){
      List<Printer> printerList = await Printing.listPrinters();
      this.printerList.clear();
      this.printerList.addAll(printerList);
    }

    update();
    ProgressDialogUtil.update();
  }

  void printerChanged(Printer printer) {
    printerName = printer.url;
    update();
  }

  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if(actionName == DialogButtonActionEnum.confirm) { ///提交，将修改内容上传到服务器
      if (workBenchTC.text.isEmpty) {
        ToastNotification(Get.overlayContext!).error('请填写工作台名称！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      String printerName = '';
      if (!kIsWeb && GetPlatform.isWindows){
        printerName = this.printerName;
      }
      else {
        printerName = printerNameTC.text;
      }
      if (printerName.isEmpty) {
        ToastNotification(Get.overlayContext!).error('请选择打印机！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      ///编辑状态时，新数据是否与原数据不同
      bool isDataChanged = true;
      if (oldWorkBench.isNotEmpty && oldPrinterName.isNotEmpty){
        ///是编辑状态
        if (oldWorkBench != workBenchTC.text || oldPrinterName != printerName){
          PrintServiceEntity? item = appPrintService.printServiceList.firstWhereOrNull(
                  (element) => element.workBench == workBenchTC.text
                      && element.printerName == printerName);
          if (item != null){
            ToastNotification(Get.overlayContext!).error('当前打印机数据已存在，请修改！');
            return DialogReturnDataModel(isCanCloseDialog: false);
          }
        }
        else {
          isDataChanged = false;
        }
      }
      else {
        ///是新增状态，判断新增的信息是否已存在
        PrintServiceEntity? item = appPrintService.printServiceList.firstWhereOrNull(
                (element) => element.workBench == workBenchTC.text
                    && element.printerName == printerName);
        if (item != null){
          ToastNotification(Get.overlayContext!).error('当前打印机数据已存在，请修改！');
          return DialogReturnDataModel(isCanCloseDialog: false);
        }
      }

      if (isDataChanged){
        ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在提交数据', completedMsg: 'APP 远程打印服务启动成功！');
        PrintServiceEntity newItem = PrintServiceEntity(
          workBench: workBenchTC.text,
          printerName: printerName,
        );
        if (oldWorkBench.isNotEmpty && oldPrinterName.isNotEmpty){
          ///是编辑状态，先取消服务、移除旧数据
          PrintServiceEntity oldItem = appPrintService.printServiceList.firstWhereOrNull(
                  (element) => element.workBench == oldWorkBench
                      && element.printerName == oldPrinterName)!;
          var res = await appPrintService.unRegister([oldItem]);
          if (!res){
            ProgressDialogUtil.close();
            ToastNotification(Get.overlayContext!).error('请重新提交！');
            return DialogReturnDataModel(isCanCloseDialog: false);
          }
          appPrintService.printServiceList.remove(oldItem);
        }
        appPrintService.printServiceList.add(newItem);
        List<Map<String, dynamic>> mapList = appPrintService.printServiceList.map((e) => e.toJson()).toList();
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.APP_PRINT_SERVICE_LIST_KEY, mapList);
        ProgressDialogUtil.update(value: 1, msg: '参数修改成功，正在重新启动 APP 远程打印服务');
        var res = await appPrintService.register([newItem]);
        if (!res){
          ToastNotification(Get.overlayContext!).error('请在 APP 远程打印服务页面再次点击启动！');
        }
        ProgressDialogUtil.update(value: 2);
        await ProgressDialogUtil.awaitCompletionDelay();
        return DialogReturnDataModel(isCanCloseDialog: true, data: true);
      }
      else {
        var dialogRes = await DialogUtils.showConfirmationDialog(
          Get.context!, msg: '数据未作修改，确认提交？',
          barrierDismissible: false,
        );
        if (dialogRes == null || !dialogRes){
          return DialogReturnDataModel(isCanCloseDialog: false);
        }
        return DialogReturnDataModel(isCanCloseDialog: true, data: true);
      }
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }

}