
import 'package:desktop/app/model/dialog_return_data_model.dart';
import 'package:desktop/app/ui/widget/dialog/interface/base_dialog_controller.dart';
import 'package:desktop/app/ui/widget/dialog/interface/dialog_controller_interface.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

/// 打印机选择 弹窗窗体
class PrintChoiceController extends BaseDialogController{

  final ScrollController scrollController = ScrollController();
  String printerName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PRINTER_NAME_KEY) ?? '';
  String printerUrl = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PRINTER_URL_KEY) ?? '';
  ///使用打印机定义的配置
  bool usePrinterSettings = ShareStorageUtil.instance?.read(SharedPreferencesKeys.USE_PRINTER_SETTINGS_KEY) ?? AppConfig.usePrinterSettings;

  final List<Printer> printerList = [];


  @override
  Future<void> onReady() async {
    super.onReady();
    if (!kIsWeb && GetPlatform.isWindows){
      printerList.clear();
      printerList.addAll(await Printing.listPrinters());
    }
    update();
  }

  Future<void> printerOnChanged(Printer printer) async {
    printerUrl = printer.url;
    printerName = printer.name;
    update();
  }

  void usePrinterSettingsOnChanged() {
    usePrinterSettings = !usePrinterSettings;
    update();
  }

  @override
  Future<DialogReturnDataModel> dialogActionPressed(DialogButtonActionEnum actionName) async{
    if (actionName == DialogButtonActionEnum.confirm){
      if (printerName.isEmpty || printerUrl.isEmpty){
        ToastNotification(Get.overlayContext!).error('请选择打印机！');
        return DialogReturnDataModel(isCanCloseDialog: false);
      }
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.PRINTER_NAME_KEY, printerName);
      ShareStorageUtil.instance?.write(SharedPreferencesKeys.PRINTER_URL_KEY, printerUrl);
      ToastNotification(Get.overlayContext!).success('打印机选择成功！');
      return DialogReturnDataModel(
        isCanCloseDialog: true,
        data: {
          'printer': Printer(url: printerUrl, name: printerName),
          'usePrinterSettings': usePrinterSettings,
        },
      );
    }
    return DialogReturnDataModel(isCanCloseDialog: true);
  }


  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}