import 'dart:convert';

import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/service.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/ui/pages/home/base/base_setting/base_setting_controller.dart';
import 'package:desktop/app/ui/pages/home/base/interface/form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/info_form_interface.dart';
import 'package:desktop/app/ui/pages/home/base/interface/interface_util.dart';
import 'package:desktop/app/ui/pages/home/base/interface/inv_class_frx_name_interface/inv_class_frx_name_interface.dart';
import 'package:desktop/app/ui/pages/home/mes/check_record_list/mes_check_record_list_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/check_record/mes_order_check_record_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/detail_tab/mes_order_detail_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/material_reject/mes_order_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/submit/mes_order_submit_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/submit_list/mes_submit_list_controller.dart';
import 'package:desktop/app/ui/widget/fluent_ui/tree_view/tree_view.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/progress_dialog_util.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产任务单 详情页 设置页面
class MesOrderDetailSettingController
    extends BaseSettingController
    with InfoFormInterface,
        InvClassFrxNameInterface,
        FormInterface,
        InterfaceUtil {

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  final MesOrderDetailTabController orderDetailTabController = Get.find<MesOrderDetailTabController>();
  MesOrderSubmitController? orderSubmitController;
  MesSubmitListController? submitListController;
  MesOrderCheckRecordController? orderCheckRecordController;
  MesOrderMaterialRejectController? orderMaterialRejectController;
  MesCheckRecordListController? checkRecordListController;

  @override
  final String title = '生产任务单详情设置';

  ///submit checkRecord submitList checkRecordList
  final String type;

  ///0：生产任务单； 1：设备任务单； 2：加工中心任务单
  final int orderOpenType;

  @override
  late final List<ChoiceChipModel> tabValueList = [
    if (type == 'tab')
      ChoiceChipModel(icon: Icons.view_array_rounded, title: '默认选项卡', keyName: 'tab'),
    if (type == 'tab' || type == 'submit')
      ...[
        ChoiceChipModel(
          icon: Icons.assignment, title: '生产报工', keyName: 'submit',
          children: [
            ChoiceChipModel(title: '任务信息显示设置', keyName: 'submitInfoForm'),
            ChoiceChipModel(title: '按钮显示设置', keyName: 'submitBtn'),
            ChoiceChipModel(title: '表单填写项显示设置', keyName: 'submitForm'),
            ChoiceChipModel(title: '表单填写设置', keyName: 'submitFormSetting'),
            ChoiceChipModel(title: '设备选单-车间过滤', keyName: 'submitFormDeviceDepFilter'),
            ChoiceChipModel(title: '设备选单-设备类别过滤', keyName: 'submitFormDeviceClassFilter'),
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
            ChoiceChipModel(title: '任务信息显示设置', keyName: 'checkRecordInfoForm'),
            ChoiceChipModel(title: '按钮显示设置', keyName: 'checkRecordBtn'),
            ChoiceChipModel(title: '表单填写项显示设置', keyName: 'checkRecordForm'),
            ChoiceChipModel(title: '表单填写设置', keyName: 'checkRecordFormSetting'),
            ChoiceChipModel(title: '设备选单-车间过滤', keyName: 'checkRecordFormDeviceDepFilter'),
            ChoiceChipModel(title: '设备选单-设备类别过滤', keyName: 'checkRecordFormDeviceClassFilter'),
            //ChoiceChipModel(title: '产品类别打印模板设置', keyName: 'checkRecordInvClassTemplate')
          ]
        ),
      ],
    if (type == 'tab' || type == 'materialReject')
      ...[
        ChoiceChipModel(
            icon: Icons.assignment_late, title: '材料不良', keyName: 'materialReject',
            children: [
              ChoiceChipModel(title: '任务信息显示设置', keyName: 'materialRejectInfoForm'),
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

  //region 默认选项卡设置
  ///默认选项卡索引
  late int initialTabIndex = (orderOpenType == 0
      ? ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_DETAIL_INITIAL_INDEX_KEY)
      : orderOpenType == 1
      ? ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_DETAIL_INITIAL_INDEX_KEY)
      : orderOpenType == 2
      ? ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_ORDER_DETAIL_INITIAL_INDEX_KEY)
      : null)
      ?? AppConfig.initialIndex;
  ///选项卡列表
  late final List<ChoiceChipModel> detailTabList = orderDetailTabController.tabValueList.map(
          (e) => ChoiceChipModel(title: e)).toList();
  //endregion

  //region 生产报工-任务信息显示设置
  final List<InfoFormModel> orderInfoFormListSubmit = [];
  //endregion

  //region 生产报工-按钮显示设置
  ///是否显示报工方式切换按钮
  bool isShowDataReportTypeBtnSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
  ///报工方式
  String submitType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_TYPE_KEY) ?? AppConfig.qtySubmit;
  ///是否显示“补打”按钮（当报工日期受班次影响时，始终不显示该按钮）
  bool isShowMakeUpBtnSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
  ///是否显示“自检确认”按钮
  bool isShowSelfInspectionBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_SELF_INSPECTION_BTN_KEY) ?? AppConfig.isShowSelfInspectionBtn;
  ///是否显示“互检确认”按钮
  bool isShowMutualInspectionBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_MUTUAL_INSPECTION_BTN_KEY) ?? AppConfig.isShowMutualInspectionBtn;
  ///是否显示“需要检验”按钮
  bool isShowInspectFlagBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_INSPECT_FLAG_BTN_KEY) ?? AppConfig.isShowInspectFlagBtn;
  ///是否可以点击修改“需要检验”按钮的值
  bool isCanClickInspectFlagBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_CAN_CLICK_INSPECT_FLAG_BTN_KEY) ?? AppConfig.isCanClickInspectFlagBtn;
  ///“需要检验”按钮的选中状态的默认值
  bool? inspectFlagDefaultValue = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_INSPECT_FLAG_DEFAULT_VALUE_KEY) ?? AppConfig.inspectFlagDefaultValue;
  ///当报工方式是“按序列号报工”时，是否显示“自动提交”按钮
  bool isShowAutoCommitBtn = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_AUTO_COMMIT_BTN_KEY) ?? AppConfig.isShowAutoCommitBtn;
  ///当报工方式是“按序列号报工”时，扫描序列号并写入数据后，是否自动提交报工数据（按序列号报工时使用）
  bool autoCommitSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_AUTO_COMMIT_FOR_SERIAL_NUMBER_SUBMIT_TYPE_KEY) ?? AppConfig.autoCommitSubmit;
  ///是否显示报工汇总（工序班组日期）
  bool isShowOpTgSubmitQty = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_OP_TG_SUBMIT_QTY_KEY) ?? AppConfig.isShowOpTgSubmitQty;
  ///是否显示工序说明行
  bool isShowOpDescriptionSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_OP_DESCRIPTION_KEY) ?? AppConfig.isShowOpDescription;
  ///页面上显示报工提交按钮（可显示多个，index 相加）
  ///
  /// 1：报工提交
  ///
  /// 2：提交并打印
  int submitBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_BTN_INDEX_KEY) ?? AppConfig.submitBtnIndex;
  ///是否显示总重称重数据的 overlay
  bool isShowWeightOverlay = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_WEIGHT_OVERLAY_KEY) ?? AppConfig.isShowWeightOverlay;
  //endregion

  //region 生产报工-表单填写项显示设置
  ///表单数据填写项的标题名称
  final Map<String, String> formTitleMapSubmit = {};
  ///表单数据填写项的样式
  final Map<String, Map<String, dynamic>> formStyleMapSubmit = {};
  ///自动获取焦点的输入框字段名
  String numPadFocusFieldSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;

  //endregion

  //region 生产报工-表单填写设置
  ///车间默认值获取方式 0: 单据车间 1: 登录账号所在车间
  int depGetWayIndexSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
  ///产线数据的填报类型：0产线 OR 1加工中心 OR 2生产班组
  ///
  /// （选2班组，不需要选员工； 选0产线，不需要选择设备）
  int wcDataReportTypeSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_WC_DATA_REPORT_TYPE_KEY) ?? AppConfig.wcDataReportType;
  ///设备是否可以通过 Adapter 选单
  bool isDeviceHasAdapterSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_DEVICE_HAS_ADAPTER_KEY) ?? AppConfig.isDeviceHasAdapter;
  ///人员是否可以通过 Adapter 选单
  bool isPsnHasAdapterSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
  ///生产人员是否可以多选
  bool isPsnMultiSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
  ///生产人员获取条件的Index 0: 全部 1: 选中的车间 2: 固定车间
  int psnGetWayIndexSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
  ///生产人员获取条件是固定车间时，固定车间的值
  final String psnDepCodeSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
  late final TextEditingController psnDepCodeSubmitTC = TextEditingController(text: psnDepCodeSubmit);
  final FocusNode psnDepCodeSubmitFN = FocusNode();
  ///生产人员获取条件是固定产线时，固定产线的值
  final String psnLineCodeSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
  late final TextEditingController psnLineCodeSubmitTC = TextEditingController(text: psnLineCodeSubmit);
  final FocusNode psnLineCodeSubmitFN = FocusNode();
  ///是否保存上次报工时选中的员工
  bool isSaveTheLastSelectedPsnIdSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;
  ///整箱箱数可以填写的上限
  final int? numMaxCountLimit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_NUM_MAX_COUNT_LIMIT_KEY) ?? AppConfig.numMaxCountLimit;
  late final TextEditingController numMaxCountLimitTC = TextEditingController(text: numMaxCountLimit?.toString() ?? '');
  final FocusNode numMaxCountLimitFN = FocusNode();
  ///当报工方式是“按托报工”时，报工数据的计算方式
  ///
  ///0：填写“单箱数量”时，计算“单托箱数”、“尾箱数量”
  ///
  ///1：填写“单箱数量”时，计算“报工总数量”
  int calcRuleForPalletSubmitType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_CALC_RULE_FOR_PALLET_SUBMIT_TYPE_KEY) ?? AppConfig.calcRuleForPalletSubmitType;
  ///是否保存上次报工时填写的皮重、单箱数量数据（或选择的装箱容器数据）
  bool isSaveTheLastPackingWeightData = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY) ?? AppConfig.isSaveTheLastPackingWeightData;
  ///是否通过选择装箱容器，自动填充皮重、单箱数量
  bool isUsePackingPicker = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_USE_PACKING_PICKER_KEY) ?? AppConfig.isUsePackingPicker;
  ///“单箱数量”是否只能通过选择装箱容器来赋值，而不是手动输入
  late bool isSingleBoxQtyOnlyChangedByContainer = !isUsePackingPicker
      ? false
      : (ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY) ?? AppConfig.isSingleBoxQtyOnlyChangedByContainer);
  ///报工条码打印模板文件名称
  final String frxNameSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesOrderSubmitPrintFileName;
  late final TextEditingController frxNameSubmitTC = TextEditingController(text: frxNameSubmit);
  final FocusNode frxNameSubmitFN = FocusNode();
  ///报工记录提交成功后，是否返回到首页
  bool isGetBackAfterCommitSuccessSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
  //endregion

  //region 生产报工-设备选单-车间过滤
  ///设备的筛选条件 设备的车间列表
  final List<DepartmentModel> deviceDepIdListSubmit = [];
  //endregion

  //region 生产报工-设备选单-设备类别过滤
  ///设备的筛选条件 设备的类别列表
  final List<TreeViewItem> deviceClassTreeViewItemListSubmit = [];
  final List<String> deviceClassIdListSubmit = [];
  //endregion

  //region 报工条码模板名称列表
  ///根据产品类别编码区分的打印模板名称列表
  final Map<String, String> invClassFrxNameMapSubmit = {};
  //endregion

  //region 报工单列表设置
  final ScrollController submitListScrollController = ScrollController();
  ///报工列表的单页显示记录数
  int pageConfigRowsSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
  ///报工单删除时间限制
  final int? limitTimeSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
  late final TextEditingController limitTimeSubmitTC = TextEditingController(text: limitTimeSubmit?.toString() ?? '');
  final FocusNode limitTimeSubmitFN = FocusNode();
  ///报工单信息显示设置
  final Map<int, List<InfoFormModel>> submitListInfoFormListMap = {};
  //endregion

  //region 次品录入-任务信息显示设置
  final List<InfoFormModel> orderInfoFormListCR = [];
  //endregion

  //region 次品录入-按钮显示设置
  ///是否显示报次品方式切换按钮
  bool isShowDataReportTypeBtnCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
  ///报次品方式
  String checkRecordType = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_TYPE_KEY) ?? AppConfig.qtyCheckRecord;
  ///是否显示“补打”按钮（当生产日期受班次影响时，始终不显示该按钮）
  bool isShowMakeUpBtnCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
  ///是否显示工序说明行
  bool isShowOpDescriptionCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_SHOW_OP_DESCRIPTION_KEY) ?? AppConfig.isShowOpDescription;
  ///页面上显示次品提交按钮（可显示多个，index 相加）
  ///
  ///1：次品提交
  ///
  ///2：提交并打印
  late int checkRecordBtnIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_BTN_INDEX_KEY) ?? AppConfig.checkRecordBtnIndex;
  //endregion

  //region 次品录入-表单填写项显示设置
  ///表单数据填写项的标题名称
  final Map<String, String> formTitleMapCR = {};
  ///表单数据填写项的样式
  final Map<String, Map<String, dynamic>> formStyleMapCR = {};
  ///自动获取焦点的输入框字段名
  String numPadFocusFieldCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
  //endregion

  //region 次品录入-表单填写设置
  ///车间默认值获取方式 0: 单据车间  1: 登录账号所在车间
  int depGetWayIndexCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
  ///产线数据的填报类型：0产线 OR 1加工中心 OR 2生产班组
  ///
  ///（选2班组，不需要选员工； 选0产线，不需要选择设备）
  int wcDataReportTypeCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_WC_DATA_REPORT_TYPE_KEY) ?? AppConfig.wcDataReportType;
  ///设备是否可以通过 Adapter 选单
  bool isDeviceHasAdapterCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_DEVICE_HAS_ADAPTER_KEY) ?? AppConfig.isDeviceHasAdapter;
  ///人员是否可以通过 Adapter 选单
  bool isPsnHasAdapterCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
  ///生产人员是否可以多选
  bool isPsnMultiCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
  ///生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间
  int psnGetWayIndexCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
  ///生产人员获取条件是固定车间时，固定车间的值
  final String psnDepCodeCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
  late final TextEditingController psnDepCodeCRTC = TextEditingController(text: psnDepCodeCR);
  final FocusNode psnDepCodeCRFN = FocusNode();
  ///生产人员获取条件是固定产线时，固定产线的值
  final String psnLineCodeCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
  late final TextEditingController psnLineCodeCRTC = TextEditingController(text: psnLineCodeCR);
  final FocusNode psnLineCodeCRFN = FocusNode();
  ///是否保存上次报工时选中的员工
  bool isSaveTheLastSelectedPsnIdCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;
  ///次品条码打印模板文件名称
  final String frxNameCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesOrderCheckRecordPrintFileName;
  late final TextEditingController frxNameCRTC = TextEditingController(text: frxNameCR);
  final FocusNode frxNameCRFN = FocusNode();
  ///次品记录提交成功后，是否返回到首页
  bool isGetBackAfterCommitSuccessCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
  //endregion

  //region 次品录入-设备车间过滤
  ///设备的筛选条件 设备的车间列表
  final List<DepartmentModel> deviceDepIdListCR = [];
  //endregion

  //region 次品录入-设备类别过滤
  ///设备的筛选条件 设备的类别列表
  final List<TreeViewItem> deviceClassTreeViewItemListCR = [];
  final List<String> deviceClassIdListCR = [];
  //endregion

  //region 次品条码模板名称列表
  ///根据产品类别编码区分的打印模板名称列表
  final Map<String, String> invClassFrxNameMapCR = {};
  //endregion

  //region 不良品上报-任务信息显示设置
  final List<InfoFormModel> orderInfoFormListMR = [];
  //endregion

  //region 不良品上报-按钮显示设置
  ///是否显示报次品方式切换按钮
  bool isShowDataReportTypeBtnMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_SHOW_TYPE_BTN_KEY) ?? AppConfig.isShowDataReportTypeBtn;
  ///报次品方式
  String checkRecordTypeMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_TYPE_KEY) ?? AppConfig.qtyMaterialReject;
  ///是否显示“补打”按钮（当生产日期受班次影响时，始终不显示该按钮）
  bool isShowMakeUpBtnMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_SHOW_MAKE_UP_BTN_KEY) ?? AppConfig.isShowMakeUpBtn;
  ///页面上显示次品提交按钮（可显示多个，index 相加）
  ///
  ///1：次品提交
  ///
  ///2：提交并打印
  late int checkRecordBtnIndexMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_BTN_INDEX_KEY) ?? AppConfig.materialRejectBtnIndex;
  //endregion

  //region 不良品上报-表单填写项显示设置
  ///表单数据填写项的标题名称
  final Map<String, String> formTitleMapMR = {};
  ///表单数据填写项的样式
  final Map<String, Map<String, dynamic>> formStyleMapMR = {};
  ///自动获取焦点的输入框字段名
  String numPadFocusFieldMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_NUM_PAD_FOCUS_FIELD_KEY) ?? AppConfig.numPadFocusField;
  //endregion

  //region 不良品上报-表单填写设置
  ///车间默认值获取方式 0: 单据车间  1: 登录账号所在车间
  int depGetWayIndexMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_DEP_GET_WAY_INDEX_KEY) ?? AppConfig.depGetWayIndex;
  ///人员是否可以通过 Adapter 选单
  bool isPsnHasAdapterMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_PSN_HAS_ADAPTER_KEY) ?? AppConfig.isPsnHasAdapter;
  ///生产人员是否可以多选
  bool isPsnMultiMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_PSN_MULTI_KEY) ?? AppConfig.isPsnMulti;
  ///生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间
  int psnGetWayIndexMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_PSN_GET_WAY_INDEX_KEY) ?? AppConfig.psnGetWayIndex;
  ///生产人员获取条件是固定车间时，固定车间的值
  final String psnDepCodeMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_PSN_GET_WAY_DEP_CODE_KEY) ?? AppConfig.psnDepCode;
  late final TextEditingController psnDepCodeMRTC = TextEditingController(text: psnDepCodeMR);
  final FocusNode psnDepCodeMRFN = FocusNode();
  ///生产人员获取条件是固定产线时，固定产线的值
  final String psnLineCodeMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_PSN_GET_WAY_LINE_CODE_KEY) ?? AppConfig.psnLineCode;
  late final TextEditingController psnLineCodeMRTC = TextEditingController(text: psnLineCodeMR);
  final FocusNode psnLineCodeMRFN = FocusNode();
  ///是否保存上次报工时选中的员工
  bool isSaveTheLastSelectedPsnIdMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY) ?? AppConfig.isSaveTheLastSelectedPsnId;
  ///次品条码打印模板文件名称
  final String frxNameMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_TEMPLATE_FILENAME_KEY) ?? AppConfig.mesOrderMaterialRejectPrintFileName;
  late final TextEditingController frxNameMRTC = TextEditingController(text: frxNameMR);
  final FocusNode frxNameMRFN = FocusNode();
  ///次品记录提交成功后，是否返回到首页
  bool isGetBackAfterCommitSuccessMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY) ?? AppConfig.isGetBackAfterCommitSuccess;
  //endregion

  //region 不良品上报条码模板名称列表
  ///根据产品类别编码区分的打印模板名称列表
  final Map<String, String> invClassFrxNameMapMR = {};
  //endregion

  //region 次品列表设置
  final ScrollController checkRecordListScrollController = ScrollController();
  ///次品记录列表的单页显示记录数
  int pageConfigRowsCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_PAGE_CONFIG_ROWS_KEY) ?? AppConfig.pageConfigRows;
  ///次品单删除时间限制
  final int? limitTimeCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_DELETE_LIMIT_TIME_KEY) ?? AppConfig.limitTime;
  late final TextEditingController limitTimeCRTC = TextEditingController(text: limitTimeCR?.toString() ?? '');
  final FocusNode limitTimeCRFN = FocusNode();
  ///次品单信息显示设置
  final Map<int, List<InfoFormModel>> checkRecordListInfoFormListMap = {};
  //endregion


  MesOrderDetailSettingController({
    super.progId = -1,
    required this.type,
    required this.orderOpenType,
    this.noPermission = false,
    this.permissionInfo = '',
  });


  @override
  void onInit() {
    super.onInit();

    //region TabView Get.find
    try{
      orderSubmitController = Get.find<MesOrderSubmitController>();
    } catch (e){}
    try{
      submitListController = Get.find<MesSubmitListController>();
    } catch (e){}
    try{
      orderCheckRecordController = Get.find<MesOrderCheckRecordController>();
    } catch (e){}
    try{
      checkRecordListController = Get.find<MesCheckRecordListController>();
    } catch (e){}
    try {
      orderMaterialRejectController = Get.find<MesOrderMaterialRejectController>();
    } catch (e){}
    //endregion

    //region 生产报工-任务信息显示设置
    List<dynamic> orderInfoFormMapListSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_INFO_FORM_LIST_KEY) ?? [];
    orderInfoFormListSubmit.clear();
    orderInfoFormListSubmit.addAll(
        getInfoFormListByStorage(
            orderInfoFormMapListSubmit,
            AppConfig.mesOrderInfoFormList
        )
    );
    //endregion

    //region 生产报工-表单填写项显示设置
    String formTitleMapStrSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_FORM_TITLE_MAP_KEY) ?? '';
    formTitleMapSubmit.addAll(getFormTitleMapByStorage(formTitleMapStrSubmit, AppConfig.mesOrderSubmitFormTitleMap));
    String formStyleMapStrSubmit = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_FORM_STYLE_MAP_KEY) ?? '';
    formStyleMapSubmit.addAll(getFormStyleMapByStorage(formStyleMapStrSubmit, AppConfig.mesOrderSubmitFormStyleMap));
    //endregion

    //region 报工条码模板名称列表
    String invClassFrxNameMapSubmitStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMapSubmit.clear();
    invClassFrxNameMapSubmit.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapSubmitStr));
    //endregion

    //region 报工列表-报工单信息显示设置
    List<dynamic> submitListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_INFO_FORM_LIST_KEY) ?? [];
    submitListInfoFormListMap.clear();
    submitListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                submitListInfoFormMapList,
                AppConfig.mesSubmitListInfoFormList
            )
        )
    );
    //endregion

    //region 次品录入-任务信息显示设置
    List<dynamic> orderInfoFormMapListCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_INFO_FORM_LIST_KEY) ?? [];
    orderInfoFormListCR.clear();
    orderInfoFormListCR.addAll(
        getInfoFormListByStorage(
            orderInfoFormMapListCR,
            AppConfig.mesOrderInfoFormList
        )
    );
    //endregion

    //region 次品录入-表单填写项显示设置
    String formTitleMapStrCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_FORM_TITLE_MAP_KEY) ?? '';
    formTitleMapCR.addAll(getFormTitleMapByStorage(formTitleMapStrCR, AppConfig.mesOrderCheckRecordFormTitleMap));
    String formStyleMapStrCR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_FORM_STYLE_MAP_KEY) ?? '';
    formStyleMapCR.addAll(getFormStyleMapByStorage(formStyleMapStrCR, AppConfig.mesOrderCheckRecordFormStyleMap));
    //endregion

    //region 次品条码模板名称列表
    String invClassFrxNameMapCRStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMapCR.clear();
    invClassFrxNameMapCR.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapCRStr));
    //endregion

    //region 不良品上报-任务信息显示设置
    List<dynamic> orderInfoFormMapListMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_INFO_FORM_LIST_KEY) ?? [];
    orderInfoFormListMR.clear();
    orderInfoFormListMR.addAll(
        getInfoFormListByStorage(
            orderInfoFormMapListMR,
            AppConfig.mesOrderInfoFormList
        )
    );
    //endregion

    //region 不良品上报-表单填写项显示设置
    String formTitleMapStrMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_FORM_TITLE_MAP_KEY) ?? '';
    formTitleMapMR.addAll(getFormTitleMapByStorage(formTitleMapStrMR, AppConfig.mesOrderMaterialRejectFormTitleMap));
    String formStyleMapStrMR = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_FORM_STYLE_MAP_KEY) ?? '';
    formStyleMapMR.addAll(getFormStyleMapByStorage(formStyleMapStrMR, AppConfig.mesOrderMaterialRejectFormStyleMap));
    //endregion

    //region 不良品条码模板名称列表
    String invClassFrxNameMapMRStr = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY) ?? '';
    invClassFrxNameMapMR.clear();
    invClassFrxNameMapMR.addAll(getInvClassFrxNameMapByStorage(invClassFrxNameMapMRStr));
    //endregion

    //region 次品列表-次品单信息显示设置
    List<dynamic> checkRecordListInfoFormMapList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_INFO_FORM_LIST_KEY) ?? [];
    checkRecordListInfoFormListMap.clear();
    checkRecordListInfoFormListMap.addAll(
        getInfoFormListMap(
            getInfoFormListByStorage(
                checkRecordListInfoFormMapList,
                AppConfig.mesCheckRecordListInfoFormList
            )
        )
    );
    //endregion
  }

  @override
  Future<bool> initializeForm() async {
    await getDeviceDepList();
    await getDeviceClassList();
    update();

    return true;
  }

  Future<bool> getDeviceDepList() async{
    if (type != 'tab' && type != 'submit' && type != 'checkRecord'){ return true; }

    var res = await DepartmentRepository().getList(4);
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('读取车间列表时出错：${res.message}');
      return false;
    }

    if (type == 'tab' || type == 'submit'){
      List<dynamic> deviceDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_DEVICE_DEP_ID_LIST_KEY) ?? [];
      deviceDepIdListSubmit.clear();
      deviceDepIdListSubmit.addAll(res.data.map((e) {
        DepartmentModel item = DepartmentModel.fromJson(e.toJson());
        if (deviceDepIdList.contains(item.departmentId)){
          item.isChoice = true;
        }
        else {
          item.isChoice = false;
        }
        return item;
      }));
    }

    if (type == 'tab' || type == 'checkRecord'){
      List<dynamic> deviceDepIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_DEVICE_DEP_ID_LIST_KEY) ?? [];
      deviceDepIdListCR.clear();
      deviceDepIdListCR.addAll(res.data.map((e) {
        DepartmentModel item = DepartmentModel.fromJson(e.toJson());
        if (deviceDepIdList.contains(item.departmentId)){
          item.isChoice = true;
        }
        else {
          item.isChoice = false;
        }
        return item;
      }));
    }

    return true;
  }

  Future<bool> getDeviceClassList() async{
    if (type != 'tab' && type != 'submit' && type != 'checkRecord'){ return true; }

    var res = await EAMClassRepository().getTree();
    if (!res.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取设备类别列表时出错：${res.message}');
      return false;
    }

    if (type == 'tab' || type == 'submit'){
      List<dynamic> deviceClassIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_SUBMIT_DEVICE_CLASS_ID_LIST_KEY) ?? [];
      deviceClassIdListSubmit.clear();
      deviceClassIdListSubmit.addAll(deviceClassIdList.map((e) => e.toString()).toList());
      deviceClassTreeViewItemListSubmit.clear();
      deviceClassTreeViewItemListSubmit.addAll(res.data.map((e) {
        TreeViewItem item = TreeViewItem.TreeModelToTreeViewItem(
          Get.context!, item: TreeModel.fromJson(e.toJson()),
          selectedItemIdList: deviceClassIdListSubmit
        );
        return item;
      }));
    }

    if (type == 'tab' || type == 'checkRecord'){
      List<dynamic> deviceClassIdList = ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_DEVICE_CLASS_ID_LIST_KEY) ?? [];
      deviceClassIdListCR.clear();
      deviceClassIdListCR.addAll(deviceClassIdList.map((e) => e.toString()).toList());
      deviceClassTreeViewItemListCR.clear();
      deviceClassTreeViewItemListCR.addAll(res.data.map((e) {
        TreeViewItem item = TreeViewItem.TreeModelToTreeViewItem(
          Get.context!, item: TreeModel.fromJson(e.toJson()),
          selectedItemIdList: deviceClassIdListCR
        );
        return item;
      }));
    }

    return true;
  }


  //region OnChanged

  //region 默认选项卡

  ///默认选项卡Item选择变化
  void initialIndexOnChanged(int index) {
    initialTabIndex = index;
    update();
  }

  //endregion

  //region 生产报工-按钮显示设置

  void isShowDataReportTypeBtnSubmitOnChanged() {
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

  void isShowSelfInspectionBtnOnChanged() {
    isShowSelfInspectionBtn = !isShowSelfInspectionBtn;
    update();
  }

  void isShowMutualInspectionBtnOnChanged() {
    isShowMutualInspectionBtn = !isShowMutualInspectionBtn;
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

  void isShowAutoCommitBtnOnChanged() {
    isShowAutoCommitBtn = !isShowAutoCommitBtn;
    update();
  }

  void autoCommitSubmitOnChanged() {
    autoCommitSubmit = !autoCommitSubmit;
    update();
  }

  void isShowOpTgSubmitQtyOnChanged() {
    isShowOpTgSubmitQty = !isShowOpTgSubmitQty;
    update();
  }

  void isShowOpDescriptionSubmitOnChanged() {
    isShowOpDescriptionSubmit = !isShowOpDescriptionSubmit;
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

  void isShowWeightOverlayOnChanged() {
    isShowWeightOverlay = !isShowWeightOverlay;
    update();
  }

  //endregion

  //region 生产报工-表单填写设置

  void depGetWayIndexSubmitOnChanged(int index) {
    depGetWayIndexSubmit = index;
    update();
  }

  void wcDataReportTypeSubmitOnChanged(int index) {
    wcDataReportTypeSubmit = index;
    update();
  }

  void isDeviceHasAdapterSubmitOnChanged() {
    isDeviceHasAdapterSubmit = !isDeviceHasAdapterSubmit;
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

  void isGetBackAfterCommitSuccessSubmitOnChanged(){
    isGetBackAfterCommitSuccessSubmit = !isGetBackAfterCommitSuccessSubmit;
    update();
  }

  //endregion

  //region 生产报工-设备选单-车间过滤

  void deviceDepSubmitOnChanged(DepartmentModel item){
    item.isChoice = !item.isChoice;
    update();
  }

  ///车间筛选 选中的车间 选择变化（全选、全不选、反选）
  void deviceDepSubmitAllOnChanged({required bool? allChoice}) {
    deviceDepIdListSubmit.forEach((element) {
      element.isChoice = allChoice ?? !element.isChoice;
    });
    update();
  }

  //endregion

  //region 生产报工-设备选单-设备类别过滤

  void deviceClassSubmitOnChanged(List<TreeViewItem> list) {
    if (list.length == 1){
      deviceClassIdListSubmit.clear();
      if (list[0].selected != null && list[0].selected!){
        deviceClassIdListSubmit.add((list[0].value as TreeModel).id);
      }
      update();
    }
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

  void isShowOpDescriptionCROnChanged(){
    isShowOpDescriptionCR = !isShowOpDescriptionCR;
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

  void isDeviceHasAdapterCROnChanged() {
    isDeviceHasAdapterCR = !isDeviceHasAdapterCR;
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

  //region 次品录入-设备车间过滤

  void deviceDepCROnChanged(DepartmentModel item){
    item.isChoice = !item.isChoice;
    update();
  }

  ///车间筛选 选中的车间 选择变化（全选、全不选、反选）
  void deviceDepCRAllOnChanged({required bool? allChoice}) {
    deviceDepIdListCR.forEach((element) {
      element.isChoice = allChoice ?? !element.isChoice;
    });
    update();
  }

  //endregion

  //region 次品录入-设备类别过滤

  void deviceClassCROnChanged(List<TreeViewItem> list) {
    if (list.length == 1){
      deviceClassIdListCR.clear();
      if (list[0].selected != null && list[0].selected!){
        deviceClassIdListCR.add((list[0].value as TreeModel).id);
      }
      update();
    }
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

  ///默认选项卡 保存
  Future<void> initialIndexSave() async{
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
    ProgressDialogUtil.showProgressDialog(max: 1, msg: '正在保存', completedMsg: '数据保存成功！');

    //region 数据保存
    String? detailInitialIndexKey = orderOpenType == 0
        ? SharedPreferencesKeys.MES_ORDER_DETAIL_INITIAL_INDEX_KEY
        : orderOpenType == 1
        ? SharedPreferencesKeys.MES_DEVICE_ORDER_DETAIL_INITIAL_INDEX_KEY
        : orderOpenType == 2
        ? SharedPreferencesKeys.MES_WORK_CENTER_ORDER_DETAIL_INITIAL_INDEX_KEY
        : null;
    if (detailInitialIndexKey != null){
      ShareStorageUtil.instance?.write(detailInitialIndexKey, initialTabIndex);
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 1);
  }

  ///生产报工-任务信息显示设置 保存
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
    mapList.addAll(orderInfoFormListSubmit.map((e) => e.toJson()));
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderSubmitController != null){
      orderSubmitController!.orderInfoFormList.clear();
      orderSubmitController!.orderInfoFormList.addAll(orderInfoFormListSubmit);
      orderSubmitController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///生产报工-按钮显示设置 保存
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_TYPE_BTN_KEY, isShowDataReportTypeBtnSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_TYPE_KEY, submitType);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_MAKE_UP_BTN_KEY, isShowMakeUpBtnSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_SELF_INSPECTION_BTN_KEY, isShowSelfInspectionBtn);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_MUTUAL_INSPECTION_BTN_KEY, isShowMutualInspectionBtn);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_INSPECT_FLAG_BTN_KEY, isShowInspectFlagBtn);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_CAN_CLICK_INSPECT_FLAG_BTN_KEY, isCanClickInspectFlagBtn);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_INSPECT_FLAG_DEFAULT_VALUE_KEY, inspectFlagDefaultValue);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_AUTO_COMMIT_BTN_KEY, isShowAutoCommitBtn);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_AUTO_COMMIT_FOR_SERIAL_NUMBER_SUBMIT_TYPE_KEY, autoCommitSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_OP_TG_SUBMIT_QTY_KEY, isShowOpTgSubmitQty);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_OP_DESCRIPTION_KEY, isShowOpDescriptionSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_BTN_INDEX_KEY, submitBtnIndex);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SHOW_WEIGHT_OVERLAY_KEY, isShowWeightOverlay);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderSubmitController != null){
      orderSubmitController!.isShowDataReportTypeBtn = isShowDataReportTypeBtnSubmit;
      orderSubmitController!.submitType = submitType;
      orderSubmitController!.isShowMakeUpBtn = isShowMakeUpBtnSubmit;
      orderSubmitController!.isShowSelfInspectionBtn = isShowSelfInspectionBtn;
      orderSubmitController!.isShowMutualInspectionBtn = isShowMutualInspectionBtn;
      orderSubmitController!.isShowInspectFlagBtn = isShowInspectFlagBtn;
      orderSubmitController!.isCanClickInspectFlagBtn = isCanClickInspectFlagBtn;
      orderSubmitController!.inspectFlagDefaultValue = inspectFlagDefaultValue;
      orderSubmitController!.isShowAutoCommitBtn = isShowAutoCommitBtn;
      orderSubmitController!.autoCommitSubmit = autoCommitSubmit;
      orderSubmitController!.isShowOpTgSubmitQty = isShowOpTgSubmitQty;
      orderSubmitController!.isShowOpDescription = isShowOpDescriptionSubmit;
      orderSubmitController!.submitBtnIndex = submitBtnIndex;
      orderSubmitController!.isShowWeightOverlay = isShowWeightOverlay;
      orderSubmitController!.numPadCTListSetEnabled();
      if (orderSubmitController!.isShowWeightOverlay
          && orderSubmitController!.weightOverlayEntry == null){
        ShareStorageUtil.instance?.remove(SharedPreferencesKeys.MES_ORDER_SUBMIT_WEIGHT_OVERLAY_DX_KEY);
        ShareStorageUtil.instance?.remove(SharedPreferencesKeys.MES_ORDER_SUBMIT_WEIGHT_OVERLAY_DY_KEY);

        orderSubmitController!.openWeightOverlay();
      }
      else if (!orderSubmitController!.isShowWeightOverlay
          && orderSubmitController!.weightOverlayEntry != null) {
        orderSubmitController!.closeWeightOverlay();
      }
      orderSubmitController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///生产报工-表单填写项显示设置 保存
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_FORM_TITLE_MAP_KEY, str);
    String styleStr = jsonEncode(formStyleMapSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_FORM_STYLE_MAP_KEY, styleStr);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_NUM_PAD_FOCUS_FIELD_KEY, numPadFocusFieldSubmit);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderSubmitController != null){
      orderSubmitController!.formTitleMap.clear();
      orderSubmitController!.formTitleMap.addAll(formTitleMapSubmit);
      orderSubmitController!.numPadCTList.sort((a, b){
        return numPadCTListSortVoidCallback.call(orderSubmitController!.formTitleMap, a, b);
      });
      orderSubmitController!.formStyleMap.clear();
      orderSubmitController!.formStyleMap.addAll(formStyleMapSubmit);
      orderSubmitController!.numPadCTList.forEach((element) {
        element.styleMap.clear();
        if (orderSubmitController!.formStyleMap.containsKey(element.key)){
          element.styleMap.addAll(orderSubmitController!.formStyleMap[element.key]!);
        }
      });
      orderSubmitController!.numPadFocusField = numPadFocusFieldSubmit;
      orderSubmitController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///生产报工-表单填写设置 保存
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_DEP_GET_WAY_INDEX_KEY, depGetWayIndexSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_WC_DATA_REPORT_TYPE_KEY, wcDataReportTypeSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_DEVICE_HAS_ADAPTER_KEY, isDeviceHasAdapterSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_PSN_HAS_ADAPTER_KEY, isPsnHasAdapterSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_PSN_MULTI_KEY, isPsnMultiSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_PSN_GET_WAY_INDEX_KEY, psnGetWayIndexSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY, psnDepCodeSubmitTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY, psnLineCodeSubmitTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY, isSaveTheLastSelectedPsnIdSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_NUM_MAX_COUNT_LIMIT_KEY, numMaxCountLimitTCInt);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_CALC_RULE_FOR_PALLET_SUBMIT_TYPE_KEY, calcRuleForPalletSubmitType);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY, isSaveTheLastPackingWeightData);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_USE_PACKING_PICKER_KEY, isUsePackingPicker);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY, isSingleBoxQtyOnlyChangedByContainer);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_TEMPLATE_FILENAME_KEY, frxNameSubmitTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY, isGetBackAfterCommitSuccessSubmit);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderSubmitController != null){
      bool needResetPerson = false;
      orderSubmitController!.depGetWayIndex = depGetWayIndexSubmit;
      if (orderSubmitController!.wcDataReportType != wcDataReportTypeSubmit) {
        orderSubmitController!.wcDataReportType = wcDataReportTypeSubmit;
        orderSubmitController!.submitModel.wcId = null;
        orderSubmitController!.submitModel.lineCode = null;
        orderSubmitController!.submitModel.lineName = null;
        switch (orderSubmitController!.wcDataReportType){
          //region
          case 0: ///产线
            if (orderSubmitController!.lineAdapter == null){
              await orderSubmitController!.getLineAdapter();
            }
            break;
          case 1: ///加工中心
            if (orderSubmitController!.workCenterAdapter == null){
              await orderSubmitController!.getWorkCenterAdapter();
            }
            break;
          case 2: ///生产班组
            if (orderSubmitController!.teamGroupAdapter == null){
              await orderSubmitController!.getTeamGroupAdapter();
            }
            break;
          //endregion
        }
      }
      if (orderSubmitController!.isDeviceHasAdapter != isDeviceHasAdapterSubmit){
        orderSubmitController!.isDeviceHasAdapter = isDeviceHasAdapterSubmit;
        orderSubmitController!.submitModel.deviceId = null;
        orderSubmitController!.submitModel.deviceCode = null;
        orderSubmitController!.submitModel.deviceName = null;
        if (orderSubmitController!.isDeviceHasAdapter){
          if (orderSubmitController!.deviceAdapter == null){
            await orderSubmitController!.getEAMDeviceAdapter();
          }
        }
        else {
          orderSubmitController!.deviceModel = EAMDeviceModel();
        }
      }
      if (orderSubmitController!.isPsnHasAdapter != isPsnHasAdapterSubmit){
        orderSubmitController!.isPsnHasAdapter = isPsnHasAdapterSubmit;
        needResetPerson = true;
      }
      if (orderSubmitController!.isPsnMulti != isPsnMultiSubmit){
        orderSubmitController!.isPsnMulti = isPsnMultiSubmit;
        needResetPerson = true;
      }
      if (orderSubmitController!.psnGetWayIndex != psnGetWayIndexSubmit){
        orderSubmitController!.psnGetWayIndex = psnGetWayIndexSubmit;
        needResetPerson = true;
      }
      if (orderSubmitController!.psnDepCode != psnDepCodeSubmitTC.text){
        orderSubmitController!.psnDepCode = psnDepCodeSubmitTC.text;
        needResetPerson = true;
      }
      if (orderSubmitController!.psnLineCode != psnLineCodeSubmitTC.text){
        orderSubmitController!.psnLineCode = psnLineCodeSubmitTC.text;
        needResetPerson = true;
      }
      orderSubmitController!.isSaveTheLastSelectedPsnId = isSaveTheLastSelectedPsnIdSubmit;
      orderSubmitController!.numMaxCountLimit = numMaxCountLimitTCInt;
      orderSubmitController!.calcRuleForPalletSubmitType = calcRuleForPalletSubmitType;
      orderSubmitController!.isSaveTheLastPackingWeightData = isSaveTheLastPackingWeightData;
      if (orderSubmitController!.isUsePackingPicker != isUsePackingPicker){
        orderSubmitController!.isUsePackingPicker = isUsePackingPicker;
        if (orderSubmitController!.isUsePackingPicker){
          NumPadUtil().setText(NumPadUtil.packingWeight, '', orderSubmitController!.numPadCTList);
          orderSubmitController!.calcQty(NumPadUtil.packingWeight);
          if (orderSubmitController!.containerWithNoPageAdapter == null){
            await orderSubmitController!.getContainerWithNoPageAdapter();
          }
          else {
            orderSubmitController!.containerWithNoPageAdapter?.clearSelection();
          }
        }
      }
      if (orderSubmitController!.isSingleBoxQtyOnlyChangedByContainer != isSingleBoxQtyOnlyChangedByContainer){
        orderSubmitController!.isSingleBoxQtyOnlyChangedByContainer = isSingleBoxQtyOnlyChangedByContainer;
        if (orderSubmitController!.isSingleBoxQtyOnlyChangedByContainer){
          NumPadUtil().setText(NumPadUtil.packingWeight, '', orderSubmitController!.numPadCTList);
          orderSubmitController!.calcQty(NumPadUtil.packingWeight);
          if (orderSubmitController!.containerWithNoPageAdapter == null){
            await orderSubmitController!.getContainerWithNoPageAdapter();
          }
          else {
            orderSubmitController!.containerWithNoPageAdapter?.clearSelection();
          }
        }
      }
      orderSubmitController!.frxName = frxNameSubmitTC.text;
      orderSubmitController!.isGetBackAfterCommitSuccess = isGetBackAfterCommitSuccessSubmit;
      if (needResetPerson){
        orderSubmitController!.submitModel.empId = null;
        orderSubmitController!.submitModel.emploee = null;
        if (orderSubmitController!.isPsnHasAdapter){
          await orderSubmitController!.getPersonAdapter();
        }
        else {
          orderSubmitController!.personList.clear();
        }
      }
      orderSubmitController!.numPadCTListSetEnabled();
      orderSubmitController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///生产报工-设备选单-车间过滤 保存
  Future<void> submitFormDeviceDepFilterSave() async {
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
    List<String> list = [];
    for (var element in deviceDepIdListSubmit) {
      if (element.isChoice){
        list.add(element.departmentId);
      }
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_DEVICE_DEP_ID_LIST_KEY, list);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderSubmitController != null){
      if (orderSubmitController!.deviceDepIdList.join(',') != list.join(',')){
        orderSubmitController!.submitModel.deviceId = null;
        orderSubmitController!.submitModel.deviceCode = null;
        orderSubmitController!.submitModel.deviceName = null;
        orderSubmitController!.deviceDepIdList.clear();
        orderSubmitController!.deviceDepIdList.addAll(list);
        if (orderSubmitController!.isDeviceHasAdapter){
          await orderSubmitController!.getEAMDeviceAdapter();
        }
        else {
          orderSubmitController!.deviceModel = EAMDeviceModel();
        }
      }
      orderSubmitController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///生产报工-设备选单-设备类别过滤 保存
  Future<void> submitFormDeviceClassFilterSave() async {
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_DEVICE_CLASS_ID_LIST_KEY, deviceClassIdListSubmit);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderSubmitController != null){
      if (orderSubmitController!.deviceClassIdList.join(',') != deviceClassIdListSubmit.join(',')){
        orderSubmitController!.submitModel.deviceId = null;
        orderSubmitController!.submitModel.deviceCode = null;
        orderSubmitController!.submitModel.deviceName = null;
        orderSubmitController!.deviceClassIdList.clear();
        orderSubmitController!.deviceClassIdList.addAll(deviceClassIdListSubmit);
        if (orderSubmitController!.isDeviceHasAdapter){
          await orderSubmitController!.getEAMDeviceAdapter();
        }
        else {
          orderSubmitController!.deviceModel = EAMDeviceModel();
        }
      }
      orderSubmitController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///生产报工-产品类别打印模板设置
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY, invClassFrxNameMapSubmitStr);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderSubmitController != null){
      orderSubmitController!.invClassFrxNameMap.clear();
      orderSubmitController!.invClassFrxNameMap.addAll(invClassFrxNameMapSubmit);
      orderSubmitController!.update();
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_PAGE_CONFIG_ROWS_KEY, pageConfigRowsSubmit);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY, int.tryParse(limitTimeSubmitTC.text));
    List<Map<String, dynamic>> mapList = [];
    submitListInfoFormListMap.forEach((key, value) {
      mapList.addAll(value.map((e) => e.toJson()));
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_SUBMIT_LIST_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (submitListController != null){
      if (submitListController!.dataListPageConfig.rows != pageConfigRowsSubmit){
        submitListController!.dataListPageConfig.rows = pageConfigRowsSubmit;
        await submitListController!.pageChanged(showLoading: false);
      }
      submitListController!.limitTime = int.tryParse(limitTimeSubmitTC.text);
      submitListController!.submitListInfoFormListMap.clear();
      submitListController!.submitListInfoFormListMap.addAll(submitListInfoFormListMap);
      submitListController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///次品录入-任务信息显示设置 保存
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
    mapList.addAll(orderInfoFormListCR.map((e) => e.toJson()));
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderCheckRecordController != null){
      orderCheckRecordController!.orderInfoFormList.clear();
      orderCheckRecordController!.orderInfoFormList.addAll(orderInfoFormListCR);
      orderCheckRecordController!.update();
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_SHOW_TYPE_BTN_KEY, isShowDataReportTypeBtnCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_TYPE_KEY, checkRecordType);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_SHOW_MAKE_UP_BTN_KEY, isShowMakeUpBtnCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_SHOW_OP_DESCRIPTION_KEY, isShowOpDescriptionCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_BTN_INDEX_KEY, checkRecordBtnIndex);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderCheckRecordController != null){
      orderCheckRecordController!.isShowDataReportTypeBtn = isShowDataReportTypeBtnCR;
      orderCheckRecordController!.checkRecordType = checkRecordType;
      orderCheckRecordController!.isShowMakeUpBtn = isShowMakeUpBtnCR;
      orderCheckRecordController!.isShowOpDescription = isShowOpDescriptionCR;
      orderCheckRecordController!.checkRecordBtnIndex = checkRecordBtnIndex;
      orderCheckRecordController!.numPadCTListSetEnabled();
      orderCheckRecordController!.update();
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_FORM_TITLE_MAP_KEY, str);
    String styleStr = jsonEncode(formStyleMapCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_FORM_STYLE_MAP_KEY, styleStr);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_NUM_PAD_FOCUS_FIELD_KEY, numPadFocusFieldCR);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderCheckRecordController != null){
      orderCheckRecordController!.formTitleMap.clear();
      orderCheckRecordController!.formTitleMap.addAll(formTitleMapCR);
      orderCheckRecordController!.numPadCTList.sort((a, b){
        return numPadCTListSortVoidCallback.call(orderCheckRecordController!.formTitleMap, a, b);
      });
      orderCheckRecordController!.formStyleMap.clear();
      orderCheckRecordController!.formStyleMap.addAll(formStyleMapCR);
      orderCheckRecordController!.numPadCTList.forEach((element) {
        element.styleMap.clear();
        if (orderCheckRecordController!.formStyleMap.containsKey(element.key)){
          element.styleMap.addAll(orderCheckRecordController!.formStyleMap[element.key]!);
        }
      });
      orderCheckRecordController!.numPadFocusField = numPadFocusFieldCR;
      orderCheckRecordController!.update();
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_DEP_GET_WAY_INDEX_KEY, depGetWayIndexCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_WC_DATA_REPORT_TYPE_KEY, wcDataReportTypeCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_DEVICE_HAS_ADAPTER_KEY, isDeviceHasAdapterCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_PSN_HAS_ADAPTER_KEY, isPsnHasAdapterCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_PSN_MULTI_KEY, isPsnMultiCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_PSN_GET_WAY_INDEX_KEY, psnGetWayIndexCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_PSN_GET_WAY_DEP_CODE_KEY, psnDepCodeCRTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_PSN_GET_WAY_LINE_CODE_KEY, psnLineCodeCRTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY, isSaveTheLastSelectedPsnIdCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_TEMPLATE_FILENAME_KEY, frxNameCRTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY, isGetBackAfterCommitSuccessCR);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderCheckRecordController != null){
      bool needResetPerson = false;
      orderCheckRecordController!.depGetWayIndex = depGetWayIndexCR;
      if (orderCheckRecordController!.wcDataReportType != wcDataReportTypeCR) {
        orderCheckRecordController!.wcDataReportType = wcDataReportTypeCR;
        orderCheckRecordController!.checkRecordModel.wcId = null;
        orderCheckRecordController!.checkRecordModel.lineCode = null;
        orderCheckRecordController!.checkRecordModel.lineName = null;
        switch (orderCheckRecordController!.wcDataReportType){
          //region
          case 0: ///产线
            if (orderCheckRecordController!.lineAdapter == null){
              await orderCheckRecordController!.getLineAdapter();
            }
            break;
          case 1: ///加工中心
            if (orderCheckRecordController!.workCenterAdapter == null){
              await orderCheckRecordController!.getWorkCenterAdapter();
            }
            break;
          case 2: ///生产班组
            if (orderCheckRecordController!.teamGroupAdapter == null){
              await orderCheckRecordController!.getTeamGroupAdapter();
            }
            break;
          //endregion
        }
      }
      if (orderCheckRecordController!.isDeviceHasAdapter != isDeviceHasAdapterCR){
        orderCheckRecordController!.isDeviceHasAdapter = isDeviceHasAdapterCR;
        orderCheckRecordController!.checkRecordModel.deviceId = null;
        orderCheckRecordController!.checkRecordModel.deviceCode = null;
        orderCheckRecordController!.checkRecordModel.deviceName = null;
        if (orderCheckRecordController!.isDeviceHasAdapter){
          if (orderCheckRecordController!.deviceAdapter == null){
            await orderCheckRecordController!.getEAMDeviceAdapter();
          }
        }
        else {
          orderCheckRecordController!.deviceModel = EAMDeviceModel();
        }
      }
      if (orderCheckRecordController!.isPsnHasAdapter != isPsnHasAdapterCR){
        orderCheckRecordController!.isPsnHasAdapter = isPsnHasAdapterCR;
        needResetPerson = true;
      }
      if (orderCheckRecordController!.isPsnMulti != isPsnMultiCR){
        orderCheckRecordController!.isPsnMulti = isPsnMultiCR;
        needResetPerson = true;
      }
      if (orderCheckRecordController!.psnGetWayIndex != psnGetWayIndexCR){
        orderCheckRecordController!.psnGetWayIndex = psnGetWayIndexCR;
        needResetPerson = true;
      }
      if (orderCheckRecordController!.psnDepCode != psnDepCodeCRTC.text){
        orderCheckRecordController!.psnDepCode = psnDepCodeCRTC.text;
        needResetPerson = true;
      }
      if (orderCheckRecordController!.psnLineCode != psnLineCodeCRTC.text){
        orderCheckRecordController!.psnLineCode = psnLineCodeCRTC.text;
        needResetPerson = true;
      }
      orderCheckRecordController!.isSaveTheLastSelectedPsnId = isSaveTheLastSelectedPsnIdCR;
      orderCheckRecordController!.frxName = frxNameCRTC.text;
      orderCheckRecordController!.isGetBackAfterCommitSuccess = isGetBackAfterCommitSuccessCR;
      if (needResetPerson){
        orderCheckRecordController!.checkRecordModel.empId = null;
        orderCheckRecordController!.checkRecordModel.emploee = null;
        if (orderCheckRecordController!.isPsnHasAdapter){
          await orderCheckRecordController!.getPersonAdapter();
        }
        else {
          orderCheckRecordController!.personList.clear();
        }
      }
      orderCheckRecordController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///次品录入-设备选单-车间过滤 保存
  Future<void> checkRecordFormDeviceDepFilterSave() async {
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
    List<String> list = [];
    for (var element in deviceDepIdListCR) {
      if (element.isChoice){
        list.add(element.departmentId);
      }
    }
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_DEVICE_DEP_ID_LIST_KEY, list);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderCheckRecordController != null){
      if (orderCheckRecordController!.deviceDepIdList.join(',') != list.join(',')){
        orderCheckRecordController!.checkRecordModel.deviceId = null;
        orderCheckRecordController!.checkRecordModel.deviceCode = null;
        orderCheckRecordController!.checkRecordModel.deviceName = null;
        orderCheckRecordController!.deviceDepIdList.clear();
        orderCheckRecordController!.deviceDepIdList.addAll(list);
        if (orderCheckRecordController!.isDeviceHasAdapter){
          await orderCheckRecordController!.getEAMDeviceAdapter();
        }
        else {
          orderCheckRecordController!.deviceModel = EAMDeviceModel();
        }
      }
      orderCheckRecordController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///次品录入-设备选单-设备类别过滤 保存
  Future<void> checkRecordFormDeviceClassFilterSave() async {
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_DEVICE_CLASS_ID_LIST_KEY, deviceClassIdListCR);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderCheckRecordController != null){
      if (orderCheckRecordController!.deviceClassIdList.join(',') != deviceClassIdListCR.join(',')){
        orderCheckRecordController!.checkRecordModel.deviceId = null;
        orderCheckRecordController!.checkRecordModel.deviceCode = null;
        orderCheckRecordController!.checkRecordModel.deviceName = null;
        orderCheckRecordController!.deviceClassIdList.clear();
        orderCheckRecordController!.deviceClassIdList.addAll(deviceClassIdListCR);
        if (orderCheckRecordController!.isDeviceHasAdapter){
          await orderCheckRecordController!.getEAMDeviceAdapter();
        }
        else {
          orderCheckRecordController!.deviceModel = EAMDeviceModel();
        }
      }
      orderCheckRecordController!.update();
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY, invClassFrxNameMapCRStr);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderCheckRecordController != null){
      orderCheckRecordController!.invClassFrxNameMap.clear();
      orderCheckRecordController!.invClassFrxNameMap.addAll(invClassFrxNameMapCR);
      orderCheckRecordController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///不良品上报-任务信息显示设置 保存
  Future<void> materialRejectInfoFormSave() async {
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
    mapList.addAll(orderInfoFormListMR.map((e) => e.toJson()));
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderMaterialRejectController != null){
      orderMaterialRejectController!.orderInfoFormList.clear();
      orderMaterialRejectController!.orderInfoFormList.addAll(orderInfoFormListMR);
      orderMaterialRejectController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///不良品上报-按钮显示设置 保存
  Future<void> materialRejectBtnSave() async {
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_SHOW_TYPE_BTN_KEY, isShowDataReportTypeBtnMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_TYPE_KEY, checkRecordTypeMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_SHOW_MAKE_UP_BTN_KEY, isShowMakeUpBtnMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_BTN_INDEX_KEY, checkRecordBtnIndexMR);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderMaterialRejectController != null){
      orderMaterialRejectController!.isShowDataReportTypeBtn = isShowDataReportTypeBtnMR;
      orderMaterialRejectController!.checkRecordType = checkRecordTypeMR;
      orderMaterialRejectController!.isShowMakeUpBtn = isShowMakeUpBtnMR;
      orderMaterialRejectController!.checkRecordBtnIndex = checkRecordBtnIndexMR;
      orderMaterialRejectController!.numPadCTListSetEnabled();
      orderMaterialRejectController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///不良品上报-表单填写项显示设置 保存
  Future<void> materialRejectFormSave() async {
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
    String str = jsonEncode(formTitleMapMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_FORM_TITLE_MAP_KEY, str);
    String styleStr = jsonEncode(formStyleMapMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_FORM_STYLE_MAP_KEY, styleStr);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_NUM_PAD_FOCUS_FIELD_KEY, numPadFocusFieldMR);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderMaterialRejectController != null){
      orderMaterialRejectController!.formTitleMap.clear();
      orderMaterialRejectController!.formTitleMap.addAll(formTitleMapMR);
      orderMaterialRejectController!.numPadCTList.sort((a, b){
        return numPadCTListSortVoidCallback.call(orderMaterialRejectController!.formTitleMap, a, b);
      });
      orderMaterialRejectController!.formStyleMap.clear();
      orderMaterialRejectController!.formStyleMap.addAll(formStyleMapMR);
      orderMaterialRejectController!.numPadCTList.forEach((element) {
        element.styleMap.clear();
        if (orderMaterialRejectController!.formStyleMap.containsKey(element.key)){
          element.styleMap.addAll(orderMaterialRejectController!.formStyleMap[element.key]!);
        }
      });
      orderMaterialRejectController!.numPadFocusField = numPadFocusFieldMR;
      orderMaterialRejectController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///不良品上报-表单填写设置 保存
  Future<void> materialRejectFormSettingSave() async {
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_DEP_GET_WAY_INDEX_KEY, depGetWayIndexMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_PSN_HAS_ADAPTER_KEY, isPsnHasAdapterMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_PSN_MULTI_KEY, isPsnMultiMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_PSN_GET_WAY_INDEX_KEY, psnGetWayIndexMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_PSN_GET_WAY_DEP_CODE_KEY, psnDepCodeMRTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_PSN_GET_WAY_LINE_CODE_KEY, psnLineCodeMRTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY, isSaveTheLastSelectedPsnIdMR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_TEMPLATE_FILENAME_KEY, frxNameMRTC.text);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY, isGetBackAfterCommitSuccessMR);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderMaterialRejectController != null){
      bool needResetPerson = false;
      orderMaterialRejectController!.depGetWayIndex = depGetWayIndexMR;
      if (orderMaterialRejectController!.isPsnHasAdapter != isPsnHasAdapterMR){
        orderMaterialRejectController!.isPsnHasAdapter = isPsnHasAdapterMR;
        needResetPerson = true;
      }
      if (orderMaterialRejectController!.isPsnMulti != isPsnMultiMR){
        orderMaterialRejectController!.isPsnMulti = isPsnMultiMR;
        needResetPerson = true;
      }
      if (orderMaterialRejectController!.psnGetWayIndex != psnGetWayIndexMR){
        orderMaterialRejectController!.psnGetWayIndex = psnGetWayIndexMR;
        needResetPerson = true;
      }
      if (orderMaterialRejectController!.psnDepCode != psnDepCodeMRTC.text){
        orderMaterialRejectController!.psnDepCode = psnDepCodeMRTC.text;
        needResetPerson = true;
      }
      if (orderMaterialRejectController!.psnLineCode != psnLineCodeMRTC.text){
        orderMaterialRejectController!.psnLineCode = psnLineCodeMRTC.text;
        needResetPerson = true;
      }
      orderMaterialRejectController!.isSaveTheLastSelectedPsnId = isSaveTheLastSelectedPsnIdMR;
      orderMaterialRejectController!.frxName = frxNameMRTC.text;
      orderMaterialRejectController!.isGetBackAfterCommitSuccess = isGetBackAfterCommitSuccessMR;
      if (needResetPerson){
        orderMaterialRejectController!.checkRecordModel.empId = null;
        orderMaterialRejectController!.checkRecordModel.emploee = null;
        if (orderMaterialRejectController!.isPsnHasAdapter){
          await orderMaterialRejectController!.getPersonAdapter(
            sourceLineCode: orderMaterialRejectController!.orderModel.lineCode
          );
        }
        else {
          orderMaterialRejectController!.personList.clear();
        }
      }
      orderMaterialRejectController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  ///不良品上报-产品类别打印模板设置
  Future<void> materialRejectInvClassTemplateSave() async {
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_MATERIAL_REJECT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY, invClassFrxNameMapMRStr);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (orderMaterialRejectController != null){
      orderMaterialRejectController!.invClassFrxNameMap.clear();
      orderMaterialRejectController!.invClassFrxNameMap.addAll(invClassFrxNameMapMR);
      orderMaterialRejectController!.update();
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
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_PAGE_CONFIG_ROWS_KEY, pageConfigRowsCR);
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_DELETE_LIMIT_TIME_KEY, int.tryParse(limitTimeCRTC.text));
    List<Map<String, dynamic>> mapList = [];
    checkRecordListInfoFormListMap.forEach((key, value) {
      mapList.addAll(value.map((e) => e.toJson()));
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.MES_ORDER_CHECK_RECORD_LIST_INFO_FORM_LIST_KEY, mapList);
    //endregion
    ProgressDialogUtil.update(value: 1, msg: '设置成功，正在刷新数据！');

    //region 数据刷新
    if (checkRecordListController != null){
      if (checkRecordListController!.dataListPageConfig.rows != pageConfigRowsCR){
        checkRecordListController!.dataListPageConfig.rows = pageConfigRowsCR;
        await checkRecordListController!.pageChanged(showLoading: false);
      }
      checkRecordListController!.limitTime = int.tryParse(limitTimeCRTC.text);
      checkRecordListController!.checkRecordListInfoFormListMap.clear();
      checkRecordListController!.checkRecordListInfoFormListMap.addAll(checkRecordListInfoFormListMap);
      checkRecordListController!.update();
    }
    //endregion
    isLoading = false;
    ProgressDialogUtil.update(value: 2);
  }

  //endregion


  @override
  void onClose() {
    psnDepCodeSubmitTC.dispose();
    psnLineCodeSubmitTC.dispose();
    numMaxCountLimitTC.dispose();
    frxNameSubmitTC.dispose();
    limitTimeSubmitTC.dispose();
    psnDepCodeSubmitFN.dispose();
    psnLineCodeSubmitFN.dispose();
    numMaxCountLimitFN.dispose();
    frxNameSubmitFN.dispose();
    limitTimeSubmitFN.dispose();

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

    submitListScrollController.dispose();
    checkRecordListScrollController.dispose();
    super.onClose();
  }


}