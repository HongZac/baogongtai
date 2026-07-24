
import 'dart:async';

import 'package:basement/service.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


///PDF的查看和打印页面
class PdfScreenController
    extends GetxController
    with InterfaceUtil {

  final String pageTitle;
  final String pdfUrl;
  final VoidCallback? onPressed;

  Uint8List pdfUint8List = Uint8List(0);
  final PdfViewerController pdfViewerController = PdfViewerController();
  bool isPDFLoadFailed = false;

  ///旋转角度
  int turns = 0;
  double? pdfAreaHeight;
  double? pdfAreaWidth;


  bool isLoading = false;

  PdfScreenController({required this.pageTitle, required this.pdfUrl, this.onPressed});

  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    ProgressDialogUtil.showProgressDialog();
    pdfUint8List = await DioService().downLoadFile(pdfUrl);
    if (pdfUint8List.isEmpty){
      isPDFLoadFailed = true;
    }
    update();
    ProgressDialogUtil.update(value: 1);
  }


  Future<void> pdfPrint() async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (isPDFLoadFailed){
      ToastNotification(Get.overlayContext!).error("PDF文档加载失败！");
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


}