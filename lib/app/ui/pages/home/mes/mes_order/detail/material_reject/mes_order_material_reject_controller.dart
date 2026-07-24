import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/ui/pages/home/base/interface/check_record_interface/material_reject_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/check_record/mes_order_check_record_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/detail_tab/mes_order_detail_tab_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产任务单 不良品上报页面
class MesOrderMaterialRejectController
    extends MesOrderCheckRecordController
    with MaterialRejectInterface {

  MoOpOrderModel? get mROrderModel => orderModel;

  MesOrderMaterialRejectController({
    super.progId = 811013,
    super.isShowProgressDialogInOnReady = true,
    required super.orderModel,
    super.orderOpenType = 0,
    super.workCenterId = '',
    super.deviceId = '',
    super.showAppBar = true,
    super.noPermission = false,
    super.permissionInfo = '',
  });


  @override
  void onInit() {
    super.onInit();

    List<dynamic> orderInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_INFO_FORM_LIST_KEY) ?? [];
    orderInfoFormList.clear();
    orderInfoFormList.addAll(
        getInfoFormListByStorage(
            orderInfoFormMapList,
            AppConfig.mesOrderInfoFormList
        )
    );

    checkRecordBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_BTN_INDEX_KEY) ?? AppConfig.materialRejectBtnIndex;
    isShowMakeUpBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
    isGetBackAfterCommitSuccess = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
    isShowDataReportTypeBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
    checkRecordType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_TYPE_KEY) ?? AppConfig.qtyMaterialReject;
    String formTitleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_FORM_TITLE_MAP_KEY) ?? '';
    formTitleMap.clear();
    formTitleMap.addAll(getFormTitleMapByStorage(formTitleMapStr, AppConfig.mesOrderMaterialRejectFormTitleMap));
    numPadCTList.sort((a, b){
      return numPadCTListSortVoidCallback.call(formTitleMap, a, b);
    });
    String formStyleMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_FORM_STYLE_MAP_KEY) ?? '';
    formStyleMap.clear();
    formStyleMap.addAll(getFormStyleMapByStorage(formStyleMapStr, AppConfig.mesOrderMaterialRejectFormStyleMap));
    numPadCTList.forEach((element) {
      element.styleMap.clear();
      if (formStyleMap.containsKey(element.key)){
        element.styleMap.addAll(formStyleMap[element.key]!);
      }
    });
    numPadFocusField = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
    formRowMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_FORM_ROW_MAX_COUNT_LIMIT_KEY) ?? AppConfig.formRowMaxCountLimit;
    depGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
    isPsnHasAdapter = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
    isPsnMulti = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
    psnGetWayIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
    psnDepCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
    psnLineCode = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
    frxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesOrderMaterialRejectPrintFileName;
    String invClassFrxNameMapStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMap.clear();
    invClassFrxNameMap.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapStr));
    isSaveTheLastSelectedPsnId = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!showAppBar){
        mesOrderDetailTabController = Get.find<MesOrderDetailTabController>();
      }
    });
    numPadCTListSetEnabled();
  }


  Future<void> Function({
    required bool isInit,
    int? progId,
    String? workCenterId,
    String? deviceId,
    String? deviceCode,
    String? deviceName,
    String? opId,
    String? opName,
    String? workBillEntryId,
  }) get setCheckRecordDataAndAdapter => ({
    required bool isInit,
    int? progId,
    String? workCenterId,
    String? deviceId,
    String? deviceCode,
    String? deviceName,
    String? opId,
    String? opName,
    String? workBillEntryId,
  }) async {
    await setMaterialRejectDataAndAdapter(
      isInit: isInit,
      progId: progId,
    );
  };


  @override
  Widget dataReportAreaWidget(BuildContext context) {
    List<Widget> itemWidgetList = [];
    Map<String, Widget> itemAreaWidgetMap = {};
    itemAreaWidgetMap.addAll({
      if (isMakeUp)
        AppConfig.productDateForm: productDateReportItem(context),
      AppConfig.depForm: depReportItem(context),
      AppConfig.teamForm: teamReportItem(context),
      AppConfig.personForm: personReportItem(context),
      AppConfig.bomEntryInvForm: bomEntryInvFormReportItem(context),
      NumPadUtil.qty: numPadReportItem(context, NumPadUtil.qty),
    });
    formTitleMap.forEach((key, value) {
      if (itemAreaWidgetMap.containsKey(key)){
        itemWidgetList.add(itemAreaWidgetMap[key]!);
      }
    });
    int space = (itemWidgetList.length / 2).ceil();
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: 420,
          ),
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: itemWidgetList.sublist(0, space),
                  ),
                ),
                const SizedBox(width: 4,),
                Expanded(
                  child: Column(
                    children: itemWidgetList.sublist(space),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: comDefectViewWidget(context),
        ),
      ],
    );
  }


}