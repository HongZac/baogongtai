
abstract class AppRoutes {
  static const ROOT = RoutePath.ROOT;

  static const LOGIN_PAGE = RoutePath.LOGIN;
  static const LOGIN_MAIN_PAGE =  RoutePath.LOGIN + RoutePath.MAIN;
  static const LOGIN_SETTING_PAGE = RoutePath.LOGIN + RoutePath.MAIN + RoutePath.SETTING;  //登录窗体上服务器参数设置

  static const HOME_PAGE = RoutePath.HOME;
  static const EMPTY_PAGE = RoutePath.HOME + RoutePath.EMPTY;

  //region 实时监测
  ///实时监测 首页
  static const PMES_REAL_TIME_MONITOR_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR;
  ///实时监测 设置页面
  static const PMES_REAL_TIME_MONITOR_SETTING_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.SETTING;
  ///实时监测 单个设备的技术指导书
  static const PMES_REAL_TIME_MONITOR_ATTACH_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.ATTACH;

  ///实时监测 设备详情 路由页
  static const PMES_REAL_TIME_MONITOR_DETAIL_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.DETAIL;
  ///实时监测 设备详情 主页面
  static const PMES_REAL_TIME_MONITOR_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.DETAIL + RoutePath.MAIN;
  ///实时监测 设备详情 设置页面
  static const PMES_REAL_TIME_MONITOR_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  ///实时监测 设备详情 附件页面
  static const PMES_REAL_TIME_MONITOR_DETAIL_ATTACH_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.ATTACH;
  ///实时监测 设备详情 首巡检页面 路由页
  static const PMES_REAL_TIME_MONITOR_DETAIL_IPQC_QUALITY_INSPECTION_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.IPQC_QUALITY_INSPECTION;
  ///实时监测 设备详情 首巡检页面 主页面
  static const PMES_REAL_TIME_MONITOR_DETAIL_IPQC_QUALITY_INSPECTION_MAIN_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.MAIN;
  ///实时监测 设备详情 首巡检页面 设置页面
  static const PMES_REAL_TIME_MONITOR_DETAIL_IPQC_QUALITY_INSPECTION_SETTING_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.MAIN + RoutePath.SETTING;
  ///实时监测 设备详情 首巡检页面 附件页面
  static const PMES_REAL_TIME_MONITOR_DETAIL_IPQC_QUALITY_INSPECTION_ATTACH_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.MAIN + RoutePath.ATTACH;

  ///实时监测 报工页面 路由页
  static const PMES_REAL_TIME_MONITOR_SUBMIT_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.SUBMIT;
  ///实时监测 报工页面 主页面
  static const PMES_REAL_TIME_MONITOR_SUBMIT_MAIN_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.SUBMIT + RoutePath.MAIN;
  ///实时监测 报工页面 设置页面
  static const PMES_REAL_TIME_MONITOR_SUBMIT_SETTING_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.SUBMIT + RoutePath.MAIN + RoutePath.SETTING;
  ///实时监测 报次品页面 路由页
  static const PMES_REAL_TIME_MONITOR_CHECK_RECORD_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.CHECK_RECORD;
  ///实时监测 报次品页面 主页面
  static const PMES_REAL_TIME_MONITOR_CHECK_RECORD_MAIN_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.CHECK_RECORD + RoutePath.MAIN;
  ///实时监测 报次品页面 设置页面
  static const PMES_REAL_TIME_MONITOR_CHECK_RECORD_SETTING_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.CHECK_RECORD + RoutePath.MAIN + RoutePath.SETTING;
  ///实时监测 材料不良上报页面 路由页
  static const PMES_REAL_TIME_MONITOR_MATERIAL_REJECT_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.MATERIAL_REJECT;
  ///实时监测 材料不良上报页面 主页面
  static const PMES_REAL_TIME_MONITOR_MATERIAL_REJECT_MAIN_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.MATERIAL_REJECT + RoutePath.MAIN;
  ///实时监测 材料不良上报页面 设置页面
  static const PMES_REAL_TIME_MONITOR_MATERIAL_REJECT_SETTING_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.MATERIAL_REJECT + RoutePath.MAIN + RoutePath.SETTING;
  ///实时监测 报工单列表页面 路由页
  static const PMES_REAL_TIME_MONITOR_SUBMIT_LIST_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.SUBMIT_LIST;
  ///实时监测 报工单列表页面 主页面
  static const PMES_REAL_TIME_MONITOR_SUBMIT_LIST_MAIN_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.SUBMIT_LIST + RoutePath.MAIN;
  ///实时监测 报工单列表页面 附件页面
  static const PMES_REAL_TIME_MONITOR_SUBMIT_LIST_ATTACH_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.SUBMIT_LIST + RoutePath.MAIN + RoutePath.ATTACH;
  ///实时监测 次品列表页面
  static const PMES_REAL_TIME_MONITOR_CHECK_RECORD_LIST_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.CHECK_RECORD_LIST;

