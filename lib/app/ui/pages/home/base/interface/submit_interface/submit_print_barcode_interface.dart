


import 'dart:convert';
import 'dart:io';

import 'package:basement/basement.dart';
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

///报工条码打印
mixin SubmitPrintBarcodeInterface
on InvClassFrxNameInterface,
    GetxController {

  ///打印模板文件名称
  String frxName = '';
  ///根据产品类别编码区分的打印模板名称列表
  Map<String, String> invClassFrxNameMap = {};


  ///报工条码打印
  ///
  /// [True]：打印成功； [False]：打印失败
  ///
  /// [billCode]：单据编号（流水依据用） 生成报工单、次品单条码时必传 生成流水依据用，就是那些单子同一个流水号；比如，派工单的报工单条码：派工单号；任务单的报工单条码：任务单号
  ///
  /// [submitType]：报工方式（保存条码时，需要这个参数，当[submitType]==[AppConfig.palletSubmit] 时，打印的条码总数为 1）
  ///
  /// [deviceAddCode]：设备档案-设备简称
  ///
  /// [invMnemCode]：产品档案-助记码
  ///
  /// [reprintFrxName]：模板名称，[SubmitBarcodeController]条码补打时用到，因为这个页面不知道报工类型
  Future<Map<bool, String>> _printSubmitBarcode({
    required String moOpSubmitId,
    required String printerUrl,
    required String printerName,
    required int printCopies,
    required String printType,
    MoTaskModel? taskModel,
    MoOpOrderModel? orderModel,
    MoOpSubmitModel? submitModel,
    String? billCode,
    List<BarcodeMainModel>? barcodeMainList,
    String? submitType,
    String deviceAddCode = '',
    String invMnemCode = '',
    String? reprintFrxName,
  }) async {
    assert(printCopies > 0);
    if (taskModel == null && orderModel == null){
      return {false: '找不到派工单和任务单，打印失败！'};
    }
    if (barcodeMainList != null){
      ///不能同时打印不同报工单的条码
      List<String> preIdList = barcodeMainList.map((e) => e.preId ?? '').toSet().toList();
      assert(preIdList.length == 1);
    }
    else {
      assert(submitType != null && billCode != null);
    }

    ///是否是补打
    bool isRePrint = barcodeMainList != null;

    if (submitModel == null){
      var submitRes = await MoOpSubmitRepository().getFormData(moOpSubmitId);
      if (!submitRes.isSuccess){
        return {false: '打印数据获取失败：${submitRes.message}！'};
      }
      submitModel = submitRes.data;
    }

    if (barcodeMainList == null){
      //region 准备打印数据 barcodeList
      BarcodeEntity barcode = BarcodeEntity();
      barcode.progid = submitModel.progid ?? 0;
      barcode.preProgid = submitModel.progid ?? 0;
      barcode.preId = submitModel.moOpSubmitId ?? '';
      barcode.preCode = submitModel.billCode ?? '';
      barcode.preName = submitModel.soCode ?? '';
      barcode.invID = submitModel.invId ?? '';
      barcode.invCode = submitModel.invCode ?? '';
      barcode.invName = submitModel.invName ?? '';
      barcode.invStd = submitModel.invStd ?? '';
      barcode.opId = submitModel.opId ?? '';
      barcode.free1 = submitModel.free1 ?? '';
      barcode.free2 = submitModel.free2 ?? '';
      barcode.free3 = submitModel.free3 ?? '';
      barcode.free4 = submitModel.free4 ?? '';
      barcode.free5 = submitModel.free5 ?? '';
      barcode.free6 = submitModel.free6 ?? '';
      barcode.free7 = submitModel.free7 ?? '';
      barcode.free8 = submitModel.free8 ?? '';
      barcode.free9 = submitModel.free9 ?? '';
      barcode.free10 = submitModel.free10 ?? '';
      barcode.empty1 = taskModel != null ? taskModel.opDescription : submitModel.lineCode; ///材料 OR 产线 Code
      barcode.empty2 = submitModel.billDate.toString();
      barcode.empty3 = submitModel.emploee ?? '';
      barcode.empty4 = submitModel.mtoNo ?? '';
      barcode.empty5 = submitModel.mtoSeq?.toString();
      barcode.empty6 = taskModel?.invWhName ?? '';
      barcode.empty7 = submitModel.deviceCode ?? '';
      barcode.empty8 = submitModel.position ?? '';
      barcode.empty9 = submitModel.packingType ?? '';
      barcode.empty10 = orderModel?.whName ?? taskModel?.whName ?? '';
      barcode.teamCode = submitModel.teamCode ?? '';
      barcode.batch = submitModel.batch;
      barcode.productDate = submitModel.billDate;
      barcode.billCode = billCode;
      barcode.memo = submitModel.num?.toString(); //箱数：整箱箱数 + 1(如果有尾箱) OR 按托报工时：代表每托箱数，一托里面装多少小箱
      barcode.quantity = submitModel.qty ?? 0;
      barcode.pieceWeight = submitModel.pieceWeight;
      barcode.weight = submitModel.weight ?? 0;
      barcode.boxQuantity = submitModel.boxQty ?? 0; //单箱件数，一个箱子装多少件产品 OR 单托件数，代表一托装多少个产品
      barcode.singleBoxWeight = (submitModel.pieceWeight ?? 0) * (submitModel.boxQty ?? 0); //单箱净重
      barcode.piece = submitModel.qty ?? 0; //总件数
      if (submitType == AppConfig.palletSubmit){
        barcode.prnCount = 1; //打印的条码总数
      }
      else {
        barcode.prnCount = (submitModel.num ?? 0).toInt(); //打印的条码总数
      }
      List<BarcodeEntity> barcodeList = [barcode];
      //endregion
      var barcodeSaveRes = await BarcodeMainRepository().generate('', barcodeList);
      if (!barcodeSaveRes.isSuccess){
        return {false: '条码生成失败：${barcodeSaveRes.message}！'};
      }
      var barcodeListRes = await BarcodeMainRepository().getPageList(
          PageConfig(
              page: 1,
              sidx: 'Numerical',
              sord: 'asc',
              rows: barcodeSaveRes.data.length,
              queryData: {'preId': submitModel.moOpSubmitId}
          )
      );
      if (!barcodeListRes.isSuccess){
        return {false: '条码数据获取失败：${barcodeListRes.message}！'};
      }
      barcodeMainList = [];
      barcodeMainList.addAll(barcodeListRes.rows);
    }

    if (barcodeMainList.isEmpty){
      return {false: '条码为空，条码数据错误！'};
    }

    switch (printType){
      case 'serverPrint':
        //region 服务端打印(支持所有平台) 保存条码，返回条码列表 => 转换List<Map>类型，并增加打印字段，生成PDF，返回pdf下载地址，通过地址打印PDF
        List<Map<String, dynamic>> mapList = [];
        barcodeMainList.forEach((element) {
          Map<String, dynamic> map = element.toJson();
          map['ProgId'] = element.preProgID;
          map['SoCode'] = orderModel?.soCode ?? taskModel?.soCode;
          map['OrderCode'] = orderModel?.orderCode;
          map['GDCode'] = taskModel?.gDCode;
          map['MtoNo'] = orderModel?.mtoNo ?? taskModel?.mtoNo;
          map['MtoSeq'] = orderModel?.mtoSeq ?? taskModel?.mtoSeq;
          map['MoOrderId'] = orderModel?.moOrderId ?? taskModel?.moOrderId;
          map['BillCode'] = orderModel?.billCode ?? taskModel?.orderCode;
          map['BillDate'] = orderModel?.billDate.toString();
          map['TaskId'] = taskModel?.taskId;
          map['TaskCode'] = taskModel?.taskCode;
          map['TaskDate'] = taskModel?.taskDate.toString();
          map['InvWhName'] = taskModel?.invWhName;
          map['WhName'] = orderModel?.whName ?? taskModel?.whName;
          map['Position'] = taskModel?.position;
          map['PackingType'] = orderModel?.packingType ?? taskModel?.packingType;
          map['DeviceAddCode'] = deviceAddCode;
          map['DeviceCode'] = submitModel?.deviceCode;
          map['DeviceName'] = submitModel?.deviceName;
          map['MouldCode'] = submitModel?.mouldCode;
          map['MouldName'] = submitModel?.mouldName;
          map['Output'] = submitModel?.output; ///标准模穴
          map['AvailOutput'] = submitModel?.availOutput; ///实际模穴
          map['OutCycle'] = submitModel?.outCycle; ///标准周期
          map['ActualCycle'] = taskModel?.actualCycle; ///实际周期
          map['Principal'] = taskModel?.principal; ///模具负责人
          map['TeamCode'] = submitModel?.teamCode;
          map['TeamName'] = submitModel?.teamName;
          map['DepCode'] = submitModel?.depCode;
          map['DepName'] = submitModel?.depName;
          map['Emploee'] = submitModel?.emploee;
          map['StandWeight'] = submitModel?.standWeight ?? 0; ///标准单重（产品单重）
          map['PieceWeight'] = submitModel?.pieceWeight ?? 0; ///实际单重
          map['Weight'] = submitModel?.weight ?? 0; ///报工总重
          map['Qty'] = submitModel?.qty ?? 0; ///报工数量
          map['AssignQty'] = submitModel?.assignQty ?? 0; ///派工数量
          map['Quantity'] = element.quantity ?? 0;
          map['Define22'] = orderModel?.define22 ?? taskModel?.orderDefine22;
          map['Define23'] = orderModel?.define23 ?? taskModel?.orderDefine23;
          map['Define24'] = orderModel?.define24 ?? taskModel?.orderDefine24;
          map['Define25'] = orderModel?.define25 ?? taskModel?.orderDefine25;
          map['Define26'] = orderModel?.define26 ?? taskModel?.orderDefine26;
          map['Define27'] = orderModel?.define27 ?? taskModel?.orderDefine27;
          map['Define28'] = orderModel?.define28 ?? taskModel?.orderDefine28;
          map['Define29'] = orderModel?.define29 ?? taskModel?.orderDefine29;
          map['Define30'] = orderModel?.define30 ?? taskModel?.orderDefine30;
          map['Define31'] = orderModel?.define31 ?? taskModel?.orderDefine31;
          map['Define32'] = orderModel?.define32 ?? taskModel?.orderDefine32;
          map['Define33'] = orderModel?.define33 ?? taskModel?.orderDefine33;
          map['Define34'] = orderModel?.define34 ?? taskModel?.orderDefine34;
          map['Define35'] = orderModel?.define35 ?? taskModel?.orderDefine35;
          map['Define36'] = orderModel?.define36 ?? taskModel?.orderDefine36;
          map['Define37'] = orderModel?.define37 ?? taskModel?.orderDefine37;
          map['InvDefine1'] = orderModel?.invDefine1 ?? taskModel?.invDefine1;
          map['InvDefine2'] = orderModel?.invDefine2 ?? taskModel?.invDefine2;
          map['InvDefine3'] = orderModel?.invDefine3 ?? taskModel?.invDefine3; ///材料？
          map['InvDefine4'] = orderModel?.invDefine4 ?? taskModel?.invDefine4;
          map['InvDefine5'] = orderModel?.invDefine5 ?? taskModel?.invDefine5;
          map['InvDefine6'] = orderModel?.invDefine6 ?? taskModel?.invDefine6; ///颜色？
          map['InvDefine7'] = orderModel?.invDefine7 ?? taskModel?.invDefine7;
          map['InvDefine8'] = orderModel?.invDefine8 ?? taskModel?.invDefine8;
          map['InvDefine9'] = orderModel?.invDefine9 ?? taskModel?.invDefine9;
          map['InvDefine10'] = orderModel?.invDefine10 ?? taskModel?.invDefine10;
          map['Free1'] = submitModel?.free1;
          map['Free2'] = submitModel?.free2;
          map['Free3'] = submitModel?.free3;
          map['Free4'] = submitModel?.free4;
          map['Free5'] = submitModel?.free5;
          map['Free6'] = submitModel?.free6;
          map['Free7'] = submitModel?.free7;
          map['Free8'] = submitModel?.free8;
          map['Free9'] = submitModel?.free9;
          map['Free10'] = submitModel?.free10;
          map['CurrentStock'] = orderModel?.currentStock ?? taskModel?.currentStock; ///当前库存数
          map['InspectFlag'] = submitModel?.inspectFlag;
          map['InvPosCode'] = submitModel?.invPosCode;
          map['InvPosName'] = submitModel?.invPosName;
          map['InvMnemCode'] = invMnemCode;
          map['PackingWeight'] = submitModel?.packingWeight;
          map['BoxNumOfPallet'] = submitModel?.num; ///单托箱数（按托报工时使用）
          map['BoxWeight'] = submitModel?.boxWeight;
          map['LineCode'] = submitModel?.lineCode;
          map['LineName'] = submitModel?.lineName;
          map['CusCode'] = orderModel?.cusCode;
          map['CusName'] = orderModel?.cusName;
          map['IsRePrint'] = isRePrint ? 1 : 0; ///是否是补打
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
            reprintFrxName ?? invClassFrxNameMap[orderModel?.invCCode] ?? frxName,
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
            printErrMsg = '打印文件下载失败：$message！';
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
            reprintFrxName ?? invClassFrxNameMap[orderModel?.invCCode] ?? frxName,
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
          '-file', '${Directory.current.path}\\nberp.Desktop.Service.Print\\print\\${invClassFrxNameMap[orderModel?.invCCode] ?? frxName}',
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
  ///报工条码打印
  ///
  /// [True]：打印成功； [False]：打印失败
  ///
  /// [billCode]：单据编号（流水依据用） 生成报工单、次品单条码时必传 生成流水依据用，就是那些单子同一个流水号；比如，派工单的报工单条码：派工单号；任务单的报工单条码：任务单号
  ///
  /// [submitType]：报工方式（保存条码时，需要这个参数，当[submitType]==[AppConfig.palletSubmit] 时，打印的条码总数为 1）
  ///
  /// [deviceAddCode]：设备档案-设备简称
  ///
  /// [invMnemCode]：产品档案-助记码
  Future<Map<bool, String>> Function({
    required String moOpSubmitId,
    required String printerUrl,
    required String printerName,
    required int printCopies,
    required String printType,
    MoTaskModel? taskModel,
    MoOpOrderModel? orderModel,
    MoOpSubmitModel? submitModel,
    String? billCode,
    List<BarcodeMainModel>? barcodeMainList,
    String? submitType,
    String deviceAddCode,
    String invMnemCode,
    String? reprintFrxName,
  }) get printSubmitBarcode => _printSubmitBarcode;

  
}