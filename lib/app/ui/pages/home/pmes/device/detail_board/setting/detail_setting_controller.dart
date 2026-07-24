import 'dart:convert';

import 'package:basement/service.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/command_bar_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/pmes/check_record_list/pmes_check_record_list_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/check_record/device_check_record_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/detail/device_detail_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/detail_board_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/material_reject/device_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/submit/device_submit_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/submit_list/pmes_submit_list_controller.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///注塑 设备实时监控 设备详情、报工、报次品 设置页面
class DeviceDetailSettingController
    extends BaseSettingController
    with InfoFormInterface,
        InvClassFrxNameInterface,
        FormInterface,
        CommandBarInterface,
        InterfaceUtil {

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  DeviceDetailBoardController? deviceDetailBoardController;
  DeviceDetailController? deviceDetailController;
  DeviceSubmitController? deviceSubmitController;
  DeviceCheckRecordController? deviceCheckRecordController;
  DeviceMaterialRejectController? deviceMaterialRejectController;
  PMesSubmitListController? pMesSubmitListController;
  PMesCheckRecordListController? pMesCheckRecordListController;

  @override
  late final String title = type == 'tab' ? '设备详情设置'
      : type == 'submit' ? '报工设置'
      : type == 'checkRecord' ? '报次品设置'
      : '';

  ///submit checkRecord submitList checkRecordList
  final String type;

  @override
  late final List<ChoiceChipModel> tabValueList = [
    if (type == 'tab')
      ...[
        ChoiceChipModel(icon: Icons.view_array_rounded, title: '默认选项卡', keyName: 'tab'),
        ChoiceChipModel(
          icon: Icons.device_hub, title: '设备详情', keyName: 'dtDetail',
          children: [
            ChoiceChipModel(title: '装箱单打印设置', keyName: 'packingPrint'),
            ChoiceChipModel(title: '设备任务信息显示设置', keyName: 'detailInfoForm'),
            ChoiceChipModel(title: '设备任务按钮显示设置', keyName: 'detailCommandBar'),
            ChoiceChipModel(title: '派工单列表信息显示设置', keyName: 'detailTaskListInfoForm'),
            ChoiceChipModel(title: '派工单列表按钮显示设置', keyName: 'detailTaskListCommandBar'),
          ]
        ),
      ],
    if (type == 'tab' || type == 'submit')
      ...[
        ChoiceChipModel(
          icon: Icons.assignment, title: '机台报工', keyName: 'submit',
          children: [
            ChoiceChipModel(title: '派工信息显示设置', keyName: 'submitInfoForm'),
            ChoiceChipModel(title: '按钮显示设置', keyName: 'submitBtn'),
            ChoiceChipModel(title: '表单填写项显示设置', keyName: 'submitForm'),
            ChoiceChipModel(title: '表单填写设置', keyName: 'submitFormSetting'),
            ChoiceChipModel(title: '产品类别打印模板设置', keyName: 'submitInvClassTemplate'),
          ]
        ),
      ],
    if (type == 'tab' || type == 'submitList')
      ...[
        ChoiceChipModel(icon: Icons.list, title: '报工单列表设置', keyName: 'submitList'),
      ],
    if (type == 'tab' || type == 'checkRecord')
      ...[
        ChoiceChipModel(
          icon: Icons.assignment_late, title: '次品录入', keyName: 'checkRecord',
          children: [
            ChoiceChipModel(title: '派工信息显示设置', keyName: 'checkRecordInfoForm'),
            ChoiceChipModel(title: '按钮显示设置', keyName: 'checkRecordBtn'),
            ChoiceChipModel(title: '表单填写项显示设置', keyName: 'checkRecordForm'),
            ChoiceChipModel(title: '表单填写设置', keyName: 'checkRecordFormSetting'),
            //ChoiceChipModel(title: '产品类别打印模板设置', keyName: 'checkRecordInvClassTemplate')
          ]
        ),
      ],
    if (type == 'tab' || type == 'materialReject')
      ...[
        ChoiceChipModel(
            icon: Icons.assignment_late, title: '材料不良', keyName: 'materialReject',
            children: [
              ChoiceChipModel(title: '派工信息显示设置', keyName: 'materialRejectInfoForm'),
              ChoiceChipModel(title: '按钮显示设置', keyName: 'materialRejectBtn'),
              ChoiceChipModel(title: '表单填写项显示设置', keyName: 'materialRejectForm'),
              ChoiceChipModel(title: '表单填写设置', keyName: 'materialRejectFormSetting'),
              //ChoiceChipModel(title: '产品类别打印模板设置', keyName: 'materialRejectInvClassTemplate')
            ]
        ),
      ],
    if (type == 'tab' || type == 'checkRecordList')
      ...[
        ChoiceChipModel(icon: Icons.list, title: '次品列表设置', keyName: 'checkRecordList'),
      ],
  ];


  //region 默认选项卡
  int initialTabIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_BOARD_INITIAL_INDEX_KEY) ?? AppConfig.initialIndex;
  final List<ChoiceChipModel> detailTabList = [];
  //endregion

  //region 装箱单打印
  ///详情页面 装箱单打印模板文件名称
  String packingFrxName = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_PACKING_PRINT_FILE_NAME_KEY) ?? AppConfig.packingPrintFrxName;
  ///详情页面 装箱单打印模板文件名称
  late final TextEditingController packingFrxNameTC = TextEditingController(text: packingFrxName);
  ///详情页面 装箱单打印模板文件名称
  final FocusNode packingFrxNameFN = FocusNode();
  //endregion

  //region 设备详情-设备任务信息显示设置
  final List<InfoFormModel> detailInfoFormList = [];
  //endregion

  //region 设备详情-设备任务按钮显示设置
  final List<CommandBarBtnModel> detailCommandBarList = [];
  //endregion

  //region 设备详情-派工单列表信息显示设置
  final Map<int, List<InfoFormModel>> detailTaskListInfoFormListMap = {};
  //endregion

  //region 设备详情-派工单列表按钮显示设置
  final List<CommandBarBtnModel> detailTaskListCommandBarList = [];
  //endregion
  
  //region 机台报工-派工信息显示设置
  final List<InfoFormModel> taskInfoFormListSubmit = [];
  //endregion

  //region 机台报工-按钮显示设置
  ///是否显示报工方式切换按钮
  bool isShowDataReportTypeBtnSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
  ///报工方式
  String submitType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_TYPE_KEY) ?? AppConfig.qtySubmit;
  ///是否显示“补打”按钮（当报工日期受班次影响时，始终不显示该按钮）
  bool isShowMakeUpBtnSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
  ///是否显示“需要检验”按钮
  bool isShowInspectFlagBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_INSPECT_FLAG_BTN_KEY) ?? AppConfig.isShowInspectFlagBtn;
  ///是否可以点击修改“需要检验”按钮的值
  bool isCanClickInspectFlagBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_CAN_CLICK_INSPECT_FLAG_BTN_KEY) ?? AppConfig.isCanClickInspectFlagBtn;
  ///“需要检验”按钮的选中状态的默认值
  bool? inspectFlagDefaultValue = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_INSPECT_FLAG_DEFAULT_VALUE_KEY) ?? AppConfig.inspectFlagDefaultValue;
  ///是否显示“获取实际单重”按钮
  bool isShowGetPieceWeightBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_GET_FIRST_INSPECT_EBWEIGHT_BTN) ?? AppConfig.isShowGetPieceWeightBtn;
  ///页面上显示报工提交按钮（可显示多个，index 相加）
  ///
  /// 1：报工提交
  ///
  /// 2：提交并打印
  int submitBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_BTN_INDEX_KEY) ?? AppConfig.submitBtnIndex;
  //endregion

  //region 机台报工-表单填写项显示设置
  final ScrollController submitFormScrollController = ScrollController();
  ///表单数据填写项的标题名称
  final Map<String, String> formTitleMapSubmit = {};
  ///表单数据填写项的样式
  final Map<String, Map<String, dynamic>> formStyleMapSubmit = {};
  ///自动获取焦点的输入框字段名
  String numPadFocusFieldSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
  ///单列可显示的表单填写项的行数
  final int? formRowMaxCountLimitSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_FORM_ROW_MAX_COUNT_LIMIT_KEY) ?? AppConfig.formRowMaxCountLimit;
  late final TextEditingController formRowMaxCountLimitSubmitTC = TextEditingController(text: formRowMaxCountLimitSubmit?.toString() ?? '');
  final FocusNode formRowMaxCountLimitSubmitFN = FocusNode();
  //endregion

  //region 机台报工-表单填写设置
  ///车间默认值获取方式 0: 单据车间 1: 登录账号所在车间
  int depGetWayIndexSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
  ///产线数据的填报类型：0产线 OR 1加工中心 OR 2生产班组
  ///
  /// （选2班组，不需要选员工； 选0产线，不需要选择设备）
  int wcDataReportTypeSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_WC_DATA_REPORT_TYPE_KEY) ?? AppConfig.wcDataReportType;
  ///人员是否可以通过 Adapter 选单
  bool isPsnHasAdapterSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
  ///生产人员是否可以多选
  bool isPsnMultiSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
  ///生产人员获取条件的Index 0: 全部 1: 选中的车间 2: 固定车间
  int psnGetWayIndexSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
  ///生产人员获取条件是固定车间时，固定车间的值
  final String psnDepCodeSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
  late final TextEditingController psnDepCodeSubmitTC = TextEditingController(text: psnDepCodeSubmit);
  final FocusNode psnDepCodeSubmitFN = FocusNode();
  ///生产人员获取条件是固定产线时，固定产线的值
  final String psnLineCodeSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
  late final TextEditingController psnLineCodeSubmitTC = TextEditingController(text: psnLineCodeSubmit);
  final FocusNode psnLineCodeSubmitFN = FocusNode();
  ///是否保存上次报工时选中的员工
  bool isSaveTheLastSelectedPsnIdSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;
  ///整箱箱数可以填写的上限
  final int? numMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_NUM_MAX_COUNT_LIMIT_KEY) ?? AppConfig.numMaxCountLimit;
  late final TextEditingController numMaxCountLimitTC = TextEditingController(text: numMaxCountLimit?.toString() ?? '');
  final FocusNode numMaxCountLimitFN = FocusNode();
  ///单箱数量可以填写的下限
  final double? singleBoxQtyMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_SINGLE_BOX_QTY_MAX_COUNT_LIMIT_KEY) ?? AppConfig.singleBoxQtyMaxCountLimit;
  late final TextEditingController singleBoxQtyMaxCountLimitTC = TextEditingController(text: singleBoxQtyMaxCountLimit?.toString() ?? '');
  final FocusNode singleBoxQtyMaxCountLimitFN = FocusNode();
  ///当报工方式是“按托报工”时，报工数据的计算方式
  ///
  ///0：填写“单箱数量”时，计算“单托箱数”、“尾箱数量”
  ///
  ///1：填写“单箱数量”时，计算“报工总数量”
  int calcRuleForPalletSubmitType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_CALC_RULE_FOR_PALLET_SUBMIT_TYPE_KEY) ?? AppConfig.calcRuleForPalletSubmitType;
  ///是否保存上次报工时填写的皮重、单箱数量数据（或选择的装箱容器数据）
  bool isSaveTheLastPackingWeightData = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY) ?? AppConfig.isSaveTheLastPackingWeightData;
  ///是否通过选择装箱容器，自动填充皮重、单箱数量
  bool isUsePackingPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_USE_PACKING_PICKER_KEY) ?? AppConfig.isUsePackingPicker;
  ///“单箱数量”是否只能通过选择装箱容器来赋值，而不是手动输入
  late bool isSingleBoxQtyOnlyChangedByContainer = !isUsePackingPicker
      ? false
      : (ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY) ?? AppConfig.isSingleBoxQtyOnlyChangedByContainer);
  ///是否自动写入实际单重数据
  bool isAutoWritePieceWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_AUTO_WRITE_PIECE_WEIGHT_KEY) ?? AppConfig.isAutoWritePieceWeight;
  ///按数量报工时，是否需要产品重量检验
  bool qtyIsNeedPieceWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_QTY_ISNEED_PIECEWEIGHT_KEY) ?? AppConfig.isNeedPieceWeight;
  ///按数量报工时，如果没有实际单重数据，是否可以根据标准单重计算总重
  bool qtyCanWeightCalcByStandWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_QTY_CAN_WEIGHT_CALC_BY_STAND_WEIGHT_KEY) ?? AppConfig.canWeightCalcByStandWeight;
  ///按数量（多箱）报工时，是否需要产品重量检验
  bool qtyBoxIsNeedPieceWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_QTY_BOX_ISNEED_PIECEWEIGHT_KEY) ?? AppConfig.isNeedPieceWeight;
  ///按数量（多箱）报工时，如果没有实际单重数据，是否可以根据标准单重计算总重
  bool qtyBoxCanWeightCalcByStandWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_QTY_BOX_CAN_WEIGHT_CALC_BY_STAND_WEIGHT_KEY) ?? AppConfig.canWeightCalcByStandWeight;
  ///按托报工时，是否需要产品重量检验
  bool palletIsNeedPieceWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_PALLET_ISNEED_PIECEWEIGHT_KEY) ?? AppConfig.isNeedPieceWeight;
  ///按托报工时，如果没有实际单重数据，是否可以根据标准单重计算总重
  bool palletCanWeightCalcByStandWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_PALLET_CAN_WEIGHT_CALC_BY_STAND_WEIGHT_KEY) ?? AppConfig.canWeightCalcByStandWeight;
  ///按重量报工时，是否需要产品重量检验
  bool weightIsNeedPieceWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_WEIGHT_ISNEED_PIECEWEIGHT_KEY) ?? AppConfig.isNeedPieceWeight;
  ///按重量报工时，产品称重的数据是否加到报工总数据上
  bool weightIsAddPieceWeightToTotal = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_WEIGHT_IS_ADD_PIECE_WEIGHT_TO_TOTAL_KEY) ?? AppConfig.weightIsAddPieceWeightToTotal;
  ///按重量（多箱）报工时，是否需要产品重量检验
  bool weightBoxIsNeedPieceWeight = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_WEIGHT_BOX_ISNEED_PIECEWEIGHT_KEY) ?? AppConfig.isNeedPieceWeight;
  ///按多箱报工时，是否显示称重消息传递过来的单箱重量、预计单箱数量
  bool isShowExpectSingleBoxQty = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_EXPECT_SINGLE_BOX_QTY_KEY) ?? AppConfig.isShowExpectSingleBoxQty;
  ///报工条码打印模板文件名称
  final String frxNameSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_TEMPLATE_FILENAME_KEY) ?? AppConfig.deviceSubmitPrintFileName;
  late final TextEditingController frxNameSubmitTC = TextEditingController(text: frxNameSubmit);
  final FocusNode frxNameSubmitFN = FocusNode();
  ///报工记录提交成功后，是否返回到首页
  bool isGetBackAfterCommitSuccessSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
  //endregion

  //region 报工条码模板名称列表
  ///根据产品类别编码区分的打印模板名称列表
  final Map<String, String> invClassFrxNameMapSubmit = {};
  //endregion

  //region 报工单列表设置
  final ScrollController submitListScrollController = ScrollController();
  ///报工列表的单页显示记录数
  int pageConfigRowsSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_SUBMIT_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
  ///报工单删除时间限制
  final int? limitTimeSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_DELETE_LIMIT_TIME) ?? AppConfig.limitTime;
  late final TextEditingController limitTimeSubmitTC = TextEditingController(text: limitTimeSubmit?.toString() ?? '');
  final FocusNode limitTimeSubmitFN = FocusNode();
  ///报工单信息显示设置
  final Map<int, List<InfoFormModel>> submitListInfoFormListMap = {};
  //endregion
  
  //region 次品录入-派工记录信息显示设置
  final List<InfoFormModel> taskInfoFormListCR = [];
  //endregion

  //region 次品录入-按钮显示设置
  ///是否显示报次品方式切换按钮
  bool isShowDataReportTypeBtnCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
  ///报次品方式
  String checkRecordType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_TYPE_KEY) ?? AppConfig.qtyCheckRecord;
  ///是否显示“补打”按钮（当生产日期受班次影响时，始终不显示该按钮）
  bool isShowMakeUpBtnCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
  ///页面上显示次品提交按钮（可显示多个，index 相加）
  ///
  ///1：次品提交
  ///
  ///2：提交并打印
  late int checkRecordBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_BTN_INDEX_KEY) ?? AppConfig.checkRecordBtnIndex;
  //endregion

  //region 次品录入-表单填写项显示设置
  final ScrollController cRFormScrollController = ScrollController();
  ///表单数据填写项的标题名称
  final Map<String, String> formTitleMapCR = {};
  ///表单数据填写项的样式
  final Map<String, Map<String, dynamic>> formStyleMapCR = {};
  ///自动获取焦点的输入框字段名
  String numPadFocusFieldCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
  ///单列可显示的表单填写项的行数
  int? formRowMaxCountLimitCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_FORM_ROW_MAX_COUNT_LIMIT_KEY) ?? AppConfig.formRowMaxCountLimit;
  late final TextEditingController formRowMaxCountLimitCRTC = TextEditingController(text: formRowMaxCountLimitCR?.toString() ?? '');
  final FocusNode formRowMaxCountLimitCRFN = FocusNode();
  //endregion

  //region 次品录入-表单填写设置
  ///车间默认值获取方式 0: 单据车间  1: 登录账号所在车间
  int depGetWayIndexCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
  ///产线数据的填报类型：0产线 OR 1加工中心 OR 2生产班组
  ///
  ///（选2班组，不需要选员工； 选0产线，不需要选择设备）
  int wcDataReportTypeCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_WC_DATA_REPORT_TYPE_KEY) ?? AppConfig.wcDataReportType;
 ///人员是否可以通过 Adapter 选单
  bool isPsnHasAdapterCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
  ///生产人员是否可以多选
  bool isPsnMultiCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
  ///生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间
  int psnGetWayIndexCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
  ///生产人员获取条件是固定车间时，固定车间的值
  final String psnDepCodeCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_PSN_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
  late final TextEditingController psnDepCodeCRTC = TextEditingController(text: psnDepCodeCR);
  final FocusNode psnDepCodeCRFN = FocusNode();
  ///生产人员获取条件是固定产线时，固定产线的值
  final String psnLineCodeCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
  late final TextEditingController psnLineCodeCRTC = TextEditingController(text: psnLineCodeCR);
  final FocusNode psnLineCodeCRFN = FocusNode();
  ///是否保存上次报工时选中的员工
  bool isSaveTheLastSelectedPsnIdCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;
  ///次品条码打印模板文件名称
  final String frxNameCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_TEMPLATE_FILENAME_KEY) ?? AppConfig.deviceCheckRecordPrintFileName;
  late final TextEditingController frxNameCRTC = TextEditingController(text: frxNameCR);
  final FocusNode frxNameCRFN = FocusNode();
  ///次品记录提交成功后，是否返回到首页
  bool isGetBackAfterCommitSuccessCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
  //endregion

  //region 次品条码模板名称列表
  ///根据产品类别编码区分的打印模板名称列表
  final Map<String, String> invClassFrxNameMapCR = {};
  //endregion

  //region 不良品上报-派工信息显示设置
  final List<InfoFormModel> taskInfoFormListMR = [];
  //endregion

  //region 不良品上报-按钮显示设置
  ///是否显示不良品上报方式切换按钮
  bool isShowDataReportTypeBtnMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
  ///不良品上报方式
  String checkRecordTypeMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_TYPE_KEY) ?? AppConfig.qtyMaterialReject;
  ///是否显示“补打”按钮（当生产日期受班次影响时，始终不显示该按钮） 不良品上报
  bool isShowMakeUpBtnMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
  ///页面上显示不良品上报提交按钮（可显示多个，index 相加）
  ///
  ///1：不良品上报提交
  ///
  ///2：提交并打印
  late int checkRecordBtnIndexMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_BTN_INDEX_KEY) ?? AppConfig.materialRejectBtnIndex;
  //endregion

  //region 不良品上报-表单填写项显示设置
  final ScrollController mRFormScrollController = ScrollController();
  ///表单数据填写项的标题名称
  final Map<String, String> formTitleMapMR = {};
  ///表单数据填写项的样式
  final Map<String, Map<String, dynamic>> formStyleMapMR = {};
  ///自动获取焦点的输入框字段名
  String numPadFocusFieldMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
  ///单列可显示的表单填写项的行数
  int? formRowMaxCountLimitMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_FORM_ROW_MAX_COUNT_LIMIT_KEY) ?? AppConfig.formRowMaxCountLimit;
  late final TextEditingController formRowMaxCountLimitMRTC = TextEditingController(text: formRowMaxCountLimitMR?.toString() ?? '');
  final FocusNode formRowMaxCountLimitMRFN = FocusNode();
  //endregion

  //region 不良品上报-表单填写设置
  ///车间默认值获取方式 0: 单据车间  1: 登录账号所在车间
  int depGetWayIndexMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
  ///人员是否可以通过 Adapter 选单
  bool isPsnHasAdapterMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
  ///生产人员是否可以多选
  bool isPsnMultiMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
  ///生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间
  int psnGetWayIndexMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
  ///生产人员获取条件是固定车间时，固定车间的值
  final String psnDepCodeMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_PSN_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
  late final TextEditingController psnDepCodeMRTC = TextEditingController(text: psnDepCodeMR);
  final FocusNode psnDepCodeMRFN = FocusNode();
  ///生产人员获取条件是固定产线时，固定产线的值
  final String psnLineCodeMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
  late final TextEditingController psnLineCodeMRTC = TextEditingController(text: psnLineCodeMR);
  final FocusNode psnLineCodeMRFN = FocusNode();
  ///是否保存上次报工时选中的员工
  bool isSaveTheLastSelectedPsnIdMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;
  ///不良品上报条码打印模板文件名称
  final String frxNameMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesTaskMaterialRejectPrintFileName;
  late final TextEditingController frxNameMRTC = TextEditingController(text: frxNameMR);
  final FocusNode frxNameMRFN = FocusNode();
  ///不良品上报记录提交成功后，是否返回到首页
  bool isGetBackAfterCommitSuccessMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
  //endregion

  //region 不良品上报条码模板名称列表
  ///根据产品类别编码区分的打印模板名称列表
  final Map<String, String> invClassFrxNameMapMR = {};
  //endregion

  //region 次品列表设置
  final ScrollController checkRecordListScrollController = ScrollController();
  ///次品记录列表的单页显示记录数
  int pageConfigRowsCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
  ///次品单删除时间限制
  final int? limitTimeCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
  late final TextEditingController limitTimeCRTC = TextEditingController(text: limitTimeCR?.toString() ?? '');
  final FocusNode limitTimeCRFN = FocusNode();
  ///次品单信息显示设置
  final Map<int, List<InfoFormModel>> checkRecordListInfoFormListMap = {};
  //endregion


  DeviceDetailSettingController({
    super.progId = -1,
    required this.type,
    this.noPermission = false,
    this.permissionInfo = '',
  });


  @override
  void onInit() {
    super.onInit();

    //region TabView Get.find
    try {
      deviceDetailBoardController = Get.find<DeviceDetailBoardController>();
      detailTabList.addAll(deviceDetailBoardController!.tabValueList.map(
              (e) => ChoiceChipModel(title: e)).toList());
    } catch (e){}
    try {
      deviceDetailController = Get.find<DeviceDetailController>();
    } catch (e){}
    try {
      deviceSubmitController = Get.find<DeviceSubmitController>();
    } catch (e){}
    try {
      deviceCheckRecordController = Get.find<DeviceCheckRecordController>();
    } catch (e){}
    try {
    deviceMaterialRejectController = Get.find<DeviceMaterialRejectController>();
    } catch (e){}
    try {
      pMesSubmitListController = Get.find<PMesSubmitListController>();
    } catch (e){}
    try {
      pMesCheckRecordListController = Get.find<PMesCheckRecordListController>();
    } catch (e){}
    //endregion

    //region 设备详情-设备任务信息显示设置
    List<dynamic> detailInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_TASK_INFO_FORM_LIST_KEY) ?? [];
    detailInfoFormList.addAll(getInfoFormListByStorage(detailInfoFormMapList, AppConfig.pMesDeiceTaskDetailInfoFormList));
    //endregion

    //region 设备详情-设备任务按钮显示设置
    final List<dynamic> detailCommandBarMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_TASK_COMMAND_BAR_LIST_KEY) ?? [];
    detailCommandBarList.clear();
    detailCommandBarList.addAll(
      getCommandBarListByStorage(
        detailCommandBarMapList,
        AppConfig.pMesDeviceDetailTaskCommandBarList
      )
    );
    //endregion

    //region 设备详情-派工单列表信息显示设置
    List<dynamic> detailTaskListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_TASK_LIST_INFO_FORM_LIST_KEY) ?? [];
    List<InfoFormModel> detailTaskListInfoFormList = getInfoFormListByStorage(detailTaskListInfoFormMapList, AppConfig.pMesTaskListInfoFormList);
    detailTaskListInfoFormList.forEach((element){
      if (detailTaskListInfoFormListMap.containsKey(element.groupType)){
        detailTaskListInfoFormListMap[element.groupType]!.add(element);
      }
      else {
        detailTaskListInfoFormListMap.addAll({element.groupType: [element]});
      }
    });
    //endregion

    //region 设备详情-派工单列表按钮显示设置
    final List<dynamic> detailTaskListCommandBarMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_TASK_LIST_COMMAND_BAR_LIST_KEY) ?? [];
    detailTaskListCommandBarList.clear();
    detailTaskListCommandBarList.addAll(
      getCommandBarListByStorage(
        detailTaskListCommandBarMapList,
        AppConfig.pMesDeviceTaskListCommandBarList
      )
    );
    //endregion

    //region 机台报工-派工信息显示设置
    List<dynamic> taskInfoFormMapListSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_INFO_FORM_LIST_KEY) ?? [];
    taskInfoFormListSubmit.clear();
    taskInfoFormListSubmit.addAll(
        getInfoFormListByStorage(
            taskInfoFormMapListSubmit,
            AppConfig.pMesTaskInfoFormList
        )
    );
    //endregion

    //region 机台报工-表单填写项显示设置
    String formTitleMapStrSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_FORM_TITLE_MAP_KEY) ?? '';
    formTitleMapSubmit.addAll(getFormTitleMapByStorage(formTitleMapStrSubmit, AppConfig.pMesSubmitFormTitleMap));
    String formStyleMapStrSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_FORM_STYLE_MAP_KEY) ?? '';
    formStyleMapSubmit.addAll(getFormStyleMapByStorage(formStyleMapStrSubmit, AppConfig.pMesSubmitFormStyleMap));
    //endregion

    //region 报工条码模板名称列表
    String invClassFrxNameMapSubmitStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMapSubmit.clear();
    invClassFrxNameMapSubmit.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapSubmitStr));
    //endregion

    //region 报工列表-报工单信息显示设置
    List<dynamic> submitListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICETASK_SUBMIT_LIST_INFO_FORM_LIST_KEY) ?? [];
    List<InfoFormModel> submitListInfoFormList = getInfoFormListByStorage(submitListInfoFormMapList, AppConfig.pMesSubmitListInfoFormList);
    submitListInfoFormList.forEach((element){
      if (submitListInfoFormListMap.containsKey(element.groupType)){
        submitListInfoFormListMap[element.groupType]!.add(element);
      }
      else {
        submitListInfoFormListMap.addAll({element.groupType: [element]});
      }
    });
    //endregion

    //region 次品录入-派工信息显示设置
    List<dynamic> taskInfoFormMapListCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_INFO_FORM_LIST_KEY) ?? [];
    taskInfoFormListCR.addAll(getInfoFormListByStorage(taskInfoFormMapListCR, AppConfig.pMesTaskInfoFormList));
    //endregion

    //region 次品录入-表单填写项显示设置
    String formTitleMapStrCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_FORM_TITLE_MAP_KEY) ?? '';
    formTitleMapCR.addAll(getFormTitleMapByStorage(formTitleMapStrCR, AppConfig.pMesCheckRecordFormTitleMap));
    String formStyleMapStrCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_FORM_STYLE_MAP_KEY) ?? '';
    formStyleMapCR.addAll(getFormStyleMapByStorage(formStyleMapStrCR, AppConfig.pMesCheckRecordFormStyleMap));
    //endregion

    //region 次品条码模板名称列表
    String invClassFrxNameMapCRStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMapCR.clear();
    invClassFrxNameMapCR.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapCRStr));
    //endregion

    //region 不良品上报-派工信息显示设置
    List<dynamic> taskInfoFormMapListMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_INFO_FORM_LIST_KEY) ?? [];
    taskInfoFormListMR.clear();
    taskInfoFormListMR.addAll(
        getInfoFormListByStorage(
            taskInfoFormMapListMR,
            AppConfig.mesTaskInfoFormList
        )
    );
    //endregion

    //region 不良品上报-表单填写项显示设置
    String formTitleMapStrMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_FORM_TITLE_MAP_KEY) ?? '';
    formTitleMapMR.clear();
    formTitleMapMR.addAll(
        getFormTitleMapByStorage(
            formTitleMapStrMR,
            AppConfig.mesTaskMaterialRejectFormTitleMap
        )
    );
    String formStyleMapStrMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_FORM_STYLE_MAP_KEY) ?? '';
    formStyleMapMR.clear();
    formStyleMapMR.addAll(
        getFormStyleMapByStorage(
            formStyleMapStrMR,
            AppConfig.mesTaskCheckRecordFormStyleMap
        )
    );
    //endregion

    //region 不良品上报条码模板名称列表
    String invClassFrxNameMapMRStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMapMR.clear();
    invClassFrxNameMapMR.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapMRStr));
    //endregion

    //region 次品列表-次品单信息显示设置
    List<dynamic> checkRecordListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_LIST_INFO_FORM_LIST_KEY) ?? [];
    List<InfoFormModel> checkRecordListInfoFormList = getInfoFormListByStorage(checkRecordListInfoFormMapList, AppConfig.pMesCheckRecordListInfoFormList);
    checkRecordListInfoFormList.forEach((element){
      if (checkRecordListInfoFormListMap.containsKey(element.groupType)){
        checkRecordListInfoFormListMap[element.groupType]!.add(element);
      }
      else {
        checkRecordListInfoFormListMap.addAll({element.groupType: [element]});
      }
    });
    //endregion
  }


  //region OnChanged

  //region 默认选项卡

  ///默认选项卡Item选择变化
  void initialIndexOnChanged(int index) {
    initialTabIndex = index;
    update();
  }

  //endregion

  //region 机台报工-按钮显示设置
  
  void isShowDataReportTypeBtnSubmitOnChanged(){
    isShowDataReportTypeBtnSubmit = !isShowDataReportTypeBtnSubmit;
    update();
  }

  void submitTypeOnChanged(ChoiceChipModel item) {
    submitType = item.keyName;
    update();
  }

  void isShowMakeUpBtnSubmitOnChanged() {
    isShowMakeUpBtnSubmit = !isShowMakeUpBtnSubmit;
    update();
  }

  void isShowInspectFlagBtnOnChanged() {
    isShowInspectFlagBtn = !isShowInspectFlagBtn;
    update();
  }

  void isCanClickInspectFlagBtnOnChanged() {
    isCanClickInspectFlagBtn = !isCanClickInspectFlagBtn;
    update();
  }

  void inspectFlagDefaultValueOnChanged(bool? boolValue){
    inspectFlagDefaultValue = boolValue;
    update();
  }

  void isShowGetPieceWeightBtnOnChanged() {
    isShowGetPieceWeightBtn = !isShowGetPieceWeightBtn;
    update();
  }

  void submitBtnIndexOnChanged(int sign) {
    if (submitBtnIndex & sign == sign){
      submitBtnIndex -= sign;
    }
    else {
      submitBtnIndex += sign;
    }
    update();
  }
  
  //endregion

  //region 机台报工-表单填写设置

  void depGetWayIndexSubmitOnChanged(int index) {
    depGetWayIndexSubmit = index;
    update();
  }

  void wcDataReportTypeSubmitOnChanged(int index) {
    wcDataReportTypeSubmit = index;
    update();
  }

  void isPsnHasAdapterSubmitOnChanged() {
    isPsnHasAdapterSubmit = !isPsnHasAdapterSubmit;
    update();
  }

  void isPsnMultiSubmitOnChanged() {
    isPsnMultiSubmit = !isPsnMultiSubmit;
    update();
  }

  void psnGetWayIndexSubmitOnChanged(int index) {
    psnGetWayIndexSubmit = index;
    update();
  }

  void isSaveTheLastSelectedPsnIdSubmitOnChanged() {
    isSaveTheLastSelectedPsnIdSubmit = !isSaveTheLastSelectedPsnIdSubmit;
    update();
  }

  void calcRuleForPalletSubmitTypeOnChanged(int index) {
    calcRuleForPalletSubmitType = index;
    update();
  }

  void isSaveTheLastPackingWeightDataOnChanged() {
    isSaveTheLastPackingWeightData = !isSaveTheLastPackingWeightData;
    update();
  }

  void isUsePackingPickerOnChanged() {
    isUsePackingPicker = !isUsePackingPicker;
    if (!isUsePackingPicker){
      isSingleBoxQtyOnlyChangedByContainer = false;
    }
    update();
  }

  void isSingleBoxQtyOnlyChangedByContainerOnChanged() {
    if (!isUsePackingPicker){
      isSingleBoxQtyOnlyChangedByContainer = false;
    }
    else {
      isSingleBoxQtyOnlyChangedByContainer = !isSingleBoxQtyOnlyChangedByContainer;
    }
    update();
  }
  
  void isAutoWritePieceWeightOnChanged() {
    isAutoWritePieceWeight = !isAutoWritePieceWeight;
    update();
  }

  void qtyIsNeedPieceWeightOnChanged() {
    qtyIsNeedPieceWeight = !qtyIsNeedPieceWeight;
    update();
  }

  void qtyCanWeightCalcByStandWeightOnChanged() {
    qtyCanWeightCalcByStandWeight = !qtyCanWeightCalcByStandWeight;
    update();
  }

  void qtyBoxIsNeedPieceWeightOnChanged() {
    qtyBoxIsNeedPieceWeight = !qtyBoxIsNeedPieceWeight;
    update();
  }

  void qtyBoxCanWeightCalcByStandWeightOnChanged() {
    qtyBoxCanWeightCalcByStandWeight = !qtyBoxCanWeightCalcByStandWeight;
    update();
  }

  void palletIsNeedPieceWeightOnChanged() {
    palletIsNeedPieceWeight = !palletIsNeedPieceWeight;
    update();
  }

  void palletCanWeightCalcByStandWeightOnChanged() {
    palletCanWeightCalcByStandWeight = !palletCanWeightCalcByStandWeight;
    update();
  }

  void weightIsNeedPieceWeightOnChanged() {
    weightIsNeedPieceWeight = !weightIsNeedPieceWeight;
    update();
  }

  void weightIsAddPieceWeightToTotalOnChanged() {
    weightIsAddPieceWeightToTotal = !weightIsAddPieceWeightToTotal;
    update();
  }

  void weightBoxIsNeedPieceWeightOnChanged() {
    weightBoxIsNeedPieceWeight = !weightBoxIsNeedPieceWeight;
    update();
  }

  void isShowExpectSingleBoxQtyOnChanged() {
    isShowExpectSingleBoxQty = !isShowExpectSingleBoxQty;
    update();
  }

  void isGetBackAfterCommitSuccessSubmitOnChanged(){
    isGetBackAfterCommitSuccessSubmit = !isGetBackAfterCommitSuccessSubmit;
    update();
  }

  //endregion

  //region 报工单列表设置

  ///报工列表的单页显示记录数 点击变化
  void pageConfigRowsSubmitOnChanged(int intValue) {
    pageConfigRowsSubmit = intValue;
    update();
  }

  //endregion

  //region 次品录入-按钮显示设置

  void isShowDataReportTypeBtnCROnChanged() {
    isShowDataReportTypeBtnCR = !isShowDataReportTypeBtnCR;
    update();
  }

  void checkRecordTypeOnChanged(ChoiceChipModel item) {
    checkRecordType = item.keyName;
    update();
  }

  void isShowMakeUpBtnCROnChanged() {
    isShowMakeUpBtnCR = !isShowMakeUpBtnCR;
    update();
  }

  void checkRecordBtnIndexOnChanged(int sign) {
    if (checkRecordBtnIndex & sign == sign){
      checkRecordBtnIndex -= sign;
    }
    else {
      checkRecordBtnIndex += sign;
    }
    update();
  }

  //endregion

  //region 次品录入-表单填写设置

  void depGetWayIndexCROnChanged(int index) {
    depGetWayIndexCR = index;
    update();
  }

  void wcDataReportTypeCROnChanged(int index) {
    wcDataReportTypeCR = index;
    update();
  }

  void isPsnHasAdapterCROnChanged() {
    isPsnHasAdapterCR = !isPsnHasAdapterCR;
    update();
  }

  void isPsnMultiCROnChanged() {
    isPsnMultiCR = !isPsnMultiCR;
    update();
  }

  void psnGetWayIndexCROnChanged(int index) {
    psnGetWayIndexCR = index;
    update();
  }

  void isSaveTheLastSelectedPsnIdCROnChanged() {
    isSaveTheLastSelectedPsnIdCR = !isSaveTheLastSelectedPsnIdCR;
    update();
  }

  void isGetBackAfterCommitSuccessCROnChanged(){
    isGetBackAfterCommitSuccessCR = !isGetBackAfterCommitSuccessCR;
    update();
  }

  //endregion

  //region 不良品上报-按钮显示设置

  void isShowDataReportTypeBtnMROnChanged() {
    isShowDataReportTypeBtnMR = !isShowDataReportTypeBtnMR;
    update();
  }

  void checkRecordTypeMROnChanged(ChoiceChipModel item) {
    checkRecordTypeMR = item.keyName;
    update();
  }

  void isShowMakeUpBtnMROnChanged() {
    isShowMakeUpBtnMR = !isShowMakeUpBtnMR;
    update();
  }

  void checkRecordBtnIndexMROnChanged(int sign) {
    if (checkRecordBtnIndexMR & sign == sign){
      checkRecordBtnIndexMR -= sign;
    }
    else {
      checkRecordBtnIndexMR += sign;
    }
    update();
  }

  //endregion

  //region 不良品上报-表单填写设置

  void depGetWayIndexMROnChanged(int index) {
    depGetWayIndexMR = index;
    update();
  }

  void isPsnHasAdapterMROnChanged() {
    isPsnHasAdapterMR = !isPsnHasAdapterMR;
    update();
  }

  void isPsnMultiMROnChanged() {
    isPsnMultiMR = !isPsnMultiMR;
    update();
  }

  void psnGetWayIndexMROnChanged(int index) {
    psnGetWayIndexMR = index;
    update();
  }

  void isSaveTheLastSelectedPsnIdMROnChanged() {
    isSaveTheLastSelectedPsnIdMR = !isSaveTheLastSelectedPsnIdMR;
    update();
  }

  void isGetBackAfterCommitSuccessMROnChanged(){
    isGetBackAfterCommitSuccessMR = !isGetBackAfterCommitSuccessMR;
    update();
  }

  //endregion

  //region 次品记录列表设置

  ///次品记录列表的单页显示记录数 点击变化
  void pageConfigRowsCROnChanged(int intValue) {
    pageConfigRowsCR = intValue;
    update();
  }

  //endregion
  
  //endregion


  //region OnSave

  ///默认选项卡保存
  Future<void> initialIndexOnSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 1, msg: '正在保存', completedMsg: '数据保存成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_DETAIL_BOARD_INITIAL_INDEX_KEY, initialTabIndex);
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 1);
  }

  ///装箱单打印设置 保存
  Future<void> packingOnSave() async{
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存数据？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 1, msg: '正在保存', completedMsg: '数据保存成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_DETAIL_PACKING_PRINT_FILE_NAME_KEY, packingFrxNameTC.text);
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 1);
  }

  ///设备详情-设备任务信息显示设置 保存
  Future<void> detailInfoFormSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    List<Map<String, dynamic>> mapList = [];
    mapList.addAll(detailInfoFormList.map((e) => e.toJson()));
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_DETAIL_TASK_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceDetailController != null){
      deviceDetailController!.taskInfoFormList.clear();
      deviceDetailController!.taskInfoFormList.addAll(detailInfoFormList);
      deviceDetailController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///设备详情-设备任务按钮显示设置 保存
  Future<void> detailCommandBarOnSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存数据', completedMsg: '数据刷新成功！');

    //region 数据保存
    List<Map<String, dynamic>> mapList = [];
    detailCommandBarList.forEach((element) {
      mapList.add(element.toJson());
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_DETAIL_TASK_COMMAND_BAR_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceDetailController != null){
      deviceDetailController!.detailCommandBarList.clear();
      deviceDetailController!.detailCommandBarList.addAll(detailCommandBarList);
      deviceDetailController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///设备详情-派工单列表信息显示设置 保存
  Future<void> detailTaskListInfoFormSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    List<Map<String, dynamic>> mapList = [];
    detailTaskListInfoFormListMap.forEach((key, value) {
      mapList.addAll(value.map((e) => e.toJson()));
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_DETAIL_TASK_LIST_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceDetailController != null){
      deviceDetailController!.taskListInfoFormListMap.clear();
      deviceDetailController!.taskListInfoFormListMap.addAll(detailTaskListInfoFormListMap);
      deviceDetailController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///设备详情-派工单列表按钮显示设置 保存
  Future<void> detailTaskListCommandBarOnSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存数据', completedMsg: '数据刷新成功！');

    //region 数据保存
    List<Map<String, dynamic>> mapList = [];
    detailTaskListCommandBarList.forEach((element) {
      mapList.add(element.toJson());
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_DETAIL_TASK_LIST_COMMAND_BAR_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceDetailController != null){
      deviceDetailController!.taskListCommandBarList.clear();
      deviceDetailController!.taskListCommandBarList.addAll(detailTaskListCommandBarList);
      deviceDetailController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///机台报工-派工信息显示设置 保存
  Future<void> submitInfoFormSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    List<Map<String, dynamic>> mapList = [];
    mapList.addAll(taskInfoFormListSubmit.map((e) => e.toJson()));
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceSubmitController != null){
      deviceSubmitController!.taskInfoFormList.clear();
      deviceSubmitController!.taskInfoFormList.addAll(taskInfoFormListSubmit);
      deviceSubmitController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///机台报工-按钮显示设置 保存
  Future<void> submitBtnSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_TYPE_BTN_KEY, isShowDataReportTypeBtnSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_TYPE_KEY, submitType);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_MAKE_UP_BTN_KEY, isShowMakeUpBtnSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_INSPECT_FLAG_BTN_KEY, isShowInspectFlagBtn);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_CAN_CLICK_INSPECT_FLAG_BTN_KEY, isCanClickInspectFlagBtn);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_INSPECT_FLAG_DEFAULT_VALUE_KEY, inspectFlagDefaultValue);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_GET_FIRST_INSPECT_EBWEIGHT_BTN, isShowGetPieceWeightBtn);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_BTN_INDEX_KEY, submitBtnIndex);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceSubmitController != null){
      deviceSubmitController!.isShowDataReportTypeBtn = isShowDataReportTypeBtnSubmit;
      deviceSubmitController!.submitType = submitType;
      deviceSubmitController!.isShowMakeUpBtn = isShowMakeUpBtnSubmit;
      deviceSubmitController!.isShowInspectFlagBtn = isShowInspectFlagBtn;
      deviceSubmitController!.isCanClickInspectFlagBtn = isCanClickInspectFlagBtn;
      deviceSubmitController!.inspectFlagDefaultValue = inspectFlagDefaultValue;
      deviceSubmitController!.isShowGetPieceWeightBtn = isShowGetPieceWeightBtn;
      deviceSubmitController!.submitBtnIndex = submitBtnIndex;
      deviceSubmitController!.updateFormJudgeTypeMap();
      deviceSubmitController!.numPadCTListSetEnabled();
      deviceSubmitController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///机台报工-表单填写项显示设置 保存
  Future<void> submitFormSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    //region 提交前校验
    int? formRowMaxCountLimitSubmitTCInt = int.tryParse(formRowMaxCountLimitSubmitTC.text);
    if (formRowMaxCountLimitSubmitTC.text.isNotEmpty
        && (formRowMaxCountLimitSubmitTCInt == null || formRowMaxCountLimitSubmitTCInt < 1)){
      ToastNotification(Get.overlayContext!).warn('“单列可显示的表单填写项的行数”输入错误，请检查！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    String str = jsonEncode(formTitleMapSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_FORM_TITLE_MAP_KEY, str);
    String styleStr = jsonEncode(formStyleMapSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_FORM_STYLE_MAP_KEY, styleStr);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_NUM_PAD_FOCUS_FIELD_KEY, numPadFocusFieldSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_FORM_ROW_MAX_COUNT_LIMIT_KEY, formRowMaxCountLimitSubmitTCInt);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceSubmitController != null){
      deviceSubmitController!.formTitleMap.clear();
      deviceSubmitController!.formTitleMap.addAll(formTitleMapSubmit);
      deviceSubmitController!.numPadCTList.sort((a, b){
        return numPadCTListSortVoidCallback.call(deviceSubmitController!.formTitleMap, a, b);
      });
      deviceSubmitController!.formStyleMap.clear();
      deviceSubmitController!.formStyleMap.addAll(formStyleMapSubmit);
      deviceSubmitController!.numPadCTList.forEach((element) {
        element.styleMap.clear();
        if (deviceSubmitController!.formStyleMap.containsKey(element.key)){
          element.styleMap.addAll(deviceSubmitController!.formStyleMap[element.key]!);
        }
      });
      deviceSubmitController!.numPadFocusField = numPadFocusFieldSubmit;
      deviceSubmitController!.formRowMaxCountLimit = formRowMaxCountLimitSubmitTCInt;
      deviceSubmitController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///机台报工-表单填写设置 保存
  Future<void> submitFormSettingSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    //region 提交前校验
    int? numMaxCountLimitTCInt = int.tryParse(numMaxCountLimitTC.text);
    if (numMaxCountLimitTC.text.isNotEmpty
        && (numMaxCountLimitTCInt == null || numMaxCountLimitTCInt < 2)){
      ToastNotification(Get.overlayContext!).warn('“整箱箱数”的上限输入错误，请检查！');
      isLoading = false;
      return;
    }
    double? singleBoxQtyMaxCountLimitDouble = double.tryParse(singleBoxQtyMaxCountLimitTC.text);
    if (singleBoxQtyMaxCountLimitTC.text.isNotEmpty
        && (singleBoxQtyMaxCountLimitDouble == null || singleBoxQtyMaxCountLimitDouble <= 0)){
      ToastNotification(Get.overlayContext!).warn('“单箱数量”的下限输入错误，请检查！');
      isLoading = false;
      return;
    }
    if (frxNameSubmitTC.text.isEmpty){
      ToastNotification(Get.overlayContext!).warn('报工条码打印模板文件名称不能为空，请检查！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_DEP_GET_WAY_INDEX_KEY, depGetWayIndexSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_WC_DATA_REPORT_TYPE_KEY, wcDataReportTypeSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY, isPsnHasAdapterSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_PSN_MULTI_KEY, isPsnMultiSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_PSN_GET_WAY_INDEX_KEY, psnGetWayIndexSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY, psnDepCodeSubmitTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY, psnLineCodeSubmitTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY, isSaveTheLastSelectedPsnIdSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_NUM_MAX_COUNT_LIMIT_KEY, numMaxCountLimitTCInt);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_SINGLE_BOX_QTY_MAX_COUNT_LIMIT_KEY, singleBoxQtyMaxCountLimitDouble);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_CALC_RULE_FOR_PALLET_SUBMIT_TYPE_KEY, calcRuleForPalletSubmitType);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY, isSaveTheLastPackingWeightData);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_USE_PACKING_PICKER_KEY, isUsePackingPicker);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY, isSingleBoxQtyOnlyChangedByContainer);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_AUTO_WRITE_PIECE_WEIGHT_KEY, isAutoWritePieceWeight);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_QTY_ISNEED_PIECEWEIGHT_KEY, qtyIsNeedPieceWeight);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_QTY_CAN_WEIGHT_CALC_BY_STAND_WEIGHT_KEY, qtyCanWeightCalcByStandWeight);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_QTY_BOX_ISNEED_PIECEWEIGHT_KEY, qtyBoxIsNeedPieceWeight);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_QTY_BOX_CAN_WEIGHT_CALC_BY_STAND_WEIGHT_KEY, qtyBoxCanWeightCalcByStandWeight);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_PALLET_ISNEED_PIECEWEIGHT_KEY, palletIsNeedPieceWeight);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_PALLET_CAN_WEIGHT_CALC_BY_STAND_WEIGHT_KEY, palletCanWeightCalcByStandWeight);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_WEIGHT_ISNEED_PIECEWEIGHT_KEY, weightIsNeedPieceWeight);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_WEIGHT_IS_ADD_PIECE_WEIGHT_TO_TOTAL_KEY, weightIsAddPieceWeightToTotal);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_WEIGHT_BOX_ISNEED_PIECEWEIGHT_KEY, weightBoxIsNeedPieceWeight);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_SHOW_EXPECT_SINGLE_BOX_QTY_KEY, isShowExpectSingleBoxQty);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_TEMPLATE_FILENAME_KEY, frxNameSubmitTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY, isGetBackAfterCommitSuccessSubmit);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceSubmitController != null){
      bool needResetPerson = false;
      deviceSubmitController!.depGetWayIndex = depGetWayIndexSubmit;
      if (deviceSubmitController!.wcDataReportType != wcDataReportTypeSubmit) {
        deviceSubmitController!.wcDataReportType = wcDataReportTypeSubmit;
        deviceSubmitController!.submitModel.wcId = null;
        deviceSubmitController!.submitModel.lineCode = null;
        deviceSubmitController!.submitModel.lineName = null;
        switch (deviceSubmitController!.wcDataReportType){
          //region
          case 0: ///产线
            if (deviceSubmitController!.lineAdapter == null){
              await deviceSubmitController!.getLineAdapter();
            }
            break;
          case 1: ///加工中心
            if (deviceSubmitController!.workCenterAdapter == null){
              await deviceSubmitController!.getWorkCenterAdapter();
            }
            break;
          case 2: ///生产班组
            if (deviceSubmitController!.teamGroupAdapter == null){
              await deviceSubmitController!.getTeamGroupAdapter();
            }
            break;
          //endregion
        }
      }
      if (deviceSubmitController!.isPsnHasAdapter != isPsnHasAdapterSubmit){
        deviceSubmitController!.isPsnHasAdapter = isPsnHasAdapterSubmit;
        needResetPerson = true;
      }
      if (deviceSubmitController!.isPsnMulti != isPsnMultiSubmit){
        deviceSubmitController!.isPsnMulti = isPsnMultiSubmit;
        needResetPerson = true;
      }
      if (deviceSubmitController!.psnGetWayIndex != psnGetWayIndexSubmit){
        deviceSubmitController!.psnGetWayIndex = psnGetWayIndexSubmit;
        needResetPerson = true;
      }
      if (deviceSubmitController!.psnDepCode != psnDepCodeSubmitTC.text){
        deviceSubmitController!.psnDepCode = psnDepCodeSubmitTC.text;
        needResetPerson = true;
      }
      if (deviceSubmitController!.psnLineCode != psnLineCodeSubmitTC.text){
        deviceSubmitController!.psnLineCode = psnLineCodeSubmitTC.text;
        needResetPerson = true;
      }
      deviceSubmitController!.isSaveTheLastSelectedPsnId = isSaveTheLastSelectedPsnIdSubmit;
      deviceSubmitController!.numMaxCountLimit = numMaxCountLimitTCInt;
      deviceSubmitController!.singleBoxQtyMaxCountLimit = singleBoxQtyMaxCountLimitDouble;
      deviceSubmitController!.calcRuleForPalletSubmitType = calcRuleForPalletSubmitType;
      deviceSubmitController!.isSaveTheLastPackingWeightData = isSaveTheLastPackingWeightData;
      if (deviceSubmitController!.isUsePackingPicker != isUsePackingPicker){
        deviceSubmitController!.isUsePackingPicker = isUsePackingPicker;
        if (deviceSubmitController!.isUsePackingPicker){
          NumPadUtil().setText(NumPadUtil.packingWeight, '', deviceSubmitController!.numPadCTList);
          deviceSubmitController!.calcQty(NumPadUtil.packingWeight);
          if (deviceSubmitController!.containerWithNoPageAdapter == null){
            await deviceSubmitController!.getContainerWithNoPageAdapter();
          }
          else {
            deviceSubmitController!.containerWithNoPageAdapter!.clearSelection();
          }
        }
      }
      if (deviceSubmitController!.isSingleBoxQtyOnlyChangedByContainer != isSingleBoxQtyOnlyChangedByContainer){
        deviceSubmitController!.isSingleBoxQtyOnlyChangedByContainer = isSingleBoxQtyOnlyChangedByContainer;
        if (deviceSubmitController!.isSingleBoxQtyOnlyChangedByContainer){
          NumPadUtil().setText(NumPadUtil.packingWeight, '', deviceSubmitController!.numPadCTList);
          deviceSubmitController!.calcQty(NumPadUtil.packingWeight);
          if (deviceSubmitController!.containerWithNoPageAdapter == null){
            await deviceSubmitController!.getContainerWithNoPageAdapter();
          }
          else {
            deviceSubmitController!.containerWithNoPageAdapter!.clearSelection();
          }
        }
      }
      deviceSubmitController!.isAutoWritePieceWeight = isAutoWritePieceWeight;
      deviceSubmitController!.qtyIsNeedPieceWeight = qtyIsNeedPieceWeight;
      deviceSubmitController!.qtyCanWeightCalcByStandWeight = qtyCanWeightCalcByStandWeight;
      deviceSubmitController!.qtyBoxIsNeedPieceWeight = qtyBoxIsNeedPieceWeight;
      deviceSubmitController!.qtyBoxCanWeightCalcByStandWeight = qtyBoxCanWeightCalcByStandWeight;
      deviceSubmitController!.palletIsNeedPieceWeight = palletIsNeedPieceWeight;
      deviceSubmitController!.palletCanWeightCalcByStandWeight = palletCanWeightCalcByStandWeight;
      deviceSubmitController!.weightIsNeedPieceWeight = weightIsNeedPieceWeight;
      deviceSubmitController!.weightIsAddPieceWeightToTotal = weightIsAddPieceWeightToTotal;
      deviceSubmitController!.weightBoxIsNeedPieceWeight = weightBoxIsNeedPieceWeight;
      deviceSubmitController!.isShowExpectSingleBoxQty = isShowExpectSingleBoxQty;
      deviceSubmitController!.frxName = frxNameSubmitTC.text;
      deviceSubmitController!.isGetBackAfterCommitSuccess = isGetBackAfterCommitSuccessSubmit;
      if (needResetPerson){
        deviceSubmitController!.submitModel.empId = null;
        deviceSubmitController!.submitModel.emploee = null;
        if (deviceSubmitController!.isPsnHasAdapter){
          await deviceSubmitController!.getPersonAdapter();
        }
        else {
          deviceSubmitController!.personList.clear();
        }
      }
      deviceSubmitController!.updateFormJudgeTypeMap();
      deviceSubmitController!.numPadCTListSetEnabled();
      deviceSubmitController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///机台报工-产品类别打印模板设置
  Future<void> submitInvClassTemplateSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    String invClassFrxNameMapSubmitStr = json.encode(invClassFrxNameMapSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICE_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY, invClassFrxNameMapSubmitStr);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceSubmitController != null){
      deviceSubmitController!.invClassFrxNameMap.clear();
      deviceSubmitController!.invClassFrxNameMap.addAll(invClassFrxNameMapSubmit);
      deviceSubmitController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///报工单列表设置 保存
  Future<void> submitListSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    //region 提交前校验
    int? limitTimeSubmitTCInt = int.tryParse(limitTimeSubmitTC.text);
    if (limitTimeSubmitTC.text.isNotEmpty
        && (limitTimeSubmitTCInt == null || limitTimeSubmitTCInt < 0)){
      ToastNotification(Get.overlayContext!).warn('“报工记录可删除的时间限制”输入错误，请检查！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_SUBMIT_LIST_PAGE_CONFIG_ROWS_KEY, pageConfigRowsSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_DELETE_LIMIT_TIME, int.tryParse(limitTimeSubmitTC.text));
    List<Map<String, dynamic>> mapList = [];
    submitListInfoFormListMap.forEach((key, value) {
      mapList.addAll(value.map((e) => e.toJson()));
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.DEVICETASK_SUBMIT_LIST_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (pMesSubmitListController != null){
      if (pMesSubmitListController!.dataListPageConfig.rows != pageConfigRowsSubmit){
        pMesSubmitListController!.dataListPageConfig.rows = pageConfigRowsSubmit;
        await pMesSubmitListController!.pageChanged(showLoading: false);
      }
      pMesSubmitListController!.limitTime = int.tryParse(limitTimeSubmitTC.text);
      pMesSubmitListController!.pMesSubmitListInfoFormListMap.clear();
      pMesSubmitListController!.pMesSubmitListInfoFormListMap.addAll(submitListInfoFormListMap);
      pMesSubmitListController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///次品录入-派工信息显示设置 保存
  Future<void> checkRecordInfoFormSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    List<Map<String, dynamic>> mapList = [];
    mapList.addAll(taskInfoFormListCR.map((e) => e.toJson()));
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceCheckRecordController != null){
      deviceCheckRecordController!.taskInfoFormList.clear();
      deviceCheckRecordController!.taskInfoFormList.addAll(taskInfoFormListCR);
      deviceCheckRecordController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///次品录入-按钮显示设置 保存
  Future<void> checkRecordBtnSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_SHOW_TYPE_BTN_KEY, isShowDataReportTypeBtnCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_TYPE_KEY, checkRecordType);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_SHOW_MAKE_UP_BTN_KEY, isShowMakeUpBtnCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_BTN_INDEX_KEY, checkRecordBtnIndex);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceCheckRecordController != null){
      deviceCheckRecordController!.isShowDataReportTypeBtn = isShowDataReportTypeBtnCR;
      deviceCheckRecordController!.checkRecordType = checkRecordType;
      deviceCheckRecordController!.isShowMakeUpBtn = isShowMakeUpBtnCR;
      deviceCheckRecordController!.checkRecordBtnIndex = checkRecordBtnIndex;
      deviceCheckRecordController!.numPadCTListSetEnabled();
      deviceCheckRecordController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///次品录入-表单填写项显示设置 保存
  Future<void> checkRecordFormSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    //region 提交前校验
    int? formRowMaxCountLimitCRTCInt = int.tryParse(formRowMaxCountLimitCRTC.text);
    if (formRowMaxCountLimitCRTC.text.isNotEmpty
        && (formRowMaxCountLimitCRTCInt == null || formRowMaxCountLimitCRTCInt < 1)){
      ToastNotification(Get.overlayContext!).warn('“单列可显示的表单填写项的行数”输入错误，请检查！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    String str = jsonEncode(formTitleMapCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_FORM_TITLE_MAP_KEY, str);
    String styleStr = jsonEncode(formStyleMapCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_FORM_STYLE_MAP_KEY, styleStr);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_NUM_PAD_FOCUS_FIELD_KEY, numPadFocusFieldCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_FORM_ROW_MAX_COUNT_LIMIT_KEY, formRowMaxCountLimitCRTCInt);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceCheckRecordController != null){
      deviceCheckRecordController!.formTitleMap.clear();
      deviceCheckRecordController!.formTitleMap.addAll(formTitleMapCR);
      deviceCheckRecordController!.numPadCTList.sort((a, b){
        return numPadCTListSortVoidCallback.call(deviceCheckRecordController!.formTitleMap, a, b);
      });
      deviceCheckRecordController!.formStyleMap.clear();
      deviceCheckRecordController!.formStyleMap.addAll(formStyleMapCR);
      deviceCheckRecordController!.numPadCTList.forEach((element) {
        element.styleMap.clear();
        if (deviceCheckRecordController!.formStyleMap.containsKey(element.key)){
          element.styleMap.addAll(deviceCheckRecordController!.formStyleMap[element.key]!);
        }
      });
      deviceCheckRecordController!.numPadFocusField = numPadFocusFieldCR;
      deviceCheckRecordController!.formRowMaxCountLimit = formRowMaxCountLimitCRTCInt;
      deviceCheckRecordController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///次品录入-表单填写设置 保存
  Future<void> checkRecordFormSettingSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    //region 提交前校验
    if (frxNameCRTC.text.isEmpty){
      ToastNotification(Get.overlayContext!).warn('次品记录条码打印模板文件名称不能为空，请检查！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_DEP_GET_WAY_INDEX_KEY, depGetWayIndexCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_WC_DATA_REPORT_TYPE_KEY, wcDataReportTypeCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_PSN_HAS_ADAPTER_KEY, isPsnHasAdapterCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_PSN_MULTI_KEY, isPsnMultiCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_PSN_GET_WAY_INDEX_KEY, psnGetWayIndexCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_PSN_DEP_CODE_KEY, psnDepCodeCRTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_PSN_GET_WAY_LINE_CODE_KEY, psnLineCodeCRTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY, isSaveTheLastSelectedPsnIdCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_TEMPLATE_FILENAME_KEY, frxNameCRTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY, isGetBackAfterCommitSuccessCR);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceCheckRecordController != null){
      bool needResetPerson = false;
      deviceCheckRecordController!.depGetWayIndex = depGetWayIndexCR;
      if (deviceCheckRecordController!.wcDataReportType != wcDataReportTypeCR) {
        deviceCheckRecordController!.wcDataReportType = wcDataReportTypeCR;
        deviceCheckRecordController!.checkRecordModel.wcId = null;
        deviceCheckRecordController!.checkRecordModel.lineCode = null;
        deviceCheckRecordController!.checkRecordModel.lineName = null;
        switch (deviceCheckRecordController!.wcDataReportType){
          //region
          case 0: ///产线
            if (deviceCheckRecordController!.lineAdapter == null){
              await deviceCheckRecordController!.getLineAdapter();
            }
            break;
          case 1: ///加工中心
            if (deviceCheckRecordController!.workCenterAdapter == null){
              await deviceCheckRecordController!.getWorkCenterAdapter();
            }
            break;
          case 2: ///生产班组
            if (deviceCheckRecordController!.teamGroupAdapter == null){
              await deviceCheckRecordController!.getTeamGroupAdapter();
            }
            break;
          //endregion
        }
      }
      if (deviceCheckRecordController!.isPsnHasAdapter != isPsnHasAdapterCR){
        deviceCheckRecordController!.isPsnHasAdapter = isPsnHasAdapterCR;
        needResetPerson = true;
      }
      if (deviceCheckRecordController!.isPsnMulti != isPsnMultiCR){
        deviceCheckRecordController!.isPsnMulti = isPsnMultiCR;
        needResetPerson = true;
      }
      if (deviceCheckRecordController!.psnGetWayIndex != psnGetWayIndexCR){
        deviceCheckRecordController!.psnGetWayIndex = psnGetWayIndexCR;
        needResetPerson = true;
      }
      if (deviceCheckRecordController!.psnDepCode != psnDepCodeCRTC.text){
        deviceCheckRecordController!.psnDepCode = psnDepCodeCRTC.text;
        needResetPerson = true;
      }
      if (deviceCheckRecordController!.psnLineCode != psnLineCodeCRTC.text){
        deviceCheckRecordController!.psnLineCode = psnLineCodeCRTC.text;
        needResetPerson = true;
      }
      deviceCheckRecordController!.isSaveTheLastSelectedPsnId = isSaveTheLastSelectedPsnIdCR;
      deviceCheckRecordController!.frxName = frxNameCRTC.text;
      deviceCheckRecordController!.isGetBackAfterCommitSuccess = isGetBackAfterCommitSuccessCR;
      if (needResetPerson){
        deviceCheckRecordController!.checkRecordModel.empId = null;
        deviceCheckRecordController!.checkRecordModel.emploee = null;
        if (deviceCheckRecordController!.isPsnHasAdapter){
          await deviceCheckRecordController!.getPersonAdapter();
        }
        else {
          deviceCheckRecordController!.personList.clear();
        }
      }
      deviceCheckRecordController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///次品录入-产品类别打印模板设置
  Future<void> checkRecordInvClassTemplateSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    String invClassFrxNameMapCRStr = json.encode(invClassFrxNameMapCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY, invClassFrxNameMapCRStr);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceCheckRecordController != null){
      deviceCheckRecordController!.invClassFrxNameMap.clear();
      deviceCheckRecordController!.invClassFrxNameMap.addAll(invClassFrxNameMapCR);
      deviceCheckRecordController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///不良品上报-派工信息显示设置 保存
  Future<void> mRInfoFormSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    List<Map<String, dynamic>> mapList = [];
    mapList.addAll(taskInfoFormListMR.map((e) => e.toJson()));
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceMaterialRejectController != null){
      deviceMaterialRejectController!.taskInfoFormList.clear();
      deviceMaterialRejectController!.taskInfoFormList.addAll(taskInfoFormListMR);
      deviceMaterialRejectController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///不良品上报-按钮显示设置 保存
  Future<void> mRBtnSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_IS_SHOW_TYPE_BTN_KEY, isShowDataReportTypeBtnMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_TYPE_KEY, checkRecordTypeMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_IS_SHOW_MAKE_UP_BTN_KEY, isShowMakeUpBtnMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_BTN_INDEX_KEY, checkRecordBtnIndexMR);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceMaterialRejectController != null){
      deviceMaterialRejectController!.isShowDataReportTypeBtn = isShowDataReportTypeBtnMR;
      deviceMaterialRejectController!.checkRecordType = checkRecordTypeMR;
      deviceMaterialRejectController!.numPadCTListSetEnabled();
      deviceMaterialRejectController!.isShowMakeUpBtn = isShowMakeUpBtnMR;
      deviceMaterialRejectController!.checkRecordBtnIndex = checkRecordBtnIndexMR;
      deviceMaterialRejectController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///不良品上报-表单填写项显示设置 保存
  Future<void> mRFormSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    //region 提交前校验
    int? formRowMaxCountLimitMRTCInt = int.tryParse(formRowMaxCountLimitMRTC.text);
    if (formRowMaxCountLimitMRTC.text.isNotEmpty
        && (formRowMaxCountLimitMRTCInt == null || formRowMaxCountLimitMRTCInt < 1)){
      ToastNotification(Get.overlayContext!).warn('“单列可显示的表单填写项的行数”输入错误，请检查！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    String str = jsonEncode(formTitleMapMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_FORM_TITLE_MAP_KEY, str);
    String styleStr = jsonEncode(formStyleMapMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_FORM_STYLE_MAP_KEY, styleStr);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_NUM_PAD_FOCUS_FIELD_KEY, numPadFocusFieldMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_FORM_ROW_MAX_COUNT_LIMIT_KEY, formRowMaxCountLimitMRTCInt);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceMaterialRejectController != null){
      deviceMaterialRejectController!.formTitleMap.clear();
      deviceMaterialRejectController!.formTitleMap.addAll(formTitleMapMR);
      deviceMaterialRejectController!.numPadCTList.sort((a, b){
        return numPadCTListSortVoidCallback.call(deviceMaterialRejectController!.formTitleMap, a, b);
      });
      deviceMaterialRejectController!.formStyleMap.clear();
      deviceMaterialRejectController!.formStyleMap.addAll(formStyleMapMR);
      deviceMaterialRejectController!.numPadCTList.forEach((element) {
        element.styleMap.clear();
        if (deviceMaterialRejectController!.formStyleMap.containsKey(element.key)){
          element.styleMap.addAll(deviceMaterialRejectController!.formStyleMap[element.key]!);
        }
      });
      deviceMaterialRejectController!.numPadFocusField = numPadFocusFieldMR;
      deviceMaterialRejectController!.formRowMaxCountLimit = formRowMaxCountLimitMRTCInt;
      deviceMaterialRejectController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///不良品上报-表单填写设置 保存
  Future<void> mRFormSettingSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    //region 提交前校验
    if (frxNameMRTC.text.isEmpty){
      ToastNotification(Get.overlayContext!).warn('不良品记录条码打印模板文件名称不能为空，请检查！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_DEP_GET_WAY_INDEX_KEY, depGetWayIndexMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_IS_PSN_HAS_ADAPTER_KEY, isPsnHasAdapterMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_IS_PSN_MULTI_KEY, isPsnMultiMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_PSN_GET_WAY_INDEX_KEY, psnGetWayIndexMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_PSN_DEP_CODE_KEY, psnDepCodeMRTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_PSN_GET_WAY_LINE_CODE_KEY, psnLineCodeMRTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY, isSaveTheLastSelectedPsnIdMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_TEMPLATE_FILENAME_KEY, frxNameMRTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY, isGetBackAfterCommitSuccessMR);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceMaterialRejectController != null){
      bool needResetPerson = false;
      deviceMaterialRejectController!.depGetWayIndex = depGetWayIndexMR;
      if (deviceMaterialRejectController!.isPsnHasAdapter != isPsnHasAdapterMR){
        deviceMaterialRejectController!.isPsnHasAdapter = isPsnHasAdapterMR;
        needResetPerson = true;
      }
      if (deviceMaterialRejectController!.isPsnMulti != isPsnMultiMR){
        deviceMaterialRejectController!.isPsnMulti = isPsnMultiMR;
        needResetPerson = true;
      }
      if (deviceMaterialRejectController!.psnGetWayIndex != psnGetWayIndexMR){
        deviceMaterialRejectController!.psnGetWayIndex = psnGetWayIndexMR;
        needResetPerson = true;
      }
      if (deviceMaterialRejectController!.psnDepCode != psnDepCodeMRTC.text){
        deviceMaterialRejectController!.psnDepCode = psnDepCodeMRTC.text;
        needResetPerson = true;
      }
      if (deviceMaterialRejectController!.psnLineCode != psnLineCodeMRTC.text){
        deviceMaterialRejectController!.psnLineCode = psnLineCodeMRTC.text;
        needResetPerson = true;
      }
      deviceMaterialRejectController!.isSaveTheLastSelectedPsnId = isSaveTheLastSelectedPsnIdMR;
      deviceMaterialRejectController!.frxNameMR = frxNameMRTC.text;
      deviceMaterialRejectController!.isGetBackAfterCommitSuccess = isGetBackAfterCommitSuccessMR;
      if (needResetPerson){
        deviceMaterialRejectController!.checkRecordModel.empId = null;
        deviceMaterialRejectController!.checkRecordModel.emploee = null;
        if (deviceMaterialRejectController!.isPsnHasAdapter){
          await deviceMaterialRejectController!.getPersonAdapter(
              sourceLineCode: deviceMaterialRejectController!.taskModel.lineCode
          );
        }
        else {
          deviceMaterialRejectController!.personList.clear();
        }
      }
      deviceMaterialRejectController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///不良品上报-产品类别打印模板设置
  Future<void> mRInvClassTemplateSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    String invClassFrxNameMapMRStr = json.encode(invClassFrxNameMapMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_MATERIAL_REJECT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY, invClassFrxNameMapMRStr);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (deviceMaterialRejectController != null){
      deviceMaterialRejectController!.invClassFrxNameMapMR.clear();
      deviceMaterialRejectController!.invClassFrxNameMapMR.addAll(invClassFrxNameMapMR);
      deviceMaterialRejectController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///次品列表设置 保存
  Future<void> checkRecordListSave() async {
    if (isLoading) {
      ToastNotification(Get.overlayContext!).warn('正在执行！');
      return;
    }
    isLoading = true;
    if (noPermission){
      ToastNotification(Get.overlayContext!).warn('没有操作的权限${BaseService.profile.isSystem == true ? permissionInfo : ''}！');
      isLoading = false;
      return;
    }
    //region 提交前校验
    int? limitTimeCRTCInt = int.tryParse(limitTimeCRTC.text);
    if (limitTimeCRTC.text.isNotEmpty
        && (limitTimeCRTCInt == null || limitTimeCRTCInt < 0)){
      ToastNotification(Get.overlayContext!).warn('“次品记录可删除的时间限制”输入错误，请检查！');
      isLoading = false;
      return;
    }
    //endregion
    var dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认保存？',
      barrierDismissible: false,
    );
    if (dialogRes == null || !dialogRes){
      isLoading = false;
      return;
    }
    ProgressDialogUtil.showProgressDialog(max: 2, msg: '正在保存', completedMsg: '数据刷新成功！');

    //region 数据保存
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_LIST_PAGE_CONFIG_ROWS_KEY, pageConfigRowsCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_LIST_DELETE_LIMIT_TIME_KEY, int.tryParse(limitTimeCRTC.text));
    List<Map<String, dynamic>> mapList = [];
    checkRecordListInfoFormListMap.forEach((key, value) {
      mapList.addAll(value.map((e) => e.toJson()));
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.PMES_DEVICE_TASK_CHECK_RECORD_LIST_INFO_FORM_LIST_KEY, mapList);

    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (pMesCheckRecordListController != null){
      if (pMesCheckRecordListController!.dataListPageConfig.rows != pageConfigRowsCR){
        pMesCheckRecordListController!.dataListPageConfig.rows = pageConfigRowsCR;
        await pMesCheckRecordListController!.pageChanged(showLoading: false);
      }
      pMesCheckRecordListController!.limitTime = int.tryParse(limitTimeCRTC.text);
      pMesCheckRecordListController!.checkRecordListInfoFormListMap.clear();
      pMesCheckRecordListController!.checkRecordListInfoFormListMap.addAll(checkRecordListInfoFormListMap);
      pMesCheckRecordListController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  //endregion


  @override
  void onClose() {
    limitTimeSubmitTC.dispose();
    frxNameSubmitTC.dispose();
    numMaxCountLimitTC.dispose();
    singleBoxQtyMaxCountLimitTC.dispose();
    psnDepCodeSubmitTC.dispose();
    psnLineCodeSubmitTC.dispose();
    limitTimeSubmitFN.dispose();
    frxNameSubmitFN.dispose();
    numMaxCountLimitFN.dispose();
    singleBoxQtyMaxCountLimitFN.dispose();
    psnDepCodeSubmitFN.dispose();
    psnLineCodeSubmitFN.dispose();

    psnDepCodeCRTC.dispose();
    psnLineCodeCRTC.dispose();
    frxNameCRTC.dispose();
    limitTimeCRTC.dispose();
    psnDepCodeCRFN.dispose();
    psnLineCodeCRFN.dispose();
    frxNameCRFN.dispose();
    limitTimeCRFN.dispose();

    psnDepCodeMRTC.dispose();
    psnLineCodeMRTC.dispose();
    frxNameMRTC.dispose();
    psnDepCodeMRFN.dispose();
    psnLineCodeMRFN.dispose();
    frxNameMRFN.dispose();

    formRowMaxCountLimitSubmitTC.dispose();
    formRowMaxCountLimitSubmitFN.dispose();
    formRowMaxCountLimitCRTC.dispose();
    formRowMaxCountLimitCRFN.dispose();
    formRowMaxCountLimitMRTC.dispose();
    formRowMaxCountLimitMRFN.dispose();

    submitFormScrollController.dispose();
    cRFormScrollController.dispose();
    mRFormScrollController.dispose();
    submitListScrollController.dispose();
    checkRecordListScrollController.dispose();
    super.onClose();
  }

}