  ///实时监测 异常报告 路由页
  static const DEVICE_EXCEPTION_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.EXCEPTION;
  ///实时监测 异常报告 主页面
  static const DEVICE_EXCEPTION_MAIN_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.EXCEPTION + RoutePath.MAIN;

  ///实时监测 全场呼叫 路由页
  static const DEVICE_ANDON_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.DEVICE_ANDON;
  ///实时监测 全场呼叫 主页面
  static const DEVICE_ANDON_MAIN_PAGE = RoutePath.HOME + RoutePath.PMES_REAL_TIME_MONITOR + RoutePath.DEVICE_ANDON + RoutePath.MAIN;
  //endregion

  //region MES_DEVICE_TASK
  static const MES_DEVICE_TASK_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_TASK;
  static const MES_DEVICE_TASK_SETTING_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_TASK + RoutePath.SETTING;
  static const MES_DEVICE_TASK_ATTACH_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_TASK + RoutePath.ATTACH;
  static const MES_DEVICE_TASK_DETAIL_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_TASK + RoutePath.DETAIL;
  static const MES_DEVICE_TASK_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_TASK + RoutePath.DETAIL + RoutePath.MAIN;
  static const MES_DEVICE_TASK_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_TASK + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  static const MES_DEVICE_TASK_DETAIL_ATTACH_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_TASK + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.ATTACH;
  //endregion

  //region MES_DEVICE_ORDER
  static const MES_DEVICE_ORDER_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_ORDER;
  static const MES_DEVICE_ORDER_SETTING_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_ORDER + RoutePath.SETTING;
  static const MES_DEVICE_ORDER_ATTACH_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_ORDER + RoutePath.ATTACH;
  static const MES_DEVICE_ORDER_DETAIL_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_ORDER + RoutePath.DETAIL;
  static const MES_DEVICE_ORDER_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_ORDER + RoutePath.DETAIL + RoutePath.MAIN;
  static const MES_DEVICE_ORDER_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_ORDER + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  static const MES_DEVICE_ORDER_DETAIL_ATTACH_PAGE = RoutePath.HOME + RoutePath.MES_DEVICE_ORDER + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.ATTACH;
  //endregion

  //region MES_WORK_CENTER
  static const MES_WORK_CENTER_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT;
  static const MES_WORK_CENTER_SETTING_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT + RoutePath.SETTING;
  static const MES_WORK_CENTER_ATTACH_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT + RoutePath.ATTACH;
  static const MES_WORK_CENTER_ALLOCATE_DETAIL_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT + RoutePath.ALLOCATE_DETAIL;
  static const MES_WORK_CENTER_ALLOCATE_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT + RoutePath.ALLOCATE_DETAIL + RoutePath.MAIN;
  static const MES_WORK_CENTER_ORDER_DETAIL_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT + RoutePath.ORDER_DETAIL;
  static const MES_WORK_CENTER_ORDER_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT + RoutePath.ORDER_DETAIL + RoutePath.MAIN;
  static const MES_WORK_CENTER_ORDER_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT + RoutePath.ORDER_DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  static const MES_WORK_CENTER_ORDER_DETAIL_ATTACH_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT + RoutePath.ORDER_DETAIL + RoutePath.MAIN + RoutePath.ATTACH;
  static const MES_WORK_CENTER_TASK_DETAIL_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT + RoutePath.TASK_DETAIL;
  static const MES_WORK_CENTER_TASK_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT + RoutePath.TASK_DETAIL + RoutePath.MAIN;
  static const MES_WORK_CENTER_TASK_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT + RoutePath.TASK_DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  static const MES_WORK_CENTER_TASK_DETAIL_ATTACH_PAGE = RoutePath.HOME + RoutePath.MES_WORK_CENTER_SUBMIT + RoutePath.TASK_DETAIL + RoutePath.MAIN + RoutePath.ATTACH;
  //endregion

