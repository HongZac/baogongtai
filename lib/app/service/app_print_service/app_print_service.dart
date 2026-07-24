import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/web_socket_model.dart';
import 'package:desktop/app/service/app_print_service/print_view/app_print_controller.dart';
import 'package:desktop/app/service/app_service.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

///APP 远程打印服务
///需要在[AutoReconnectWebSocket]打开之后，才能接收APP打印消息
///
/// 打印服务信息保存到本地；
/// 打开工作台后，从本地读取打印服务信息；
/// 登录后（或启动 WebSocket 后），启动打印服务；
/// WebSocket 重连后，重新启动；
class AppPrintService extends GetxService {

  ///远程打印服务的打印机信息列表
  final List<PrintServiceEntity> printServiceList = [];

  ///WebSocket 传递过来的打印数据列表
  final List<ModelWithGetxController<PrintTaskModel>> printDataList = [];

  final appService = Get.find<AppService>();
  late final StreamSubscription<WebSocketModel> webSocketModelStreamSubscription;

  bool isLoading = false;

  final Debounce _debounce = Debounce(Duration(milliseconds: 3000));


  @override
  void onInit() {
    super.onInit();
    var list = ShareStorageUtil.instance?.read(SharedPreferencesKeys.APP_PRINT_SERVICE_LIST_KEY) ?? [];
    if (list.isNotEmpty){
      list.forEach((element){
        PrintServiceEntity model = PrintServiceEntity.fromJson(element);
        printServiceList.add(model);
      });
    }
  }

  @override
  void onReady() {
    super.onReady();

    webSocketModelStreamSubscription = appService.eventBus.on<WebSocketModel>().listen((event) async{
      await onData(event);
    });
  }

  Future<void> onData(WebSocketModel webSocketModel) async {
    switch (webSocketModel.name){
      case 'PrintTaskModel':
        var data = json.decode(webSocketModel.data);
        PrintTaskModel printTaskModel = PrintTaskModel(
          token: data['token'],
          printUrl: data['printUrl'],
          acceptDate: DateTime.now(),
        );
        if (printTaskModel.token != null && printTaskModel.printUrl != null){
          ModelWithGetxController<PrintTaskModel>? existItem; ///是否已存在该打印任务数据
          try {
            existItem = Get.find<ModelWithGetxController<PrintTaskModel>>(tag: printTaskModel.tag);
          } catch (e){}

          if (existItem != null){
            /// 执行打印
            onPrint(existItem);
          }
          else {
            PrintServiceEntity? printServiceEntity = printServiceList.firstWhereOrNull(
                    (element1) => printTaskModel.token == element1.token);
            if (printServiceEntity != null){
              printTaskModel.printServiceEntity = printServiceEntity;
              ModelWithGetxController<PrintTaskModel> newItem = ModelWithGetxController(model: printTaskModel);
              Get.create<ModelWithGetxController<PrintTaskModel>>(() => newItem, tag: printTaskModel.tag);
              if (printDataList.length >= 100){
                var dItem = printDataList.removeLast();
                Get.delete<ModelWithGetxController<PrintTaskModel>>(tag: dItem.model.tag, force: true);
              }
              printDataList.insert(0, newItem);
              try {
                var controller = Get.find<AppPrintController>();
                controller.update();
              } catch(e){}
              await Future.delayed(const Duration(milliseconds: 500));

              /// 执行打印
              onPrint(newItem);
            }
          }
        }
        break;
    }
  }


  ///打印服务取消
  Future<bool> unRegister(List<PrintServiceEntity> list) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return false;
    }
    isLoading = true;

    List<PrintServiceEntity> serviceList = [];
    list.forEach((element) {
      if (element.isRegister){
        serviceList.add(element);
      }
    });
    var res = await PrintServiceRepository().unregister(serviceList);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('打印服务取消失败：${res.message}！');
      isLoading = false;
      return false;
    }
    list.forEach((element) {
      element.isRegister = false;
    });

    try {
      var controller = Get.find<AppPrintController>();
      controller.update();
    } catch(e){}

    isLoading = false;

    return true;
  }

  ///启动远程打印服务
  Future<bool> register(List<PrintServiceEntity> list) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return false;
    }
    isLoading = true;

    List<PrintServiceEntity> serviceList = [];
    list.forEach((element) {
      if (!element.isRegister){
        serviceList.add(element);
      }
    });
    var res = await PrintServiceRepository().register(serviceList);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('启动远程打印服务失败：${res.message}！');
      isLoading = false;
      return false;
    }
    list.forEach((element) {
      element.isRegister = true;
    });

    try {
      var controller = Get.find<AppPrintController>();
      controller.update();
    } catch(e){}

    isLoading = false;
    return true;
  }

  ///打印
  Future<bool> onPrint(ModelWithGetxController<PrintTaskModel> item) async {
    if (item.model.isPrinting){
      ToastNotification(Get.overlayContext!).warn('正在打印！');
      return false;
    }
    item.model.isPrinting = true;
    item.update();
    await Future.delayed(const Duration(milliseconds: 500));

    if ((item.model.printUrl ?? '').isEmpty || (item.model.token ?? '').isEmpty){
      ToastNotification(Get.overlayContext!).error("错误的打印任务数据，打印失败！");
      item.model.isPrinting = false;
      item.update();
      return false;
    }
    PrintServiceEntity? printServiceEntity = printServiceList.firstWhereOrNull((element) => element.token == item.model.token);
    if (printServiceEntity == null){
      ToastNotification(Get.overlayContext!).error("未找到打印机信息，打印失败！");
      item.model.isPrinting = false;
      item.update();
      return false;
    }
    if (!printServiceEntity.isRegister){
      ToastNotification(Get.overlayContext!).error("该打印机未启动服务，打印失败！");
      item.model.isPrinting = false;
      item.update();
      return false;
    }
    String url = item.model.printUrl!;
    Printer printer = Printer(
      url: printServiceEntity.printerName!,
      name: printServiceEntity.printerName!
    );
    AppRepository().downloadFile(
      url,
      onReceiveProgress: (int current, int length){
        if (length == 0){
          length = 1;
        }
        var process = current / length;
        PrintUtil.printDebug(process.toString());
      },
      onDone: (Uint8List data) async {
        bool printingRes;
        if (!kIsWeb && GetPlatform.isWindows){
          printingRes = await Printing.directPrintPdf(
            printer: printer,
            onLayout: (format) => Future.value(data),
            usePrinterSettings: true,
          );
        }
        else {
          printingRes = await Printing.layoutPdf(
            onLayout: (format) => Future.value(data),
            usePrinterSettings: true,
          );
        }
        if (!printingRes){
          ToastNotification(Get.overlayContext!).error("打印文件生成失败！");
          item.model.isPrinting = false;
          item.update();
          return;
        }
        item.model.nprint ++;
        item.model.isPrinting = false;
        ToastNotification(Get.overlayContext!).success("打印成功！");
        item.update();

        try {
          var controller = Get.find<AppPrintController>();
          controller.update();
        } catch(e){}
      },
      onError: (String message){
        ToastNotification(Get.overlayContext!).error("打印文件生成失败！");
        item.model.isPrinting = false;
        item.update();
        return;
      },
    );

    return true;
  }

  ///重新启动远程打印服务
  Future<void> reRegister() async {
    _debounce(() async {
      await unRegister(printServiceList);
      await register(printServiceList);
    });
  }


  @override
  Future<void> onClose() async {
    try {
      webSocketModelStreamSubscription.cancel();
    } catch (e){}
    _debounce.dispose();
    await unRegister(printServiceList);
    super.onClose();
  }

}