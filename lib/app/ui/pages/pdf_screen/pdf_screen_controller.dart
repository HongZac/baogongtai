
import 'dart:async';

import 'package:basement/service.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/cloud_service_task/cloud_service_task_controller.dart';
import 'package:desktop/app/ui/widget/pdf_view/pdf_view_data_manager.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:printing/printing.dart';


///PDF的查看和打印页面
class PdfScreenController
    extends GetxController
    with InterfaceUtil {

  final String pageTitle;
  final String pdfUrl;
  final VoidCallback? onPressed;

  ///pdf 数据流（用来在前台显示 pdf 预览）
  Uint8List pdfUint8List = Uint8List(0);
  bool isPDFLoadFailed = false;

  ///PDF 视图管理器
  PdfViewDataManager? pdfViewDataManager;
  ///当前页（用于判断是否需要刷新工具栏）
  int pageNumber = 0;
  ///当前 pdf 的总页数（用于判断是否需要刷新工具栏）
  int pageCount = 0;
  ///当前 pdf 的缩放级别（用于判断是否需要刷新工具栏）
  double zoom = 1;

  bool isLoading = false;
  bool isInitData = false;
  bool _isClosed = false;

  PdfScreenController({
    required this.pageTitle,
    required this.pdfUrl,
    this.onPressed,
  });

  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    ProgressDialogUtil.showProgressDialog();
    pdfUint8List = await DioService.downLoadFile(pdfUrl);
    if (pdfUint8List.isEmpty){
      isPDFLoadFailed = true;
    }
    if (_isClosed) {
      ProgressDialogUtil.close();
      return;
    }
    isInitData = true;

    update();
    ProgressDialogUtil.update(value: 1);
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    super.update();
    try {
      var ctl = Get.find<CloudServiceTaskController>();
      ctl.update();
    } catch (e){}
  }

  Future<void> pdfViewDataManagerListener() async {
    if (_isClosed || pdfViewDataManager == null) { return; }
    if (pdfViewDataManager!.pdfViewerController.isReady) {
      //todo
    }
  }


  Future<void> pdfPrint() async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (isPDFLoadFailed){
      ToastNotification(Get.overlayContext!).error("PDF文档加载失败，无法打印！");
      isLoading = false;
      return;
    }

    Map<String, dynamic> printInfoMap = await getPrintInfo();
    String printerUrl = printInfoMap['printerUrl']!; ///打印机Url
    String printerName = printInfoMap['printerName']!; ///打印机Name
    //int printCopies = printInfoMap['printCopies']!; ///打印份数
    //String printType = printInfoMap['printType']!; ///打印方式

    Printer? printer = Printer(url: printerUrl, name: printerName);
    if (!kIsWeb && GetPlatform.isWindows){
      await Printing.directPrintPdf(
        printer: printer,
        onLayout: (format) => Future.value(pdfUint8List),
        usePrinterSettings: true,
      );
    }
    else {
      await Printing.layoutPdf(
        onLayout: (format) => Future.value(pdfUint8List),
        usePrinterSettings: true,
      );
    }
    ToastNotification(Get.overlayContext!).success('打印成功！');
    isLoading = false;
  }


  @override
  void onClose() {
    _isClosed = true;
    ProgressDialogUtil.close();
    if (pdfViewDataManager != null){
      pdfViewDataManager!.pdfViewerController.removeListener(pdfViewDataManagerListener);
      pdfViewDataManager = null;
    }
    super.onClose();
  }


}