  //region MES_ORDER
  static const MES_ORDER_PAGE = RoutePath.HOME + RoutePath.MES_ORDER;
  static const MES_ORDER_ITEM_ATTACH_PAGE = RoutePath.HOME + RoutePath.MES_ORDER + RoutePath.ATTACH;
  static const MES_ORDER_SETTING_PAGE = RoutePath.HOME + RoutePath.MES_ORDER + RoutePath.SETTING;
  static const MES_ORDER_DETAIL_PAGE = RoutePath.HOME + RoutePath.MES_ORDER + RoutePath.DETAIL;
  static const MES_ORDER_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.MES_ORDER + RoutePath.DETAIL + RoutePath.MAIN;
  static const MES_ORDER_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.MES_ORDER + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  static const MES_ORDER_DETAIL_ATTACH_PAGE = RoutePath.HOME + RoutePath.MES_ORDER + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.ATTACH;
  //endregion

  //region MES_TASK
  static const MES_TASK_PAGE = RoutePath.HOME + RoutePath.MES_TASK;
  static const MES_TASK_ITEM_ATTACH_PAGE = RoutePath.HOME + RoutePath.MES_TASK + RoutePath.ATTACH;
  static const MES_TASK_SETTING_PAGE = RoutePath.HOME + RoutePath.MES_TASK + RoutePath.SETTING;
  static const MES_TASK_DETAIL_PAGE = RoutePath.HOME + RoutePath.MES_TASK + RoutePath.DETAIL;
  static const MES_TASK_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.MES_TASK + RoutePath.DETAIL + RoutePath.MAIN;
  static const MES_TASK_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.MES_TASK + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  static const MES_TASK_DETAIL_ATTACH_PAGE = RoutePath.HOME + RoutePath.MES_TASK + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.ATTACH;
  //endregion

  //region 全场呼叫
  static const ANDON_PAGE = RoutePath.HOME + RoutePath.ANDON; //安灯系统-全场呼叫
  static const ANDON_ITEM_ATTACH_PAGE = RoutePath.HOME + RoutePath.ANDON + RoutePath.ATTACH;
  static const ANDON_SETTING_PAGE = RoutePath.HOME + RoutePath.ANDON + RoutePath.SETTING;
  //endregion

  //region 系统消息
  static const MESSAGE_PAGE = RoutePath.HOME + RoutePath.MESSAGE; //系统消息
  static const MESSAGE_DETAIL_PAGE = RoutePath.HOME + RoutePath.MESSAGE + RoutePath.DETAIL; //系统消息详细列表页面
  static const MESSAGE_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.MESSAGE + RoutePath.DETAIL + RoutePath.MAIN; //系统消息详细列表页面
  //endregion

  //region SUBMIT_BARCODE
  ///报工条码 首页
  static const SUBMIT_BARCODE_PAGE  = RoutePath.HOME + RoutePath.SUBMIT_BARCODE;
  //endregion

  //region 拌料单
  static const MO_MIXTURE_PAGE = RoutePath.HOME + RoutePath.MO_MIXTURE;
  static const MO_MIXTURE_DETAIL_PAGE = RoutePath.HOME + RoutePath.MO_MIXTURE + RoutePath.DETAIL;
  static const MO_MIXTURE_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.MO_MIXTURE + RoutePath.DETAIL + RoutePath.MAIN;
  static const MO_MIXTURE_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.MO_MIXTURE + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  //endregion

  //region 粉料单
  static const MO_POWDER_PAGE = RoutePath.HOME + RoutePath.MO_POWDER;
  static const MO_POWDER_DETAIL_PAGE = RoutePath.HOME + RoutePath.MO_POWDER + RoutePath.DETAIL;
  static const MO_POWDER_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.MO_POWDER + RoutePath.DETAIL + RoutePath.MAIN;
  static const MO_POWDER_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.MO_POWDER + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  //endregion

  //region 发料单
  static const MO_ISSUANCE_PAGE = RoutePath.HOME + RoutePath.MO_ISSUANCE;
  static const MO_ISSUANCE_DETAIL_PAGE = RoutePath.HOME + RoutePath.MO_ISSUANCE + RoutePath.DETAIL;
  static const MO_ISSUANCE_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.MO_ISSUANCE + RoutePath.DETAIL + RoutePath.MAIN;
  static const MO_ISSUANCE_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.MO_ISSUANCE + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  //endregion

