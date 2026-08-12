
import 'package:basement/utils.dart';
import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/model/command_bar_btn_model.dart';
import 'package:desktop/app/model/info_form_model.dart';
import 'package:desktop/app/model/mo_sign_model.dart';
import 'package:desktop/app/ui/widget/num_pad/num_pad_util.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';


///全局默认配置文件
abstract class AppConfig {


  ///默认行高
  static const double rowHeight = 32;

  ///默认IP地址
  //static const String host = 'http://123.60.78.67:8082/';

  /// 提示方式
  ///
  /// dialog
  ///
  /// toast
  static const String tipsShowTypeStr = 'dialog';

  ///文本比例
  static const double textScale = 1;

  ///字体样式
  static const String fontFamily = 'FontFamilyOfSiYuanHeiTi';

  ///主题 system light dark
  static const String themeMode = 'light';

  ///主题 跟随系统 明亮 深黑
  static const String themeModeName = '明亮';

  ///默认Language
  static const Locale defaultLocal = Locale('zh','CN');

  ///windows平台下，点击输入框时，是否弹出软键盘
  static const bool isKeyboardOpenAfterClickTC = false;

  ///默认用户名
  static const String userName = 'admin';
  ///默认密码
  static const String password = '000000';
  ///默认不保存密码
  static const bool isReservePW = false;

  ///应用程序是否需要定时重启
  static const bool isNeedTimedRestart = false;
  ///应用程序是否是通过重启打开的
  static const bool isOpenByRestart = false;
  ///应用程序定时重启的天数
  static const int? dayOfAppRestart = null;
  ///应用程序定时重启的时间
  static const String? dateTimeOfAppRestart = null;

  ///是否接收消息数据
  static const bool isOnListen = true;

  ///websocket 定时重连的频率
  static const int? secondsOfWSReconnection = null;

  ///导航栏是否展开
  static const bool isNavigationRailExtended = true;

  ///NavigationRail默认选中的Item的Key
  static const String destinationKeyName = 'home.navigate.device';

  ///是否使用打印机定义的配置
  static const bool usePrinterSettings = false;
  ///默认打印份数 int
  static const int defaultPrintCopies = 1;
  ///默认打印方式(服务端打印 serverPrint OR 本地打印 localPrint)
  static const String printType = 'serverPrint';

  ///是否闪烁
  static const bool isBlink = false;
  ///闪烁频率
  static const int rate = 500;

  ///单个设备卡片显示的设备信息 0 设备编号； 1 设备简称； 2设备名称
  static const int deviceShowInfoType = 0;

  ///是否显示单据类型选择标签
  static const bool isShowCategory = true;

  ///加工中心 显示的单据的检验类型（任务单 610001 OR 派工单 650011）
  static const int workCenterCategorySelectedIndex = 650011;

  ///单个加工中心显示的加工中心信息 0 加工中心编号； 1 加工中心名称
  static const int workCenterShowInfoType = 0;

  ///单页显示记录数
  static const int pageConfigRows = 10;

  ///日期选择器的初始值（当天）（报工列表、次品列表用）
  static const Map<String, dynamic> todayDatePickerValueMap = {
    'startDate': {'d': {'interval': 0}},
    'endDate': {'d': {'interval': 0}},
  };

  //region 搜索方式
  ///搜索方式默认值
  static const int searchTypeIndex = 0;

  ///任务单搜索方式列表
  static List<ChoiceChipModel> orderSearchTypeList = [
    ChoiceChipModel(title: '任务单号搜索', keyName: 'orderCode', content: 'billcode',),
    ChoiceChipModel(title: '产品编号搜索', keyName: 'invCode', content: 'invCode',),
    ChoiceChipModel(title: '产品名称搜索', keyName: 'invName', content: 'invName',),
    ChoiceChipModel(title: '产品规格搜索', keyName: 'invStd', content: 'productstd',),
    ChoiceChipModel(title: '序列号搜索', keyName: 'orderSN', content: 'MoOrderSN',), /// MoOrderSN MoOrderId
  ];

  ///派工单搜索方式列表
  static List<ChoiceChipModel> taskSearchTypeList = [
    ChoiceChipModel(title: '派工单号搜索', keyName: 'taskCode', content: 'taskcode'),
    ChoiceChipModel(title: '任务单号搜索', keyName: 'orderCode', content: 'ordercode'),
    ChoiceChipModel(title: '产品编号搜索', keyName: 'invCode', content: 'invcode'),
    ChoiceChipModel(title: '产品名称搜索', keyName: 'invName', content: 'invname'),
    ChoiceChipModel(title: '员工编号搜索', keyName: 'psnIdCode', content: 'EmploeeId'),
    ChoiceChipModel(title: '员工卡号搜索', keyName: 'psnNum', content: 'EmploeeId'),
    ChoiceChipModel(title: '销售单号搜索', keyName: 'soCode', content: 'socode'),
    ChoiceChipModel(title: '产品规格搜索', keyName: 'invStd', content: 'invstd'),
  ];

  ///注塑报工单搜索方式列表
  static List<ChoiceChipModel> pMesSubmitSearchTypeList = [
    ChoiceChipModel(title: '报工单号搜索', keyName: 'submit', content: 'billcode'),
    ChoiceChipModel(title: '派工单号搜索', keyName: 'task', content: 'taskcode'),
    ChoiceChipModel(title: '任务单号搜索', keyName: 'order', content: 'ordercode'),
    ChoiceChipModel(title: '产品编码搜索', keyName: 'invCode', content: 'invcode'),
    ChoiceChipModel(title: '产品名称搜索', keyName: 'invName', content: 'invname'),
  ];

  ///生产报工单搜索方式列表
  static List<ChoiceChipModel> mesSubmitSearchTypeList = [
    ChoiceChipModel(title: '报工单号搜索', keyName: 'submit', content: 'billcode'),
    ChoiceChipModel(title: '派工单号搜索', keyName: 'task', content: 'taskcode'),
    ChoiceChipModel(title: '任务单号搜索', keyName: 'order', content: 'ordercode'),
    ChoiceChipModel(title: '产品编码搜索', keyName: 'invCode', content: 'invcode'),
    ChoiceChipModel(title: '产品名称搜索', keyName: 'invName', content: 'invname'),
  ];

  ///报工条码搜索方式列表
  static List<ChoiceChipModel> submitBarcodeSearchTypeList = [
    ChoiceChipModel(title: '条码搜索', keyName: 'barcode', content: 'keyword'),
    ChoiceChipModel(title: '报工单号搜索', keyName: 'submit', content: 'preCode'),
    ChoiceChipModel(title: '派工单号搜索', keyName: 'task', content: 'preId'),
    ChoiceChipModel(title: '任务单号搜索', keyName: 'order', content: 'preId'),
  ];

  ///产品搜索方式列表
  static List<ChoiceChipModel> inventorySearchTypeList = [
    ChoiceChipModel(title: '关键字搜索', keyName: 'keyWord', content: 'keyword'),
    ChoiceChipModel(title: '产品编码搜索', keyName: 'invCode', content: 'invcode'),
    ChoiceChipModel(title: '产品名称搜索', keyName: 'invName', content: 'invname'),
    ChoiceChipModel(title: '产品规格搜索', keyName: 'invStd', content: 'invstd'),
    ChoiceChipModel(title: '产品图号搜索', keyName: 'engineerFigNo', content: 'engineerfigno'),
    ChoiceChipModel(title: '存货代码搜索', keyName: 'invAddCode', content: 'InvAddCode'),
  ];

  ///物料条码搜索方式列表
  static List<ChoiceChipModel> invBarcodeSearchTypeList = [
    ChoiceChipModel(title: '条码搜索', keyName: 'barcode', content: 'keyword'),
    ChoiceChipModel(title: '产品编码搜索', keyName: 'invCode', content: 'invcode'),
    ChoiceChipModel(title: '产品名称搜索', keyName: 'invName', content: 'invname'),
  ];

  ///工序计划明细单据搜索方式列表
  static List<ChoiceChipModel> wbEntrySearchTypeList = [
    ChoiceChipModel(title: '任务单号搜索', keyName: 'orderCode', content: 'mocode',),
    //ChoiceChipModel(title: '产品编号搜索', keyName: 'invCode', content: 'invCode',),
    //ChoiceChipModel(title: '产品名称搜索', keyName: 'invName', content: 'invName',),
    //ChoiceChipModel(title: '产品规格搜索', keyName: 'invStd', content: 'productstd',),
    //ChoiceChipModel(title: '序列号搜索', keyName: 'orderSN', content: 'MoOrderSN',), /// MoOrderSN MoOrderId
  ];
  //endregion

  //region 日期查询类型
  ///日期查询类型默认值
  static const int dateSearchTypeIndex = 0;

  ///任务单日期查询类型列表
  static List<ChoiceChipModel> orderDateSearchTypeList = [
    ChoiceChipModel(title: '单据日期', keyName: 'billDate', content: 'startdate,enddate',),
    ChoiceChipModel(title: '预计开工', keyName: 'dueStartDate', content: 'Begin,End',),
  ];

  ///派工单日期查询类型列表
  static List<ChoiceChipModel> taskDateSearchTypeList = [
    ChoiceChipModel(title: '单据日期', keyName: 'taskDate', content: 'startdate,enddate',),
    ChoiceChipModel(title: '预计开工', keyName: 'dueStartDate', content: 'StartDuedate,EndDuedate',),
  ];

  ///安灯日期查询类型列表
  static List<ChoiceChipModel> andonDateSearchTypeList = [
    ChoiceChipModel(title: '单据日期', keyName: 'date', content: 'StartTime,EndTime',),
  ];

  ///物料条码日期查询类型列表
  static List<ChoiceChipModel> invBarcodeDateSearchTypeList = [
    ChoiceChipModel(title: '单据日期', keyName: 'date', content: 'StartTime,EndTime',),
  ];

  ///注塑报工单日期查询类型列表
  static List<ChoiceChipModel> pMesSubmitDateSearchTypeList = [
    ChoiceChipModel(title: '单据日期', keyName: 'date', content: 'StartTime,EndTime',),
  ];

  ///生产报工单日期查询类型列表
  static List<ChoiceChipModel> mesSubmitDateSearchTypeList = [
    ChoiceChipModel(title: '单据日期', keyName: 'date', content: 'StartTime,EndTime',),
  ];

  ///注塑次品单日期查询类型列表
  static List<ChoiceChipModel> pMesCheckRecordDateSearchTypeList = [
    ChoiceChipModel(title: '单据日期', keyName: 'date', content: 'startDate,endDate',),
  ];

  ///生产次品单日期查询类型列表
  static List<ChoiceChipModel> mesCheckRecordDateSearchTypeList = [
    ChoiceChipModel(title: '单据日期', keyName: 'date', content: 'startDate,endDate',),
  ];

  ///停机记录束记录时间查询类型列表
  static List<ChoiceChipModel> shutdownRecordDateSearchTypeList = [
    ChoiceChipModel(title: '记录时间', keyName: 'date', content: 'startdate,enddate',),
  ];

  ///生产记录生产日期查询类型列表
  static List<ChoiceChipModel> productionRecordDateSearchTypeList = [
    ChoiceChipModel(title: '生产日期', keyName: 'date', content: 'StartTime,EndTime',),
  ];

  //endregion

  //region 状态筛选
  ///任务单状态筛选列表
  static List<MoSignModel> orderSignList = [
    ///8
    MoSignModel(
        title: '待派工', content: 'NoAssign = 1',
        sign: 8, lTSign: MoOpOrderSign.yjh.sign, gESign: null
    ),
    ///1 >= 1 <16
    MoSignModel(
        title: '待生产', content: '已计划,已派工,已领料,已挂起',
        sign: 1, lTSign: MoOpOrderSign.scz.sign, gESign: MoOpOrderSign.yjh.sign
    ),
    ///2 >=16 <32
    MoSignModel(
        title: '生产中', content: '生产中',
        sign: 2, lTSign: MoOpOrderSign.ysc.sign, gESign: MoOpOrderSign.scz.sign
    ),
    ///4 >=32
    MoSignModel(
        title: '已生产', content: '已生产,已检验,指定完工',
        sign: 4, lTSign: null, gESign: MoOpOrderSign.ysc.sign
    ),
  ];

