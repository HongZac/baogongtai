import 'package:basement/basement.dart';
import 'package:basement/model.dart';
import 'package:basement/picker.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/mixin/serial_port_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/serial_com_service/model/serial_port_data_model.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/mixin/tcp_socket_getx_listener_mixin.dart';
import 'package:desktop/app/service/tcp_serial/tcp_socket_service/model/tcp_socket_data_model.dart';
import 'package:desktop/app/service/tcp_serial/utils/tcp_serial_data_utils.dart';
import 'package:desktop/app/ui/pages/home/base/base_form/base_form_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/barcode_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_barcode_interface/inv_barcode_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_barcode_interface/inv_barcode_print_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/detail_tab/inv_barcode_detail_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/list/inv_barcode_list_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/tips_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../base/interface/interface_util.dart';


///物料条码新增查看 新增条码页面 230004
class InvBarcodeAddFormController
    extends BaseFormController
    with InfoFormInterface,
        SerialPortGetXListenerMixin<InvBarcodeAddFormController>, ScanInterface<InvBarcodeAddFormController>,
        TcpSocketGetxListenerMixin<InvBarcodeAddFormController>,
        InvClassFrxNameInterface,
        InvBarcodePrintInterface,
        InvBarcodeInterface,
        InterfaceUtil {

  late final InvBarcodeDetailTabController invBarcodeDetailTabController;

  ///物料条码新增表单页面-数据字段列表
  final List<InfoFormModel> invInfoFormList = [];

  @override
  final List<NumPadController> numPadCTList = [
    NumPadController(key: NumPadUtil.eBWeight), ///称重重量(g)
    NumPadController(key: NumPadUtil.eBPiece), ///称重件数
    NumPadController(key: NumPadUtil.pieceWeight, enabled: false), ///实际单重(g)
    //NumPadController(key: NumPadUtil.packingWeight), ///单箱皮重(kg)
    NumPadController(key: NumPadUtil.num), ///入库箱数（装箱数）(整箱箱数)
    NumPadController(key: NumPadUtil.boxNumOfPallet), ///单托箱数 只读，总数量 / 单箱数量，有余数进一位
    NumPadController(key: NumPadUtil.singleBoxQty), ///单箱数量 单箱件数（一箱里面装几个）（从数据库中读取，且数据可修改）
    NumPadController(key: NumPadUtil.lastBoxQty), ///尾箱数量 尾箱件数（箱子中数量未装满）（按托填报时，只读）
    NumPadController(key: NumPadUtil.singleBoxWeight), ///单箱重量(kg)
    NumPadController(key: NumPadUtil.lastBoxWeight), ///尾箱重量(kg)
    NumPadController(key: NumPadUtil.qty), ///总数量
    NumPadController(key: NumPadUtil.weight), ///总重(kg)
    //NumPadController(key: NumPadUtil.boxWeight), ///箱重（按托填报时使用，员工直接输入，数值 ~= 单箱数量 * 产品实际单重 + 皮重） (kg)
  ];

  final bool showAppBar;

  ///重量超额限制比例（标准单重与实际单重允许的偏差百分比）
  double get limitWeightDeviationValue => double.tryParse(accInformationMap['limit.weight']?.text?.toString() ?? '') ?? AppConfig.limitWeightDeviationValue;


  InvBarcodeAddFormController({
    super.progId = 230004,
    super.isShowProgressDialogInOnReady = true,
    required InventoryModel inventoryModel,
    this.showAppBar = true,
  }){
    this.inventoryModel = inventoryModel;
  }


  Map<String, String> setAccItemMap(){
    return {'limit.weight': 'pdm'};
  }


  @override
  void onInit() {
    super.onInit();

    List<dynamic> invInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_INFO_FORM_LIST_KEY) ?? [];
    invInfoFormList.clear();
    invInfoFormList.addAll(
        getInfoFormListByStorage(
            invInfoFormMapList,
            AppConfig.invBarcodeInvFormInfoFormList
        )
    );

    invBarcodeSaveBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_SAVE_BTN_INDEX_KEY) ?? AppConfig.invBarcodeSaveBtnIndex;
    isGetBackAfterSaveSuccess = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
    isShowSaveTypeBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
    saveType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_TYPE_KEY) ?? AppConfig.qtySubmit;
    calcRuleForPalletSaveType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_CALC_RULE_FOR_PALLET_SAVE_TYPE_KEY) ?? AppConfig.calcRuleForPalletSubmitType;
    String formTitleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_FORM_TITLE_MAP_KEY) ?? '';
    formTitleMap.clear();
    formTitleMap.addAll(getFormTitleMapByStorage(formTitleMapStr, AppConfig.invBarcodeFormFormTitleMap));
    numPadCTList.sort((a, b){
      return numPadCTListSortVoidCallback.call(formTitleMap, a, b);
    });
    String formStyleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_FORM_STYLE_MAP_KEY) ?? '';
    formStyleMap.clear();
    formStyleMap.addAll(getFormStyleMapByStorage(formStyleMapStr, AppConfig.invBarcodeFormFormStyleMap));
    numPadCTList.forEach((element) {
      element.styleMap.clear();
      if (formStyleMap.containsKey(element.key)){
        element.styleMap.addAll(formStyleMap[element.key]!);
      }
    });
    numPadFocusField = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
    formRowMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_FORM_ROW_MAX_COUNT_LIMIT_KEY) ?? AppConfig.formRowMaxCountLimit;
    numMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_NUM_MAX_COUNT_LIMIT_KEY) ?? AppConfig.numMaxCountLimit;
    singleBoxQtyMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_SINGLE_BOX_QTY_MAX_COUNT_LIMIT_KEY) ?? AppConfig.singleBoxQtyMaxCountLimit;
    weightIsAddPieceWeightToTotal = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_WEIGHT_IS_ADD_PIECE_WEIGHT_TO_TOTAL_KEY) ?? AppConfig.weightIsAddPieceWeightToTotal;
    isShowExpectSingleBoxQty = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_IS_SHOW_EXPECT_SINGLE_BOX_QTY_KEY) ?? AppConfig.isShowExpectSingleBoxQty;
    isSaveTheLastPackingWeightData = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY) ?? AppConfig.isSaveTheLastPackingWeightData;
    isUsePackingPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_IS_USE_PACKING_PICKER_KEY) ?? AppConfig.isUsePackingPicker;
    isSingleBoxQtyOnlyChangedByContainer = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY) ?? AppConfig.isSingleBoxQtyOnlyChangedByContainer;
    frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_TEMPLATE_FILENAME_KEY) ?? AppConfig.invBarcodePrintFileName;
    String invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_FORM_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMap.clear();
    invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { ///页面build完后调用
      if (!showAppBar){
        invBarcodeDetailTabController = Get.find<InvBarcodeDetailTabController>();
      }
    });
    numPadCTListSetEnabled();
  }


  @override
  Future<void> onReady() async{
    await super.onReady();
  }


  Future<bool> initializeForm() async {
    setFormJudgeTypeMap();
    setWeightFormDecimalLengthMap();
    setSaveDataAndAdapter(
      isInit: true,
      progId: progId,
    );

    ///写入历史皮重（单箱数量）数据
    if (isSaveTheLastPackingWeightData){
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        ///如果使用装箱容器，需要等待 containerWithNoPageAdapter 被赋值后，再写入历史皮重数据
        if (!isUsePackingPicker || containerWithNoPageAdapter != null){
          await setTheLastPackingWeightData(
            theLastContainerSelectedValue: ShareStorageUtil.instance?.read(
                SharedPreferencesKeys.INV_BARCODE_FORM_THE_LAST_CONTAINER_SELECTED_VALUE_KEY
            ),
            theLastPackingWeightValue: ShareStorageUtil.instance?.read(
                SharedPreferencesKeys.INV_BARCODE_FORM_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY
            ),
            theLastSingleBoxQtyValue: ShareStorageUtil.instance?.read(
                SharedPreferencesKeys.INV_BARCODE_FORM_THE_LAST_NUM_PAD_SINGLE_BOX_QTY_VALUE_KEY
            ),
          );
          return false;
        }
        return true;
      });
    }

    /*///写入实际单重数据
    if (isAutoWritePieceWeight){
      getPieceWeightBtnOnTap();
    }*/
    
    return true;
  }


  //region OnChanged

  @override
  void saveTypeOnChanged(ChoiceChipModel item) {
    if (saveType == item.keyName){ return; }
    super.saveTypeOnChanged(item);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_TYPE_KEY, saveType);
    numPadCTList.forEach((element) {
      element.controller.clear();
    });
    //updateFormJudgeTypeMap();
    containerWithNoPageAdapter?.clearSelection();

    ///历史皮重数据赋值
    if (isSaveTheLastPackingWeightData){
      setTheLastPackingWeightData(
        theLastContainerSelectedValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.INV_BARCODE_FORM_THE_LAST_CONTAINER_SELECTED_VALUE_KEY
        ),
        theLastPackingWeightValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.INV_BARCODE_FORM_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY
        ),
        theLastSingleBoxQtyValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.INV_BARCODE_FORM_THE_LAST_NUM_PAD_SINGLE_BOX_QTY_VALUE_KEY
        ),
      );
    }

    /*///写入实际单重数据
    if (isAutoWritePieceWeight){
      getPieceWeightBtnOnTap();
    }*/

    update();
  }

  @override
  void containerOnChanged(PickerDataModel model) {
    super.containerOnChanged(model);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_THE_LAST_CONTAINER_SELECTED_VALUE_KEY, model.id);
  }

  Future<void> getOtherInventory(InventoryModel item, {bool isOtherPageNeedChanged = true}) async {
    if (inventoryModel.invID == item.invID){
      return;
    }
    inventoryModel = item;
    await setSaveDataAndAdapter(
      isInit: false,
    );
    if (isOtherPageNeedChanged){
      if (!showAppBar){
        invBarcodeDetailTabController.inventoryModel = InventoryModel.fromJson(inventoryModel.toJson());
        invBarcodeDetailTabController.key = inventoryModel.invID ?? '';
      }

      //region 刷新条码列表的数据
      InvBarcodeListController? invBarcodeListController;
      try {
        invBarcodeListController = Get.find<InvBarcodeListController>();
      } catch (e){}
      if (invBarcodeListController != null){
        invBarcodeListController.dataListPageConfig.queryData!['InvID'] = inventoryModel.invID;
        await invBarcodeListController.pageChanged(showLoading: false);
        invBarcodeListController.update();
      }
      //endregion
    }
  }

  //endregion
  

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
      case AppConfig.dSEBWeight:
        //region 称重重量
        if (saveType == AppConfig.weight){ return; }
        String formatValue = TcpSerialDataUtils.getFormatValue(
          data,
        );
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.eBWeight, numPadCTList) ?? '';
        bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
            oldValue: double.tryParse(_oldString),
            value: double.tryParse(formatValue) ?? 0,
            errorRange: accuracy
        );
        if (isLessThen){ return; }
        //endregion
        NumPadUtil().setText(NumPadUtil.eBWeight, formatValue, numPadCTList, isDataByWeightMsg: true);
        calcQty(NumPadUtil.eBWeight);
        //endregion
        break;
      case AppConfig.dSEBWeightForWeightSubmitType:
        //region 报单重的称重重量消息
        if (saveType != AppConfig.weight) { return; }
        String formatValue = TcpSerialDataUtils.getFormatValue(
          data,
        );
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.eBWeight, numPadCTList) ?? '';
        bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
            oldValue: double.tryParse(_oldString),
            value: double.tryParse(formatValue) ?? 0,
            errorRange: accuracy
        );
        if (isLessThen){ return; }
        //endregion
        NumPadUtil().setText(NumPadUtil.eBWeight, formatValue, numPadCTList, isDataByWeightMsg: true);
        calcQty(NumPadUtil.eBWeight);
        //endregion
        break;
      case AppConfig.dSPackingWeight:
        //region 单箱皮重
        if (isUsePackingPicker || saveType == AppConfig.weight || saveType == AppConfig.palletSubmit){ return; }
        //region 数据处理
        String formatValue = '';
        if (data.length > 3 && data.substring(0, 3) == '|O|'){ ///容器条码(周转箱条码): |O|序列号|皮重
          List<String> _list  = data.split('|');
          formatValue = TcpSerialDataUtils.getFormatValue(_list.last);
        }
        else {
          formatValue = TcpSerialDataUtils.getFormatValue(
            data,
          );
        }
        //endregion
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '';
        bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
            oldValue: double.tryParse(_oldString),
            value: double.tryParse(formatValue) ?? 0,
            errorRange: accuracy
        );
        if (isLessThen){ return; }
        //endregion
        NumPadUtil().setText(NumPadUtil.packingWeight, formatValue, numPadCTList, isDataByWeightMsg: true);
        calcQty(NumPadUtil.packingWeight);
        //endregion
        break;
      case AppConfig.dSSingleBoxWeight:
        //region 单箱重量
        if (isShowExpectSingleBoxQty){
          if (saveType == AppConfig.qtyBoxSubmit || saveType == AppConfig.weightBoxSubmit){
            String formatValue = TcpSerialDataUtils.getFormatValue(
              data,
            );
            //region 判断差值
            bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
                oldValue: singleBoxWeightForExpect,
                value: double.tryParse(formatValue) ?? 0,
                errorRange: accuracy
            );
            if (isLessThen){ return; }
            //endregion
            singleBoxWeightForExpect = double.tryParse(formatValue);
          }
        }
        else if (saveType == AppConfig.weightBoxSubmit) {
          String formatValue = TcpSerialDataUtils.getFormatValue(
            data,
          );
          //region 判断差值
          String _oldString = NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '';
          bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
              oldValue: double.tryParse(_oldString),
              value: double.tryParse(formatValue) ?? 0,
              errorRange: accuracy
          );
          if (isLessThen){ return; }
          //endregion
          NumPadUtil().setText(NumPadUtil.singleBoxWeight, formatValue, numPadCTList, isDataByWeightMsg: true);
          calcQty(NumPadUtil.singleBoxWeight);
        }
        //endregion
        break;
      case AppConfig.dSLastBoxWeight:
        //region 尾箱重量
        if (saveType != AppConfig.weightBoxSubmit) { return; }
        String formatValue = TcpSerialDataUtils.getFormatValue(
          data,
        );
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.lastBoxWeight, numPadCTList) ?? '';
        bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
            oldValue: double.tryParse(_oldString),
            value: double.tryParse(formatValue) ?? 0,
            errorRange: accuracy
        );
        if (isLessThen){ return; }
        //endregion
        NumPadUtil().setText(NumPadUtil.lastBoxWeight, formatValue, numPadCTList, isDataByWeightMsg: true);
        calcQty(NumPadUtil.lastBoxWeight);
        //endregion
        break;
      case AppConfig.dSWeight:
        //region 总重
        if (saveType != AppConfig.weightSubmit && saveType != AppConfig.weightBoxSubmit) { return; }
        String formatValue = TcpSerialDataUtils.getFormatValue(
          data,
        );
        //region 判断差值
        String _oldString = NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '';
        bool isLessThen = TcpSerialDataUtils.isWithinAcceptableErrorRange(
            oldValue: double.tryParse(_oldString),
            value: double.tryParse(formatValue) ?? 0,
            errorRange: accuracy
        );
        if (isLessThen){ return; }
        //endregion
        NumPadUtil().setText(NumPadUtil.weight, formatValue, numPadCTList, isDataByWeightMsg: true);
        calcQty(NumPadUtil.weight);
        //endregion
        break;
      case AppConfig.scanGun:
      case AppConfig.cardReader:
        onBarcode(data);
        break;
    }
  }

  @override
  Future<void> onBarcode(String searchString) async {
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
    ProgressDialogUtil.showProgressDialog(msg: '正在返回扫描结果');

    searchString = getBarCodePrefix(searchString, objectItem.attributeList);
    List<String> list = searchString.split('|');
    if (list.length < 3){
      TipsUtils.showTip(
        msg: '条码错误，请检查设置的默认条码格式！',
        toastType: ToastType.warn,
      );
      isLoading = false;
      ProgressDialogUtil.close();
      return;
    }
    switch (list[1]){
      case 'B':
        if (list.length == 5){
          //scanQueryDataOnChanged(keyWord: 'InvID', keyValue: list[4]);
          //res = await pageChanged(showLoading: false);
          var invRes = await InventoryRepository().getFormData(list[4]);
          if (!invRes.isSuccess){
            TipsUtils.showTip(
              msg: '获取产品信息时出错：${invRes.message}',
              toastType: ToastType.error,
            );
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
          if (invRes.data.id.isEmpty){
            TipsUtils.showTip(
              msg: '查询不到该产品！',
              toastType: ToastType.warn,
            );
            isLoading = false;
            ProgressDialogUtil.close();
            return;
          }
          await getOtherInventory(invRes.data);
        }
        else {
          TipsUtils.showTip(
            msg: '条码错误！',
            toastType: ToastType.warn,
          );
          isLoading = false;
          ProgressDialogUtil.close();
          return;
        }
        break;
      default:
        TipsUtils.showTip(
          msg: '条码错误！',
          toastType: ToastType.warn,
        );
        isLoading = false;
        ProgressDialogUtil.close();
        return;
    }

    isLoading = false;
    update();
    ProgressDialogUtil.update(value: 1);
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
  

  //region NumPad SetEnabled + 计算

  @override
  void numPadCTListSetEnabled(){
    switch (saveType){
      case AppConfig.qtySubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, /*qtyIsNeedPieceWeight*/true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, /*qtyIsNeedPieceWeight*/true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, !isUsePackingPicker, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList);
        break;
      case AppConfig.qtyBoxSubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, /*qtyBoxIsNeedPieceWeight*/true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, /*qtyBoxIsNeedPieceWeight*/true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, !isUsePackingPicker, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, !isUsePackingPicker || !isSingleBoxQtyOnlyChangedByContainer, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, true, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList); ///总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList);
        break;
      case AppConfig.palletSubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, /*palletIsNeedPieceWeight*/true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, /*palletIsNeedPieceWeight*/true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, true, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, true, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, true, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.qty, true, numPadCTList); ///总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, true, numPadCTList);
        break;
      case AppConfig.weightSubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, /*weightIsNeedPieceWeight*/true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, /*weightIsNeedPieceWeight*/true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, !isUsePackingPicker, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, true, numPadCTList); ///总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList);
        break;
      case AppConfig.weightBoxSubmit:
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, /*weightBoxIsNeedPieceWeight*/true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, /*weightBoxIsNeedPieceWeight*/true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, !isUsePackingPicker, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, true, numPadCTList); ///总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList);
        break;
      case AppConfig.weight:
        NumPadUtil().setEnabled(NumPadUtil.eBWeight, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.eBPiece, true, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.packingWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.num, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.boxNumOfPallet, false, numPadCTList); ///单托箱数
        NumPadUtil().setEnabled(NumPadUtil.singleBoxQty, false, numPadCTList); ///单箱数量(单箱件数)
        NumPadUtil().setEnabled(NumPadUtil.lastBoxQty, false, numPadCTList); ///尾箱数量
        NumPadUtil().setEnabled(NumPadUtil.singleBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.lastBoxWeight, false, numPadCTList);
        NumPadUtil().setEnabled(NumPadUtil.qty, false, numPadCTList); ///总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.weight, false, numPadCTList); ///总数量 OR 预计件数
        NumPadUtil().setEnabled(NumPadUtil.boxWeight, false, numPadCTList);
        break;
    }
  }

  @override
  void calcQty(String keyName){
    numPadDebounce(() {
      if (keyName == NumPadUtil.packingWeight){
        ///填写皮重数据时，把填写的数据保存到本地
        double? packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '');
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY, packingWeight);
      }
      if (keyName == NumPadUtil.singleBoxQty){
        ///填写单箱数量数据时，把填写的数据保存到本地
        double? packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '');
        ShareStorageUtil.instance?.write(SharedPreferencesKeys.INV_BARCODE_FORM_THE_LAST_NUM_PAD_SINGLE_BOX_QTY_VALUE_KEY, packingWeight);
      }

      if (saveType == AppConfig.qtySubmit) { ///按数量填报
        switch (keyName){
          case NumPadUtil.eBWeight: ///称重重量(g)
          case NumPadUtil.eBPiece: ///称重件数
            getPieceWeightTC();
            getWeightByQSaveType();
            break;
          case NumPadUtil.packingWeight: ///皮重
          case NumPadUtil.qty: /// 总件数
            getWeightByQSaveType();
            break;
        }
      }
      else if (saveType == AppConfig.qtyBoxSubmit){ ///按数量（多箱）填报
        switch (keyName){
          case NumPadUtil.eBWeight: ///称重重量(g)
          case NumPadUtil.eBPiece: ///称重件数
            getPieceWeightTC();
            getWeightByQBSaveType();
            break;
          case NumPadUtil.packingWeight: ///单箱皮重(kg)
          case NumPadUtil.singleBoxQty: ///单箱数量
          case NumPadUtil.lastBoxQty: ///尾箱数量
          case NumPadUtil.num: ///入库箱数（装箱数）
            getQtyByQBSaveType();
            getWeightByQBSaveType();
            break;
          case NumPadUtil.qty: ///总数量
            getBoxNumByQBSaveType();
            getWeightByQBSaveType();
            break;
        }
      }
      else if (saveType == AppConfig.palletSubmit){ ///按托填报
        switch (keyName){
          case NumPadUtil.eBWeight: ///称重重量(g)
          case NumPadUtil.eBPiece: ///称重件数
            getPieceWeightTC();
            break;
          case NumPadUtil.singleBoxQty: ///单箱数量
            if (calcRuleForPalletSaveType == 0){
              getBoxNumOfPallet();
            }
            else if (calcRuleForPalletSaveType == 1){
              getQtyOfPallet();
            }
            break;
          case NumPadUtil.qty: ///总数量
            getBoxNumOfPallet();
            break;
          case NumPadUtil.boxNumOfPallet: ///单托箱数
          case NumPadUtil.lastBoxQty: ///尾箱数量
            getQtyOfPallet();
            break;
        }
      }
      else if (saveType == AppConfig.weightSubmit) { ///按重量填报
        switch (keyName){
          case NumPadUtil.eBWeight: ///称重重量(g)
          case NumPadUtil.eBPiece: ///称重件数
            getPieceWeightTC();
            getQtyByWSaveType();
            break;
          case NumPadUtil.packingWeight: ///皮重
          case NumPadUtil.weight: ///总重
            getQtyByWSaveType();
            break;
        }
      }
      else if (saveType == AppConfig.weightBoxSubmit) { ///按重量（多箱）填报
        switch (keyName){
          case NumPadUtil.eBWeight: ///称重重量(g)
          case NumPadUtil.eBPiece: ///称重件数
            getPieceWeightTC();
            getQtyByWBSaveType();
            break;
          case NumPadUtil.packingWeight: ///单箱皮重(kg)
          case NumPadUtil.singleBoxWeight: ///单箱重量
          case NumPadUtil.lastBoxWeight: ///尾箱重量
          case NumPadUtil.num: ///入库箱数（装箱数）
            getWeightByWBSaveType();
            getQtyByWBSaveType();
            break;
          case NumPadUtil.weight: ///总重量
            getBoxNumByWBSaveType();
            getQtyByWBSaveType();
            break;
        }
      }
      else if (saveType == AppConfig.weight) { ///报单重
        switch (keyName){
          case NumPadUtil.eBWeight: ///称重重量(g)
          case NumPadUtil.eBPiece: ///称重件数
            getPieceWeightTC();
            break;
        }
      }

      if (isShowExpectSingleBoxQty
          && (saveType == AppConfig.qtyBoxSubmit || saveType == AppConfig.weightBoxSubmit)
          && (keyName == NumPadUtil.singleBoxWeight || keyName == NumPadUtil.eBWeight || keyName == NumPadUtil.eBPiece || keyName == NumPadUtil.packingWeight)){
        singleBoxWeightForExpect = double.tryParse(NumPadUtil().getText(
            NumPadUtil.singleBoxWeight, numPadCTList
        ) ?? '') ?? 0;
      }

      update();
    });
  }


  ///计算实际单重：称重重量 / 称重件数
  void getPieceWeightTC(){
    ///称重重量
    double _eBWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.eBWeight, numPadCTList) ?? '') ?? 0;
    ///称重件数
    int _eBPiece = int.tryParse(NumPadUtil().getText(NumPadUtil.eBPiece, numPadCTList) ?? '') ?? 0;
    String _pieceWeightString;
    if (_eBWeight > 0 && _eBPiece > 0){
      _pieceWeightString = (_eBWeight / _eBPiece).toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.pieceWeight]!);
    }
    else {
      _pieceWeightString = '';
    }
    double _pieceWeight = double.tryParse(_pieceWeightString) ?? 0;
    NumPadUtil().setText(NumPadUtil.pieceWeight, _pieceWeightString, numPadCTList);
    isWeightError = _pieceWeight != 0
        && ((saveType == AppConfig.qtySubmit && /*qtyIsNeedPieceWeight*/true)
            || (saveType == AppConfig.qtyBoxSubmit && /*qtyBoxIsNeedPieceWeight*/true)
            || (saveType == AppConfig.weightSubmit && /*weightIsNeedPieceWeight*/true)
            || (saveType == AppConfig.weightBoxSubmit && /*weightBoxIsNeedPieceWeight*/true)
            || saveType == AppConfig.weight)
        && ((inventoryModel.invWeight ?? 0) / _pieceWeight - 1).abs() > (limitWeightDeviationValue / 100);
  }

  ///按数量填报时，计算预计总重：实际单重(标准单重)(g) * 总数量 + 皮重(kg)
  void getWeightByQSaveType(){
    ///总数量
    int _qty = int.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '') ?? 0;
    ///单箱皮重
    double _packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '') ?? 0;
    ///单重
    double _pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '') ?? 0;
    /*double _pieceWeight = 0;
    if (qtyIsNeedPieceWeight){ ///先判断是否需要产品重量检验，如果需要的话，就取实际单重
      _pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '') ?? 0;
    }
    else if (qtyCanWeightCalcByStandWeight){ ///如果不需要产品重量检验，并且可以根据标准单重计算总重，取标准单重
      _pieceWeight = inventoryModel.invWeight ?? 0;
    }*/
    String _weightString = _pieceWeight == 0
        ? ''
        : (_pieceWeight / 1000 * _qty + _packingWeight).toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.weight]!);
    NumPadUtil().setText(NumPadUtil.weight, _weightString, numPadCTList);
  }

  ///按数量（多箱）填报时，计算总件数：整箱箱数 * 单箱件数 + 尾箱件数
  void getQtyByQBSaveType() {
    ///整箱箱数
    int _num = int.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '') ?? 1;
    ///单箱件数
    int _singleBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') ?? 0;
    ///尾箱件数
    int _lastBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxQty,numPadCTList) ?? '') ?? 0;
    ///总数量
    String _qtyString = (_num * _singleBoxQty + _lastBoxQty).toStringAsFixed(0);
    NumPadUtil().setText(NumPadUtil.qty, _qtyString, numPadCTList);
  }

  ///按数量（多箱）填报时，计算整箱箱数：总件数 / 单箱数量，取整
  ///                    计算尾箱数量：总件数 / 单箱数量，取余数
  void getBoxNumByQBSaveType() {
    ///总数量
    int _qty = int.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '') ?? 0;
    ///单箱数量
    int _singleBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') ?? 0;
    int _num = _qty == 0 || _singleBoxQty == 0 ? 0 : _qty ~/ _singleBoxQty;
    int _lastBoxQty = _qty == 0 || _singleBoxQty == 0 ? 0 : _qty % _singleBoxQty;
    String _numString = _num > 0 ? _num.toString() : '';
    String _lastBoxQtyString = _lastBoxQty > 0 ? _lastBoxQty.toString() : '';
    NumPadUtil().setText(NumPadUtil.num, _numString, numPadCTList);
    NumPadUtil().setText(NumPadUtil.lastBoxQty, _lastBoxQtyString, numPadCTList);
  }

  ///按数量（多箱）填报时，计算预计总重：总数量 * 实际单重(标准单重)(g) + 皮重(kg) * (整箱箱数 + (尾箱件数 > 0 ? 1 : 0))
  void getWeightByQBSaveType() {
    ///总数量
    int _qty = int.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '') ?? 0;
    ///单重
    /*double _pieceWeight = 0;
    if (qtyBoxIsNeedPieceWeight){ ///先判断是否需要产品重量检验，如果需要的话，就取实际单重
      _pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '') ?? 0;
    }
    else if (qtyBoxCanWeightCalcByStandWeight){ ///如果不需要产品重量检验，并且可以根据标准单重计算总重，取标准单重
      _pieceWeight = inventoryModel.invWeight ?? 0;
    }*/
    double _pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '') ?? 0;
    ///皮重
    double _packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '') ?? 0;
    ///整箱箱数
    int _num = int.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '') ?? 1;
    ///尾箱件数
    int _lastBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxQty, numPadCTList) ?? '') ?? 0;
    String _weightString = _pieceWeight == 0
        ? ''
        : (_qty * _pieceWeight / 1000 + _packingWeight * (_num + (_lastBoxQty > 0 ? 1 : 0))).toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.weight]!);
    NumPadUtil().setText(NumPadUtil.weight, _weightString, numPadCTList);
  }

  ///按托填报时，通过“单箱数量”、“总数量”计算“单托箱数”、“尾箱数量”
  ///计算单托箱数：总数量 / 单箱数量，取整
  ///计算尾箱数量：总数量 / 单箱数量，取余数
  void getBoxNumOfPallet(){
    int _qty = int.tryParse(NumPadUtil().getText(NumPadUtil.qty, numPadCTList) ?? '') ?? 0;
    int _singleBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') ?? 0;
    int _lastBoxQty = (_qty == 0 || _singleBoxQty == 0) ? 0 : _qty % _singleBoxQty;
    int _boxNumOfPallet = (_qty == 0 || _singleBoxQty == 0) ? 0 : _qty ~/ _singleBoxQty;
    String _lastBoxQtyString = _lastBoxQty > 0 ? _lastBoxQty.toString() : '';
    String _boxNumOfPalletString = _boxNumOfPallet > 0 ? _boxNumOfPallet.toString() : '';
    NumPadUtil().setText(NumPadUtil.lastBoxQty, _lastBoxQtyString, numPadCTList);
    NumPadUtil().setText(NumPadUtil.boxNumOfPallet, _boxNumOfPalletString, numPadCTList);
  }

  ///按托填报时，通过“单箱数量”、“单托箱数”、“尾箱数量”计算“总数量”
  ///计算总数量：单箱数量 * 单托箱数 + 尾箱数量
  void getQtyOfPallet(){
    int _singleBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxQty, numPadCTList) ?? '') ?? 0;
    int _boxNumOfPallet = int.tryParse(NumPadUtil().getText(NumPadUtil.boxNumOfPallet, numPadCTList) ?? '') ?? 0;
    int _lastBoxQty = int.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxQty, numPadCTList) ?? '') ?? 0;
    int _qty = _singleBoxQty * _boxNumOfPallet + _lastBoxQty;
    String _qtyString = _qty > 0 ? _qty.toString() : '';
    NumPadUtil().setText(NumPadUtil.qty, _qtyString, numPadCTList);
  }

  ///按重量填报时 计算预计总件数：(总重 - 皮重)kg / 实际单重(标准单重)(g)
  void getQtyByWSaveType(){
    ///总重
    double _weight = double.tryParse(NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '') ?? 0;
    ///单箱皮重
    double _packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '') ?? 0;
    ///单重
    double _pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '') ?? 0;
    /*double _pieceWeight = 0;
    if (weightIsNeedPieceWeight){ ///先判断是否需要产品重量检验，如果需要的话，就取实际单重
      _pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '') ?? 0;
    }
    else { ///如果不需要产品重量检验，并且可以根据标准单重计算总数，取标准单重
      _pieceWeight = inventoryModel.invWeight ?? 0;
    }*/
    String _qtyString = _pieceWeight == 0 ? '' : ((_weight - _packingWeight) * 1000 / _pieceWeight).toStringAsFixed(0);
    NumPadUtil().setText(NumPadUtil.qty, _qtyString, numPadCTList);
  }

  ///按重量（多箱）填报时，计算总重量：整箱箱数 * 单箱重量 + 尾箱重量
  void getWeightByWBSaveType() {
    ///整箱箱数
    int _num = int.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '') ?? 1;
    ///单箱重量
    double _singleBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '') ?? 0;
    ///尾箱重量
    double _lastBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxWeight, numPadCTList) ?? '') ?? 0;
    ///总重
    String _weightString = (_num * _singleBoxWeight + _lastBoxWeight).toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.weight]!);
    NumPadUtil().setText(NumPadUtil.weight, _weightString, numPadCTList);
  }

  ///按重量（多箱）填报时，计算整箱箱数：总重量 / 单箱重量，取整
  ///                    计算尾箱重量：总重量 / 单箱重量，取余数
  void getBoxNumByWBSaveType() {
    ///总重量
    double _weight = double.tryParse(NumPadUtil().getText(NumPadUtil.weight, numPadCTList) ?? '') ?? 0;
    ///单箱重量
    double _singleBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '') ?? 0;
    int _num = _weight == 0 || _singleBoxWeight == 0 ? 0 : _weight ~/ _singleBoxWeight;
    double _lastBoxWeight = _weight == 0 || _singleBoxWeight == 0 ? 0 : _weight % _singleBoxWeight;
    String _numString = _num > 0 ? _num.toString() : '';
    String _lastBoxWeightString = _lastBoxWeight > 0
        ? _lastBoxWeight.toStringAsFixed(weightFormDecimalLengthMap[NumPadUtil.lastBoxWeight]!)
        : '';
    NumPadUtil().setText(NumPadUtil.num, _numString, numPadCTList);
    NumPadUtil().setText(NumPadUtil.lastBoxWeight, _lastBoxWeightString, numPadCTList);
  }

  ///按重量（多箱）填报时，计算总件数：
  ///单箱数量 = (单箱重量(kg) - 单箱皮重(kg)) / 实际单重(标准单重)(g) (有余数进一位)
  ///尾箱数量 = (尾箱重量(kg) - 单箱皮重(kg)) / 实际单重(标准单重)(g) (有余数进一位)
  ///总数量 = 整箱箱数 * 单箱数量 + 尾箱数量
  void getQtyByWBSaveType() {
    ///单箱重量
    double _singleBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.singleBoxWeight, numPadCTList) ?? '') ?? 0;
    ///尾箱重量
    double _lastBoxWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.lastBoxWeight,numPadCTList) ?? '') ?? 0;
    ///皮重
    double _packingWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.packingWeight, numPadCTList) ?? '') ?? 0;
    ///整箱箱数
    int _num = int.tryParse(NumPadUtil().getText(NumPadUtil.num, numPadCTList) ?? '') ?? 1;
    ///单重
    double _pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '') ?? 0;
    /*double _pieceWeight = 0;
    if (weightBoxIsNeedPieceWeight){ ///先判断是否需要产品重量检验，如果需要的话，就取实际单重
      _pieceWeight = double.tryParse(NumPadUtil().getText(NumPadUtil.pieceWeight, numPadCTList) ?? '') ?? 0;
    }
    else { ///如果不需要产品重量检验，并且可以根据标准单重计算总数，取标准单重
      _pieceWeight = inventoryModel.invWeight ?? 0;
    }*/

    int _singleBoxQty = _pieceWeight == 0 || _singleBoxWeight <= _packingWeight
        ? 0
        : ((_singleBoxWeight - _packingWeight) * 1000 / _pieceWeight).ceil();
    _singleBoxQty = _singleBoxQty < 0 ? 0 : _singleBoxQty;
    int _lastBoxQty = _pieceWeight == 0 || _lastBoxWeight <= _packingWeight
        ? 0
        : ((_lastBoxWeight - _packingWeight) * 1000 / _pieceWeight).ceil();
    _lastBoxQty = _lastBoxQty < 0 ? 0 : _lastBoxQty;
    int _qty = _num * _singleBoxQty + _lastBoxQty;
    NumPadUtil().setText(NumPadUtil.qty, _qty.toString(), numPadCTList);
  }

  //endregion


  @override
  Future<void> saveInvBarcode(bool isPrint) async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    ///条码提交前检查
    Map<bool, String> checkMap = saveInvBarcodeCheck(
      isPrint: isPrint,
    );
    if (checkMap.containsKey(false)){
      ToastNotification(Get.overlayContext!).error(checkMap[false]!);
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认提交物料条码${isPrint ? '并打印' : ''}？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    String printerUrl = ''; ///打印机Url
    String printerName = ''; ///打印机Name
    int printCopies = 0; ///打印份数
    String printType = ''; ///打印方式
    if (isPrint){
      Map<String, dynamic> printInfoMap = await getPrintInfo();
      printerUrl = printInfoMap['printerUrl']!;
      printerName = printInfoMap['printerName']!;
      printCopies = printInfoMap['printCopies']!;
      printType = printInfoMap['printType']!;
    }
    ProgressDialogUtil.showProgressDialog(
        max: isPrint ? 3 : 2,
        msg: '正在提交条码记录',
        completedMsg: '${isPrint ? '打印成功！' : '刷新成功！'}'
    );
    //region 提交物料条码记录
    setInvBarcodeDataBeforeSave();
    List<BarcodeEntity> barcodeList = [barcodeEntity];
    var res = await BarcodeMainRepository().generate('', barcodeList);
    if (!res.isSuccess){
      TipsUtils.showTip(
        msg: '物料条码提交失败！${res.message}！',
        toastType: ToastType.error,
      );
      ProgressDialogUtil.close();
      isLoading = false;
      return;
    }
    ProgressDialogUtil.update(value: 1, msg: '条码记录提交成功，正在刷新数据！');
    //endregion
    //region 刷新数据
    var barcodeMainRes = await BarcodeMainRepository().getPageList(PageConfig(
        page: 1,
        sidx: 'Numerical',
        sord: 'asc',
        rows: res.data.length,
        queryData: {'Barcode': res.data.map((e) => e.barcode ?? '').join(',')}
    ));
    //region 刷新另一个标签的条码列表
    InvBarcodeListController? invBarcodeListController;
    try {
      invBarcodeListController = Get.find<InvBarcodeListController>();
    } catch (e){}
    if (invBarcodeListController != null){
      await invBarcodeListController.pageChanged(showLoading: false);
      invBarcodeListController.update();
    }
    //endregion
    ///刷新填报区域的数据
    await resetInvBarcodeDataAfterSave();
    ///历史皮重数据赋值
    if (isSaveTheLastPackingWeightData){
      await setTheLastPackingWeightData(
        theLastContainerSelectedValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.INV_BARCODE_FORM_THE_LAST_CONTAINER_SELECTED_VALUE_KEY
        ),
        theLastPackingWeightValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.INV_BARCODE_FORM_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY
        ),
        theLastSingleBoxQtyValue: ShareStorageUtil.instance?.read(
            SharedPreferencesKeys.INV_BARCODE_FORM_THE_LAST_NUM_PAD_SINGLE_BOX_QTY_VALUE_KEY
        ),
      );
    }
    /*///写入实际单重数据
    if (isAutoWritePieceWeight){
      getPieceWeightBtnOnTap();
    }*/
    update();
    ProgressDialogUtil.update(value: 2, msg: '${isPrint ? '数据刷新成功，正在打印！' : null}');
    //endregion
    //region 打印
    if (isPrint){
      Map<bool, String> printRes = await printInvBarcode(
        printerUrl: printerUrl,
        printerName: printerName,
        printCopies: printCopies,
        printType: printType,
        barcodeMainList: barcodeMainRes.rows,
        invCCode: inventoryModel.invCCode ?? '',
      );
      if (printRes.containsKey(true)) {
        ProgressDialogUtil.update(value: 3);
        ToastNotification(Get.overlayContext!).info(printRes[true]!);
      }
      else {
        TipsUtils.showTip(
          msg: printRes[false] ?? '',
          toastType: ToastType.error,
        );
        ProgressDialogUtil.close();
        isLoading = false;
        return;
      }
    }
    //endregion
    //region 如果提交成功，直接返回到首页
    if(res.isSuccess && isGetBackAfterSaveSuccess){
      await ProgressDialogUtil.awaitCompletionDelay();
      await Future.doWhile(() async{
        await Get.rootDelegate.popRoute();
        var page = Get.rootDelegate.history.last;
        if (page.currentPage?.binding == null){
          return true;
        }
        return false;
      });
    }
    //endregion
    isLoading = false;
  }


  @override
  Widget dataReportAreaWidget(BuildContext context) {
    List<Widget> itemWidgetList = [];
    Map<String, Widget> itemAreaWidgetMap = {};
    itemAreaWidgetMap.addAll({
      if ((saveType == AppConfig.qtySubmit/* && qtyIsNeedPieceWeight*/)
          || (saveType == AppConfig.qtyBoxSubmit/* && qtyBoxIsNeedPieceWeight*/)
          || (saveType == AppConfig.palletSubmit/* && palletIsNeedPieceWeight*/)
          || (saveType == AppConfig.weightSubmit/* && weightIsNeedPieceWeight*/)
          || (saveType == AppConfig.weightBoxSubmit/* && weightBoxIsNeedPieceWeight*/)
          || saveType == AppConfig.weight)
        ...{
          NumPadUtil.eBWeight: numPadReportItem(context, NumPadUtil.eBWeight),
          NumPadUtil.eBPiece: numPadReportItem(context, NumPadUtil.eBPiece),
          NumPadUtil.pieceWeight: numPadReportItem(context, NumPadUtil.pieceWeight),
        },

      if (saveType == AppConfig.qtySubmit)
        ...{
          //NumPadUtil.packingWeight: containerReportItem(context),
          NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
          NumPadUtil.weight: numPadReportItem(context, NumPadUtil.weight),
        }
      else if (saveType == AppConfig.qtyBoxSubmit)
        ...{
          //NumPadUtil.packingWeight: containerReportItem(context),
          NumPadUtil.num: numPadReportItem(context, NumPadUtil.num),
          NumPadUtil.singleBoxQty: singleBoxQtyReportItem(context),
          NumPadUtil.lastBoxQty: numPadReportItem(context, NumPadUtil.lastBoxQty),
          NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
          NumPadUtil.weight: numPadReportItem(context, NumPadUtil.weight),
        }
      else if (saveType == AppConfig.palletSubmit)
          ...{
            NumPadUtil.singleBoxQty: singleBoxQtyReportItem(context),
            NumPadUtil.lastBoxQty: numPadReportItem(context, NumPadUtil.lastBoxQty),
            NumPadUtil.boxNumOfPallet: numPadReportItem(context, NumPadUtil.boxNumOfPallet),
            //NumPadUtil.boxWeight: numPadReportItem(context, NumPadUtil.boxWeight),
            NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
          }
        else if (saveType == AppConfig.weightSubmit)
            ...{
              //NumPadUtil.packingWeight: containerReportItem(context),
              NumPadUtil.weight: numPadReportItem(context, NumPadUtil.weight),
              NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
            }
          else if (saveType == AppConfig.weightBoxSubmit)
              ...{
                //NumPadUtil.packingWeight: containerReportItem(context),
                NumPadUtil.num: numPadReportItem(context, NumPadUtil.num),
                NumPadUtil.singleBoxWeight: numPadReportItem(context, NumPadUtil.singleBoxWeight),
                NumPadUtil.lastBoxWeight: numPadReportItem(context, NumPadUtil.lastBoxWeight),
                NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
                NumPadUtil.weight: numPadReportItem(context, NumPadUtil.weight),
              }
    });
    formTitleMap.forEach((key, value) {
      if (itemAreaWidgetMap.containsKey(key)){
        itemWidgetList.add(itemAreaWidgetMap[key]!);
      }
    });

    double _itemHeight = 72;
    double _needHeight = _itemHeight * itemWidgetList.length;
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        interactive: false,
        thumbVisibility: WidgetStateProperty.all(false),
        trackVisibility: WidgetStateProperty.all(false),
        thumbColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          int? _count;
          if (formRowMaxCountLimit != null){
            _count = formRowMaxCountLimit! > itemWidgetList.length
                ? null
                : formRowMaxCountLimit!;
          }
          else if (constraints.maxHeight < _needHeight){
            _count = constraints.maxHeight ~/ _itemHeight;
          }

          if (_count != null){
            return SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: itemWidgetList.sublist(0, _count),
                    ),
                  ),
                  const SizedBox(width: 4,),
                  Expanded(
                    child: Column(
                      children: itemWidgetList.sublist(_count),
                    ),
                  ),
                ],
              ),
            );
          }
          else {
            return SingleChildScrollView(
              child: Column(
                children: itemWidgetList,
              ),
            );
          }
        },
      ),
    );
  }
  

  @override
  Future<void> onClose() async {
    numPadDebounce.dispose();
    numPadCTList.forEach((element) {
      element.dispose();
    });
    super.onClose();
  }

}