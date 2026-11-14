
import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/pdf_controller_with_key_model.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/ui/pages/attach_view/attach_utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/inventory_search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';


///产品图纸查询 首页
class InventoryAttachController
    extends BaseFormWithPageDataController<InventoryModel>
    with SearchInterface, InventorySearchInterface,
        SerialPortGetXListenerMixin<InventoryAttachController>, ScanInterface<InventoryAttachController>,
        TcpSocketGetxListenerMixin<InventoryAttachController> {

  ///附件列表 key：产品ID
  final Map<String, List<DMDocumentModel>> attachListMap = {};
  ///当前页面显示的附件总数量
  int nowPageAttachTotal = 0;

  final List<PdfControllerWithKeyModel> pdfControllerList = [];


  InventoryAttachController({
    super.progId = 200025,
  });


  @override
  void onInit() {
    super.onInit();

    searchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INVENTORY_ATTACH_SEARCH_BTN_TYPE_INDEX_KEY) ?? AppConfig.searchBtnTypeIndex;

    scanQueryDataList.addAll(['InvID']);

    dataListPageConfig.rows = 10;
    dataListPageConfig.sidx = 'EngineerFigNo';
    dataListPageConfig.sord = 'asc';
  }


  @override
  Future<bool> initializeForm() async {
    return true;
  }

  @override
  Future<PageResult<InventoryModel>> getDataList(PageConfig pageConfig) async{
    var res = await InventoryRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取产品列表时出错：${res.message}');
      return PageResult();
    }
    await getAttachList(res.rows);
    getPdfControllerList();
    return res;
  }


  ///获取产品图纸列表
  Future<void> getAttachList(List<InventoryModel> invList) async {
    attachListMap.clear();
    nowPageAttachTotal = 0;
    if (invList.isEmpty){ return; }
    for (var element in invList) {
      var res1 = await FormRepository().getDocument('attach', progId, element.invID ?? '');
      if (!res1.isSuccess){
        ToastNotification(Get.overlayContext!).error('读取附件时出错！${res1.message}');
        return;
      }
      var res2 = await FormRepository().getDocument('image', progId, element.invID ?? '');
      if (!res2.isSuccess){
        ToastNotification(Get.overlayContext!).error('读取图片时出错！${res1.message}');
        return;
      }
      attachListMap[element.invID ?? ''] = [];
      if (res1.data.initialPreviewConfig != null && res1.data.initialPreviewConfig!.isNotEmpty){
        attachListMap[element.invID ?? '']!.add(res1.data);
        nowPageAttachTotal += res1.data.initialPreviewConfig!.length;
      }
      if (res2.data.initialPreviewConfig != null && res2.data.initialPreviewConfig!.isNotEmpty){
        attachListMap[element.invID ?? '']!.add(res2.data);
        nowPageAttachTotal += res2.data.initialPreviewConfig!.length;
      }
    }
  }

  ///把 pdf 的第一张转换成图片格式
  Future<void> getPdfControllerList() async {
    pdfControllerList.clear();
    for (var element in attachListMap.values.toList()) {
      for (var element3 in element) {
        if (element3.initialPreviewConfig != null && element3.initialPreviewConfig!.isNotEmpty){
          for (int index = 0; index < element3.initialPreviewConfig!.length; index ++){
            InitialPreviewConfigModel initialPreviewConfigModel = element3.initialPreviewConfig![index];
            if (initialPreviewConfigModel.type == 'pdf'){
              String url = element3.initialPreview?.asMap()[index] ?? '';
              if (url.isNotEmpty){
                var pdfControllerWithKeyModel = await AttachUtils().getPdfUint8List(
                    key: initialPreviewConfigModel.key ?? '',
                    url: url
                );
                pdfControllerList.add(pdfControllerWithKeyModel);
              }
            }
          }
        }
      }
    }
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
  Future<void> resetScan() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    ProgressDialogUtil.showProgressDialog();

    await super.resetScan();
    scanQueryDataOnChanged();
    dataList.clear();
    total = 0;
    totalPage = 0;
    nowPage = 0;
    attachListMap.clear();
    nowPageAttachTotal = 0;
    pdfControllerList.clear();
    isLoading = false;
    update();
    ProgressDialogUtil.update(value: 1);
  }

  ///扫码接收处理
  @override
  Future<void> onBarcode(String searchString) async {
    if (kDebugMode){
      //searchString = '|B|03.017.190|输出轴|8HY.030C.044-1|03.017.190';
    }
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (searchString.isEmpty){
      ToastNotification(Get.overlayContext!).warn('条码为空！');
      isLoading = false;
      return;
    }
    bool res = false;
    ProgressDialogUtil.showProgressDialog(msg: '正在返回扫描结果');

    searchString = getBarCodePrefix(searchString, objectItem.attributeList);
    if (searchString.substring(0, 1) == r'$'){
      ///该条码查询独立于其他条件查询
      ApiResult<InventoryModel> res = await splitBy$BarcodeCheckInv<InventoryModel>(
        searchString,
        rows: 1,
      );
      if (!res.isSuccess){
        ToastNotification(Get.overlayContext!).error('${res.info}');
        ProgressDialogUtil.close();
        isLoading = false;
        return;
      }
      await getAttachList([res.data!]);
      getPdfControllerList();
    }
    else {
      List<String> list = searchString.split('|');
      if (list.length < 3){
        ToastNotification(Get.overlayContext!).warn('条码错误，请检查设置的默认条码格式！');
        isLoading = false;
        ProgressDialogUtil.close();
        return;
      }
      switch (list[1]){
        case 'B':
          //region 物料条码
          if (list.length == 5){
            scanQueryDataOnChanged(keyWord: 'InvID', keyValue: list[4]);
            res = await pageChanged(showLoading: false);
          }
          else {
            ToastNotification(Get.overlayContext!).warn('条码错误！');
            ProgressDialogUtil.close();
            isLoading = false;
            return;
          }
          //endregion
          break;
        default:
          ToastNotification(Get.overlayContext!).warn('条码错误！');
          isLoading = false;
          ProgressDialogUtil.close();
          return;
      }
    }

    isDataByScan = true;
    isLoading = false;
    update();
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1);
    }
  }

  void scanQueryDataOnChanged({String? keyWord, String? keyValue}) {
    dataListPageConfig.queryData!.removeWhere((key, value) => scanQueryDataList.contains(key));
    if (keyWord != null){
      ///如果是扫码查询的话，todo
      dataListPageConfig.queryData![keyWord] = keyValue;
    }
  }

  //endregion


  //region 搜索

  @override
  Future<void> searchTypeOnChanged(ChoiceChipModel item, int index) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (index == inventorySearchTypeIndex){
      isLoading = false;
      return;
    }
    inventorySearchTypeIndex = index;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INVENTORY_ATTACH_SEARCH_BTN_TYPE_INDEX_KEY, inventorySearchTypeIndex);
    searchQueryDataOnChanged();
    if (searchTC.text.isNotEmpty){
      await pageChanged();
    }
    update();
    isLoading = false;
  }

  @override
  void searchTCOnChanged() {
    searchQueryDataOnChanged();
    update();
  }

  @override
  Future<void> onSearch() async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchFN.unfocus();
    searchQueryDataOnChanged();
    await pageChanged();
    update();
    isLoading = false;
  }

  @override
  Future<void> searchTCOnClear() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    searchFN.unfocus();
    searchTC.text = '';
    searchQueryDataOnChanged();
    dataList.clear();
    total = 0;
    totalPage = 0;
    nowPage = 0;
    attachListMap.clear();
    nowPageAttachTotal = 0;
    pdfControllerList.clear();

    isSearchWidgetOpen = false;
    update();
    isLoading = false;
  }

  void searchQueryDataOnChanged() {
    dataListPageConfig.queryData!.removeWhere((key, value) => inventorySearchQueryDataList.contains(key));
    if (searchTC.text.isNotEmpty){
      String keyWord = searchTypeList[inventorySearchTypeIndex].content;
      dataListPageConfig.queryData![keyWord] = searchTC.text;
    }
  }

  //endregion


  @override
  void onClose() {
    searchTC.dispose();
    searchFN.dispose();
    super.onClose();
  }

}