  ///派工单状态筛选列表
  static List<MoSignModel> taskSignList = [
    ///1 <16
    MoSignModel(
      title: '待生产', content: '制单,已计划,已审核,已挂起',
      sign: 1, lTSign: MoTaskSign.scz.sign, gESign: null
    ),
    ///2 >=16 <32
    MoSignModel(
      title: '生产中', content: '生产中',
      sign: 2, lTSign: MoTaskSign.ysc.sign, gESign: MoTaskSign.scz.sign
    ),
    ///4 >=32
    MoSignModel(
      title: '已生产', content: '已生产,指定完工',
      sign: 4, lTSign: null, gESign: MoTaskSign.ysc.sign
    ),
  ];

  ///机台派工单状态筛选列表
  static List<MoSignModel> deviceTaskSignList = [
    ///1 >=16 <32
    MoSignModel(
        title: '生产中', content: '生产中',
        sign: 1, lTSign: MoTaskSign.ysc.sign, gESign: MoTaskSign.scz.sign
    ),
    ///2 <16
    MoSignModel(
        title: '待生产', content: '制单,已计划,已审核,已挂起',
        sign: 2, lTSign: MoTaskSign.scz.sign, gESign: null
    ),
    ///4 >=32
    MoSignModel(
        title: '已生产', content: '已生产,指定完工',
        sign: 4, lTSign: null, gESign: MoTaskSign.ysc.sign
    ),
  ];

  ///工序计划明细单据状态筛选列表
  static List<MoSignModel> workBillEntrySignList = [
    ///1 <16
    MoSignModel(
        title: '待生产', content: '未派工,已计划,已派工,已领料,已挂起',
        sign: 1, lTSign: MoWorkBillEntrySign.scz.sign, gESign: null
    ),
    ///2 >=16 <32
    MoSignModel(
        title: '生产中', content: '生产中',
        sign: 2, lTSign: MoWorkBillEntrySign.ysc.sign, gESign: MoWorkBillEntrySign.scz.sign
    ),
    ///4 >=32
    MoSignModel(
        title: '已生产', content: '已生产,已检验,指定完工',
        sign: 4, lTSign: null, gESign: MoWorkBillEntrySign.ysc.sign
    ),
  ];

  ///全场呼叫状态筛选列表
  static List<MoSignModel> andonSignList = [
    ///1
    MoSignModel(title: '待处理', sign: 1),
    ///2
    MoSignModel(title: '处理中', sign: 2),
    ///4
    MoSignModel(title: '待确认', sign: 4),
    ///8
    MoSignModel(title: '已处理', sign: 8),
  ];
  //endregion

