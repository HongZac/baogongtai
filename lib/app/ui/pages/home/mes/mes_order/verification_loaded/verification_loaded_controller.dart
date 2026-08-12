import 'package:basement/utils.dart';
import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:desktop/app/model/dfs_item_model.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///任务单-上料验证
class VerificationLoadedController
    extends BaseFormController
    with SerialPortGetXListenerMixin<VerificationLoadedController>, ScanInterface<VerificationLoadedController>,
        TcpSocketGetxListenerMixin<VerificationLoadedController> {

  ///上一个页面选中的任务单
  final MoOpOrderModel orderModel;

  ///已经扫码过了的条码 + 领料信息（生产领料单明细）列表
  final Map<String, List<MoStockEntryList>> barcodeStockMap = {};

  ///已经扫码过了的条码 + 条码信息列表
  final Map<String, BarcodeEntity?> barcodeMap = {};

  ///已选中的条码
  String selectedBarcode = '';

  final List<DFSItemModel> fieldList = [
    DFSItemModel(title: '领料单号', enTitle: 'billCode', width: 2),
    DFSItemModel(title: '物料名称', enTitle: 'invName', width: 2),
    DFSItemModel(title: '物料规格', enTitle: 'invStd', width: 2),
    DFSItemModel(title: '仓库名称', enTitle: 'whName', width: 2),
    DFSItemModel(title: '货位名称', enTitle: 'posName', width: 2),
    DFSItemModel(title: '数量', enTitle: 'quantity', alignmentX: 0),
    DFSItemModel(title: '毛重', enTitle: 'grossW', alignmentX: 0),
    DFSItemModel(title: '净重', enTitle: 'invWeight', alignmentX: 1),
  ];

  final FocusNode scanFN = FocusNode();
  final TextEditingController scanTC = TextEditingController();

  final ScrollController orderDetailController = ScrollController();


  VerificationLoadedController({
    super.progId = -1,
    required this.orderModel,
  });


  @override
  Future<void> onReady() async {
    super.onReady();
    scanFN.addListener(scanFNOnListen);
  }

  void scanFNOnListen() {
    if (scanFN.hasFocus) {
      PrintUtil.printDebug('扫码监听：得到焦点');
    }
    else{
      PrintUtil.printDebug('扫码监听：失去焦点，正在重新获取焦点');
      FocusScope.of(Get.context!).requestFocus(scanFN);
    }
  }

  ///扫码完成后提交（扫码内容的最后一个字符一定是回车符）
  Future<void> onSubmitted() async {
    await onBarcode(scanTC.text);
    scanTC.clear();
  }

  void selectedBarcodeOnChanged(String barcode) {
    selectedBarcode = barcode;
    update();
  }


  //region 串口、扫码、TCP

  @override
  Future<void> onSerialPortData(SerialPortDataModel serialPortDataModel) async {
    for (var element in serialComService.serialPortMsgProcessList){
      if (element.com == serialPortDataModel.com){
        portMsgOnData(
          element.keyName,
          data: serialPortDataModel.data,
          accuracy: element.accuracy,
        );
      }
    }
  }

  void portMsgOnData(String key, {
    required dynamic data,
    bool isWeightMsgReverseOrder = false,
    double accuracy = 0,
  }){
    switch (key){
      case AppConfig.scanGun:
      case AppConfig.cardReader:
        onBarcode(data);
        break;
    }
  }

  @override
  Future<void> onBarcode(String searchString) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (searchString.isEmpty){
      ToastNotification(Get.overlayContext!).warn('条码为空！');
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在返回扫描结果', completedMsg: '数据提交成功！');

    searchString = getBarCodePrefix(searchString, objectItem.attributeList);
    List<String> list = searchString.split('|');
    String barcode;
    if (list.length < 3){
      barcode = searchString;
    }
    else if (list[1] == 'U'){
      barcode = list[2];
    }
    else {
      ToastNotification(Get.overlayContext!).warn('条码错误，请检查设置的默认条码格式！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    var barcodeRes = await BarcodeServiceRepository().parse('U', barcode);
    if (!barcodeRes.isSuccess){
      ToastNotification(Get.overlayContext!).warn('获取条码信息时出错：${barcodeRes.message}！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    PageConfig pageConfig = PageConfig(
      page: 1, rows: 999,
      queryData: {
        'ProgID': 610031,
        'CkMoOrderId': orderModel.moOrderId,
        'InvCode': barcodeRes.data.invCode,
        'Batch': barcodeRes.data.batch,
        'Free1': barcodeRes.data.free1,
        'Free2': barcodeRes.data.free2,
        'Free3': barcodeRes.data.free3,
        'Free4': barcodeRes.data.free4,
        'Free5': barcodeRes.data.free5,
        'Free6': barcodeRes.data.free6,
        'Free7': barcodeRes.data.free7,
        'Free8': barcodeRes.data.free8,
        'Free9': barcodeRes.data.free9,
        'Free10': barcodeRes.data.free10,
        'Define22': barcodeRes.data.define22,
      }
    );
    var stockRes = await MoStockBillRepository().getEntryPageList(pageConfig);
    if (!stockRes.isSuccess){
      ToastNotification(Get.overlayContext!).warn('获取领料信息时出错：${stockRes.message}！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    if (stockRes.rows.isEmpty){
      DialogUtils.showTipsDialog(
        Get.context!,
        msg: '未找到领料信息，上料验证未通过！',
      );
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    barcodeMap.addAll({barcode: barcodeRes.data});
    barcodeStockMap.addAll({barcode: stockRes.rows});
    selectedBarcode = barcode;
    update();
    ProgressDialogUtil.update(value: 1, msg: '验证通过，正在提交数据');
    //region BarcodeMainEntity
    BarcodeMainEntity barcodeMainEntity = BarcodeMainEntity();
    barcodeMainEntity.ruleCode = 'U';
    barcodeMainEntity.numerical = 0;
    barcodeMainEntity.barcode = barcode;
    barcodeMainEntity.invID = barcodeRes.data.invID;
    barcodeMainEntity.invCode = barcodeRes.data.invCode;
    barcodeMainEntity.invName = barcodeRes.data.invName;
    barcodeMainEntity.invStd = barcodeRes.data.invStd;
    barcodeMainEntity.batch = barcodeRes.data.batch;
    barcodeMainEntity.progid = 650049;
    barcodeMainEntity.quantity = barcodeRes.data.quantity;
    barcodeMainEntity.piece = 1;
    barcodeMainEntity.empty1 = barcodeRes.data.empty1;
    barcodeMainEntity.empty2 = barcodeRes.data.define22;
    barcodeMainEntity.deleteMark = 0;
    barcodeMainEntity.preProgID = orderModel.progid;
    barcodeMainEntity.preId = orderModel.moOrderId;
    //endregion
    var barcodeSaveRes = await BarcodeMainRepository().saveForm(barcodeMainEntity);
    if (!barcodeSaveRes.isSuccess){
      ToastNotification(Get.overlayContext!).warn('验证通过，验证信息提交失败：${barcodeSaveRes.message}！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  @override
  Future<void> onTcpSocketData(TcpSocketDataModel tcpSocketDataModel) async {
    for (var element in tcpSocketService.tcpSocketMsgProcessList){
      if (element.host == tcpSocketDataModel.host && element.port == tcpSocketDataModel.port){
        portMsgOnData(
          element.keyName,
          data: tcpSocketDataModel.data,
          accuracy: element.accuracy,
        );
      }
    }
  }

  //endregion


  @override
  void onClose() {
    orderDetailController.dispose();
    super.onClose();
  }

}