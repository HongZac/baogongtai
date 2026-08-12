import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_form_with_page_data/base_form_with_page_data_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/inventory_search_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/search_interface/search_interface.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';


///物料条码新增查看 首页
class InvBarcodeController
    extends BaseFormWithPageDataController<InventoryModel>
    with SearchInterface, InventorySearchInterface,
        SerialPortGetXListenerMixin<InvBarcodeController>, ScanInterface<InvBarcodeController>,
        TcpSocketGetxListenerMixin<InvBarcodeController>,
        InfoFormInterface,
        CommandBarInterface,
        InterfaceUtil {

  ///数据字段列表（已分组）
  final Map<int, List<InfoFormModel>> invBarcodeListInfoFormListMap = {};

  ///任务单列表页面显示的按钮组列表
  final List<CommandBarBtnModel> invBarcodeCommandBarList = [];


  InvBarcodeController({
    super.progId = 230004,
  });


  @override
  void onInit() {
    super.onInit();

    //region
    isShowSearchInputBox = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_IS_SHOW_SEARCH_INPUT_BOX_KEY) ?? AppConfig.isShowSearchInputBox;
    inventorySearchTypeIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_SEARCH_TYPE_INDEX_KEY) ?? AppConfig.searchTypeIndex;

    scanQueryDataList.addAll(['InvID']);

    List<dynamic> invBarcodeListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_INFO_FORM_LIST_KEY) ?? [];
    invBarcodeListInfoFormListMap.clear();
    invBarcodeListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                invBarcodeListInfoFormMapList,
                AppConfig.invBarcodeInvListInfoFormList
            )
        )
    );

    List<dynamic> invBarcodeCommandBarMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_COMMAND_BAR_LIST_KEY) ?? [];
    invBarcodeCommandBarList.clear();
    invBarcodeCommandBarList.addAll(
        getCommandBarListByStorage(
            invBarcodeCommandBarMapList,
            AppConfig.invBarcodeCommandBarList
        )
    );
    //endregion

    dataListPageConfig.rows = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
    dataListPageConfig.sidx = 'InvCode';
    dataListPageConfig.queryData = {  };
  }

  @override
  Future<PageResult<InventoryModel>> getDataList(PageConfig pageConfig) async {
    var res = await InventoryRepository().getPageList(pageConfig);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取生产任务单列表时出错：${res.message}');
      return PageResult();
    }
    return res;
  }


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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_SEARCH_TYPE_INDEX_KEY, inventorySearchTypeIndex);
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
    await pageChanged();
    isSearchWidgetOpen = false;
    update();
    isLoading = false;
  }

  void searchQueryDataOnChanged() {
    dataListPageConfig.queryData!.removeWhere((key, value) => inventorySearchQueryDataList.contains(key));
    if (searchTC.text.isNotEmpty){
      String keyWord = inventorySearchTypeList[inventorySearchTypeIndex].content;
      dataListPageConfig.queryData![keyWord] = searchTC.text;
    }
  }

  //endregion


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
  
  
  //region 扫描

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
    bool res = await pageChanged(showLoading: false);
    isLoading = false;
    update();
    if (!res){
      ProgressDialogUtil.close();
    }
    else {
      ProgressDialogUtil.update(value: 1);
    }
  }

  @override
  Future<void> onBarcode(String searchString) async {
    ///|B|t5|1|9b7c0544-1f3e-4c80-81f1-104e68387d41
    if (kDebugMode){
      searchString = '|B|t5|1|9b7c0544-1f3e-4c80-81f1-104e68387d41';
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
    List<String> list = searchString.split('|');
    if (list.length < 3){
      ToastNotification(Get.overlayContext!).warn('条码错误，请检查设置的默认条码格式！');
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    switch (list[1]){
      case 'B':
        if (list.length == 5){
          scanQueryDataOnChanged(keyWord: 'InvID', keyValue: list[4]);
          res = await pageChanged(showLoading: false);
        }
        break;
      default:
        ToastNotification(Get.overlayContext!).warn('条码错误！');
        isLoading = false;
        ProgressDialogUtil.close();
        return;
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


  //region OnTap

  @override
  void settingOnTap(){
     Get.rootDelegate.toNamed(
      AppRoutes.INV_BARCODE_SETTING_PAGE,
      parameters: {
        'noPermission': (dataService.isEnableOperatePrivilege
            && objectItem.buttons?['desktopUISettingBtn'] == null) ? '1' : '0',
        'permissionInfo': BaseService.profile.isSystem == true ? '【${objectItem.progid}】【desktopUISettingBtn】' : '',
      },
    );
  }

  @override
  Future<void> commandBarOnPressed(String keyName, ICloneable item) async {
    item as InventoryModel;
    switch (keyName){
      case '${AppConfig.invBarcodeBtn}-${AppConfig.detail}':
        await itemOnDoubleTap(item);
        break;
      case '${AppConfig.invBarcodeBtn}-${AppConfig.expanded}':
        invItemExpandedOnChanged(item);
        break;
    }
  }

  ///Item“展开按钮”点击变化
  void invItemExpandedOnChanged(InventoryModel item){
    item.isExpanded = !item.isExpanded;
    update();
  }

  Future<void> itemOnDoubleTap(InventoryModel item) async{
    Get.rootDelegate.toNamed(
        AppRoutes.INV_BARCODE_DETAIL_MAIN_PAGE,
        arguments: InventoryModel.fromJson(item.toJson()),
        parameters: {
          'key': item.invID ?? '',
          'noPermission': (dataService.isEnableOperatePrivilege
              && objectItem.buttons?['desktopUISettingBtn'] == null) ? '1' : '0',
          'permissionInfo': BaseService.profile.isSystem == true ? '【${objectItem.progid}】【desktopUISettingBtn】' : '',
        }
    );
  }


  ///查看产品附件
  Future<void> getInvAttach(InventoryModel item) async {
    if (item.invID == null || item.invID!.isEmpty){
      ToastNotification(Get.overlayContext!).error('该产品信息有错误！');
      return;
    }
    Get.rootDelegate.toNamed(
      AppRoutes.INV_BARCODE_ITEM_ATTACH_PAGE,
      parameters: {
        'pageTitle': '产品附件-${item.invName}',
        'id': item.invID!,
        'progId': '200025',
        'category': 'attach',
      }
    );
  }

  //endregion

}