  //region 页面显示的数据字段列表
  ///生产任务单列表页面显示的数据字段列表（生产任务单）
  static List<InfoFormModel> mesOrderListInfoFormList = [
    InfoFormModel(keyName: 'BillCode', title: '任务单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'BillDate', title: '单据日期',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'StartDate', title: '实际开工',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DueStartDate', title: '预计开工', width: 320, groupType: 0, isShow: false),
    InfoFormModel(keyName: 'ProductStd', title: '产品规格',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PackingType', title: '包装规格',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Qty', title: '任务数量',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'ProductQty', title: '已生产数',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'QualifiedQty', title: '已报产数',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'DisabledQty', title: '次品数量',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'StockQty', title: '入库数量',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'SoCode', title: '销售单号',  width: 320, groupType: 1),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号',  width: 320, groupType: 1),
    InfoFormModel(keyName: 'OrderCode', title: '生产订单号',  width: 320, groupType: 1),
    InfoFormModel(keyName: 'DepName', title: '生产车间',  width: 320, groupType: 1),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define22', title: '@单据体.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define23', title: '@单据体.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define24', title: '@单据体.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define25', title: '@单据体.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define26', title: '@单据体.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define27', title: '@单据体.自定义项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define28', title: '@单据体.自定义项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define29', title: '@单据体.自定义项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define30', title: '@单据体.自定义项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define31', title: '@单据体.自定义项10',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define32', title: '@单据体.自定义项11',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define33', title: '@单据体.自定义项12',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define34', title: '@单据体.自定义项13',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define35', title: '@单据体.自定义项14',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define36', title: '@单据体.自定义项15',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Define37', title: '@单据体.自定义项16',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderSN', title: '扫码序列号',  width: 320, groupType: 1, isShow: true),
  ];

  ///生产任务单报工、报次品页面显示的数据字段列表（生产任务单）
  static List<InfoFormModel> mesOrderInfoFormList = [
    InfoFormModel(keyName: 'BillCode', title: '任务单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'ProductName', title: '产品名称',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'ProductStd', title: '产品规格',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DepName', title: '生产车间',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Qty', title: '任务数量',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'ProductQty', title: '已生产数',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'QualifiedQty', title: '已报产数',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'RemainingQty', title: '剩余报工数',  width: 320, groupType: 0, isShow: true, isHighlight: true),
    InfoFormModel(keyName: 'DisabledQty', title: '次品数量',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'StockQty', title: '入库数量',  width: 320, groupType: 0, isShow: true, isHighlight: true),
    InfoFormModel(keyName: 'UnStockQty', title: '未入库数量',  width: 320, groupType: 0, isShow: true, isHighlight: true),
    InfoFormModel(keyName: 'PackingType', title: '包装规格',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'PackingQty', title: '标准装箱数',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'BillDate', title: '单据日期',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'StartDate', title: '实际开工',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'DueStartDate', title: '预计开工', width: 320, groupType: 0, isShow: false),
    InfoFormModel(keyName: 'SoCode', title: '销售单号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'OrderCode', title: '生产订单号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'DeviceCode', title: '设备编号',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'DeviceName', title: '设备名称',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpCode', title: '工序编号',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpName', title: '工序名称',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'sequ', title: '工序顺序号',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpDescription', title: '工序说明',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpSubmitQty', title: '工序报工数',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpDisabledQty', title: '工序次品数',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpAcceptQty', title: '工序检验数',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define22', title: '@单据体.自定义项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define23', title: '@单据体.自定义项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define24', title: '@单据体.自定义项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define25', title: '@单据体.自定义项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define26', title: '@单据体.自定义项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define27', title: '@单据体.自定义项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define28', title: '@单据体.自定义项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define29', title: '@单据体.自定义项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define30', title: '@单据体.自定义项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define31', title: '@单据体.自定义项10',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define32', title: '@单据体.自定义项11',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define33', title: '@单据体.自定义项12',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define34', title: '@单据体.自定义项13',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define35', title: '@单据体.自定义项14',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define36', title: '@单据体.自定义项15',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define37', title: '@单据体.自定义项16',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'ContainerPackingDescription', title: '容器说明',  width: 320, groupType: 0, isShow: true),
  ];

  ///生产派工单列表页面显示的数据字段列表（生产派工单）
  static List<InfoFormModel> mesTaskListInfoFormList = [
    InfoFormModel(keyName: 'TaskCode', title: '派工单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'TaskDate', title: '派工日期', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'StartDate', title: '实际开工', width: 320, groupType: 0, isShow: false),
    InfoFormModel(keyName: 'DueStartDate', title: '预计开工', width: 320, groupType: 0, isShow: false),
    InfoFormModel(keyName: 'InvStd', title: '产品规格', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DeviceName', title: '机器名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderCode', title: '任务单号', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'DeviceCode', title: '机器编号', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'DepName', title: '生产车间', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'PackingType', title: '包装规格', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'AssignQty', title: '派工数量',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'QualifiedQty', title: '已生产数', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'submitQty', title: '已报产数', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'disabledQty', title: '次品数量', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'StockQty', title: '入库数量',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpWorkDescription', title: '工序说明', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'SoCode', title: '销售单号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'GDCode', title: '生产单号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine22', title: '@单据体.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine23', title: '@单据体.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine24', title: '@单据体.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine25', title: '@单据体.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine26', title: '@单据体.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine27', title: '@单据体.自定义项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine28', title: '@单据体.自定义项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine29', title: '@单据体.自定义项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine30', title: '@单据体.自定义项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine31', title: '@单据体.自定义项10',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine32', title: '@单据体.自定义项11',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine33', title: '@单据体.自定义项12',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine34', title: '@单据体.自定义项13',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine35', title: '@单据体.自定义项14',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine36', title: '@单据体.自定义项15',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine37', title: '@单据体.自定义项16',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 1, isShow: true),
  ];

  ///生产派工单报工、报次品页面显示的数据字段列表（生产派工单）
  static List<InfoFormModel> mesTaskInfoFormList = [
    InfoFormModel(keyName: 'TaskCode', title: '派工单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderCode', title: '任务单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvName', title: '产品名称',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'InvStd', title: '产品规格',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'sequ', title: '工序顺序号',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OpName', title: '工序名称',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'OpWorkDescription', title: '工序说明',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DepName', title: '生产车间',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DeviceCode', title: '设备编号',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DeviceName', title: '设备名称',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'AssignQty', title: '任务数量',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'QualifiedQty', title: '已生产数',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'submitQty', title: '已报产数',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'RemainingQty', title: '剩余报工数',  width: 320, groupType: 0, isShow: true, isHighlight: true),
    InfoFormModel(keyName: 'disabledQty', title: '次品数量',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'StockQty', title: '入库数量',  width: 320, groupType: 0, isShow: true, isHighlight: true),
    InfoFormModel(keyName: 'UnStockQty', title: '未入库数量',  width: 320, groupType: 0, isShow: true, isHighlight: true),
    InfoFormModel(keyName: 'PackingType', title: '包装规格',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'PackingQty', title: '标准装箱数',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'TaskDate', title: '派工日期',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'StartDate', title: '实际开工',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'DueStartDate', title: '预计开工', width: 320, groupType: 0, isShow: false),
    InfoFormModel(keyName: 'SoCode', title: '销售单号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'GDCode', title: '生产订单号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine22', title: '@单据体.自定义项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine23', title: '@单据体.自定义项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine24', title: '@单据体.自定义项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine25', title: '@单据体.自定义项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine26', title: '@单据体.自定义项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine27', title: '@单据体.自定义项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine28', title: '@单据体.自定义项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine29', title: '@单据体.自定义项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine30', title: '@单据体.自定义项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine31', title: '@单据体.自定义项10',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine32', title: '@单据体.自定义项11',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine33', title: '@单据体.自定义项12',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine34', title: '@单据体.自定义项13',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine35', title: '@单据体.自定义项14',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine36', title: '@单据体.自定义项15',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine37', title: '@单据体.自定义项16',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 0, isShow: true),
  ];

  ///生产报工单列表页面显示的数据字段列表（生产报工单）
  static List<InfoFormModel> mesSubmitListInfoFormList = [
    InfoFormModel(keyName: 'OrderCode', title: '任务单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'TaskCode', title: '派工单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'InvName', title: '产品名称',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'InvStd', title: '产品规格',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'Qty', title: '报产数量', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Weight', title: '报产重量', width: 320, groupType: 0),
    InfoFormModel(keyName: 'QualifiedQty', title: '合格数量', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Emploee', title: '生产员工', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'BillDate', title: '生产日期', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'CreateDate', title: '记录日期', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DepName', title: '生产车间', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'TeamName', title: '生产班次', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'LineName', title: '生产产线', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OpName', title: '工序名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'SerialNumber', title: '序\u00A0\u00A0列\u00A0\u00A0号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'SoCode', title: '销售单号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine22', title: '@单据体.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine23', title: '@单据体.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine24', title: '@单据体.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine25', title: '@单据体.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine26', title: '@单据体.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine27', title: '@单据体.自定义项6',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine28', title: '@单据体.自定义项7',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine29', title: '@单据体.自定义项8',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine30', title: '@单据体.自定义项9',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine31', title: '@单据体.自定义项10',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine32', title: '@单据体.自定义项11',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine33', title: '@单据体.自定义项12',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine34', title: '@单据体.自定义项13',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine35', title: '@单据体.自定义项14',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine36', title: '@单据体.自定义项15',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine37', title: '@单据体.自定义项16',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 1, isShow: true),
  ];

  ///生产次品单列表页面显示的数据字段列表（生产次品单）
  static List<InfoFormModel> mesCheckRecordListInfoFormList = [
    InfoFormModel(keyName: 'OrderCode', title: '任务单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'TaskCode', title: '派工单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'InvName', title: '产品名称',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'InvStd', title: '产品规格',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'disabledQty', title: '次品数量', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Emploee', title: '生产员工', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'ProductDate', title: '生产日期', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'CreateDate', title: '记录日期', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DepName', title: '生产车间', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'TeamName', title: '生产班次', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'LineName', title: '生产产线', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OpName', title: '工序名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'SerialNumber', title: '序\u00A0\u00A0列\u00A0\u00A0号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'SoCode', title: '销售单号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号', width: 320, groupType: 1),
    //InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine22', title: '@单据体.自定义项1',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine23', title: '@单据体.自定义项2',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine24', title: '@单据体.自定义项3',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine25', title: '@单据体.自定义项4',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine26', title: '@单据体.自定义项5',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine27', title: '@单据体.自定义项6',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine28', title: '@单据体.自定义项7',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine29', title: '@单据体.自定义项8',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine30', title: '@单据体.自定义项9',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine31', title: '@单据体.自定义项10',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine32', title: '@单据体.自定义项11',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine33', title: '@单据体.自定义项12',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine34', title: '@单据体.自定义项13',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine35', title: '@单据体.自定义项14',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine36', title: '@单据体.自定义项15',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine37', title: '@单据体.自定义项16',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 1, isShow: true),
  ];

  ///注塑设备详情页面显示的注塑派工单列表的数据字段列表（注塑派工单）
  static List<InfoFormModel> pMesTaskListInfoFormList = [
    InfoFormModel(keyName: 'TaskCode', title: '派工单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'TaskDate', title: '派工日期', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvStd', title: '产品规格', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'MouldCode', title: '模具编号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PackingQty', title: '标准装箱数', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderCode', title: '任务单号', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'MouldName', title: '模具名称', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'DeviceCode', title: '机器编号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'DeviceName', title: '机器名称', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'DepName', title: '生产车间', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'PackingType', title: '包装规格', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'AssignQty', title: '派工数量',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'QualifiedQty', title: '已生产数', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'submitQty', title: '已报产数', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'disabledQty', title: '次品数量', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'StockQty', title: '入库数量',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'StartDate', title: '实际开工',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'DueStartDate', title: '预计开工',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'SoCode', title: '销售单号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'GDCode', title: '生产单号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine22', title: '@单据体.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine23', title: '@单据体.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine24', title: '@单据体.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine25', title: '@单据体.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine26', title: '@单据体.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine27', title: '@单据体.自定义项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine28', title: '@单据体.自定义项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine29', title: '@单据体.自定义项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine30', title: '@单据体.自定义项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine31', title: '@单据体.自定义项10',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine32', title: '@单据体.自定义项11',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine33', title: '@单据体.自定义项12',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine34', title: '@单据体.自定义项13',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine35', title: '@单据体.自定义项14',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine36', title: '@单据体.自定义项15',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine37', title: '@单据体.自定义项16',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 1, isShow: true),
  ];

  ///注塑设备详情页面显示的当前任务信息的生产数据字段列表（注塑派工单 + 实时监测信息）
  ///
  /// [groupType]：== 0 时，数据源来自 [MoTaskModel]
  ///
  /// [groupType]：== 1 时，数据源来自 [DeviceTaskModel]
  static List<InfoFormModel> pMesDeiceTaskDetailInfoFormList = [
    InfoFormModel(keyName: 'DeviceCode', title: '设备编号',  width: 310, groupType: 1),
    InfoFormModel(keyName: 'DeviceName', title: '设备名称',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderCode', title: '任务单号', width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'TaskCode', title: '派工单号', width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvName', title: '产品名称',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvStd', title: '产品规格',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'MouldCode', title: '模具编号',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'MouldName', title: '模具名称',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PackingType', title: '包装规格',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'AssignQty', title: '任务数量',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OverQty', title: '可超产数',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'FinishQty', title: '已生产数',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'submitQty', title: '已报产数',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'disabledQty', title: '次品数量',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'StockQty', title: '入库数量',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'CycleTime', title: '标准周期',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'DesignOutput', title: '标准模穴',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'TaskDate', title: '派工日期',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'StartDate', title: '实际开工',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DueStartDate', title: '预计开工',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'SoCode', title: '销售单号',  width: 310, groupType: 0),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号',  width: 310, groupType: 0),
    InfoFormModel(keyName: 'GDCode', title: '生产订单号',  width: 310, groupType: 0),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine22', title: '@单据体.自定义项1',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine23', title: '@单据体.自定义项2',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine24', title: '@单据体.自定义项3',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine25', title: '@单据体.自定义项4',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine26', title: '@单据体.自定义项5',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine27', title: '@单据体.自定义项6',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine28', title: '@单据体.自定义项7',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine29', title: '@单据体.自定义项8',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine30', title: '@单据体.自定义项9',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine31', title: '@单据体.自定义项10',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine32', title: '@单据体.自定义项11',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine33', title: '@单据体.自定义项12',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine34', title: '@单据体.自定义项13',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine35', title: '@单据体.自定义项14',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine36', title: '@单据体.自定义项15',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine37', title: '@单据体.自定义项16',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 310, groupType: 0, isShow: true),
  ];

  ///注塑派工单报工、报次品页面显示的数据字段列表（注塑派工单 + 实时监测信息 + 产品信息）
  ///
  /// [groupType]：== 0 时，数据源来自 [MoTaskModel]
  ///
  /// [groupType]：== 1 时，数据源来自 [DeviceTaskModel]
  ///
  /// [groupType]：== 2 时，数据源来自 [InventoryModel]
  static List<InfoFormModel> pMesTaskInfoFormList = [
    InfoFormModel(keyName: 'TaskCode', title: '派工单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderCode', title: '任务单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvName', title: '产品名称',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'InvStd', title: '产品规格',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DepName', title: '生产车间',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DeviceCode', title: '设备编号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'DeviceName', title: '设备名称',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'MouldCode', title: '模具编号',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'MouldName', title: '模具名称',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PackingType', title: '包装规格',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PackingQty', title: '标准装箱数',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PackingDescription', title: '装箱说明',  width: 320, groupType: 2, isShow: true),
    InfoFormModel(keyName: 'AssignQty', title: '任务数量',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'FinishQty', title: '已生产数',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OverQty', title: '可超产数',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'submitQty', title: '已报产数',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'RemainingQty', title: '剩余报工数',  width: 320, groupType: 0, isShow: true, isHighlight: true),
    InfoFormModel(keyName: 'disabledQty', title: '次品数量',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'StockQty', title: '入库数量',  width: 320, groupType: 0, isShow: true, isHighlight: true),
    InfoFormModel(keyName: 'UnStockQty', title: '未入库数量',  width: 320, groupType: 0, isShow: true, isHighlight: true),
    InfoFormModel(keyName: 'DesignOutput', title: '标准模穴',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Output', title: '实际模穴',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvWeight', title: '标准单重',  width: 320, groupType: 2, isShow: true),
    InfoFormModel(keyName: 'TaskDate', title: '派工日期',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'StartDate', title: '实际开工',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'DueStartDate', title: '预计开工', width: 320, groupType: 0, isShow: false),
    InfoFormModel(keyName: 'SoCode', title: '销售单号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'GDCode', title: '生产订单号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine22', title: '@单据体.自定义项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine23', title: '@单据体.自定义项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine24', title: '@单据体.自定义项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine25', title: '@单据体.自定义项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine26', title: '@单据体.自定义项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine27', title: '@单据体.自定义项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine28', title: '@单据体.自定义项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine29', title: '@单据体.自定义项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine30', title: '@单据体.自定义项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine31', title: '@单据体.自定义项10',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine32', title: '@单据体.自定义项11',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine33', title: '@单据体.自定义项12',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine34', title: '@单据体.自定义项13',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine35', title: '@单据体.自定义项14',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine36', title: '@单据体.自定义项15',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine37', title: '@单据体.自定义项16',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'ContainerPackingDescription', title: '容器说明',  width: 320, groupType: 0, isShow: true),
  ];

  ///注塑报工单列表页面显示的数据字段列表（注塑报工单）
  static List<InfoFormModel> pMesSubmitListInfoFormList = [
    InfoFormModel(keyName: 'Qty', title: '报产数量', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Weight', title: '报产重量', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Num', title: '装\u00A0\u00A0箱\u00A0\u00A0数', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'BoxQty', title: '单箱数量', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PackingType', title: '包装规格', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'BillDate', title: '生产日期', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'CreateDate', title: '记录日期', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Emploee', title: '生产员工', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DepName', title: '生产车间', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'SoCode', title: '销售单号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'LineName', title: '生产产线', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'TeamName', title: '生产班次', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'TaskCode', title: '派工单号', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderCode', title: '任务单号', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号',  width: 320, groupType: 1),
    InfoFormModel(keyName: 'InvName', title: '产品名称',  width: 320, groupType: 1),
    InfoFormModel(keyName: 'InvStd', title: '产品规格',  width: 320, groupType: 1),
    InfoFormModel(keyName: 'QualifiedQty', title: '合格数量', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'DeviceName', title: '设备名称', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Description', title: '备\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0注', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine22', title: '@单据体.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine23', title: '@单据体.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine24', title: '@单据体.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine25', title: '@单据体.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine26', title: '@单据体.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderDefine27', title: '@单据体.自定义项6',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine28', title: '@单据体.自定义项7',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine29', title: '@单据体.自定义项8',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine30', title: '@单据体.自定义项9',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine31', title: '@单据体.自定义项10',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine32', title: '@单据体.自定义项11',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine33', title: '@单据体.自定义项12',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine34', title: '@单据体.自定义项13',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine35', title: '@单据体.自定义项14',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine36', title: '@单据体.自定义项15',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine37', title: '@单据体.自定义项16',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 1, isShow: true),
  ];

  ///注塑次品单列表页面显示的数据字段列表（注塑次品单）
  static List<InfoFormModel> pMesCheckRecordListInfoFormList = [
    InfoFormModel(keyName: 'OrderCode', title: '任务单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'TaskCode', title: '派工单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'InvName', title: '产品名称',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'InvStd', title: '产品规格',  width: 320, groupType: 0),
    InfoFormModel(keyName: 'disabledQty', title: '次品数量', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'disabledNum', title: '次品重量', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Emploee', title: '生产员工', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'ProductDate', title: '生产日期', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'CreateDate', title: '记录日期', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DepName', title: '生产车间', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'TeamName', title: '生产班次', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'LineName', title: '生产产线', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DeviceName', title: '设备名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'SoCode', title: '销售单号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号', width: 320, groupType: 1),
    //InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine22', title: '@单据体.自定义项1',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine23', title: '@单据体.自定义项2',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine24', title: '@单据体.自定义项3',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine25', title: '@单据体.自定义项4',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine26', title: '@单据体.自定义项5',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine27', title: '@单据体.自定义项6',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine28', title: '@单据体.自定义项7',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine29', title: '@单据体.自定义项8',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine30', title: '@单据体.自定义项9',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine31', title: '@单据体.自定义项10',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine32', title: '@单据体.自定义项11',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine33', title: '@单据体.自定义项12',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine34', title: '@单据体.自定义项13',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine35', title: '@单据体.自定义项14',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine36', title: '@单据体.自定义项15',  width: 320, groupType: 1, isShow: true),
    //InfoFormModel(keyName: 'OrderDefine37', title: '@单据体.自定义项16',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 1, isShow: true),
  ];

  ///报工条码列表页面显示的数据字段列表（报工条码）
  static List<InfoFormModel> submitBarcodeListInfoFormList = [
    InfoFormModel(keyName: 'InvCode', title: '产品编号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvName', title: '产品名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvStd', title: '产品规格', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'preCode', title: '报工单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'BillCode', title: '流水依据号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Batch', title: '批次号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'quantity', title: '本箱数量', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'ProductDate', title: '报工日期', width: 320, groupType: 0, isShow: true),
  ];

  ///物料条码新增查看首页-产品单据
  static List<InfoFormModel> invBarcodeInvListInfoFormList = [
    InfoFormModel(keyName: 'InvCode', title: '产品编码', width: 320, groupType: 0),
    InfoFormModel(keyName: 'InvName', title: '产品名称', width: 320, groupType: 0),
    InfoFormModel(keyName: 'InvStd', title: '产品规格', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCCode', title: '类别编码', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCName', title: '类别名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'CurrentStock', title: '当前库存', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'PackingType', title: '装箱容器', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'PackingQty', title: '标准装箱数', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'PackingDescription', title: '装箱说明', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvWhCode', title: '仓库编码', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvWhName', title: '仓库名称', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDepCode', title: '车间编码', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDepName', title: '车间名称', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'PositionCode', title: '货位编码', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'PositionName', title: '货位名称', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'BomCode', title: 'Bom编码', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'BomName', title: 'Bom名称', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Module', title: '所属模块', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine11', title: '@存货.自定义项11',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine12', title: '@存货.自定义项12',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine13', title: '@存货.自定义项13',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine14', title: '@存货.自定义项14',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine15', title: '@存货.自定义项15',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine16', title: '@存货.自定义项16',  width: 320, groupType: 1, isShow: true),
  ];

  ///物料条码新增页面-产品单据
  static List<InfoFormModel> invBarcodeInvFormInfoFormList = [
    InfoFormModel(keyName: 'InvCode', title: '产品编码', width: 320, groupType: 0),
    InfoFormModel(keyName: 'InvName', title: '产品名称', width: 320, groupType: 0),
    InfoFormModel(keyName: 'InvStd', title: '产品规格', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCCode', title: '类别编码', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCName', title: '类别名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'CurrentStock', title: '当前库存', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PackingType', title: '装箱容器', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PackingQty', title: '标准装箱数', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PackingDescription', title: '装箱说明', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvWhCode', title: '仓库编码', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvWhName', title: '仓库名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDepCode', title: '车间编码', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDepName', title: '车间名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PositionCode', title: '货位编码', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PositionName', title: '货位名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'BomCode', title: 'Bom编码', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'BomName', title: 'Bom名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Module', title: '所属模块', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine11', title: '@存货.自定义项11',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine12', title: '@存货.自定义项12',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine13', title: '@存货.自定义项13',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine14', title: '@存货.自定义项14',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine15', title: '@存货.自定义项15',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine16', title: '@存货.自定义项16',  width: 320, groupType: 0, isShow: true),
  ];

  ///物料条码列表页面显示的数据字段列表（物料条码）
  static List<InfoFormModel> invBarcodeListInfoFormList = [
    InfoFormModel(keyName: 'InvCode', title: '产品编号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvName', title: '产品名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvStd', title: '产品规格', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Batch', title: '批次号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'quantity', title: '本箱数量', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'ProductDate', title: '提交日期', width: 320, groupType: 0, isShow: true),
  ];

  ///生产 设备对应生产任务单 设备详情页面显示的工序计划明细单据列表的数据字段列表（工序计划明细单据）
  static List<InfoFormModel> mesWBEntryListInfoFormList = [
    InfoFormModel(keyName: 'moCode', title: '任务单号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OpCode', title: '工序编号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OpName', title: '工序名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'sequ', title: '工序顺序号', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OpDescription', title: '工序说明', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'BillDate', title: '单据日期', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvName', title: '产品名称', width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvStd', title: '产品规格', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'DepName', title: '生产车间', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Qty', title: '工序任务数',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'QualifiedQty', title: '工序已生产数', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'SubmitQty', title: '工序报工数', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'disabledQty', title: '工序次品数', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'acceptQty', title: '工序合格数', width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'StockQty', title: '任务入库数',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'DueStartDate', title: '预计开工',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'StartDate', title: '实际开工',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'SoCode', title: '销售单号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号', width: 320, groupType: 1),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine11', title: '@存货.自定义项11',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine12', title: '@存货.自定义项12',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine13', title: '@存货.自定义项13',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine14', title: '@存货.自定义项14',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine15', title: '@存货.自定义项15',  width: 320, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'InvDefine16', title: '@存货.自定义项16',  width: 320, groupType: 1, isShow: true),
  ];

  ///生产 设备对应生产任务单 设备详情页面显示的数据字段列表（生产任务单 + 设备实时生产数据）
  ///
  /// [groupType]：== 0 时，数据源来自 [MoOpOrderModel]
  ///
  /// [groupType]：== 1 时，数据源来自 [MoDeviceWorkBillList]
  static List<InfoFormModel> mesDeiceOrderDetailInfoFormList = [
    InfoFormModel(keyName: 'DeviceCode', title: '设备编号',  width: 310, groupType: 1),
    InfoFormModel(keyName: 'DeviceName', title: '设备名称',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'BillCode', title: '任务单号', width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvName', title: '产品名称',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvStd', title: '产品规格',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OpCode', title: '工序编号',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpName', title: '工序名称',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'sequ', title: '工序顺序号',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpDescription', title: '工序说明',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpQty', title: '工序任务数',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpSubmitQty', title: '工序报工数',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'UnOpSubmitQty', title: '剩余工序报工数',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpDisabledQty', title: '工序次品数',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpAcceptQty', title: '工序检验数',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OpQualifiedQty', title: '工序已生产数',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'Qty', title: '任务数量',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'ProductQty', title: '已生产数',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'QualifiedQty', title: '已质检数',  width: 320, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'SubmitQty', title: '报工数量',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'RemainingQty', title: '剩余报工数',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'disabledQty', title: '次品数量',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'StockQty', title: '入库数量',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'UnStockQty', title: '未入库数',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PackingType', title: '包装规格',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'StartDate', title: '实际开工',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'DueStartDate', title: '预计开工',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'SoCode', title: '销售单号',  width: 310, groupType: 0),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号',  width: 310, groupType: 0),
    InfoFormModel(keyName: 'OrderCode', title: '生产订单号',  width: 310, groupType: 0),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define22', title: '@单据体.自定义项1',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define23', title: '@单据体.自定义项2',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define24', title: '@单据体.自定义项3',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define25', title: '@单据体.自定义项4',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define26', title: '@单据体.自定义项5',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define27', title: '@单据体.自定义项6',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define28', title: '@单据体.自定义项7',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define29', title: '@单据体.自定义项8',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define30', title: '@单据体.自定义项9',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define31', title: '@单据体.自定义项10',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define32', title: '@单据体.自定义项11',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define33', title: '@单据体.自定义项12',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define34', title: '@单据体.自定义项13',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define35', title: '@单据体.自定义项14',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define36', title: '@单据体.自定义项15',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Define37', title: '@单据体.自定义项16',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine11', title: '@存货.自定义项11',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine12', title: '@存货.自定义项12',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine13', title: '@存货.自定义项13',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine14', title: '@存货.自定义项14',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine15', title: '@存货.自定义项15',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine16', title: '@存货.自定义项16',  width: 310, groupType: 0, isShow: true),
  ];

  ///生产 设备对应生产派工单 设备详情页面显示的数据字段列表（生产派工单 + 设备数据）
  ///
  /// [groupType]：== 0 时，数据源来自 [MoTaskModel]
  ///
  /// [groupType]：== 1 时，数据源来自 [EAMDeviceModel]
  static List<InfoFormModel> mesDeiceTaskDetailInfoFormList = [
    InfoFormModel(keyName: 'DeviceCode', title: '设备编号',  width: 310, groupType: 1),
    InfoFormModel(keyName: 'DeviceName', title: '设备名称',  width: 310, groupType: 1, isShow: true),
    InfoFormModel(keyName: 'OrderCode', title: '任务单号', width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'TaskCode', title: '派工单号', width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvCode', title: '产品编号',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvName', title: '产品名称',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvStd', title: '产品规格',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OpCode', title: '工序编号',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OpName', title: '工序名称',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OpWorkDescription', title: '工艺说明',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OpDescription', title: '派工描述',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'PackingType', title: '包装规格',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'AssignQty', title: '任务数量',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OverQty', title: '可超产数',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'FinishQty', title: '已生产数',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'submitQty', title: '已报产数',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'disabledQty', title: '次品数量',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'StockQty', title: '入库数量',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'TaskDate', title: '派工日期',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'StartDate', title: '实际开工',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'DueStartDate', title: '预计开工',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'SoCode', title: '销售单号',  width: 310, groupType: 0),
    InfoFormModel(keyName: 'MtoNo', title: '需求跟踪号',  width: 310, groupType: 0),
    InfoFormModel(keyName: 'GDCode', title: '生产订单号',  width: 310, groupType: 0),
    InfoFormModel(keyName: 'Free1', title: '@存货.自由项1',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free2', title: '@存货.自由项2',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free3', title: '@存货.自由项3',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free4', title: '@存货.自由项4',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free5', title: '@存货.自由项5',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free6', title: '@存货.自由项6',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free7', title: '@存货.自由项7',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free8', title: '@存货.自由项8',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free9', title: '@存货.自由项9',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'Free10', title: '@存货.自由项10',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine22', title: '@单据体.自定义项1',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine23', title: '@单据体.自定义项2',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine24', title: '@单据体.自定义项3',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine25', title: '@单据体.自定义项4',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine26', title: '@单据体.自定义项5',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine27', title: '@单据体.自定义项6',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine28', title: '@单据体.自定义项7',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine29', title: '@单据体.自定义项8',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine30', title: '@单据体.自定义项9',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine31', title: '@单据体.自定义项10',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine32', title: '@单据体.自定义项11',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine33', title: '@单据体.自定义项12',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine34', title: '@单据体.自定义项13',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine35', title: '@单据体.自定义项14',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine36', title: '@单据体.自定义项15',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'OrderDefine37', title: '@单据体.自定义项16',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine1', title: '@存货.自定义项1',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine2', title: '@存货.自定义项2',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine3', title: '@存货.自定义项3',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine4', title: '@存货.自定义项4',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine5', title: '@存货.自定义项5',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine6', title: '@存货.自定义项6',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine7', title: '@存货.自定义项7',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine8', title: '@存货.自定义项8',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine9', title: '@存货.自定义项9',  width: 310, groupType: 0, isShow: true),
    InfoFormModel(keyName: 'InvDefine10', title: '@存货.自定义项10',  width: 310, groupType: 0, isShow: true),
  ];
  //endregion

  //region 按钮组
  ///生产任务单
  static const String mesOrderBtn = 'mesOrderBtn';
  ///生产派工单
  static const String mesTaskBtn = 'mesTaskBtn';
  ///生产报工单
  static const String mesSubmitBtn = 'mesSubmitBtn';
  ///生产次品记录
  static const String mesCheckRecordBtn = 'mesCheckRecordBtn';
  ///设备概览 设备详情
  static const String pMesDeviceDetailBtn = 'pMesDeviceDetailBtn';
  ///机台报工单
  static const String pMesSubmitBtn = 'pMesSubmitBtn';
  ///机台次品记录
  static const String pMesCheckRecordBtn = 'pMesCheckRecordBtn';
  ///物料条码
  static const String invBarcodeBtn = 'invBarcodeBtn';
  ///物料条码列表
  static const String invBarcodeListBtn = 'invBarcodeListBtn';
  ///全场呼叫列表
  static const String andonListBtn = 'andonListBtn';
  ///生产 设备对应生产任务单 设备详情页
  static const String MesDeviceOrderDetailBtn = 'MesDeviceOrderDetailBtn';
  ///生产 设备对应生产派工单 设备详情页
  static const String MesDeviceTaskDetailBtn = 'MesDeviceTaskDetailBtn';

  ///产品附件
  static const String invAttach = 'invAttach';
  ///产品图片
  static const String invImage = 'invImage';
  ///工序图纸
  static const String opSop = 'opSop';
  ///上料验证
  static const String verificationLoaded = 'verificationLoaded';
  ///生成首检报检单
  static const String createFirstInspection = 'createFirstInspection';
  ///生成巡检报检单
  static const String createPatrolInspection = 'createPatrolInspection';
  ///生成首检检验单
  static const String createFirstCheckVoucher = 'createFirstCheckVoucher';
  ///生成巡检检验单
  static const String createPatrolCheckVoucher = 'createPatrolCheckVoucher';
  ///设置完工
  static const String setFinish = 'setFinish';
  ///切单（开工）
  static const String shiftTask = 'shiftTask';
  ///对调
  static const String swapTask = 'swapTask';
  ///挂起
  static const String suspendTask = 'suspendTask';
  ///详情
  static const String detail = 'detail';
  ///展开
  static const String expanded = 'expanded';
  ///条码打印
  static const String print = 'print';
  ///检验
  static const String check = 'check';
  ///删除
  static const String delete = 'delete';
  ///打印装箱单
  static const String printPacking = 'printPacking';
  ///全选
  static const String selectAll = 'selectAll';
  ///全不选
  static const String deSelectAll = 'deSelectAll';
  ///下一步
  static const String nextStep = 'nextStep';
  ///全场呼叫
  static const String setAndon = 'setAndon';
  ///取消呼叫
  static const String cancelAndon = 'cancelAndon';
  ///派工
  static const String toTask = 'toTask';
  ///超产处理
  static const String setOverQty = 'setOverQty';

  ///生产任务单列表页面显示的按钮组
  static List<CommandBarBtnModel> mesOrderCommandBarList = [
    CommandBarBtnModel(
      title: '产品图片',
      keyName: '$mesOrderBtn-$invImage',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.text,
      isShow: true,
    ),
    CommandBarBtnModel(
      title: '上料验证',
      keyName: '$mesOrderBtn-$verificationLoaded',
      bkgdColorValue: 'secondary',
      commandBarBtnType: CommandBarBtnType.filled,
      isShow: true,
    ),
    CommandBarBtnModel(
      title: '首检报检',
      keyName: '$mesOrderBtn-$createFirstInspection',
      bkgdColorValue: 'secondary',
      commandBarBtnType: CommandBarBtnType.filled,
      isShow: true,
      btnPermissionKeyName: 'btnCreateFirstInspection',
    ),
    CommandBarBtnModel(
      title: '\u00A0\u00A0\u00A0\u00A0派工\u00A0\u00A0\u00A0\u00A0',
      keyName: '$mesOrderBtn-$toTask',
      bkgdColorValue: 'secondary',
      commandBarBtnType: CommandBarBtnType.filled,
      isShow: true,
      btnPermissionKeyName: 'btntask',
    ),
    CommandBarBtnModel(
      title: '设置完工',
      keyName: '$mesOrderBtn-$setFinish',
      bkgdColorValue: 'secondary',
      commandBarBtnType: CommandBarBtnType.filled,
      isShow: true,
      btnPermissionKeyName: 'btnSetFinish',
    ),
    CommandBarBtnModel(
      title: '\u00A0\u00A0\u00A0\u00A0开工\u00A0\u00A0\u00A0\u00A0',
      keyName: '$mesOrderBtn-$shiftTask',
      bkgdColorValue: 'primary',
      commandBarBtnType: CommandBarBtnType.filled,
      isShow: true,
      btnPermissionKeyName: 'btnshifttask',
    ),
    CommandBarBtnModel(
      title: '\u00A0\u00A0\u00A0\u00A0挂起\u00A0\u00A0\u00A0\u00A0',
      keyName: '$mesOrderBtn-$suspendTask',
      bkgdColorValue: 'primaryContainer',
      commandBarBtnType: CommandBarBtnType.filled,
      isShow: true,
      btnPermissionKeyName: 'btnsuspend',
    ),
    CommandBarBtnModel(
      title: '\u00A0\u00A0\u00A0\u00A0详情\u00A0\u00A0\u00A0\u00A0',
      keyName: '$mesOrderBtn-$detail',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.outlined,
      isShow: true,
    ),
    CommandBarBtnModel(
      title: '\u00A0\u00A0\u00A0\u00A0展开\u00A0\u00A0\u00A0\u00A0',
      keyName: '$mesOrderBtn-$expanded',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.outlined,
      isShow: true,
    ),
  ];

  ///生产派工单列表页面显示的按钮组
  static List<CommandBarBtnModel> mesTaskCommandBarList = [
    CommandBarBtnModel(
      title: '工序图纸',
      keyName: '$mesTaskBtn-$opSop',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.text,
      isShow: true,
    ),
    CommandBarBtnModel(
      title: '设置完工',
      keyName: '$mesTaskBtn-$setFinish',
      bkgdColorValue: 'secondary',
      commandBarBtnType: CommandBarBtnType.filled,
      isShow: true,
      btnPermissionKeyName: 'btnSetFinish',
    ),
    CommandBarBtnModel( ///切单并生成首检报检单
      title: '\u00A0\u00A0\u00A0\u00A0开工\u00A0\u00A0\u00A0\u00A0',
      keyName: '$mesTaskBtn-$shiftTask',
      bkgdColorValue: 'primary',
      commandBarBtnType: CommandBarBtnType.filled,
      isShow: true,
      btnPermissionKeyName: 'btnshifttask',
    ),
    CommandBarBtnModel(
      title: '\u00A0\u00A0\u00A0\u00A0挂起\u00A0\u00A0\u00A0\u00A0',
      keyName: '$mesTaskBtn-$suspendTask',
      bkgdColorValue: 'primaryContainer',
      commandBarBtnType: CommandBarBtnType.filled,
      isShow: true,
      btnPermissionKeyName: 'btnsuspend',
    ),
    CommandBarBtnModel(
      title: '\u00A0\u00A0\u00A0\u00A0详情\u00A0\u00A0\u00A0\u00A0',
      keyName: '$mesTaskBtn-$detail',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.outlined,
      isShow: true,
    ),
    CommandBarBtnModel(
      title: '\u00A0\u00A0\u00A0\u00A0展开\u00A0\u00A0\u00A0\u00A0',
      keyName: '$mesTaskBtn-$expanded',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.outlined,
      isShow: true,
    ),
  ];

  ///生产报工单列表页面显示的按钮组
  static List<CommandBarBtnModel> mesSubmitListCommandBarList = [
    CommandBarBtnModel(
      title: '条码打印',
      icon: Icons.local_print_shop_rounded,
      keyName: '$mesSubmitBtn-$print',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'print',
    ),
    CommandBarBtnModel(
      title: '删除',
      icon: FluentIcons.delete_24_filled,
      keyName: '$mesSubmitBtn-$delete',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btndelete',
    ),
  ];

  ///生产次品单列表页面显示的按钮组
  static List<CommandBarBtnModel> mesCheckRecordListCommandBarList = [
    CommandBarBtnModel(
      title: '条码打印',
      icon: Icons.local_print_shop_rounded,
      keyName: '$mesCheckRecordBtn-$print',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'print',
    ),
    CommandBarBtnModel(
      title: '删除',
      icon: FluentIcons.delete_24_filled,
      keyName: '$mesCheckRecordBtn-$delete',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btndelete',
    ),
  ];

  ///机台报工单列表页面显示的按钮组
  static List<CommandBarBtnModel> pMesSubmitListCommandBarList = [
    CommandBarBtnModel(
      title: '条码打印',
      icon: Icons.local_print_shop_rounded,
      keyName: '$pMesSubmitBtn-$print',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'print',
    ),
    CommandBarBtnModel(
      title: '删除',
      icon: FluentIcons.delete_24_filled,
      keyName: '$pMesSubmitBtn-$delete',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btndelete',
    ),
  ];

  ///机台次品单列表页面显示的按钮组
  static List<CommandBarBtnModel> pMesCheckRecordListCommandBarList = [
    CommandBarBtnModel(
      title: '条码打印',
      icon: Icons.local_print_shop_rounded,
      keyName: '$pMesCheckRecordBtn-$print',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'print',
    ),
    CommandBarBtnModel(
      title: '删除',
      icon: FluentIcons.delete_24_filled,
      keyName: '$pMesCheckRecordBtn-$delete',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btndelete',
    ),
  ];

  ///物料条码首页列表页面显示的按钮组
  static List<CommandBarBtnModel> invBarcodeCommandBarList = [
    CommandBarBtnModel(
      title: '\u00A0\u00A0\u00A0\u00A0详情\u00A0\u00A0\u00A0\u00A0',
      keyName: '$invBarcodeBtn-$detail',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.outlined,
      isShow: true,
    ),
    CommandBarBtnModel(
      title: '\u00A0\u00A0\u00A0\u00A0展开\u00A0\u00A0\u00A0\u00A0',
      keyName: '$invBarcodeBtn-$expanded',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.outlined,
      isShow: true,
    ),
  ];

  ///全场呼叫首页列表页面显示的按钮组
  static List<CommandBarBtnModel> andonCommandBarList = [
    CommandBarBtnModel(
      title: '下一步',
      keyName: '$andonListBtn-$nextStep',
      bkgdColorValue: 'secondary',
      commandBarBtnType: CommandBarBtnType.filled,
      isShow: true,
      //btnPermissionKeyName: 'btnSetFinish',
    ),
    CommandBarBtnModel(
      title: '取消呼叫',
      keyName: '$andonListBtn-$cancelAndon',
      bkgdColorValue: 'primaryContainer',
      commandBarBtnType: CommandBarBtnType.filled,
      isShow: true,
      //btnPermissionKeyName: 'btnSetFinish',
    ),
  ];

  ///设备概览-设备详情页面 当前机台正在生产任务的按钮组列表
  static List<CommandBarBtnModel> pMesDeviceDetailTaskCommandBarList = [
    CommandBarBtnModel(
      title: '挂起',
      icon: Icons.hourglass_empty,
      keyName: '$pMesDeviceDetailBtn-$suspendTask',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnhugup',
    ),
    CommandBarBtnModel(
      title: '超产处理',
      icon: Icons.add_task,
      keyName: '$pMesDeviceDetailBtn-$setOverQty',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnSetOverQty',
    ),
    CommandBarBtnModel(
      title: '全场呼叫',
      icon: Icons.perm_phone_msg,
      keyName: '$pMesDeviceDetailBtn-$setAndon',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnAndon',
    ),
    CommandBarBtnModel(
      title: '首检报检',
      icon: Icons.playlist_add,
      keyName: '$pMesDeviceDetailBtn-$createFirstInspection',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnCreateFirstInspection',
    ),
    CommandBarBtnModel(
      title: '巡检报检',
      icon: Icons.playlist_add,
      keyName: '$pMesDeviceDetailBtn-$createPatrolInspection',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnCreatePatrolInspection',
    ),
    CommandBarBtnModel(
      title: '首检',
      icon: Icons.fact_check_rounded,
      keyName: '$pMesDeviceDetailBtn-$createFirstCheckVoucher',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnCreateFirstCheckVoucher',
    ),
    CommandBarBtnModel(
      title: '巡检',
      icon: Icons.fact_check_rounded,
      keyName: '$pMesDeviceDetailBtn-$createPatrolCheckVoucher',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnCreatePatrolCheckVoucher',
    ),
    CommandBarBtnModel(
      title: '产品图片',
      icon: Icons.photo,
      keyName: '$pMesDeviceDetailBtn-$invImage',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
    ),
    CommandBarBtnModel(
      title: '产品附件',
      icon: Icons.picture_as_pdf_outlined,
      keyName: '$pMesDeviceDetailBtn-$invAttach',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
    ),
  ];

  ///设备概览-设备详情页面 派工单列表区域显示的按钮组列表
  static List<CommandBarBtnModel> pMesDeviceTaskListCommandBarList = [
    CommandBarBtnModel(
      title: '切单',
      icon: Icons.change_history,
      keyName: '$pMesDeviceDetailBtn-$shiftTask',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnpass',
    ),
    CommandBarBtnModel(
      title: '对调',
      icon: FluentIcons.arrow_swap_20_filled,
      keyName: '$pMesDeviceDetailBtn-$swapTask',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnswap',
    ),
    CommandBarBtnModel(
      title: '设置完工',
      icon: Icons.assignment_turned_in_outlined,
      keyName: '$pMesDeviceDetailBtn-$setFinish',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnfinish',
    ),
    CommandBarBtnModel(
      title: '打印装箱单',
      icon: Icons.print_outlined,
      keyName: '$pMesDeviceDetailBtn-$printPacking',
      bkgdColorValue: '',
      commandBarBtnType: CommandBarBtnType.commandBar,
      isShow: true,
      btnPermissionKeyName: 'btnPrintPacking',
    ),
  ];

  //endregion

  //region 报工方式（物料条码提交方式）
  ///按数量报工
  static const String qtySubmit = 'qtySubmit';
  ///按数量（多箱）报工
  static const String qtyBoxSubmit = 'qtyBoxSubmit';
  ///按托报工
  static const String palletSubmit = 'palletSubmit';
  ///按重量报工
  static const String weightSubmit = 'weightSubmit';
  ///按重量（多箱）报工
  static const String weightBoxSubmit = 'weightBoxSubmit';
  ///按重量报工（生产用，实际上是“按数量报工”，总重保存在总数）
  static const String mesWeightSubmit = 'mesWeightSubmit';
  ///按重量（多箱）报工（生产用，实际上是“按数量（多箱）报工”，总重保存在总数）
  static const String mesWeightBoxSubmit = 'mesWeightBoxSubmit';
  ///报单重
  static const String weight = 'weight';
  ///序列号报工
  static const String serialNumberSubmit = 'serialNumberSubmit';
  ///单箱序列号报工
  static const String singleBoxSerialNumberSubmit = 'singleBoxSerialNumberSubmit';

  ///生产任务单-报工方式列表
  static List<ChoiceChipModel> mesOrderSubmitOperationWayList = [
    ChoiceChipModel(title: '按数量报工', keyName: AppConfig.qtySubmit),
    ChoiceChipModel(title: '按数量(多箱)报工', keyName: AppConfig.qtyBoxSubmit),
    ChoiceChipModel(title: '按重量报工', keyName: AppConfig.mesWeightSubmit),
    ChoiceChipModel(title: '按重量(多箱)报工', keyName: AppConfig.mesWeightBoxSubmit),
    ChoiceChipModel(title: '按托报工', keyName: AppConfig.palletSubmit),
    ChoiceChipModel(title: '按序列号报工', keyName: AppConfig.serialNumberSubmit),
    ChoiceChipModel(title: '按单箱序列号报工', keyName: AppConfig.singleBoxSerialNumberSubmit),
  ];

  ///生产派工单-报工方式列表
  static List<ChoiceChipModel> mesTaskSubmitOperationWayList = [
    ChoiceChipModel(title: '按数量报工', keyName: AppConfig.qtySubmit),
    ChoiceChipModel(title: '按数量(多箱)报工', keyName: AppConfig.qtyBoxSubmit),
    ChoiceChipModel(title: '按托报工', keyName: AppConfig.palletSubmit),
    ChoiceChipModel(title: '按单箱序列号报工', keyName: AppConfig.singleBoxSerialNumberSubmit),
  ];

  ///注塑派工单-报工方式列表
  static List<ChoiceChipModel> pMesTaskSubmitOperationWayList = [
    ChoiceChipModel(title: '按数量报工', keyName: AppConfig.qtySubmit),
    ChoiceChipModel(title: '按数量(多箱)报工', keyName: AppConfig.qtyBoxSubmit),
    ChoiceChipModel(title: '按托报工', keyName: AppConfig.palletSubmit),
    ChoiceChipModel(title: '按重量报工', keyName: AppConfig.weightSubmit),
    ChoiceChipModel(title: '按重量(多箱)报工', keyName: AppConfig.weightBoxSubmit),
    ChoiceChipModel(title: '报单重', keyName: AppConfig.weight),
  ];

  ///物料条码-填报方式列表
  static List<ChoiceChipModel> invBarcodeOperationWayList = [
    ChoiceChipModel(title: '按数量填报', keyName: AppConfig.qtySubmit),
    ChoiceChipModel(title: '按数量(多箱)填报', keyName: AppConfig.qtyBoxSubmit),
    ChoiceChipModel(title: '按托填报', keyName: AppConfig.palletSubmit),
    ChoiceChipModel(title: '按重量填报', keyName: AppConfig.weightSubmit),
    ChoiceChipModel(title: '按重量(多箱)填报', keyName: AppConfig.weightBoxSubmit),
  ];
  //endregion

  //region 报次品方式
  ///按数量报次品
  static const String qtyCheckRecord = 'qtyCheckRecord';
  ///按重量报次品
  static const String weightCheckRecord = 'weightCheckRecord';
  ///序列号报次品
  static const String serialNumberCheckRecord = 'serialNumberCheckRecord';

  ///生产任务单-次品录入方式列表
  static List<ChoiceChipModel> mesOrderCROperationWayList = [
    ChoiceChipModel(title: '按数量报次品', keyName: AppConfig.qtyCheckRecord),
    ChoiceChipModel(title: '按序列号报次品', keyName: AppConfig.serialNumberCheckRecord),
  ];

  ///生产派工单-次品录入方式列表
  static List<ChoiceChipModel> mesTaskCROperationWayList = [
    ChoiceChipModel(title: '按数量报次品', keyName: AppConfig.qtyCheckRecord),
  ];

  ///注塑派工单-次品录入方式列表
  static List<ChoiceChipModel> pMesTaskCROperationWayList = [
    ChoiceChipModel(title: '按数量报次品', keyName: AppConfig.qtyCheckRecord),
    ChoiceChipModel(title: '按重量报次品', keyName: AppConfig.weightCheckRecord),
  ];
  //endregion

  //region 不良品上报填报方式
  ///按数量上报不良品
  static const String qtyMaterialReject = 'qtyMaterialReject';
  ///按重量报次品上报不良品
  static const String weightMaterialReject = 'weightMaterialReject';
  ///序列号报次品上报不良品
  static const String serialNumberMaterialReject = 'serialNumberMaterialReject';

  ///生产任务单-不良品上报填报方式列表
  static List<ChoiceChipModel> mesOrderMROperationWayList = [
    ChoiceChipModel(title: '按数量上报', keyName: AppConfig.qtyMaterialReject),
  ];

  ///生产派工单-不良品上报填报方式列表
  static List<ChoiceChipModel> mesTaskMROperationWayList = [
    ChoiceChipModel(title: '按数量上报', keyName: AppConfig.qtyMaterialReject),
  ];

  ///注塑派工单-不良品上报填报方式列表
  static List<ChoiceChipModel> pMesTaskMROperationWayList = [
    ChoiceChipModel(title: '按数量上报', keyName: AppConfig.qtyMaterialReject),
    ChoiceChipModel(title: '按重量上报', keyName: AppConfig.weightMaterialReject),
  ];
  //endregion

  //region 表单填报项的标题名称
  ///报工记录的生产日期
  static const String billDateForm = 'billDateForm';
  static const String depForm = 'depForm';
  static const String teamForm = 'teamForm';
  static const String workCenterForm = 'workCenterForm';
  static const String lineForm = 'lineForm';
  static const String teamGroupForm = 'teamGroupForm';
  static const String deviceForm = 'deviceForm';
  static const String personForm = 'personForm';
  static const String processForm = 'processForm';
  static const String orderSNForm = 'orderSNForm';
  ///次品录入的生产日期
  static const String productDateForm = 'productDateForm';
  static const String reProcessForm = 'reProcessForm';
  static const String comDefectForm = 'comDefectForm';
  ///物料清单明细（材料明细）材料 Id
  static const String bomEntryInvForm = 'bomEntryInvForm';

  static const String isHighlight = 'isHighlight';

  ///注塑派工单报工-表单填报项的标题名称 Map
  static Map<String, String> pMesSubmitFormTitleMap = {
    billDateForm: '生产日期',
    depForm: '生产车间',
    teamForm: '生产班次',
    lineForm: '生产产线',
    workCenterForm: '加工中心',
    teamGroupForm: '生产班组',
    personForm: '生产人员',
    NumPadUtil.eBWeight: '称重重量',
    NumPadUtil.eBPiece: '称重件数',
    NumPadUtil.pieceWeight: '实际单重',
    NumPadUtil.packingWeight: '单箱皮重',
    NumPadUtil.num: '整箱箱数',
    NumPadUtil.singleBoxQty: '单箱数量',
    NumPadUtil.lastBoxQty: '尾箱数量',
    NumPadUtil.singleBoxWeight: '单箱重量',
    NumPadUtil.lastBoxWeight: '尾箱重量',
    NumPadUtil.boxNumOfPallet: '单托箱数',
    NumPadUtil.qty: '报工总数',
    NumPadUtil.weight: '报工总重',
    NumPadUtil.boxWeight: '箱重',
  };
  static Map<String, Map<String, dynamic>> pMesSubmitFormStyleMap = {
    NumPadUtil.singleBoxQty: { ///单箱数量
      isHighlight: true, ///是否突出显示（红色加粗）
    },
  };

  ///注塑派工单报次品-表单填报项的标题名称 Map
  static Map<String, String> pMesCheckRecordFormTitleMap = {
    productDateForm: '生产日期',
    depForm: '生产车间',
    teamForm: '生产班次',
    lineForm: '生产产线',
    workCenterForm: '加工中心',
    teamGroupForm: '生产班组',
    personForm: '生产人员',
    comDefectForm: '次品原因',
    NumPadUtil.qty: '次品数量',
    NumPadUtil.weight: '次品总重',
  };
  static Map<String, Map<String, dynamic>> pMesCheckRecordFormStyleMap = {};

  ///注塑派工单不良品上报-表单填报项的标题名称 Map
  static Map<String, String> pMesMaterialRejectFormTitleMap = {
    productDateForm: '上报日期',
    depForm: '上报车间',
    teamForm: '上报班次',
    personForm: '上报人员',
    bomEntryInvForm: '不良材料',
    comDefectForm: '不良原因',
    NumPadUtil.qty: '不良数量',
  };
  static Map<String, Map<String, dynamic>> pMesMaterialRejectFormStyleMap = {};

  ///生产任务单报工-表单填报项的标题名称 Map
  static Map<String, String> mesOrderSubmitFormTitleMap = {
    billDateForm: '生产日期',
    depForm: '生产车间',
    teamForm: '生产班次',
    lineForm: '生产产线',
    workCenterForm: '加工中心',
    teamGroupForm: '生产班组',
    deviceForm: '生产设备',
    personForm: '生产人员',
    processForm: '生产工序',
    orderSNForm: '序列号',
    NumPadUtil.packingWeight: '单箱皮重',
    NumPadUtil.num: '整箱箱数',
    NumPadUtil.singleBoxQty: '单箱数量',
    NumPadUtil.lastBoxQty: '尾箱数量',
    NumPadUtil.singleBoxWeight: '单箱重量',
    NumPadUtil.lastBoxWeight: '尾箱重量',
    NumPadUtil.boxNumOfPallet: '单托箱数',
    NumPadUtil.qty: '报工总数',
    NumPadUtil.weight: '报工总重',
    NumPadUtil.boxWeight: '箱重',
  };
  static Map<String, Map<String, dynamic>> mesOrderSubmitFormStyleMap = {};

  ///生产任务单报次品-表单填报项的标题名称 Map
  static Map<String, String> mesOrderCheckRecordFormTitleMap = {
    productDateForm: '生产日期',
    depForm: '生产车间',
    teamForm: '生产班次',
    lineForm: '生产产线',
    workCenterForm: '加工中心',
    teamGroupForm: '生产班组',
    deviceForm: '生产设备',
    personForm: '生产人员',
    processForm: '生产工序',
    reProcessForm: '返修工序',
    orderSNForm: '序列号',
    comDefectForm: '次品原因',
    NumPadUtil.qty: '次品数量',
  };
  static Map<String, Map<String, dynamic>> mesOrderCheckRecordFormStyleMap = {};

  ///生产任务单不良品上报-表单填报项的标题名称 Map
  static Map<String, String> mesOrderMaterialRejectFormTitleMap = {
    productDateForm: '上报日期',
    depForm: '上报车间',
    teamForm: '上报班次',
    personForm: '上报人员',
    bomEntryInvForm: '不良材料',
    comDefectForm: '不良原因',
    NumPadUtil.qty: '不良数量',
  };
  static Map<String, Map<String, dynamic>> mesOrderMaterialRejectFormStyleMap = {};

  ///生产派工单报工-表单填报项的标题名称 Map
  static Map<String, String> mesTaskSubmitFormTitleMap = {
    NumPadUtil.eBWeight: '称重重量',
    NumPadUtil.eBPiece: '称重件数',
    NumPadUtil.pieceWeight: '实际单重',
    billDateForm: '生产日期',
    depForm: '生产车间',
    teamForm: '生产班次',
    lineForm: '生产产线',
    workCenterForm: '加工中心',
    teamGroupForm: '生产班组',
    deviceForm: '生产设备',
    personForm: '生产人员',
    NumPadUtil.num: '整箱箱数',
    NumPadUtil.singleBoxQty: '单箱数量',
    NumPadUtil.lastBoxQty: '尾箱数量',
    NumPadUtil.boxNumOfPallet: '单托箱数',
    NumPadUtil.qty: '报工总数',
    NumPadUtil.weight: '报工总重',
    NumPadUtil.boxWeight: '箱重',
  };
  static Map<String, Map<String, dynamic>> mesTaskSubmitFormStyleMap = {};

  ///生产派工单报次品-表单填报项的标题名称 Map
  static Map<String, String> mesTaskCheckRecordFormTitleMap = {
    productDateForm: '生产日期',
    depForm: '生产车间',
    teamForm: '生产班次',
    lineForm: '生产产线',
    workCenterForm: '加工中心',
    teamGroupForm: '生产班组',
    deviceForm: '生产设备',
    personForm: '生产人员',
    reProcessForm: '返修工序',
    comDefectForm: '次品原因',
    NumPadUtil.qty: '次品数量',
  };
  static Map<String, Map<String, dynamic>> mesTaskCheckRecordFormStyleMap = {};

  ///生产派工单不良品上报-表单填报项的标题名称 Map
  static Map<String, String> mesTaskMaterialRejectFormTitleMap = {
    productDateForm: '上报日期',
    depForm: '上报车间',
    teamForm: '上报班次',
    personForm: '上报人员',
    bomEntryInvForm: '不良材料',
    comDefectForm: '不良原因',
    NumPadUtil.qty: '不良数量',
  };
  static Map<String, Map<String, dynamic>> mesTaskMaterialRejectFormStyleMap = {};

  ///物料条码新增页面-表单填报项的标题名称 Map
  static Map<String, String> invBarcodeFormFormTitleMap = {
    NumPadUtil.eBWeight: '称重重量',
    NumPadUtil.eBPiece: '称重件数',
    NumPadUtil.pieceWeight: '实际单重',
    //NumPadUtil.packingWeight: '单箱皮重',
    NumPadUtil.num: '整箱箱数',
    NumPadUtil.singleBoxQty: '单箱数量',
    NumPadUtil.lastBoxQty: '尾箱数量',
    NumPadUtil.singleBoxWeight: '单箱重量',
    NumPadUtil.lastBoxWeight: '尾箱重量',
    NumPadUtil.boxNumOfPallet: '单托箱数',
    NumPadUtil.qty: '报工总数',
    NumPadUtil.weight: '报工总重',
    //NumPadUtil.boxWeight: '箱重',
  };
  static Map<String, Map<String, dynamic>> invBarcodeFormFormStyleMap = {};
  //endregion

  //region 次品处理方式
  ///次品处理方式列表
  static List<ChoiceChipModel> disposeFlowList = [
    ChoiceChipModel(title: '报废', keyName: 'dis', sign: 1),
    ChoiceChipModel(title: '返修', keyName: 're', sign: 7),
  ];
  //endregion

  //region 报工页面的提交按钮
  ///报工页面显示的按钮列表
  static List<ChoiceChipModel> submitBtnList = [
    ChoiceChipModel(title: '报工提交', sign: 1),
    ChoiceChipModel(title: '提交并打印', sign: 2),
  ];

  ///报工页面显示的按钮的 sign index
  static const int submitBtnIndex = 3;
  //endregion

  //region 次品录入页面的提交按钮
  ///次品录入页面显示的按钮列表
  static List<ChoiceChipModel> checkRecordBtnList = [
    ChoiceChipModel(title: '次品提交', sign: 1),
    ChoiceChipModel(title: '提交并打印', sign: 2),
  ];

  ///次品录入页面显示的按钮的 sign index
  static const int checkRecordBtnIndex = 3;
  //endregion

  //region 不良品上报页面的提交按钮
  ///不良品上报页面显示的按钮列表
  static List<ChoiceChipModel> materialRejectBtnList = [
    ChoiceChipModel(title: '不良品上报', sign: 1),
    ChoiceChipModel(title: '提交并打印', sign: 2),
  ];

  ///不良品上报页面显示的按钮的 sign index
  static const int materialRejectBtnIndex = 3;
  //endregion

  //region 物料条码提交页面的提交按钮
  ///物料条码提交页面显示的按钮列表
  static List<ChoiceChipModel> invBarcodeSaveBtnList = [
    ChoiceChipModel(title: '条码提交', sign: 1),
    ChoiceChipModel(title: '提交并打印', sign: 2),
  ];

  ///物料条码提交页面显示的按钮的 sign index
  static const int invBarcodeSaveBtnIndex = 3;
  //endregion

  ///刷新 是否可以定时刷新
  static const bool isCanTimedRefresh = true;

  ///刷新 数据刷新频率（时间 秒） 图表、列表
  static const int secondOfRefresh = 300;

  ///按多箱报工时，是否显示称重消息传递过来的单箱重量、预计单箱数量
  static const bool isShowExpectSingleBoxQty = false;

  ///报工 是否需要产品重量检验
  static const bool isNeedPieceWeight = true;

  ///机台报工 如果没有实际单重数据，是否可以根据标准单重计算总重
  static const bool canWeightCalcByStandWeight = true;

  ///机台报工 按重量报工时，产品称重的数据是否加到报工总数据上
  static const bool weightIsAddPieceWeightToTotal = true;

  ///报工 是否显示 ‘获取实际单重’ 的按钮
  static const bool isShowGetPieceWeightBtn = false;

  ///是否显示“补打”按钮
  static const bool isShowMakeUpBtn = false;

  ///是否显示“自检确认”按钮
  static const bool isShowSelfInspectionBtn = false;

  ///是否显示“互检确认”按钮
  static const bool isShowMutualInspectionBtn = false;

  ///报工/次品/物料条码记录提交成功后，是否返回到首页
  static const bool isGetBackAfterCommitSuccess = false;

  ///报工 是否通过选择装箱容器，自动填充皮重、单箱数量
  static const bool isUsePackingPicker = false;
  
  ///是否自动写入实际单重数据
  static const bool isAutoWritePieceWeight = false;

  ///语音播报音量
  static const double flutterTtsVolume = 1;

  ///语音播报语速
  static const double flutterTtsSpeechRate = 0.5;

  ///语音播报音调
  static const double flutterTtsPitch = 1;

  ///是否打开语音播报
  static const bool isOpenFlutterTts = false;

  ///两次循环之间的间隔时间
  static const int timeBetweenCyclesFlutterTts = 300;

  ///每次循环的播报次数
  static const int numOfEachCycleFlutterTts = 3;

  ///超产预警 播报提前时间（秒）
  static const int leadTimeOverProductWarnFlutterTts = 1800;

  ///打印时是否显示参数设置
  static const bool isShowPrintSetting = false;

  ///报工输入框中的默认值
  static const String defaultSubmitQty = '1';

  ///选中的单据状态
  static const int binaryForSignSelected = 3;

  ///选中的单据状态
  static const int selectedSignBinaryNull = 0;

  ///生产人员是否可以多选
  static const bool isPsnMulti = false;

  ///生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间（拌料单只有0、2！）
  static const int psnGetWayIndex = 0;

  ///生产人员获取条件 车间固定值
  static const String psnDepCode = '';

  ///生产人员获取条件 产线固定值
  static const String psnLineCode = '';

  ///车间默认值获取方式 0: 单据车间 1: 登录账号所在车间
  static const int depGetWayIndex = 0;

  ///车间默认值获取方式列表 0: 单据车间  1: 登录人员所在的车间
  static List<ChoiceChipModel> depDefaultValueGetWayList = [
    ChoiceChipModel(title: '单据车间'),
    ChoiceChipModel(title: '登录账号所属车间'),
  ];

  ///产线数据的填报类型：0产线 OR 1加工中心 OR 2生产班组
  static const int wcDataReportType = 0;

  ///产线数据的填报类型列表
  static List<ChoiceChipModel> wcDataReportTypeList = [
    ChoiceChipModel(title: '生产产线', sign: 0),
    ChoiceChipModel(title: '加工中心', sign: 1),
    ChoiceChipModel(title: '生产班组', sign: 2),
  ];

  ///打印方式列表
  static List<ChoiceChipModel> printTypeList = [
  ChoiceChipModel(title: '服务端打印（支持所有平台）', keyName: 'serverPrint'),
  ChoiceChipModel(title: '本地打印（仅支持Windows平台）', keyName: 'localPrint'),
  ];

  ///生产人员获取的条件列表（报工 报次品）
  static List<ChoiceChipModel> psnGetWayList = [
    ChoiceChipModel(title: '取全部（无限制条件）'),
    ChoiceChipModel(title: '以填报的车间为条件'),
    ChoiceChipModel(title: '以固定车间为条件'),
    ChoiceChipModel(title: '以填报的产线为条件'),
    ChoiceChipModel(title: '以固定产线为条件'),
  ];

  ///生产人员获取的条件列表（不良品上报）
  static List<ChoiceChipModel> psnGetWayListForMR = [
    ChoiceChipModel(title: '取全部（无限制条件）'),
    ChoiceChipModel(title: '以填报的车间为条件'),
    ChoiceChipModel(title: '以固定车间为条件'),
    ChoiceChipModel(title: '以派工单/任务单的产线为条件'),
    ChoiceChipModel(title: '以固定产线为条件'),
  ];

  ///主题列表
  static List<ChoiceChipModel> themeList = [
    ChoiceChipModel(title: '跟随系统', keyName: 'system'),
    ChoiceChipModel(title: '明亮', keyName: 'light'),
    ChoiceChipModel(title: '深黑', keyName: 'dark'),
  ];
  static List<ChoiceChipModel> tipsShowTypeList = [
    ChoiceChipModel(title: '弹窗', keyName: 'dialog'),
    ChoiceChipModel(title: '顶部推送通知', keyName: 'toast'),
  ];

  ///是否显示工序说明
  static const bool isShowOpDescription = false;

  ///是否显示报工汇总（工序班组日期）
  static const bool isShowOpTgSubmitQty = false;

  ///是否显示报工/报次品/不良品上报/物料条码填报方式切换按钮
  static const bool isShowDataReportTypeBtn = true;

  ///设备是否可以通过 Adapter 选单
  static const bool isDeviceHasAdapter = true;

  ///生产人员是否可以通过 Adapter 选单
  static const bool isPsnHasAdapter = true;

  ///报工单删除时间限制 1day:86400;  null:无限制
  static const int? limitTime = null;

  ///整箱箱数最大数量限制     null:无限制
  static const int? numMaxCountLimit = null;

  ///单箱数量最大数量限制     null:无限制
  static const double? singleBoxQtyMaxCountLimit = null;

  ///自动获取焦点的输入框字段名
  static const String numPadFocusField = '';

  ///单列可显示的表单填写项的行数     null:无限制
  static const int? formRowMaxCountLimit = null;

  ///tab 标签的宽度
  static const double tabWidth = 340;

  ///是否显示状态选择过滤标签
  static const bool isShowSignFilter = true;

  ///状态标签是否可以多选
  static const bool isSignChipMulti = true;

  ///是否显示单据日期选择器
  static const bool isShowDatePicker = true;

  ///是否显示关键字搜索输入框
  static const bool isShowSearchInputBox = true;

  ///是否显示车间选择器
  static const bool isShowDepPicker = true;

  ///是否显示产线选择器
  static const bool isShowLinePicker = false;

  ///是否显示加工中心选择器
  static const bool isShowWorkCenterPicker = false;

  ///是否显示全场呼叫类型选择器
  static const bool isShowAndonClassPicker = true;

  ///派工单单个项是否默认展开
  static const bool isTaskItemExpanded = false;

  ///默认显示的选项卡
  static const int initialIndex = 0;

  ///报工条码 搜索按钮列表选中的项    0：报工单号搜索      1：派工单号搜索     2: 任务单号搜索
  static const int searchBtnTypeIndex = 0;

  ///打印数据源类型列表 数据源类型选择
  static List<ChoiceChipModel> dataSourceTypeTCList = [
    ChoiceChipModel(title: '派工单', keyName: 'task'),
    ChoiceChipModel(title: '任务单', keyName: 'order'),
  ];

  /// 全场呼叫状态列表 选中的单据状态
  static const int binaryForAndonServiceSignSelected = 1;

  ///详情页面 装箱单打印模板文件名称
  static const String packingPrintFrxName = '机台派工_装箱单.frx';

  ///注塑机台 报工装箱单 打印模板名称
  static const String deviceSubmitPrintFileName = '机台报工单.frx';

  ///注塑机台 次品装箱单 打印模板名称
  static const String deviceCheckRecordPrintFileName = '机台次品记录单.frx';

  ///注塑机台 不良品上报单据 打印模板名称
  static const String deviceMaterialRejectPrintFileName = '机台不良品记录单.frx';

  ///生产任务单 报工装箱单 打印模板名称
  static const String mesOrderSubmitPrintFileName = '生产报工单.frx';

  ///生产任务单 次品装箱单 打印模板名称
  static const String mesOrderCheckRecordPrintFileName = '生产次品单.frx';

  ///生产任务单 不良品上报单据 打印模板名称
  static const String mesOrderMaterialRejectPrintFileName = '生产不良品记录单.frx';

  ///生产派工单 报工装箱单 打印模板名称
  static const String mesTaskSubmitPrintFileName = '生产报工单.frx';

  ///物料条码 标签 物料条码单据 打印模板名称
  static const String invBarcodePrintFileName = '物料条码标签.frx';

  ///生产派工单 次品装箱单 打印模板名称
  static const String mesTaskCheckRecordPrintFileName = '生产次品记录单.frx';

  ///生产派工单 不良品上报单据 打印模板名称
  static const String mesTaskMaterialRejectPrintFileName = '生产不良品记录单.frx';

  ///拌料单 报工 打印模板名称
  static const String moMixtureSubmitPrintFileName = '拌料单标签.frx';

  ///拌料单 报工 打印模板名称
  static const String moPowderSubmitPrintFileName = '粉料单标签.frx';

  ///发料单 报工 打印模板名称
  static const String moIssuancePrintFileName = '发料标签.frx';


  ///质量巡检 选中的单据的检验状态
  static const int qualityInspectionSignSelectedIndex = 0;

  ///质量巡检 选中的单据的检验类型
  static const int qualityInspectionCategorySelectedIndex = 1;

  ///质量巡检 前台显示的检验类型列表
  static const int showCategory = 63;

  ///质量巡检 - 派工单选择（新增自定义的检验单） 搜索按钮列表选中的项     0：产品图号搜索      1：产品编号搜索     2：产品名称搜索      3：派工编号搜索      4：员工编号搜索
  static const int qualityInspectionMoTaskSearchBtnTypeIndex = 0;

  ///质量巡检-类型列表
  static List<ChoiceChipModel> qualityInspectionCategoryList = [
    ChoiceChipModel(title: '来料检验', sign: 1),
    ChoiceChipModel(title: '首检', sign: 2),
    ChoiceChipModel(title: '巡检', sign: 4),
    ChoiceChipModel(title: '末检', sign: 8),
    ChoiceChipModel(title: '完检', sign: 16),
    ChoiceChipModel(title: '自检', sign: 32),
  ];

  static List<ChoiceChipModel> mesWorkCenterCategoryList = [
    ChoiceChipModel(title: '任务单', sign: 1),
    ChoiceChipModel(title: '派工单', sign: 2),
  ];


  ///质量巡检 质量巡检单据的搜索方式列表
  static List<ChoiceChipModel> qualityInspectionSearchTypeList = [
    ChoiceChipModel(title: '工程图号搜索', keyName: 'engineerFigNo'),
  ];

  ///派工单生成首检检验单
  static const String firstCheckVoucher = 'firstCheckVoucher';
  ///派工单生成巡检检验单
  static const String checkVoucher = 'checkVoucher';
  ///派工单生成末检检验单
  static const String theLastCheckVoucher = 'theLastCheckVoucher';

  ///派工单生成检验单：firstCheckVoucher 2首检检验单；checkVoucher 4巡检检验单；theLastCheckVoucher 8末检检验单
  static const String taskToCheckVoucherType = 'firstCheckVoucher';

  ///当报工方式是“按托报工”时，填写“单箱数量”时的计算方式
  static List<ChoiceChipModel> calcRuleForPalletSubmitTypeList = [
    ChoiceChipModel(title: '填写“单箱数量”时，计算“单托箱数”、“尾箱数量”', sign: 0),
    ChoiceChipModel(title: '填写“单箱数量”时，计算“报工总数量”', sign: 1),
  ];

  ///当报工方式是“按托报工”时，填写“单箱数量”时的计算方式
  ///
  ///0：填写“单箱数量”时，计算“单托箱数”、“尾箱数量”
  ///
  ///1：填写“单箱数量”时，计算“报工总数量”
  static const int calcRuleForPalletSubmitType = 0;

  ///当报工方式是“按序列号报工”时，是否显示“自动提交”按钮
  static const bool isShowAutoCommitBtn = true;

  ///扫描序列号并写入数据后，自动提交报工数据（按序列号报工时使用）
  static const bool autoCommitSubmit = false;

  ///是否显示“需要检验”按钮
  static const bool isShowInspectFlagBtn = false;

  ///“需要检验”按钮是否可以点击
  static const bool isCanClickInspectFlagBtn = true;

  ///“需要检验”按钮的选中状态的默认值
  ///
  /// [Null]：该默认值不起作用，取派工单/工序的值；[True]：默认强制选中；[False]：默认强制不选中；
  static const bool? inspectFlagDefaultValue = null;

  ///是否保存上次报工时选中的员工
  static const bool isSaveTheLastSelectedPsnId = false;

  ///“单箱数量”是否只能通过选择装箱容器来赋值，而不是手动输入
  static const bool isSingleBoxQtyOnlyChangedByContainer = false;

  ///是否保存上次报工时填写的皮重、单箱数量数据（或选择的装箱容器数据）
  static const bool isSaveTheLastPackingWeightData = false;

  ///是否显示总重称重数据的
  static const bool isShowWeightOverlay = false;

  ///是否保存上一次报工时填写的报工总数
  static const bool isSaveTheLastQtyData = false;

  static const double limitWeightDeviationValue = 20;

  ///次品列表-次品单据类型（次品记录 OR 材料不良记录）
  static const int checkRecordDocumentTypeIndex = 0;

  ///任务说明-必须符合全部条件（No：符合其中一个条件即可）
  static const bool isAllConditionMustBeMet = false;

  ///dio 网络检查器 消息队列显示 是否启用过滤
  static const bool dioLogIsFilter = false;
  ///dio 网络检查器 消息队列显示 当前显示的请求方法类型
  static const String dioLogMethod = 'all';

  ///程序日志视图显示 是否启用过滤
  static const bool loggerIsFilter = false;
  ///程序日志视图显示 当前显示的日志的级别
  static const String loggerLevel = 'all';

  ///是否需要监测网络连接状态
  static const bool isNeedCheckNetwork = true;

  ///电子秤（称重重量）
  static const String dSEBWeight = 'device-submit-eBWeight';
  ///电子秤（报单重的称重重量）
  static const String dSEBWeightForWeightSubmitType = 'device-submit-eBWeight-for-weightSubmitType';
  ///电子秤（单箱皮重）
  static const String dSPackingWeight = 'device-submit-packingWeight';
  ///电子秤（单箱重量）
  static const String dSSingleBoxWeight = 'device-submit-singleBoxWeight';
  ///电子秤（尾箱重量）
  static const String dSLastBoxWeight = 'device-submit-lastBoxWeight';
  ///电子秤（报工总重）
  static const String dSWeight = 'device-submit-weight';
  ///扫码枪
  static const String scanGun = 'scan-gun';
  ///读卡器
  static const String cardReader = 'card-reader';
  ///序列号
  static const String serialNumberScan = 'serialNumber-scan';

  static final List<ChoiceChipModel> socketDataList = [
    ChoiceChipModel(keyName: dSEBWeight, title: '电子秤（称重重量）'),
    ChoiceChipModel(keyName: dSEBWeightForWeightSubmitType, title: '电子秤（报单重的称重重量）'),
    ChoiceChipModel(keyName: dSPackingWeight, title: '电子秤（单箱皮重）'),
    ChoiceChipModel(keyName: dSSingleBoxWeight, title: '电子秤（单箱重量）'),
    ChoiceChipModel(keyName: dSLastBoxWeight, title: '电子秤（尾箱重量）'),
    ChoiceChipModel(keyName: dSWeight, title: '电子秤（报工总重）'),
    ChoiceChipModel(keyName: scanGun, title: '扫码枪'),
    ChoiceChipModel(keyName: cardReader, title: '读卡器'),
    ChoiceChipModel(keyName: serialNumberScan, title: '序列号（报工）'),
  ];

}

class AppConfigUtil {

  String getMoPowderAppConfig(int progId, String appConfigKey){
    String key = '';
    switch (progId){
      case 651071:
        //region 拌料单
        key = appConfigKey;
        //endregion
        break;
      case 651076:
        //region 粉料单
        switch (appConfigKey){
          case AppConfig.moMixtureSubmitPrintFileName:
            key = AppConfig.moPowderSubmitPrintFileName;
            break;
        }
        //endregion
        break;
    }
    return key;
  }

}