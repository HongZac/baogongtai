
import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/service/serial_com_service/mixin/serial_port_getx_listener.dart';
import 'package:desktop/app/service/serial_com_service/serial_port_data_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_service.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/submit_interface/submit_print_barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/tm/submit_barcode/frx_file_name_and_data_source_type_choice/frx_file_name_and_data_source_type_choice_controller.dart';
import 'package:desktop/app/ui/pages/home/tm/submit_barcode/frx_file_name_and_data_source_type_choice/frx_file_name_and_data_source_type_choice_view.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///报工记录的条码列表
class SubmitBarcodeController
    extends BaseFormWithPageDataController<BarcodeMainModel>
    with SearchInterface,
        SerialPortGetXListenerMixin<SubmitBarcodeController>, ScanInterface<SubmitBarcodeController>,
        InvClassFrxNameInterface,
        SubmitPrintBarcodeInterface,
        InfoFormInterface,
        CommandBarInterface,
        InterfaceUtil {

  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> submitBarcodeListInfoFormListMap = {};

  get searchTypeList => List.unmodifiable(AppConfig.submitBarcodeSearchTypeList);
  get searchQueryDataList => List.unmodifiable(searchTypeList.map((e) => e.content).toSet().toList());

  final List<CommandBarBtnModel> commandBarList = [
    CommandBarBtnModel(
      title: '全选',
      keyName: 'submitBarcode-selectAll',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: null,
    ),
    CommandBarBtnModel(
      title: '全不选',
      keyName: 'submitBarcode-deselectAll',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: null,
    ),
    CommandBarBtnModel(
      title: '条码打印',
      icon: Icons.local_print_shop_rounded,
      keyName: 'submitBarcode-print',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: null,
    ),
  ];


  SubmitBarcodeController({
    super.progId = -1,
    super.isNeedGetObjectItem = false,
  });


  @override
  void onInit() {
    super.onInit();

    //region
    List<dynamic> submitBarcodeListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.SUBMIT_BARCODE_INFO_FORM_LIST_KEY) ?? [];
    submitBarcodeListInfoFormListMap.clear();
    submitBarcodeListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                submitBarcodeListInfoFormMapList,
                AppConfig.submitBarcodeListInfoFormList
            )
        )
    );

    searchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.SUBMIT_BARCODE_SEARCH_BTN_TYPE_INDEX_KEY) ?? AppConfig.searchBtnTypeIndex;

    scanQueryDataList.addAll(['preId']);
    //endregion

    dataListPageConfig.rows = 100;
    dataListPageConfig.sidx = 'Numerical';
    dataListPageConfig.sord = 'asc';
    dataListPageConfig.queryData = {}; ///PreProgID 一定是 650041 651051
  }


  @override
  Future<PageResult<BarcodeMainModel>> getDataList(PageConfig pageConfig) async{
    var res = await BarcodeMainRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取条码列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }

  void itemChanged(BarcodeMainModel item) async{
    item.isChoice = !item.isChoice;
    update();
  }

  @override
  Future<void> infoItemOnTap(ICloneable item) async{
    item as BarcodeMainModel;
    itemChanged(item);
  }

  //region 搜索

  @override
  Future<void> searchTypeOnChanged(ChoiceChipModel item, int index) async {
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (index == searchTypeIndex){
      isLoading = false;
      return;
    }
    searchTypeIndex = index;
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.SUBMIT_BARCODE_SEARCH_BTN_TYPE_INDEX_KEY, searchTypeIndex);
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
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (searchTC.text.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请填写搜索内容！");
      isLoading = false;
      return;
    }
    searchFN.unfocus();
    String? keyValue;
    switch (searchTypeIndex){
      case 2:
        //region 派工单号
        ProgressDialogUtil.showProgressDialog(msg: '正在返回搜索结果');
        PageConfig pageConfig = PageConfig(
          page: 1,
          rows: 100,
          queryData: {'taskcode': searchTC.text}
        );
        var submitRes = await MoOpSubmitRepository().getPageList(pageConfig);
        if (!submitRes.isSuccess){
          ToastNotification(Get.overlayContext!).error('报工单列表获取失败！${submitRes.message}！');
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        else if (submitRes.rows.isEmpty){
          dataList.clear();
          total = 0;
          totalPage = 0;
          nowPage = 0;
          update();
          ToastNotification(Get.overlayContext!).info('未查询到派工单信息！');
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        else {
          String preId = submitRes.rows.map((e) => e.moOpSubmitId).toList().join(',');
          keyValue = preId;
        }
        ProgressDialogUtil.close();
        //endregion
        break;
      case 3:
        //region 任务单号搜索
        ProgressDialogUtil.showProgressDialog(msg: '正在返回搜索结果');
        PageConfig pageConfig = PageConfig(
            page: 1,
            rows: 100,
            queryData: {'ordercode': searchTC.text}
        );
        var submitRes = await MoOpSubmitRepository().getPageList(pageConfig);
        if (!submitRes.isSuccess){
          ToastNotification(Get.overlayContext!).error('报工单列表获取失败！${submitRes.message}！');
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        else if (submitRes.rows.isEmpty){
          dataList.clear();
          total = 0;
          totalPage = 0;
          nowPage = 0;
          update();
          ToastNotification(Get.overlayContext!).info('未查询到任务单信息！');
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        else {
          String preId = submitRes.rows.map((e) => e.moOpSubmitId).toList().join(',');
          keyValue = preId;
        }
        ProgressDialogUtil.close();
        //endregion
        break;
    }
    searchQueryDataOnChanged(keyValue: keyValue);
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
    ProgressDialogUtil.showProgressDialog();

    searchFN.unfocus();
    searchTC.text = '';
    searchQueryDataOnChanged();
    dataList.clear();
    total = 0;
    totalPage = 0;
    nowPage = 0;
    isSearchWidgetOpen = false;

    isLoading = false;
    update();
    ProgressDialogUtil.update(value: 1);
  }

  void searchQueryDataOnChanged({String? keyValue}) {
    dataListPageConfig.queryData!.removeWhere((key, value) => searchQueryDataList.contains(key));
    String keyWord = searchTypeList[searchTypeIndex].content;
    if ((keyValue ?? '').isNotEmpty){
      dataListPageConfig.queryData![keyWord] = keyValue;
    }
    else if (searchTC.text.isNotEmpty){
      dataListPageConfig.queryData![keyWord] = searchTC.text;
    }
  }

  //endregion


  //region 串口、扫码

  @override
  Future<void> onSerialPortData(SerialPortDataModel serialPortDataModel) async {
    for (var element in weightMsgConnectService.connectList){
      if (element.com == serialPortDataModel.com){
        portMsgOnData(
          element.key,
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
      case WeightMsgConnectService.scanGun:
      case WeightMsgConnectService.cardReader:
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

    isLoading = false;
    update();
    ProgressDialogUtil.update(value: 1);
  }

  @override
  Future<void> onBarcode(String searchString) async{
    if(kDebugMode){
      //searchString = '|F|651011|475bb017-3a13-4a73-9adb-7e4a09c782e0';
      //searchString = '|F|611001|38f1fc07-4c50-42d3-9382-fb5fd2301ff6';
    }
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
    bool res = false;
    ProgressDialogUtil.showProgressDialog(msg: '正在返回扫描结果');

    searchString = getBarCodePrefix(searchString, objectItem.attributeList);
    if (searchString.startsWith('|CA') || searchString.startsWith('|CB')){
      scanQueryDataOnChanged(keyWord: 'Barcode', keyValue: searchString);
      res = await pageChanged(pageIndex: 1, showLoading: false);
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
        case 'F':
          //region 生产任务单条码 610001；生产派工单条码 650011；注塑任务单条码 611001；注塑派工单 651011
          if (list.length == 4){
            if (list[2] == '650011' || list[2] == '651011'){  ///派工单
              PageConfig pageConfig = PageConfig(
                  page: 1,
                  rows: 100,
                  queryData: {'TaskId': list[3]}
              );
              var submitRes = await MoOpSubmitRepository().getPageList(pageConfig);
              if (!submitRes.isSuccess){
                ToastNotification(Get.overlayContext!).error('报工单列表获取失败：${submitRes.message}！');
                ProgressDialogUtil.close();
                isLoading = false;
                return;
              }
              else if (submitRes.rows.isEmpty){
                dataList.clear();
                total = 0;
                totalPage = 0;
                nowPage = 0;
                ToastNotification(Get.overlayContext!).info('未查询到派工单信息！');
                res = true;
              }
              else {
                String preId = submitRes.rows.map((e) => e.moOpSubmitId).toList().join(',');
                scanQueryDataOnChanged(keyWord: 'preId', keyValue: preId);
                res = await pageChanged(pageIndex: 1, showLoading: false);
              }
            }
            else if (list[2] == '610001' || list[2] == '611001'){ ///任务单
              PageConfig pageConfig = PageConfig(
                  page: 1,
                  rows: 100,
                  queryData: {'MoOrderId': list[3]}
              );
              var submitRes = await MoOpSubmitRepository().getPageList(pageConfig);
              if (!submitRes.isSuccess){
                ToastNotification(Get.overlayContext!).error('报工单列表获取失败！${submitRes.message}！');
                ProgressDialogUtil.close();
                isLoading = false;
                return;
              }
              else if (submitRes.rows.isEmpty){
                dataList.clear();
                total = 0;
                totalPage = 0;
                nowPage = 0;
                ToastNotification(Get.overlayContext!).info('未查询到任务单信息！');
                res = true;
              }
              else {
                String preId = submitRes.rows.map((e) => e.moOpSubmitId).toList().join(',');
                scanQueryDataOnChanged(keyWord: 'preId', keyValue: preId);
                res = await pageChanged(pageIndex: 1, showLoading: false);
              }
            }
            else {
              ToastNotification(Get.overlayContext!).warn('条码错误！');
              isLoading = false;
              ProgressDialogUtil.close();
              return;
            }
          }
          else {
            ToastNotification(Get.overlayContext!).warn('条码错误！');
            isLoading = false;
            ProgressDialogUtil.close();
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
      dataListPageConfig.queryData![keyWord] = keyValue;
    }
  }

  //endregion


  //region commandBar

  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    switch (keyName){
      case 'submitBarcode-selectAll':
        dataList.forEach((element) {
          element.isChoice = true;
        });
        update();
        break;
      case 'submitBarcode-deselectAll':
        dataList.forEach((element) {
          element.isChoice = false;
        });
        update();
        break;
      case 'submitBarcode-print':
        await printBarcode();
        break;
    }
  }

  ///条码打印
  Future<void> printBarcode() async{
    if (isLoading){
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    //region 提交前判断
    List<BarcodeMainModel> selectDataList = dataList.where((element) => element.isChoice).toList();
    if (selectDataList.isEmpty){
      ToastNotification(Get.overlayContext!).warn("请选择要补打的条码！");
      isLoading = false;
      return;
    }
    List<String> submitIdList = [];
    selectDataList.forEach((element) {
      if (submitIdList.firstWhereOrNull((element1) => element1 == (element.preId ?? '')) == null){
        submitIdList.add(element.preId ?? '');
      }
    });
    if (submitIdList.contains('')){
      ToastNotification(Get.overlayContext!).warn("当前选中条码无报工数据，请检查！");
      isLoading = false;
      return;
    }
    if (submitIdList.length > 1){
      ToastNotification(Get.overlayContext!).warn("不能同时打印不同报工单的条码！");
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认补打条码？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    Map<String, dynamic> printInfoMap = await getPrintInfo();
    String printerUrl = printInfoMap['printerUrl']!; ///打印机Url
    String printerName = printInfoMap['printerName']!; ///打印机Name
    int printCopies = printInfoMap['printCopies']!; ///打印份数
    String printType = printInfoMap['printType']!; ///打印方式
    //region 获取模板文件名称、数据源类型（服务端打印用）
    var frxNameRes = await DialogUtils.showCustomDialog<FrxFileNameAndDataSourceTypeChoiceController, Map<String, dynamic>>(
      Get.context!,
      initialWidth: 550, initialHeight: 700,
      title: '打印模板、数据源选择', onConfirmName: '确认',
      contentPadding: const EdgeInsets.all(12),
      content: FrxFileNameAndDataSourceTypeChoiceView(),
      controller: FrxFileNameAndDataSourceTypeChoiceController(
        printType: printType,
        invCCode: selectDataList[0].invCCode ?? '',
      ),
    );
    if (frxNameRes == null){
      ToastNotification(Get.overlayContext!).error('请选择打印模板和数据源！');
      isLoading = false;
      return;
    }
    frxName = frxNameRes['frxFileName'];
    String dataSourceType = frxNameRes['dataSourceType'];
    //endregion

    ProgressDialogUtil.showProgressDialog(msg: '正在打印', completedMsg: '打印成功！');
    MoTaskModel? taskModel;
    MoOpOrderModel? orderModel;
    MoOpSubmitModel? submitModel;
    //region 获取源单数据源 [taskModel]、[orderModel]、[submitModel]
    if ((selectDataList[0].preId ?? '').isNotEmpty){
      var submitRes = await MoOpSubmitRepository().getFormData(selectDataList[0].preId!);
      if (!submitRes.isSuccess){
        ToastNotification(Get.overlayContext!).error('获取报工单数据时失败！');
        ProgressDialogUtil.close();
        isLoading = false;
        return;
      }
      submitModel = submitRes.data;
    }
    if (dataSourceType == 'task'){
      if ((submitModel?.taskId ?? '').isNotEmpty){
        var taskRes = await MoTaskRepository().getFormData(submitModel!.taskId!);
        if (!taskRes.isSuccess){
          ToastNotification(Get.overlayContext!).error('获取派工单数据时失败！');
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        taskModel = taskRes.data;
      }
    }
    if (dataSourceType == 'task' || dataSourceType == 'order'){
      if ((submitModel?.moOrderId ?? '').isNotEmpty){
        var orderRes = await MoOrderRepository().getFormData(submitModel!.moOrderId!);
        if (!orderRes.isSuccess){
          ToastNotification(Get.overlayContext!).error('获取任务单数据时失败！');
          ProgressDialogUtil.close();
          isLoading = false;
          return;
        }
        orderModel = orderRes.data;
      }
    }
    //endregion
    Map<bool, String> printRes = await printSubmitBarcode(
      moOpSubmitId: selectDataList[0].preId ?? '',
      printerUrl: printerUrl,
      printerName: printerName,
      printCopies: printCopies,
      printType: printType,
      taskModel: taskModel,
      orderModel: orderModel,
      submitModel: submitModel,
      barcodeMainList: selectDataList,
      reprintFrxName: frxName,
    );
    if (printRes.containsKey(true)) {
      ProgressDialogUtil.update();
      ToastNotification(Get.overlayContext!).info(printRes[true]!);
    }
    else {
      ToastNotification(Get.overlayContext!).error(printRes[false] ?? '');
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }

    isLoading = false;
  }

  //endregion


  @override
  void onClose() {
    super.onClose();
  }

}