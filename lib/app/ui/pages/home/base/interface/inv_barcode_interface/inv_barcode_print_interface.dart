

import 'dart:convert';
import 'dart:io';

import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';

///物料条码打印接口
mixin InvBarcodePrintInterface
on InvClassFrxNameInterface, GetxController{

  ///打印模板文件名称
  String frxName = '';
  ///根据产品类别编码区分的打印模板名称列表
  Map<String, String> invClassFrxNameMap = {};


  ///物料条码打印
  ///
  /// [True]：打印成功； [False]：打印失败
  Future<Map<bool, String>> _printInvBarcode({
    required String printerUrl,
    required String printerName,
    required int printCopies,
    required String printType,
    required List<BarcodeMainModel> barcodeMainList,
    required String invCCode,
  }) async {
    assert(printCopies > 0);
    assert(barcodeMainList.length > 0);
    switch (printType) {
      case 'serverPrint':
        //region 服务端打印(支持所有平台) 保存条码，返回条码列表 => 转换List<Map>类型，并增加打印字段，生成PDF，返回pdf下载地址，通过地址打印PDF
        List<Map<String, dynamic>> mapList = [];
        barcodeMainList.forEach((element) {
          Map<String, dynamic> map = element.toJson();
          map['ProgId'] = element.preProgID;
          map['Quantity'] = element.quantity ?? 0;
          mapList.add(map);
        });
        String jsonStr = json.encode(
            mapList,
            toEncodable: DioService().datetimeEncode
        );
        Printer? printer = Printer(url: printerUrl, name: printerName);
        bool isPrintFinished = false;
        String printErrMsg = '';
        int copies = 0;
        AppRepository().downloadFile(
          FormRepository().getPrintUrl(
            invClassFrxNameMap[invCCode] ?? frxName,
            null, 'pdf',
          ),
          parames: jsonStr,
          onReceiveProgress: (int current, int length){
            if (length == 0){
              length = 1;
            }
            var process = current / length;
            PrintUtil.printDebug(process.toString());
          },
          onDone: (Uint8List data) async {
            for (var page = 0; page < printCopies; page ++) {
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
                ToastNotification(Get.overlayContext!).error('打印失败${page != (printCopies - 1) ? '，继续打印下一份' : ''}！');
                continue;
              }
              copies ++;
            }
            isPrintFinished = true;
          },
          onError: (String message){
            printErrMsg = '打印文件生成失败：$message！';
            isPrintFinished = true;
          },
        );
        await Future.doWhile(() async{
          await Future.delayed(const Duration(seconds: 1));
          if (isPrintFinished){
            return false;
          }
          return true;
        });
        if (printErrMsg.isNotEmpty){
          return {false: printErrMsg};
        }
        return {true: '打印完成，共$copies份，${barcodeMainList.length * copies}张！'};
        /*var barcodeRes = await BarcodeMainRepository().generatePrintMap(
          invClassFrxNameMap[invCCode] ?? frxName,
          mapList,
        );
        if (!barcodeRes.isSuccess || barcodeRes.data.isEmpty){
          return {false: '生成PDF文件失败：${barcodeRes.message}！'};
        }
        String url = AddressService.getUrl(barcodeRes.data);
        Printer? printer = Printer(url: printerUrl, name: printerName);
        Uint8List printContent = await DioService().downLoadFile(url);
        if (printContent.isEmpty){
          return {false: '打印失败！'};
        }
        int copies = 0;
        for (var page = 0; page < printCopies; page ++) {
          Printing.layoutPdf(
          var printingRes = await Printing.directPrintPdf(
            printer: printer,
            onLayout: (format) => Future.value(printContent),
            usePrinterSettings: true,
          );
          if (!printingRes){
            ToastNotification(Get.overlayContext!).error('打印失败${page != (printCopies - 1) ? '，继续打印下一份' : ''}！');
            continue;
          }
          copies ++;
        }
        return {true: '打印完成，共$copies份，${barcodeMainList.length * copies}张！'};*/
        //endregion
      case 'localPrint':
        //region 本地打印(仅支持Windows平台) 判断是否可以打开外部打印程序 => 保存条码，返回条码列表 => 启动外部打印程序，打印
        if (kIsWeb || !GetPlatform.isWindows){
          return {false: '本地打印仅支持Windows平台，请在全局设置中修改打印方式！'};
        }
        String executable = '${Directory.current.path}\\nberp.Desktop.Service.Print\\nberp.Desktop.Service.Print.exe';
        if(!(await File(executable).exists())){
          return {false: '没有发现本地打印主程序nberp.Desktop.Service.Print.exe！'};
        }
        var base64Str = base64.encode(utf8.encode(json.encode(barcodeMainList.map((e) => e.toJson()).toList(), toEncodable: DioService().datetimeEncode)));
        ///写入文档
        File testFile = File('${ShareStorageUtil.printDirectory!.path}\\${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}.txt');
        await testFile.writeAsString(base64Str);
        ///打印时是否显示参数设置
        bool isShowPrintSetting = ShareStorageUtil.instance?.read(SharedPreferencesKeys.IS_SHOW_PRINT_SETTING_KEY) ?? AppConfig.isShowPrintSetting;
        List<String> arguments = [
          '-datafile', barcodeMainList.length > 10 ? testFile.path : base64Str, ///如果条码份数大于10份的话，则通过 "datafile" 文件来传替打印内容
          '-file', '${Directory.current.path}\\nberp.Desktop.Service.Print\\print\\${invClassFrxNameMap[invCCode] ?? frxName}',
          '-printer', printerUrl,
          '-printerdialog', isShowPrintSetting.toString()
        ];
        ///启动进程进行打印
        try {
          var process = await Process.run(executable, arguments);
          ToastNotification(Get.overlayContext!).info(process.stdout.toString());
        } catch (e){
          PrintUtil.printDebug(e.toString());
          return {false: '打印失败：$e！'};
        }
        return {true: '打印完成，共${barcodeMainList.length}份！'};
        //endregion
    }
    return {false: '打印失败！'};
  }
  ///物料条码打印
  ///
  /// [True]：打印成功； [False]：打印失败
  Future<Map<bool, String>> Function({
    required String printerUrl,
    required String printerName,
    required int printCopies,
    required String printType,
    required List<BarcodeMainModel> barcodeMainList,
    required String invCCode,
  }) get printInvBarcode => _printInvBarcode;
}