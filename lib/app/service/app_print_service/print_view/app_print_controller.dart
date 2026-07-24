import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/service/app_print_service/app_print_service.dart';
import 'package:desktop/app/service/app_print_service/setting/app_print_service_form_controller.dart';
import 'package:desktop/app/service/app_print_service/setting/app_print_service_form_view.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';


///APP 远程打印服务 主页面
class AppPrintController extends GetxController {

  final appPrintService = Get.find<AppPrintService>();

  final List<bool> isExpandedList = [true, true];

  bool isLoading = false;


  AppPrintController();


  Future<void> addNewAppPrintService() async {
    await DialogUtils.showCustomDialog<AppPrintServiceFormController, bool>(
      Get.context!, title: 'APP 远程打印服务-新增打印机信息',
      initialHeight: 500,
      initialWidth: 800,
      barrierDismissible: false,
      content: AppPrintServiceFormView(),
      controller: AppPrintServiceFormController(),
    );
  }

  Future<void> editNewAppPrintService(PrintServiceEntity item) async {
    await DialogUtils.showCustomDialog<AppPrintServiceFormController, bool>(
      Get.context!, title: 'APP 远程打印服务-编辑打印机信息',
      initialHeight: 500,
      initialWidth: 800,
      barrierDismissible: false,
      content: AppPrintServiceFormView(),
      controller: AppPrintServiceFormController(
        oldWorkBench: item.workBench ?? '',
        oldPrinterName: item.printerName ?? '',
      ),
    );
  }


  Future<void> removeNewAppPrintService(PrintServiceEntity item) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;

    ProgressDialogUtil.showProgressDialog(msg: '正在删除数据', completedMsg: '数据删除成功！');
    var res = await appPrintService.unRegister([item]);
    if (!res){
      ToastNotification(Get.overlayContext!).error('请重新提交！');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    appPrintService.printServiceList.remove(item);
    List<Map<String, dynamic>> mapList = appPrintService.printServiceList.map((e) => e.toJson()).toList();
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.APP_PRINT_SERVICE_LIST_KEY, mapList);
    ProgressDialogUtil.update();

    isLoading = false;
  }

  Future<void> registerOrCancel(PrintServiceEntity item) async {
    ProgressDialogUtil.showProgressDialog(
        msg: item.isRegister ? '正在取消服务' : '正在启动服务',
        completedMsg: item.isRegister ? '取消成功！' : '启动成功！'
    );
    bool res;
    if (item.isRegister){
      res = await appPrintService.unRegister([item]);
    }
    else {
      res = await appPrintService.register([item]);
    }
    if (res){
      ProgressDialogUtil.update();
    }
    else {
      ProgressDialogUtil.close();
    }
  }


}