  //region 模具档案
  static const MOULD_PAGE = RoutePath.HOME + RoutePath.MOULD;
  static const MOULD_ATTACH_PAGE = RoutePath.HOME + RoutePath.MOULD + RoutePath.ATTACH;
  //endregion

  //region 质量巡检
  ///质量巡检 首页
  static const IPQC_QUALITY_INSPECTION_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION;
  ///质量巡检 首页设置
  static const IPQC_QUALITY_INSPECTION_SETTING_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.SETTING;
  ///质量巡检 Item的附件页面
  static const IPQC_QUALITY_INSPECTION_ATTACH_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.ATTACH;
  ///质量巡检 检验单详情
  static const IPQC_QUALITY_INSPECTION_DETAIL_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.DETAIL;
  ///质量巡检 检验单详情 主页面
  static const IPQC_QUALITY_INSPECTION_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.DETAIL + RoutePath.MAIN;
  ///质量巡检 检验单详情 设置页面
  static const IPQC_QUALITY_INSPECTION_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  ///质量巡检 检验单详情 附件页面
  static const IPQC_QUALITY_INSPECTION_DETAIL_ATTACH_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.ATTACH;
  ///质量巡检 终检检验单详情
  static const IPQC_QUALITY_INSPECTION_FINAL_INSPECTION_DETAIL_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.FINAL_INSPECTION_DETAIL;
  ///质量巡检 终检检验单详情 主页面
  static const IPQC_QUALITY_INSPECTION_FINAL_INSPECTION_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.FINAL_INSPECTION_DETAIL + RoutePath.MAIN;
  ///质量巡检 终检检验单详情 设置页面
  static const IPQC_QUALITY_INSPECTION_FINAL_INSPECTION_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.FINAL_INSPECTION_DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  ///质量巡检 终检检验单详情 附件页面
  static const IPQC_QUALITY_INSPECTION_FINAL_INSPECTION_DETAIL_ATTACH_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.FINAL_INSPECTION_DETAIL + RoutePath.MAIN + RoutePath.ATTACH;
  ///质量巡检 来料检验单详情
  static const IPQC_QUALITY_INSPECTION_QM_INSPECTION_DETAIL_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.QM_INSPECTION_DETAIL;
  ///质量巡检 来料检验单详情 主页面
  static const IPQC_QUALITY_INSPECTION_QM_INSPECTION_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.QM_INSPECTION_DETAIL + RoutePath.MAIN;
  ///质量巡检 来料检验单详情 设置页面
  static const IPQC_QUALITY_INSPECTION_QM_INSPECTION_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.QM_INSPECTION_DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  ///质量巡检 来料检验单详情 附件页面
  static const IPQC_QUALITY_INSPECTION_QM_INSPECTION_DETAIL_ATTACH_PAGE = RoutePath.HOME + RoutePath.IPQC_QUALITY_INSPECTION + RoutePath.QM_INSPECTION_DETAIL + RoutePath.MAIN + RoutePath.ATTACH;
  //endregion

  //region 产线
  static const BELT_LINE_PAGE = RoutePath.HOME + RoutePath.BELT_LINE;
  static const BELT_LINE_DETAIL_PAGE = RoutePath.HOME + RoutePath.BELT_LINE + RoutePath.DETAIL;
  static const BELT_LINE_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.BELT_LINE + RoutePath.DETAIL + RoutePath.MAIN;
  //endregion

  //region 班组
  static const TEAM_GROUP_PAGE = RoutePath.HOME + RoutePath.TEAM_GROUP;
  static const TEAM_GROUP_DETAIL_PAGE = RoutePath.HOME + RoutePath.TEAM_GROUP + RoutePath.DETAIL;
  static const TEAM_GROUP_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.TEAM_GROUP + RoutePath.DETAIL + RoutePath.MAIN;
  //endregion

  //region 加工中心
  static const WORK_CENTER_PAGE = RoutePath.HOME + RoutePath.WORK_CENTER;
  static const WORK_CENTER_DETAIL_PAGE = RoutePath.HOME + RoutePath.WORK_CENTER + RoutePath.DETAIL;
  static const WORK_CENTER_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.WORK_CENTER + RoutePath.DETAIL + RoutePath.MAIN;
  //static const WORK_CENTER_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.WORK_CENTER + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  //static const WORK_CENTER_DETAIL_ATTACH_PAGE = RoutePath.HOME + RoutePath.WORK_CENTER + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.ATTACH;
  //endregion

  //region 物料条码新增查看
  static const INV_BARCODE_PAGE = RoutePath.HOME + RoutePath.INV_BARCODE;
  static const INV_BARCODE_ITEM_ATTACH_PAGE = RoutePath.HOME + RoutePath.INV_BARCODE + RoutePath.ATTACH;
  static const INV_BARCODE_SETTING_PAGE = RoutePath.HOME + RoutePath.INV_BARCODE + RoutePath.SETTING;
  static const INV_BARCODE_DETAIL_PAGE = RoutePath.HOME + RoutePath.INV_BARCODE + RoutePath.DETAIL;
  static const INV_BARCODE_DETAIL_MAIN_PAGE = RoutePath.HOME + RoutePath.INV_BARCODE + RoutePath.DETAIL + RoutePath.MAIN;
  static const INV_BARCODE_DETAIL_SETTING_PAGE = RoutePath.HOME + RoutePath.INV_BARCODE + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.SETTING;
  static const INV_BARCODE_DETAIL_ATTACH_PAGE = RoutePath.HOME + RoutePath.INV_BARCODE + RoutePath.DETAIL + RoutePath.MAIN + RoutePath.ATTACH;
  //endregion

  ///远程云消息
  static const CLOUD_SERVICE_TASK_PAGE = RoutePath.HOME + RoutePath.CLOUD_SERVICE_TASK;

  static const SETTING = RoutePath.HOME + RoutePath.SETTING; //全局设置页面

}

abstract class RoutePath {
  static const ROOT = '/';
  static const LOGIN = '/Login';
  static const HOME = '/Home';
  static const MAIN = '/Main';
  static const DETAIL = '/Detail';
  static const SUBMIT = '/Submit';
  static const CHECK_RECORD = '/CheckRecord';
  static const MATERIAL_REJECT = '/MaterialReject';
  static const SUBMIT_LIST = '/SubmitList';
  static const CHECK_RECORD_LIST = '/CheckRecordList';
  static const SETTING ='/Setting';
  static const ATTACH = '/Attach';
  static const PDF_SCREEN = '/PDFScreen';
  static const EMPTY = '/Empty';

  ///实时监测
  static const PMES_REAL_TIME_MONITOR = '/PMesRealTimeMonitor';
  ///异常报告
  static const EXCEPTION = '/ExceptionReport';
  ///全场呼叫
  static const DEVICE_ANDON = '/DeviceAndon';
  ///设备对应生产派工单
  static const MES_DEVICE_TASK = '/MesDeviceTask';
  ///设备对应生产任务单
  static const MES_DEVICE_ORDER = '/MesDeviceOrder';
  //region 加工中心报工
  ///加工中心报工
  static const MES_WORK_CENTER_SUBMIT = '/MesWorkCenterSubmit';
  static const ORDER_DETAIL = '/OrderDetail';
  static const TASK_DETAIL = '/TaskDetail';
  static const ALLOCATE_DETAIL = '/AllocateDetail';
  //endregion
  ///生产任务单
  static const MES_ORDER = '/MesOrder';
  ///派工单报工页
  static const MES_TASK  = '/MesTask';
  ///货位看板
  static const POSITION_TRACK = '/PositionTrack';
  ///系统消息
  static const MESSAGE ="/Message";
  ///安灯系统-全场呼叫
  static const ANDON = "/Andon";
  ///报工条码
  static const SUBMIT_BARCODE = '/SubmitBarcode';
  ///拌料单
  static const MO_MIXTURE = '/MoMixture';
  ///粉料单
  static const MO_POWDER = '/MoPowder';
  ///发料单
  static const MO_ISSUANCE = '/MoIssuance';
  ///模具档案
  static const MOULD = '/Mould';
  ///加工中心
  static const WORK_CENTER = '/WorkCenter';
  ///产线
  static const BELT_LINE = '/BeltLine';
  ///班组
  static const TEAM_GROUP = '/TeamGroup';

  //region IPQC 质量巡检
  static const IPQC_QUALITY_INSPECTION = '/IpqcQualityInspection';
  static const FINAL_INSPECTION_DETAIL = '/FinalInspectionDetail';
  static const QM_INSPECTION_DETAIL = '/QMInspectionDetail';
  //endregion

  ///物料条码新增查看
  static const INV_BARCODE = '/InvBarcode';

  ///远程云消息
  static const CLOUD_SERVICE_TASK = '/CloudServiceTask';

}
