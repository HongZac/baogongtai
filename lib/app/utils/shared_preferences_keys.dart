
///统一定义SharedPreferences 中的关键字
abstract class SharedPreferencesKeys{

  /// 软件名称 String（存储在个人本地存储中）
  static const SOFTWARE_NAME_KEY = 'software-name-key';

  ///首页初始页面的key值（存储在个人本地存储中）
  static const DEFAULT_DESTINATION_KEY = 'default-destination-key';
  ///导航栏是否展开 bool
  static const HOME_IS_NAVIGATION_RAIL_EXTENDED_KEY = 'home-is-navigation-rail-extended-key';

  ///是否保存密码 bool
  static const RESERVEPWD_KEY = "reservepassword";
  ///登录的账号 String
  static const USER_NAME_KEY = "user-name";
  ///密码 String
  static const PW_KEY = "user-pw";

  ///应用程序是否需要定时重启 bool
  static const IS_NEED_TIMED_RESTART_KEY = 'is-need-timed-restart-key';
  ///应用程序是否是通过重启打开的 bool
  static const IS_OPEN_BY_RESTART_KEY = 'is-open-by-restart-key';
  ///应用程序定时重启的天数 int
  static const DAY_OF_APP_RESTART_KEY = 'day-of-app-restart-key';
  ///应用程序定时重启的时间 String
  static const DATE_TIME_OF_APP_RESTART_KEY = 'date-time-of-app-restart-key';

  ///是否需要监测网络连接状态
  static const IS_NEED_CHECK_NETWORK_KEY = 'is-need-check-network-key';

  ///websocket 监听是否可以打开（存储在个人本地存储中） bool
  static const IS_WEBSOCKET_ON_LISTEN_KEY = 'is-websocket-on-listen-key';
  ///websocket 定时重连的频率（时间 秒）
  static const SECONDS_OF_WS_RECONNECTION_KEY = 'seconds-of-ws-reconnection-key';

  ///字体大小比例 double
  static const TEXT_SCALE_KEY = 'text-scale-key';
  ///字体样式 String
  static const FONT_FAMILY_KEY = 'font-family-key';
  ///颜色方案 String
  static const MATERIAL3_THEME_BUILDER_KEY = 'material3-theme-builder-key';
  ///浅色方案 String
  static const LIGHT_COLOR_THEME_KEY = 'light-color-theme-key';
  ///深色方案 String
  static const DARK_COLOR_THEME_KEY = 'dark-color-theme-key';
  ///颜色主题（英文） system light dark String
  static const THEME_MODE_KEY = 'theme-mode-key';
  ///颜色主题（中文）跟随系统 明亮 深黑 String
  static const THEME_MODE_NAME_KEY = 'theme-mode-name-key';
  ///语言 String
  static const LOCALE_LANGUAGE_CODE_KEY = 'locale_language-code-key';
  ///语言 String
  static const LOCALE_COUNTRY_CODE_KEY = 'locale_country-code-key';

  ///windows平台下，点击输入框时，是否弹出软键盘
  static const IS_KEYBOARD_OPEN_AFTER_CLICK_TC_KEY = 'is-keyboard-open-after-click-tc-key';

  ///默认打印机 name String
  static const PRINTER_NAME_KEY = 'printer-name-key';
  ///默认打印机 url String
  static const PRINTER_URL_KEY = 'printer-url-key';
  ///是否使用打印机定义的配置 bool
  static const USE_PRINTER_SETTINGS_KEY = 'use-printer-settings-key';
  ///默认打印份数 int
  static const DEFAULT_PRINT_COPIES = 'default-print-copies';
  ///打印方式(服务端打印 serverPrint OR 本地打印 localPrint) String
  static const PRINT_TYPE_KEY = 'print-type-key';
  ///本地打印时是否显示参数设置 bool
  static const IS_SHOW_PRINT_SETTING_KEY = 'is-show-print-setting-key';

  ///串口通讯服务 接收数据的串口列表 List<Map<String, dynamic>>
  static const CONNECTLIST_KEY = 'connectlist-key';

  ///语音播报音量 double
  static const FLUTTERTTS_VOLUME = 'fluttertts-volume';
  ///语音播报语速 double
  static const FLUTTERTTS_SPEECHRATE = 'fluttertts-speechrate';
  ///语音播报音调 double
  static const FLUTTERTTS_PITCH = 'fluttertts-pitch';
  ///语音包引擎 String
  static const FLUTTERTTS_ENGINES = 'fluttertts-engines';

  /// 提示方式 String
  static const TIPS_SHOW_TYPE_KEY = 'tips-show-type-key';

  ///APP 远程打印服务 远程打印服务的打印机信息列表 List<Map<String, dynamic>>
  static const APP_PRINT_SERVICE_LIST_KEY = 'app-print-service-list-key';

  ///串口通讯服务 已经注册了的串口通讯服务列表 List<Map<String, dynamic>>
  static const SERIAL_COM_SERVICE_SERIAL_PORT_LIST_KEY = 'serial-com-service-serial-port-list-key';

  ///dio 网络检查器 消息队列显示 是否启用过滤 bool
  static const DIO_INSPECTOR_IS_FILTER_KEY = 'dio-inspector-is-filter-key';
  ///dio 网络检查器 消息队列显示 当前显示的请求方法类型 String
  static const DIO_INSPECTOR_METHOD_KEY = 'dio-inspector-method-key';

  ///程序日志视图显示 是否启用过滤 bool
  static const LOGGER_IS_FILTER_KEY = 'logger-is-filter-key';
  ///程序日志视图显示 当前显示的日志的级别 String
  static const LOGGER_LEVEL_KEY = 'logger-level-key';

  //region 设备概览
  ///设备概览 语音播报 超产 是否打开语音播报 bool
  static const DEVICETASK_IS_OPEN_OVER_PRODUCT_FLUTTER_TTS = 'devicetask-is-open-over-product-flutter-tts';
  ///设备概览 语音播报 超产预警 播报提前时间（秒） int
  static const DEVICETASK_LEAD_TIME_OVER_PRODUCT_WARN_FLUTTER_TTS = 'devicetask-lead-time-over_product-warn-flutter-tts';
  ///设备概览 语音播报 异常报告 是否打开语音播报 bool
  static const DEVICETASK_IS_OPEN_EXCEPTION_REPORT_FLUTTER_TTS = 'devicetask-is-open-exception-report-flutter-tts';
  ///设备概览 语音播报 全场呼叫 是否打开语音播报 bool
  static const DEVICETASK_IS_OPEN_ANDON_FLUTTER_TTS = 'devicetask-is-open-andon-flutter-tts';
  ///设备概览 语音播报 两次循环之间的间隔时间（秒） int
  static const DEVICETASK_TIME_BETWEEN_CYCLES_FLUTTER_TTS = 'devicetask-time-between-cycles-flutter-tts';
  ///设备概览 语音播报 每次循环的播报次数 int
  static const DEVICETASK_NUM_OF_EACH_CYCLE_FLUTTER_TTS = 'devicetask-num-of-each-cycle-flutter-tts';

  ///设备概览 页面定时刷新 是否可以定时刷新 bool
  static const DEVICETASK_IS_CAN_TIMED_REFRESH_KEY = 'devicetask-is-can-timed-refresh-key';
  ///设备概览 页面定时刷新 数据刷新频率（时间 秒）
  static const DEVICETASK_SCROLL_REFRESH_TIME_KEY = 'devicetask-scroll-refresh-time-key';

  ///设备概览 主页面 不显示的机器的机器id列表 List<String>
  static const DEVICETASK_DEVICE_ID_DISPLAY_KEY = "devicetask-device-id-display";
  ///设备概览 主页面 不显示的机器的车间Id列表 List<String>
  static const DEVICETASK_DEP_ID_DISPLAY_KEY = "devicetask-dep-id-display";
  ///设备概览 主页面 不显示的机器状态列表 List<int>
  static const DEVICETASK_UN_VISIBLE_DEVICE_SIGN_LIST_KEY = 'devicetask-un-visible-device-sign-list-key';
  ///设备概览 主页面 是否超产闪烁 bool
  static const DEVICETASK_IS_BLINK_KEY = 'devicetask-is-blink';
  ///设备概览 主页面 超产闪烁频率 int
  static const DEVICETASK_BLINK_RATE_KEY = 'devicetask-blink-rate';
  ///设备概览 主页面 单个设备卡片显示的设备信息 0 设备编号； 1 设备简称； 2设备名称 int
  static const DEVICETASK_DEVICE_SHOW_INFO_TYPE_KEY = 'devicetask-device-show-info-type-key';

  ///设备概览 设备详情Tab页 默认显示的选项卡 (0设备详情；1生产报工；2报工列表；3次品录入；4次品列表) int
  static const DEVICE_DETAIL_BOARD_INITIAL_INDEX_KEY = 'devicedetailboard-ddbInitialIndex-key';

  ///设备概览 设备详情 详情区域显示的数据字段列表 List<Map<String, dynamic>>
  static const DEVICE_DETAIL_TASK_INFO_FORM_LIST_KEY = 'device-detail-task-info-form-list-key';
  ///设备概览 设备详情 当前机台正在生产任务的按钮组列表 List<Map<String, dynamic>>
  static const DEVICE_DETAIL_TASK_COMMAND_BAR_LIST_KEY = 'device-detail-task-command-bar-list-key';
  ///设备概览 设备详情 底部派工单列表显示的数据字段列表 List<Map<String, dynamic>>
  static const DEVICE_DETAIL_TASK_LIST_INFO_FORM_LIST_KEY = 'device-detail-task-list-info-form-list-key';
  ///设备概览 设备详情 底部派工单列表显示的按钮组列表 List<Map<String, dynamic>>
  static const DEVICE_DETAIL_TASK_LIST_COMMAND_BAR_LIST_KEY = 'device-detail-task-list-command-bar-list-key';
  ///设备概览 设备详情 派工单的状态列表 选中的单据状态（可多选） int
  static const DEVICE_DETAIL_TADTITLES_KEY = 'devicedetail-tabtiles-key';
  ///设备概览 设备详情 搜索方式 int
  static const DEVICE_DETAIL_SEARCH_TYPE_INDEX_KEY = 'device-detail-search-type-index-key';
  ///设备概览 设备详情 装箱单打印 模板文件名称 String
  static const DEVICE_DETAIL_PACKING_PRINT_FILE_NAME_KEY = 'device-detail-packing-print-file-name-key';

  ///设备概览 报工 报工页面显示的数据字段列表 List<Map<String, dynamic>>
  static const DEVICE_SUBMIT_INFO_FORM_LIST_KEY = 'devicesubmit-info-form-list-key';
  ///设备概览 报工 报工提交按钮的显示 int
  static const DEVICE_SUBMIT_BTN_INDEX_KEY = 'devicesubmit-btn-index-key';
  ///设备概览 机台报工 是否显示“补打”按钮 bool
  static const DEVICE_SUBMIT_IS_SHOW_MAKE_UP_BTN_KEY = 'devicesubmit-is-show-is-show-makeupbtn';
  ///设备概览 报工 是否显示“需要检验”按钮 bool
  static const DEVICE_SUBMIT_IS_SHOW_INSPECT_FLAG_BTN_KEY = 'devicesubmit-is-show-inspect-flag-btn-key';
  ///设备概览 报工 “需要检验”按钮是否可以点击修改 bool
  static const DEVICE_SUBMIT_IS_CAN_CLICK_INSPECT_FLAG_BTN_KEY = 'devicesubmit-is-can-click-inspect-flag-btn-key';
  ///设备概览 报工 “需要检验”按钮按钮的选中状态的默认值 bool?
  static const DEVICE_SUBMIT_INSPECT_FLAG_DEFAULT_VALUE_KEY = 'devicesubmit-inspect-flag-default-value-key';
  ///设备概览 机台报工 是否显示 ‘获取实际单重’ 的按钮 bool
  static const DEVICE_SUBMIT_IS_SHOW_GET_FIRST_INSPECT_EBWEIGHT_BTN = 'devicesubmit-is-show-getfirstinspectebweightbtn';
  ///设备概览 机台报工 报工记录提交成功后，是否返回到首页 bool
  static const DEVICE_SUBMIT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY = 'devicesubmit-is-get-back-after-submit-success-key';
  ///设备概览 报工 是否显示报工方式切换按钮 bool
  static const DEVICE_SUBMIT_IS_SHOW_TYPE_BTN_KEY = 'devicesubmit-is-show-type-btn-key';
  ///设备概览 机台报工 报工方式 String
  static const DEVICE_SUBMIT_TYPE_KEY = 'devicesubmit-type';
  ///设备概览 机台报工 按数量报工时 是否需要产品重量检验 bool
  static const DEVICE_SUBMIT_QTY_ISNEED_PIECEWEIGHT_KEY = 'devicesubmit-qty-isneed-pieceweight-key';
  ///设备概览 机台报工 按数量报工时 如果没有实际单重数据，是否根据标准单重计算总重 bool
  static const DEVICE_SUBMIT_QTY_CAN_WEIGHT_CALC_BY_STAND_WEIGHT_KEY = 'devicesubmit-qty-can-weight-calc-by-stand-weight-key';
  ///设备概览 机台报工 按数量（多箱）报工时 是否需要产品重量检验 bool
  static const DEVICE_SUBMIT_QTY_BOX_ISNEED_PIECEWEIGHT_KEY = 'devicesubmit-qty-box-isneed-pieceweight-key';
  ///设备概览 机台报工 按数量（多箱）报工时 如果没有实际单重数据，是否根据标准单重计算总重 bool
  static const DEVICE_SUBMIT_QTY_BOX_CAN_WEIGHT_CALC_BY_STAND_WEIGHT_KEY = 'devicesubmit-qty-box-can-weight-calc-by-stand-weight-key';
  ///设备概览 机台报工 按托报工时 是否需要产品重量检验 bool
  static const DEVICE_SUBMIT_PALLET_ISNEED_PIECEWEIGHT_KEY = 'devicesubmit-pallet-isneed-pieceweight-key';
  ///设备概览 机台报工 按托报工时 如果没有实际单重数据，是否根据标准单重计算总重 bool
  static const DEVICE_SUBMIT_PALLET_CAN_WEIGHT_CALC_BY_STAND_WEIGHT_KEY = 'devicesubmit-pallet-can-weight-calc-by-stand-weight-key';
  ///设备概览 机台报工 当报工方式是“按托报工”时，报工数据的计算方式 int
  static const DEVICE_SUBMIT_CALC_RULE_FOR_PALLET_SUBMIT_TYPE_KEY = 'devicesubmit-calc-rule-for-pallet-submit-type-key';
  ///设备概览 机台报工 按重量报工时 是否需要产品重量检验 bool
  static const DEVICE_SUBMIT_WEIGHT_ISNEED_PIECEWEIGHT_KEY = 'devicesubmit-weight-isneed-pieceweight-key';
  ///设备概览 机台报工 按重量报工时 产品称重的数据是否加到报工总数据上 bool
  static const DEVICE_SUBMIT_WEIGHT_IS_ADD_PIECE_WEIGHT_TO_TOTAL_KEY = 'devicesubmit-isaddtototal-key';
  ///设备概览 机台报工 按重量（多箱）报工时 是否需要产品重量检验 bool
  static const DEVICE_SUBMIT_WEIGHT_BOX_ISNEED_PIECEWEIGHT_KEY = 'devicesubmit-weight-box-isneed-pieceweight-key';
  ///设备概览 机台报工 上一次选中的装箱容器ID String
  static const DEVICE_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY = 'device-submit-the-last-container-selected-value-key';
  ///设备概览 机台报工 上一次填写的皮重数据 double
  static const DEVICE_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY = 'device-submit-the-last-num-pad-packing-weight-value-key';
  ///设备概览 机台报工 上一次填写的单箱数量数据 double
  static const DEVICE_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY = 'device-submit-the-last-single-box-qty-value-key';
  ///设备概览 机台报工 表单数据填写项的标题名称列表 String
  static const DEVICE_SUBMIT_FORM_TITLE_MAP_KEY = 'devicesubmit-form-title-map-key';
  ///设备概览 机台报工 表单数据填写项的样式列表 String
  static const DEVICE_SUBMIT_FORM_STYLE_MAP_KEY = 'devicesubmit-form-style-map-key';
  ///设备概览 机台报工 自动获取焦点的输入框字段名 String
  static const DEVICE_SUBMIT_NUM_PAD_FOCUS_FIELD_KEY = 'devicesubmit-num-pad-focus-field-key';
  ///设备概览 机台报工 单列可显示的表单填写项的行数 int?
  static const DEVICE_SUBMIT_FORM_ROW_MAX_COUNT_LIMIT_KEY = 'device-submit-form-row-max-count-limit-key';
  ///设备概览 机台报工 车间默认值获取方式 0: 单据车间 1: 登录账号所在车间 int
  static const DEVICE_SUBMIT_DEP_GET_WAY_INDEX_KEY = 'devicesubmit-dep-get-way-index-key';
  ///设备概览 机台报工 产线数据的填报类型 0产线 OR 1加工中心 OR 2生产班组 int
  static const DEVICE_SUBMIT_WC_DATA_REPORT_TYPE_KEY = 'devicesubmit-wc-data-report-type-key';
  ///设备概览 机台报工 人员是否可以通过 Adapter 选单 bool
  static const DEVICE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY = 'devicesubmit-is-psn-has-adapter-key';
  ///设备概览 机台报工 生产人员是否可以多选 bool
  static const DEVICE_SUBMIT_IS_PSN_MULTI_KEY = 'devicesubmit-is-psn-multi-key';
  ///设备概览 机台报工 生产人员获取条件设置 int
  static const DEVICE_SUBMIT_PSN_GET_WAY_INDEX_KEY = 'devicetask-psngetWay-index';
  ///设备概览 机台报工 生产人员获取条件设置（车间固定值） String
  static const DEVICE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY = 'devicetask-psngetWay-depcode';
  ///设备概览 机台报工 生产人员获取条件设置（产线固定值） String
  static const DEVICE_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY = 'devicetask-submit-psn-get-way-line-code-key';
  ///设备概览 机台报工 “整箱箱数”可以填写的上限 int?
  static const DEVICE_SUBMIT_NUM_MAX_COUNT_LIMIT_KEY = 'device-submit-num-max-count-limit-key';
  ///设备概览 机台报工 “单箱数量”可以填写的下限 int?
  static const DEVICE_SUBMIT_SINGLE_BOX_QTY_MAX_COUNT_LIMIT_KEY = 'device-submit-single-box-qty-max-count-limit-key';
  ///设备概览 机台报工 是否通过选择装箱容器，自动填充皮重、单箱数量 bool
  static const DEVICE_SUBMIT_IS_USE_PACKING_PICKER_KEY = 'device-submit-use-packing-picker-key';
  ///设备概览 机台报工 是否自动写入实际单重数据 bool   isAutoWritePieceWeight
  static const DEVICE_SUBMIT_IS_AUTO_WRITE_PIECE_WEIGHT_KEY = 'device-submit-is-auto-write-piece-weight-key';
  ///设备概览 机台报工 按多箱报工时，是否显示称重消息传递过来的单箱重量、预计单箱数量
  static const DEVICE_SUBMIT_IS_SHOW_EXPECT_SINGLE_BOX_QTY_KEY = 'device-submit-is-show-expect-single-box-qty-key';
  ///设备概览 机台报工 是否保存上次报工时选中的员工 bool
  static const DEVICE_SUBMIT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY = 'device-submit-is-save-the-last-selected-psn-list-key';
  ///设备概览 机台报工 上次报工时选中的员工列表 List<Map<String, dynamic>> String
  static const DEVICE_SUBMIT_THE_LAST_SELECTED_PSN_LIST_KEY = 'device-submit-the-last-selected-psn-list-key';
  ///设备概览 机台报工 是否保存上次报工时填写的皮重、单箱数量数据（或选择的装箱容器数据） bool
  static const DEVICE_SUBMIT_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY = 'device-submit-is-save-the-last-packing-weight-data-key';
  ///设备概览 机台报工 “单箱数量”是否只能通过选择装箱容器来赋值，而不是手动输入 bool
  static const DEVICE_SUBMIT_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY = 'device-submit-is-single-box-qty-only-changed-by-container-key';
  ///设备概览 机台报工 报工单打印 模板名称 String
  static const DEVICE_SUBMIT_TEMPLATE_FILENAME_KEY = 'devicesubmit-template-filename-key';
  ///设备概览 机台报工 报工单打印 根据产品类别编码区分的打印模板名称列表 String
  static const DEVICE_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY = 'devicesubmit-inv-class-template-filename-map-key';

  ///设备概览 报工列表 日期查询类型 String
  static const DEVICETASK_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY = 'devicetask-submit-list-date-search-type-index-key';
  ///设备概览 报工列表 日期选择器的初始值 String
  static const DEVICETASK_SUBMIT_LIST_DATE_PICKER_VALUE_MAP_KEY = 'devicetask-submit-list-date-picker-value-map-key';
  ///设备概览 报工列表 报工单列表页面显示的数据字段列表 List<Map<String, dynamic>>
  static const DEVICETASK_SUBMIT_LIST_INFO_FORM_LIST_KEY = 'devicetask-submit-list-info-form-list-key';
  ///设备概览 报工列表 报工单列表页面显示的按钮组列表 List<Map<String, dynamic>>
  static const DEVICETASK_SUBMIT_LIST_COMMAND_BAR_LIST_KEY = 'devicetask-submit-list-command-bar-list-key';
  ///设备概览 报工列表 单页显示记录数 int
  static const DEVICETASK_SUBMIT_LIST_PAGE_CONFIG_ROWS_KEY = 'devicetask-submit-list-page-config-rows-key';
  ///设备概览 报工列表 超过指定时间范围不可删除（秒） int
  static const DEVICETASK_DELETE_LIMIT_TIME = 'devicetask-delete-limit-time';
  ///设备概览 报工列表 是否显示搜索框 bool
  static const DEVICE_TASK_SUBMIT_LIST_IS_SHOW_SEARCH_INPUT_BOX_KEY = 'device-task-submit-list-is-show-search-in-put-key';
  ///设备概览 报工列表 搜索方式 int
  static const DEVICE_TASK_SUBMIT_LIST_SEARCH_TYPE_INDEX_KEY = 'device-task-submit-list-search-type-index-key';

  ///设备概览 次品记录 报次品页面显示的数据字段列表 List<Map<String, dynamic>>
  static const PMES_DEVICE_TASK_CHECK_RECORD_INFO_FORM_LIST_KEY = 'pmes-device-task-check-record-info-form-list-key';
  ///设备概览 次品记录 次品提交按钮的显示 int
  static const PMES_DEVICE_TASK_CHECK_RECORD_BTN_INDEX_KEY = 'pmes-device-task-check-record-btn-index-key';
  ///设备概览 次品记录  是否显示补打按钮 bool
  static const PMES_DEVICE_TASK_CHECK_RECORD_IS_SHOW_MAKE_UP_BTN_KEY = 'pmes-device-task-check-record-is-show-make-up-btn-key';
  ///设备概览 次品记录 次品记录提交成功后，是否返回到首页 bool
  static const PMES_DEVICE_TASK_CHECK_RECORD_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY = 'pmes-device-task-check-record-is-get-back-after-check-record-success-key';
  ///设备概览 次品记录 是否显示报次品方式切换按钮 bool
  static const PMES_DEVICE_TASK_CHECK_RECORD_IS_SHOW_TYPE_BTN_KEY = 'pmes-device-task-check-record-is-show-type-btn-key';
  ///设备概览 次品记录 报次品方式 String
  static const PMES_DEVICE_TASK_CHECK_RECORD_TYPE_KEY = 'pmes-device-task-check-record-type-key';
  ///设备概览 次品记录 表单数据填写项的标题名称列表 String
  static const PMES_DEVICE_TASK_CHECK_RECORD_FORM_TITLE_MAP_KEY = 'pmes-device-task-check-record-form-title-map-key';
  ///设备概览 次品记录 表单数据填写项的样式列表 String
  static const PMES_DEVICE_TASK_CHECK_RECORD_FORM_STYLE_MAP_KEY = 'pmes-device-task-check-record-form-style-map-key';
  ///设备概览 次品记录 自动获取焦点的输入框字段名 String
  static const PMES_DEVICE_TASK_CHECK_RECORD_NUM_PAD_FOCUS_FIELD_KEY = 'pmes-device-task-check-record-num-pad-focus-field-key';
  ///设备概览 次品记录 单列可显示的表单填写项的行数 int?
  static const PMES_DEVICE_TASK_CHECK_RECORD_FORM_ROW_MAX_COUNT_LIMIT_KEY = 'pmes-device-task-check-record-form-row-max-count-limit-key';
  ///设备概览 次品记录 车间默认值获取方式 0: 单据车间 1: 登录账号所在车间 int
  static const PMES_DEVICE_TASK_CHECK_RECORD_DEP_GET_WAY_INDEX_KEY = 'pmes-device-task-check-record-dep-get-way-index-key';
  ///设备概览 次品记录 产线数据的填报类型 0产线 OR 1加工中心 OR 2生产班组 int
  static const PMES_DEVICE_TASK_CHECK_RECORD_WC_DATA_REPORT_TYPE_KEY = 'pmes-device-task-check-record-wc-data-report-type-key';
  ///设备概览 次品记录 人员是否可以通过 Adapter 选单 bool
  static const PMES_DEVICE_TASK_CHECK_RECORD_IS_PSN_HAS_ADAPTER_KEY = 'pmes-device-task-check-record-is-psn-has-adapter-key';
  ///设备概览 次品记录 生产人员是否可以多选 bool
  static const PMES_DEVICE_TASK_CHECK_RECORD_IS_PSN_MULTI_KEY = 'pmes-device-task-check-record-is-psn-multi-key';
  ///设备概览 次品记录 生产人员获取条件的Index int
  static const PMES_DEVICE_TASK_CHECK_RECORD_PSN_GET_WAY_INDEX_KEY = 'pmes-device-task-check-record-psn-get-way-index-key';
  ///设备概览 次品记录 生产人员获取条件 车间固定值 String
  static const PMES_DEVICE_TASK_CHECK_RECORD_PSN_DEP_CODE_KEY = 'pmes-device-task-check-record-psn-dep-code-key';
  ///设备概览 次品记录 生产人员获取条件设置（产线固定值） String
  static const PMES_DEVICE_TASK_CHECK_RECORD_PSN_GET_WAY_LINE_CODE_KEY = 'pmes-device-task-check-record-psn-get-way-line-code-key';
  ///设备概览 次品记录 是否保存上次报工时选中的员工 bool
  static const PMES_DEVICE_TASK_CHECK_RECORD_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY = 'pmes-device-task-check-record-is-save-the-last-selected-psn-list-key';
  ///设备概览 次品记录 上次报工时选中的员工列表 List<Map<String, dynamic>>
  static const PMES_DEVICE_TASK_CHECK_RECORD_THE_LAST_SELECTED_PSN_LIST_KEY = 'pmes-device-task-check-record-the-last-selected-psn-list-key';
  ///设备概览 次品记录 打印模板文件名称 String
  static const PMES_DEVICE_TASK_CHECK_RECORD_TEMPLATE_FILENAME_KEY = 'pmes-device-task-check-record-template-filename-key';
  ///设备概览 次品记录 根据产品类别编码区分的打印模板名称列表 String
  static const PMES_DEVICE_TASK_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY = 'pmes-device-task-check-record-inv-class-template-filename-map-key';

  ///设备概览 不良品上报 报次品页面显示的数据字段列表 List<Map<String, dynamic>>
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_INFO_FORM_LIST_KEY = 'pmes-device-task-material-reject-info-form-list-key';
  ///设备概览 不良品上报 次品提交按钮的显示 int
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_BTN_INDEX_KEY = 'pmes-device-task-material-reject-btn-index-key';
  ///设备概览 不良品上报  是否显示补打按钮 bool
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_IS_SHOW_MAKE_UP_BTN_KEY = 'pmes-device-task-material-reject-is-show-make-up-btn-key';
  ///设备概览 不良品上报 不良品记录提交成功后，是否返回到首页 bool
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY = 'pmes-device-task-material-reject-is-get-back-after-commit-success-key';
  ///设备概览 不良品上报 是否显示报次品方式切换按钮 bool
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_IS_SHOW_TYPE_BTN_KEY = 'pmes-device-task-material-reject-is-show-type-btn-key';
  ///设备概览 不良品上报 报次品方式 String
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_TYPE_KEY = 'pmes-device-task-material-reject-type-key';
  ///设备概览 不良品上报 表单数据填写项的标题名称列表 String
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_FORM_TITLE_MAP_KEY = 'pmes-device-task-material-reject-form-title-map-key';
  ///设备概览 不良品上报 表单数据填写项的样式列表 String
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_FORM_STYLE_MAP_KEY = 'pmes-device-task-material-reject-form-style-map-key';
  ///设备概览 不良品上报 自动获取焦点的输入框字段名 String
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_NUM_PAD_FOCUS_FIELD_KEY = 'pmes-device-task-material-reject-num-pad-focus-field-key';
  ///设备概览 不良品上报 单列可显示的表单填写项的行数 int?
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_FORM_ROW_MAX_COUNT_LIMIT_KEY = 'pmes-device-task-material-reject-form-row-max-count-limit-key';
  ///设备概览 不良品上报 车间默认值获取方式 0: 单据车间 1: 登录账号所在车间 int
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_DEP_GET_WAY_INDEX_KEY = 'pmes-device-task-material-reject-dep-get-way-index-key';
  ///设备概览 不良品上报 人员是否可以通过 Adapter 选单 bool
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_IS_PSN_HAS_ADAPTER_KEY = 'pmes-device-task-material-reject-is-psn-has-adapter-key';
  ///设备概览 不良品上报 生产人员是否可以多选 bool
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_IS_PSN_MULTI_KEY = 'pmes-device-task-material-reject-is-psn-multi-key';
  ///设备概览 不良品上报 生产人员获取条件的Index int
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_PSN_GET_WAY_INDEX_KEY = 'pmes-device-task-material-reject-psn-get-way-index-key';
  ///设备概览 不良品上报 生产人员获取条件 车间固定值 String
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_PSN_DEP_CODE_KEY = 'pmes-device-task-material-reject-psn-dep-code-key';
  ///设备概览 不良品上报 生产人员获取条件设置（产线固定值） String
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_PSN_GET_WAY_LINE_CODE_KEY = 'pmes-device-task-material-reject-psn-get-way-line-code-key';
  ///设备概览 不良品上报 是否保存上次报工时选中的员工 bool
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY = 'pmes-device-task-material-reject-is-save-the-last-selected-psn-list-key';
  ///设备概览 不良品上报 上次报工时选中的员工列表 List<Map<String, dynamic>>
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_THE_LAST_SELECTED_PSN_LIST_KEY = 'pmes-device-task-material-reject-the-last-selected-psn-list-key';
  ///设备概览 不良品上报 打印模板文件名称 String
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_TEMPLATE_FILENAME_KEY = 'pmes-device-task-material-reject-template-filename-key';
  ///设备概览 不良品上报 根据产品类别编码区分的打印模板名称列表 String
  static const PMES_DEVICE_TASK_MATERIAL_REJECT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY = 'pmes-device-task-material-reject-inv-class-template-filename-map-key';

  ///设备概览 次品记录列表 日期查询类型 String
  static const PMES_DEVICE_TASK_CHECK_RECORD_LIST_DATE_SEARCH_TYPE_INDEX_KEY = 'pmes-device-task-check-record-list-date-search-type-index-key';
  ///设备概览 次品记录列表 日期选择器的初始值 String
  static const PMES_DEVICE_TASK_CHECK_RECORD_LIST_DATE_PICKER_VALUE_MAP_KEY = 'pmes-device-task-check-record-list-date-picker-value-map-key';
  ///设备概览 次品记录列表 次品单列表页面显示的数据字段列表 List<Map<String, dynamic>>
  static const PMES_DEVICE_TASK_CHECK_RECORD_LIST_INFO_FORM_LIST_KEY = 'pmes-device-task-check-record-list-info-form-list-key';
  ///设备概览 次品记录列表 次品单列表页面显示的按钮组列表 List<Map<String, dynamic>>
  static const PMES_DEVICE_TASK_CHECK_RECORD_LIST_COMMAND_BAR_LIST_KEY = 'pmes-device-task-check-record-list-command-bar-list-key';
  ///设备概览 次品记录列表 单页显示记录数 int
  static const PMES_DEVICE_TASK_CHECK_RECORD_LIST_PAGE_CONFIG_ROWS_KEY = 'pmes-device-task-check-record-list-page-config-rows-key';
  ///设备概览 次品记录列表 次品单删除时间限制 int?
  static const PMES_DEVICE_TASK_CHECK_RECORD_LIST_DELETE_LIMIT_TIME_KEY = 'pmes-device-task-check-record-list-delete-limit-time-key';
  ///设备概览 次品记录列表 次品单据类型（次品记录 OR 材料不良记录） int
  static const PMES_DEVICE_TASK_CHECK_RECORD_LIST_CR_DOCUMENT_TYPE_INDEX_KEY = 'pmes-device-task-check-record-list-cr-document-type-index-key';
  //endregion


  //region 设备对应生产派工单
  ///设备对应生产派工单 不显示的机器的机器id列表 List<String>
  static const MES_DEVICE_TASK_DEVICE_ID_DISPLAY_KEY = "mes-device-task-device-id-display";
  ///设备对应生产派工单 不显示的机器的车间Id列表 List<String>
  static const MES_DEVICE_TASK_DEP_ID_DISPLAY_KEY = "mes-device-task-dep-id-display";
  ///设备对应生产派工单 是否超产闪烁 bool
  static const MES_DEVICE_TASK_IS_BLINK_KEY = 'mes-device-task-is-blink';
  ///设备对应生产派工单 超产闪烁频率 int
  static const MES_DEVICE_TASK_BLINK_RATE_KEY = 'mes-device-task-blink-rate';
  ///设备对应生产派工单 单个设备卡片显示的设备信息 0 设备编号； 1 设备简称； 2设备名称 int
  static const MES_DEVICE_TASK_DEVICE_SHOW_INFO_TYPE_KEY = 'mes-device-task-device-show-info-type-key';

  ///设备对应生产派工单 设备详情 taskList条件 (待生产,生产中,已生产) int
  static const MES_DEVICE_TASK_DETAIL_TADTITLES_KEY = 'mes-device-task-detail-tabtiles-key';
  ///设备对应生产派工单 设备详情 搜索方式 int
  static const MES_DEVICE_TASK_DETAIL_SEARCH_TYPE_INDEX_KEY = 'mes-device-task-detail-search-type-index-key';
  ///设备对应生产派工单 设备详情 详情区域显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_DEVICE_TASK_DETAIL_TASK_INFO_FORM_LIST_KEY = 'mes-device-task-detail-task-info-form-list-key';
  ///设备对应生产派工单 设备详情 底部派工单列表显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_DEVICE_TASK_DETAIL_TASK_LIST_INFO_FORM_LIST_KEY = 'mes-device-task-detail-task-list-info-form-list-key';

  ///设备对应生产派工单 设备详情页 设备详情页选项卡 (0设备详情；1生产报工；2报工列表；3次品录入；4次品列表) int
  static const MES_DEVICE_TASK_DETAIL_INITIAL_INDEX_KEY = 'mes-device-task-detail-board-ddbInitialIndex-key';
  //endregion


  //region 设备对应任务单
  ///设备对应任务单 不显示的机器的机器id列表 List<String>
  static const MES_DEVICE_ORDER_DEVICE_ID_DISPLAY_KEY = "mes-device-order-device-id-display";
  ///设备对应任务单 不显示的机器的车间Id列表 List<String>
  static const MES_DEVICE_ORDER_DEP_ID_DISPLAY_KEY = "mes-device-order-dep-id-display";
  ///设备对应任务单 是否超产闪烁 bool
  static const MES_DEVICE_ORDER_IS_BLINK_KEY = 'mes-device-order-is-blink';
  ///设备对应任务单 超产闪烁频率 int
  static const MES_DEVICE_ORDER_BLINK_RATE_KEY = 'mes-device-order-blink-rate';
  ///设备对应任务单 单个设备卡片显示的设备信息 0 设备编号； 1 设备简称； 2设备名称 int
  static const MES_DEVICE_ORDER_DEVICE_SHOW_INFO_TYPE_KEY = 'mes-device-order-device-show-info-type-key';
  ///设备对应任务单 单个设备生产的对应工艺 Map<String, Map<String, dynamic>
  static const MES_DEVICE_ORDER_DEVICE_CURRENT_OP_MAP_KEY = 'mes-device-order-device-op-map-key';

  ///设备对应任务单 设备详情 orderList条件 (待生产,生产中,已生产) int
  static const MES_DEVICE_ORDER_DETAIL_TADTITLES_KEY = 'mes-device-order-detail-tabtiles-key';
  ///设备对应任务单 设备详情 搜索方式 int
  static const MES_DEVICE_ORDER_DETAIL_SEARCH_TYPE_INDEX_KEY = 'mes-device-order-detail-search-type-index-key';
  ///设备对应任务单 设备详情 详情区域显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_DEVICE_ORDER_DETAIL_WB_ENTRY_INFO_FORM_LIST_KEY = 'mes-device-order-detail-wb-entry-info-form-list-key';
  ///设备对应任务单 设备详情 底部工序计划详情列表显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_DEVICE_ORDER_DETAIL_WB_ENTRY_LIST_INFO_FORM_LIST_KEY = 'mes-device-order-detail-wb-entry-list-info-form-list-key';

  ///设备对应任务单 设备详情页 设备详情页选项卡 (0设备详情；1生产报工；2报工列表；3次品录入；4次品列表) int
  static const MES_DEVICE_ORDER_DETAIL_INITIAL_INDEX_KEY = 'mes-device-order-detail-board-ddbInitialIndex-key';
  //endregion


  //region 加工中心报工
  ///加工中心报工 主页面 当前显示的加工中心 加工中心ID String
  static const MES_WORK_CENTER_SUBMIT_WC_ID_KEY = 'mes-work-center-submit-wc-id-key';
  ///加工中心报工 主页面 不显示的加工中心的主键id列表 List<String>
  static const MES_WORK_CENTER_WORK_CENTER_ID_DISPLAY_KEY = "mes-work-center-work-center-id-display-key";
  ///加工中心报工 主页面 不显示的加工中心的车间Id列表 List<String>
  static const MES_WORK_CENTER_DEP_ID_DISPLAY_KEY = "mes-work-center-dep-id-display-key";
  ///加工中心报工 主页面 是否显示单据类型选择标签 bool
  static const MES_WORK_CENTER_IS_SHOW_CATEGORY_KEY = 'mes-work-center-is-show-category-key';
  ///加工中心报工 主页面 选中的单据类型（任务单 610001 OR 派工单 650011） int
  static const MES_WORK_CENTER_CATEGORY_SELECTED_KEY = 'mes-work-center-category-selected-key';
  ///加工中心报工 主页面 是否显示单据状态选择过滤标签 bool
  static const MES_WORK_CENTER_IS_SHOW_SIGN_FILTER_KEY = 'mes-work-center-is-show-sign-filter-key';
  ///加工中心报工 主页面 状态标签是否可以多选 bool
  static const MES_WORK_CENTER_IS_SIGN_CHIP_MULTI_KEY = 'mes-work-center-is-sign-chip-multi-key';
  ///加工中心报工 主页面 状态标签列表 选中的状态（可多选） int
  static const MES_WORK_CENTER_SIGN_SELECTED_KEY = 'mes-work-center-sign-selected-key';
  ///加工中心报工 主页面 是否显示单据日期选择器 bool
  static const MES_WORK_CENTER_IS_SHOW_DATE_PICKER_KEY = 'mes-work-center-is-show-date-picker-key';
  ///加工中心报工 主页面 任务单列表日期查询类型 String
  static const MES_WORK_CENTER_ORDER_DATE_SEARCH_TYPE_INDEX_KEY = 'mes-work-center-order-date-search-type-index-key';
  ///加工中心报工 主页面 派工单列表日期查询类型 String
  static const MES_WORK_CENTER_TASK_DATE_SEARCH_TYPE_INDEX_KEY = 'mes-work-center-task-date-search-type-index-key';
  ///加工中心报工 主页面 日期选择器的初始值 String
  static const MES_WORK_CENTER_DATE_PICKER_VALUE_MAP_KEY = 'mes-work-center-date-picker-value-map-key';
  ///加工中心报工 主页面 是否显示搜索框 bool
  static const MES_WORK_CENTER_IS_SHOW_SEARCH_INPUT_BOX_KEY = 'mes-work-center-is-show-search-input-box-key';
  ///加工中心报工 主页面 任务单列表搜索方式 int
  static const MES_WORK_CENTER_ORDER_SEARCH_TYPE_INDEX_KEY = 'mes-work-center-order-search-type-index-key';
  ///加工中心报工 主页面 派工单列表搜索方式 int
  static const MES_WORK_CENTER_TASK_SEARCH_TYPE_INDEX_KEY = 'mes-work-center-task-search-type-index-key';
  ///加工中心报工 主页面 单据列表的单页显示记录数 int
  static const MES_WORK_CENTER_PAGE_CONFIG_ROWS_KEY = 'mes-work-center-page-config-rows-key';

  ///加工中心报工 加工中心详情页 派工单加工中心详情页选项卡 (0生产报工；1报工列表；2次品录入；3次品列表) int
  static const MES_WORK_CENTER_TASK_DETAIL_INITIAL_INDEX_KEY = 'mes-work-center-task-detail-initial-index-key';
  ///加工中心报工 加工中心详情页 任务单加工中心详情页选项卡 (0生产报工；1报工列表；2次品录入；3次品列表) int
  static const MES_WORK_CENTER_ORDER_DETAIL_INITIAL_INDEX_KEY = 'mes-work-center-order-detail-initial-index-key';
  //endregion


  //region 任务单
  ///生产任务单 主页面 是否显示任务单状态选择过滤标签 bool
  static const MES_ORDER_IS_SHOW_ORDER_SIGN_FILTER_KEY = 'mes-order-is-show-order-sign-filter-key';
  ///生产任务单 主页面 任务单状态标签是否可以多选 bool
  static const MES_ORDER_IS_ORDER_SIGN_CHIP_MULTI_KEY = 'mes-order-is-order-sign-chip-multi-key';
  ///生产任务单 主页面 任务单的状态列表 选中的单据状态（可多选） int
  static const MES_ORDER_SIGN_SELECTED_KEY = 'mes-order-sign-selected-key';
  ///生产任务单 主页面 是否显示车间选择器 bool
  static const MES_ORDER_IS_SHOW_DEP_PICKER_KEY = 'mes-order-is-show-dep-picker-key';
  ///生产任务单 主页面 任务单车间筛选 车间IDs String
  static const MES_ORDER_DEP_IDS_KEY = 'mes-order-dep-ids-key';
  ///生产任务单 主页面 是否显示单据日期选择器 bool
  static const MES_ORDER_IS_SHOW_DATE_PICKER_KEY = 'mes-order-is-show-date-picker-key';
  ///生产任务单 主页面 日期查询类型 String
  static const MES_ORDER_DATE_SEARCH_TYPE_INDEX_KEY = 'mes-order-date-search-type-index-key';
  ///生产任务单 主页面 日期选择器的初始值 String
  static const MES_ORDER_DATE_PICKER_VALUE_MAP_KEY = 'mes-order-date-picker-value-map-key';
  ///生产任务单 主页面 是否显示搜索框 bool
  static const MES_ORDER_IS_SHOW_SEARCH_INPUT_BOX_KEY = 'mes-order-is-show-search-in-put-key';
  ///生产任务单 主页面 搜索方式 int  0任务单号搜索、1产品编号搜索、2产品名称搜索、3产品规格搜索
  static const MES_ORDER_SEARCH_TYPE_INDEX_KEY = 'mes-order-search-type-index-key';
  ///生产任务单 主页面 任务单列表页面显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_ORDER_INFO_FORM_LIST_KEY = 'mes-order-info-form-list-key';
  ///生产任务单 主页面 任务单列表页面显示的按钮组列表 List<Map<String, dynamic>>
  static const MES_ORDER_COMMAND_BAR_LIST_KEY = 'mes-order-command-bar-list-key';
  ///生产任务单 主页面 任务单列表的单页显示记录数 int
  static const MES_ORDER_PAGE_CONFIG_ROWS_KEY = 'mes-order-page-config-rows-key';

  ///生产任务单 任务单详情Tab页 默认显示的选项卡 int
  static const MES_ORDER_DETAIL_INITIAL_INDEX_KEY = 'mes-order-detail-initial-index-key';

  ///生产任务单 报工 序列号校验码 String
  static const MES_ORDER_SUBMIT_ASSIGNMENT_SERIAL_NUMBER_CHECK_CODE_KEY = 'mes-order-submit-assignment-serial-number-check-code-key';
  ///生产任务单 报工 报工页面显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_ORDER_SUBMIT_INFO_FORM_LIST_KEY = 'mes-order-submit-info-form-list-key';
  ///生产任务单 报工 报工提交按钮的显示 int
  static const MES_ORDER_SUBMIT_BTN_INDEX_KEY = 'mes-order-submit-btn-index-key';
  ///生产任务单 报工 是否显示补打按钮 bool
  static const MES_ORDER_SUBMIT_IS_SHOW_MAKE_UP_BTN_KEY = 'mes-order-submit-is-show-make-up-btn-key';
  ///生产任务单 报工 是否显示“自检确认”按钮 bool
  static const MES_ORDER_SUBMIT_IS_SHOW_SELF_INSPECTION_BTN_KEY = 'mes-order-submit-is-show-self-inspection-btn-key';
  ///生产任务单 报工 是否显示“互检确认”按钮 bool
  static const MES_ORDER_SUBMIT_IS_SHOW_MUTUAL_INSPECTION_BTN_KEY = 'mes-order-submit-is-show-mutual-inspection-btn-key';
  ///生产任务单 报工 报工记录提交成功后，是否返回到首页 bool
  static const MES_ORDER_SUBMIT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY = 'mes-order-submit-is-get-back-after-submit-success-key';
  ///生产任务单 报工 是否显示报工汇总 [opTGDailySubmitQty]、[opSubmitQty] bool
  static const MES_ORDER_SUBMIT_IS_SHOW_OP_TG_SUBMIT_QTY_KEY = 'mes-order-submit-is-show-op-tg-submit-qty-key';
  ///生产任务单 报工 是否显示工序说明 bool
  static const MES_ORDER_SUBMIT_IS_SHOW_OP_DESCRIPTION_KEY = 'mes-order-submit-is-show-op-description-key';
  ///生产任务单 报工 是否显示报工方式切换按钮 bool
  static const MES_ORDER_SUBMIT_IS_SHOW_TYPE_BTN_KEY = 'mes-order-submit-is-show-type-btn-key';
  ///生产任务单 报工 报工方式 String
  static const MES_ORDER_SUBMIT_TYPE_KEY = 'mes-order-submit-type-key';
  ///生产任务单 报工 当报工方式是“按托报工”时，报工数据的计算方式 int
  static const MES_ORDER_SUBMIT_CALC_RULE_FOR_PALLET_SUBMIT_TYPE_KEY = 'mes-order-submit-calc-rule-for-pallet-submit-type-key';
  ///生产任务单 报工 上一次选中的装箱容器ID String
  static const MES_ORDER_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY = 'mes-order-submit-the-last-container-selected-value-key';
  ///生产任务单 报工 上一次填写的皮重数据 double
  static const MES_ORDER_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY = 'mes-order-submit-the-last-num-pad-packing-weight-value-key';
  ///生产任务单 报工 上一次填写的单箱数量数据 double
  static const MES_ORDER_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY = 'mes-order-submit-the-last-single-box-qty-value-key';
  ///生产任务单 报工 表单数据填写项的标题名称列表 String
  static const MES_ORDER_SUBMIT_FORM_TITLE_MAP_KEY = 'mes-order-submit-form-title-map-key';
  ///生产任务单 报工 表单数据填写项的样式列表 String
  static const MES_ORDER_SUBMIT_FORM_STYLE_MAP_KEY = 'mes-order-submit-form-style-map-key';
  ///生产任务单 报工 自动获取焦点的输入框字段名 String
  static const MES_ORDER_SUBMIT_NUM_PAD_FOCUS_FIELD_KEY = 'mes-order-submit-num-pad-focus-field-key';
  ///生产任务单 报工 单列可显示的表单填写项的行数 int?
  static const MES_ORDER_SUBMIT_FORM_ROW_MAX_COUNT_LIMIT_KEY = 'mes-order-submit-form-row-max-count-limit-key';
  ///生产任务单 报工 车间默认值获取方式 0: 单据车间 1: 登录账号所在车间 int
  static const MES_ORDER_SUBMIT_DEP_GET_WAY_INDEX_KEY = 'mes-order-submit-dep-get-way-index-key';
  ///生产任务单 报工 产线数据的填报类型 0产线 OR 1加工中心 OR 2生产班组 int
  static const MES_ORDER_SUBMIT_WC_DATA_REPORT_TYPE_KEY = 'mes-order-submit-wc-data-report-type-key';
  ///生产任务单 报工 人员是否可以通过 Adapter 选单 bool
  static const MES_ORDER_SUBMIT_IS_PSN_HAS_ADAPTER_KEY = 'mes-order-submit-is-pan-has-adapter-key';
  ///生产任务单 报工 生产人员是否可以多选 bool
  static const MES_ORDER_SUBMIT_IS_PSN_MULTI_KEY = 'mes-order-submit-is-psn-multi-key';
  ///生产任务单 报工 生产人员获取条件设置 int
  static const MES_ORDER_SUBMIT_PSN_GET_WAY_INDEX_KEY = 'mes-order-submit-psn-get-way-index-key';
  ///生产任务单 报工 生产人员获取条件设置（车间固定值） String
  static const MES_ORDER_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY = 'mes-order-submit-psn-get-way-dep-code-key';
  ///生产任务单 报工 生产人员获取条件设置（产线固定值） String
  static const MES_ORDER_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY = 'mes-order-submit-psn-get-way-line-code-key';
  ///生产任务单 报工 设备是否可以通过 Adapter 选单 bool
  static const MES_ORDER_SUBMIT_IS_DEVICE_HAS_ADAPTER_KEY = 'mes-order-submit-is-device-has-adapter-key';
  ///生产任务单 报工 设备的筛选条件 设备的车间id String
  static const MES_ORDER_SUBMIT_DEVICE_DEP_ID_LIST_KEY = 'mes-order-submit-device-dep-id-list-key';
  ///生产任务单 报工 设备的筛选条件 设备的类别id String
  static const MES_ORDER_SUBMIT_DEVICE_CLASS_ID_LIST_KEY = 'mes-order-submit-device-class-id-list-key';
  ///生产任务单 报工 “整箱箱数”可以填写的上限 int
  static const MES_ORDER_SUBMIT_NUM_MAX_COUNT_LIMIT_KEY = 'mes-order-submit-num-max-count-limit-key';
  ///生产任务单 报工 “单箱数量”可以填写的下限 int?
  static const MES_ORDER_SUBMIT_SINGLE_BOX_QTY_MAX_COUNT_LIMIT_KEY = 'mes-order-submit-single-box-qty-max-count-limit-key';
  ///生产任务单 报工 是否显示“需要检验”按钮 bool
  static const MES_ORDER_SUBMIT_IS_SHOW_INSPECT_FLAG_BTN_KEY = 'mes-order-submit-is-show-inspect-flag-btn-key';
  ///生产任务单 报工 “需要检验”按钮是否可以点击修改 bool
  static const MES_ORDER_SUBMIT_IS_CAN_CLICK_INSPECT_FLAG_BTN_KEY = 'mes-order-submit-is-can-click-inspect-flag-btn-key';
  ///生产任务单 报工 “需要检验”按钮按钮的选中状态的默认值 bool?
  static const MES_ORDER_SUBMIT_INSPECT_FLAG_DEFAULT_VALUE_KEY = 'mes-order-submit-inspect-flag-default-value-key';
  ///生产任务单 报工 当报工方式是“按序列号报工”时，是否显示“自动提交”按钮 bool
  static const MES_ORDER_SUBMIT_IS_SHOW_AUTO_COMMIT_BTN_KEY = 'mes-order-submit-is-show-auto-commit-btn-key';
  ///生产任务单 报工 当报工方式是“按序列号报工”时，扫描序列号后，是否自动提交报工记录 bool
  static const MES_ORDER_SUBMIT_AUTO_COMMIT_FOR_SERIAL_NUMBER_SUBMIT_TYPE_KEY = 'mes-order-submit-auto-commit-for-serial-number-submit-type-key';
  ///生产任务单 报工 是否通过选择装箱容器，自动填充皮重、单箱数量 bool
  static const MES_ORDER_SUBMIT_IS_USE_PACKING_PICKER_KEY = 'mes-order-submit-is-use-packing-picker-key';
  ///生产任务单 报工 是否保存上次报工时选中的员工 bool
  static const MES_ORDER_SUBMIT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY = 'mes-order-submit-is-save-the-last-selected-psn-list-key';
  ///生产任务单 报工 上次报工时选中的员工列表 List<Map<String, dynamic>>
  static const MES_ORDER_SUBMIT_THE_LAST_SELECTED_PSN_LIST_KEY = 'mes-order-submit-the-last-selected-psn-list-key';
  ///生产任务单 报工 是否保存上次报工时填写的皮重、单箱数量数据（或选择的装箱容器数据） bool
  static const MES_ORDER_SUBMIT_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY = 'mes-order-submit-is-save-the-last-packing-weight-data-key';
  ///生产任务单 报工 “单箱数量”是否只能通过选择装箱容器来赋值，而不是手动输入 bool
  static const MES_ORDER_SUBMIT_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY = 'mes-order-submit-is-single-box-qty-only-changed-by-container-key';
  ///生产任务单 报工 打印模板文件名称 String
  static const MES_ORDER_SUBMIT_TEMPLATE_FILENAME_KEY = 'mes-order-submit-template-filename-key';
  ///生产任务单 报工 根据产品类别编码区分的打印模板名称列表 String
  static const MES_ORDER_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY = 'mes-order-submit-inv-class-template-filename-map-key';
  ///生产任务单 报工 是否显示总重称重数据的 overlay bool
  static const MES_ORDER_SUBMIT_IS_SHOW_WEIGHT_OVERLAY_KEY = 'mes-order-submit-is-show-weight-overlay-key';
  ///生产任务单 报工 显示总重称重数据 overlay 的位置 dx double
  static const MES_ORDER_SUBMIT_WEIGHT_OVERLAY_DX_KEY = 'mes-order-submit-weight-overlay-dx-key';
  ///生产任务单 报工 显示总重称重数据 overlay 的位置 dy double
  static const MES_ORDER_SUBMIT_WEIGHT_OVERLAY_DY_KEY = 'mes-order-submit-weight-overlay-dy-key';

  ///生产任务单 报工列表 日期查询类型 String
  static const MES_ORDER_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY = 'mes-order-submit-list-date-search-type-index-key';
  ///生产任务单 报工列表 日期选择器的初始值 String
  static const MES_ORDER_SUBMIT_LIST_DATE_PICKER_VALUE_MAP_KEY = 'mes-order-submit-list-date-picker-value-map-key';
  ///生产任务单 报工列表 报工单列表页面显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_ORDER_SUBMIT_LIST_INFO_FORM_LIST_KEY = 'mes-order-submit-list-info-form-list-key';
  ///生产任务单 报工列表 报工单列表页面显示的按钮组列表 List<Map<String, dynamic>>
  static const MES_ORDER_SUBMIT_LIST_COMMAND_BAR_LIST_KEY = 'mes-order-submit-list-command-bar-list-key';
  ///生产任务单 报工列表 单页显示记录数 int
  static const MES_ORDER_SUBMIT_LIST_PAGE_CONFIG_ROWS_KEY = 'mes-order-submit-list-page-config-rows-key';
  ///生产任务单 报工列表 超过指定时间范围不可删除（秒） int
  static const MES_ORDER_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY = 'mes-order-submit-list-delete-limit-time-key';
  ///生产任务单 报工列表 是否显示搜索框 bool
  static const MES_ORDER_SUBMIT_LIST_IS_SHOW_SEARCH_INPUT_BOX_KEY = 'mes-order-submit-list-is-show-search-in-put-key';
  ///生产任务单 报工列表 搜索方式 int
  static const MES_ORDER_SUBMIT_LIST_SEARCH_TYPE_INDEX_KEY = 'mes-order-submit-list-search-type-index-key';

  ///生产任务单 报次品 序列号校验码 String
  static const MES_ORDER_CHECK_RECORD_ASSIGNMENT_SERIAL_NUMBER_CHECK_CODE_KEY = 'mes-order-check-record-assignment-serial-number-check-code-key';
  ///生产任务单 报次品 报次品页面显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_ORDER_CHECK_RECORD_INFO_FORM_LIST_KEY = 'mes-order-check-record-info-form-list-key';
  ///生产任务单 报次品 次品提交按钮的显示 int
  static const MES_ORDER_CHECK_RECORD_BTN_INDEX_KEY = 'mes-order-check-record-btn-index-key';
  ///生产任务单 报次品 是否显示补打按钮 bool
  static const MES_ORDER_CHECK_RECORD_IS_SHOW_MAKE_UP_BTN_KEY = 'mes-order-check-record-is-show-make-up-btn-key';
  ///生产任务单 报次品 次品记录提交成功后，是否返回到首页 bool
  static const MES_ORDER_CHECK_RECORD_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY = 'mes-order-check-record-is-get-back-after-check-record-success-key';
  ///生产任务单 报次品 是否显示报次品方式切换按钮 bool
  static const MES_ORDER_CHECK_RECORD_IS_SHOW_TYPE_BTN_KEY = 'mes-order-check-record-is-show-type-btn-key';
  ///生产任务单 报次品 报次品方式 String
  static const MES_ORDER_CHECK_RECORD_TYPE_KEY = 'mes-order-check-record-type-key';
  ///生产任务单 报次品 表单数据填写项的标题名称列表 String
  static const MES_ORDER_CHECK_RECORD_FORM_TITLE_MAP_KEY = 'mes-order-check-record-form-title-map-key';
  ///生产任务单 报次品 表单数据填写项的样式列表 String
  static const MES_ORDER_CHECK_RECORD_FORM_STYLE_MAP_KEY = 'mes-order-check-record-form-style-map-key';
  ///生产任务单 报次品 自动获取焦点的输入框字段名 String
  static const MES_ORDER_CHECK_RECORD_NUM_PAD_FOCUS_FIELD_KEY = 'mes-order-check-record-num-pad-focus-field-key';
  ///生产任务单 报次品 单列可显示的表单填写项的行数 int?
  static const MES_ORDER_CHECK_RECORD_FORM_ROW_MAX_COUNT_LIMIT_KEY = 'mes-order-check-record-form-row-max-count-limit-key';
  ///生产任务单 报次品 车间默认值获取方式 0: 单据车间 1: 登录账号所在车间 int
  static const MES_ORDER_CHECK_RECORD_DEP_GET_WAY_INDEX_KEY = 'mes-order-check-record-dep-get-way-index-key';
  ///生产任务单 报次品 产线数据的填报类型 0产线 OR 1加工中心 OR 2生产班组 int
  static const MES_ORDER_CHECK_RECORD_WC_DATA_REPORT_TYPE_KEY = 'mes-order-check-record-wc-data-report-type-key';
  ///生产任务单 报次品 人员是否可以通过 Adapter 选单 bool
  static const MES_ORDER_CHECK_RECORD_IS_PSN_HAS_ADAPTER_KEY = 'mes-order-check-record-is-psn-has-adapter-key';
  ///生产任务单 报次品 生产人员是否可以多选 bool
  static const MES_ORDER_CHECK_RECORD_IS_PSN_MULTI_KEY = 'mes-order-check-record-is-psn-multi-key';
  ///生产任务单 报次品 生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间  int
  static const MES_ORDER_CHECK_RECORD_PSN_GET_WAY_INDEX_KEY = 'mes-order-check-record-psn-get-way-index-key';
  ///生产任务单 报次品 生产人员获取条件 车间固定值 String
  static const MES_ORDER_CHECK_RECORD_PSN_GET_WAY_DEP_CODE_KEY = 'mes-order-check-record-psn-dep-code-key';
  ///生产任务单 报次品 生产人员获取条件设置（产线固定值） String
  static const MES_ORDER_CHECK_RECORD_PSN_GET_WAY_LINE_CODE_KEY = 'mes-order-check-record-psn-get-way-line-code-key';
  ///生产任务单 报次品 设备是否可以通过 Adapter 选单 bool
  static const MES_ORDER_CHECK_RECORD_IS_DEVICE_HAS_ADAPTER_KEY = 'mes-order-check-record-is-device-has-adapter-key';
  ///生产任务单 报次品 设备的筛选条件 设备的车间id List<String>
  static const MES_ORDER_CHECK_RECORD_DEVICE_DEP_ID_LIST_KEY = 'mes-order-check-record-device-dep-id-list-key';
  ///生产任务单 报次品 设备的筛选条件 设备的类别id List<String>
  static const MES_ORDER_CHECK_RECORD_DEVICE_CLASS_ID_LIST_KEY = 'mes-order-check-record-device-class-id-list-key';
  ///生产任务单 报次品 是否显示工序说明 bool
  static const MES_ORDER_CHECK_RECORD_IS_SHOW_OP_DESCRIPTION_KEY = 'mes-order-check-record-is-show-op-description-key';
  ///生产任务单 报次品 是否保存上次报工时选中的员工 bool
  static const MES_ORDER_CHECK_RECORD_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY = 'mes-order-check-record-is-save-the-last-selected-psn-list-key';
  ///生产任务单 报次品 上次报工时选中的员工列表 List<Map<String, dynamic>>
  static const MES_ORDER_CHECK_RECORD_THE_LAST_SELECTED_PSN_LIST_KEY = 'mes-order-check-record-the-last-selected-psn-list-key';
  ///生产任务单 报次品 打印模板文件名称 String
  static const MES_ORDER_CHECK_RECORD_TEMPLATE_FILENAME_KEY = 'mes-order-check-record-template-filename-key';
  ///生产任务单 报次品 根据产品类别编码区分的打印模板名称列表 String
  static const MES_ORDER_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY = 'mes-order-check-record-inv-class-template-filename-map-key';

  ///生产任务单 不良品上报 不良品上报页面显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_ORDER_MATERIAL_REJECT_INFO_FORM_LIST_KEY = 'mes-order-material-reject-info-form-list-key';
  ///生产任务单 不良品上报 不良品提交按钮的显示 int
  static const MES_ORDER_MATERIAL_REJECT_BTN_INDEX_KEY = 'mes-order-material-reject-btn-index-key';
  ///生产任务单 不良品上报 是否显示补打按钮 bool
  static const MES_ORDER_MATERIAL_REJECT_IS_SHOW_MAKE_UP_BTN_KEY = 'mes-order-material-reject-is-show-make-up-btn-key';
  ///生产任务单 不良品上报 不良品记录提交成功后，是否返回到首页 bool
  static const MES_ORDER_MATERIAL_REJECT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY = 'mes-order-material-reject-is-get-back-after-commit-success-key';
  ///生产任务单 不良品上报 是否显示不良品上报方式切换按钮 bool
  static const MES_ORDER_MATERIAL_REJECT_IS_SHOW_TYPE_BTN_KEY = 'mes-order-material-reject-is-show-type-btn-key';
  ///生产任务单 不良品上报 不良品上报方式 String
  static const MES_ORDER_MATERIAL_REJECT_TYPE_KEY = 'mes-order-material-reject-type-key';
  ///生产任务单 不良品上报 表单数据填写项的标题名称列表 String
  static const MES_ORDER_MATERIAL_REJECT_FORM_TITLE_MAP_KEY = 'mes-order-material-reject-form-title-map-key';
  ///生产任务单 不良品上报 表单数据填写项的样式列表 String
  static const MES_ORDER_MATERIAL_REJECT_FORM_STYLE_MAP_KEY = 'mes-order-material-reject-form-style-map-key';
  ///生产任务单 不良品上报 自动获取焦点的输入框字段名 String
  static const MES_ORDER_MATERIAL_REJECT_NUM_PAD_FOCUS_FIELD_KEY = 'mes-order-material-reject-num-pad-focus-field-key';
  ///生产任务单 不良品上报 单列可显示的表单填写项的行数 int?
  static const MES_ORDER_MATERIAL_REJECT_FORM_ROW_MAX_COUNT_LIMIT_KEY = 'mes-order-material-reject-form-row-max-count-limit-key';
  ///生产任务单 不良品上报 车间默认值获取方式 0: 单据车间 1: 登录账号所在车间 int
  static const MES_ORDER_MATERIAL_REJECT_DEP_GET_WAY_INDEX_KEY = 'mes-order-material-reject-dep-get-way-index-key';
  ///生产任务单 不良品上报 人员是否可以通过 Adapter 选单 bool
  static const MES_ORDER_MATERIAL_REJECT_IS_PSN_HAS_ADAPTER_KEY = 'mes-order-material-reject-is-psn-has-adapter-key';
  ///生产任务单 不良品上报 生产人员是否可以多选 bool
  static const MES_ORDER_MATERIAL_REJECT_IS_PSN_MULTI_KEY = 'mes-order-material-reject-is-psn-multi-key';
  ///生产任务单 不良品上报 生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间  int
  static const MES_ORDER_MATERIAL_REJECT_PSN_GET_WAY_INDEX_KEY = 'mes-order-material-reject-psn-get-way-index-key';
  ///生产任务单 不良品上报 生产人员获取条件 车间固定值 String
  static const MES_ORDER_MATERIAL_REJECT_PSN_GET_WAY_DEP_CODE_KEY = 'mes-order-material-reject-psn-dep-code-key';
  ///生产任务单 不良品上报 生产人员获取条件设置（产线固定值） String
  static const MES_ORDER_MATERIAL_REJECT_PSN_GET_WAY_LINE_CODE_KEY = 'mes-order-material-reject-psn-get-way-line-code-key';
  ///生产任务单 不良品上报 是否保存上次报工时选中的员工 bool
  static const MES_ORDER_MATERIAL_REJECT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY = 'mes-order-material-reject-is-save-the-last-selected-psn-list-key';
  ///生产任务单 不良品上报 上次报工时选中的员工列表 List<Map<String, dynamic>>
  static const MES_ORDER_MATERIAL_REJECT_THE_LAST_SELECTED_PSN_LIST_KEY = 'mes-order-material-reject-the-last-selected-psn-list-key';
  ///生产任务单 不良品上报 打印模板文件名称 String
  static const MES_ORDER_MATERIAL_REJECT_TEMPLATE_FILENAME_KEY = 'mes-order-material-reject-template-filename-key';
  ///生产任务单 不良品上报 根据产品类别编码区分的打印模板名称列表 String
  static const MES_ORDER_MATERIAL_REJECT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY = 'mes-order-material-reject-inv-class-template-filename-map-key';

  ///生产任务单 次品记录列表 日期查询类型 String
  static const MES_ORDER_CHECK_RECORD_LIST_DATE_SEARCH_TYPE_INDEX_KEY = 'mes-order-check-record-list-date-search-type-index-key';
  ///生产任务单 次品记录列表 日期选择器的初始值 String
  static const MES_ORDER_CHECK_RECORD_LIST_DATE_PICKER_VALUE_MAP_KEY = 'mes-order-check-record-list-date-picker-value-map-key';
  ///生产任务单 次品记录列表 次品单列表页面显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_ORDER_CHECK_RECORD_LIST_INFO_FORM_LIST_KEY = 'mes-order-check-record-list-info-form-list-key';
  ///生产任务单 次品记录列表 次品单列表页面显示的按钮组列表 List<Map<String, dynamic>>
  static const MES_ORDER_CHECK_RECORD_LIST_COMMAND_BAR_LIST_KEY = 'mes-order-check-record-list-command-bar-list-key';
  ///生产任务单 次品记录列表 单页显示记录数 int
  static const MES_ORDER_CHECK_RECORD_LIST_PAGE_CONFIG_ROWS_KEY = 'mes-order-check-record-list-page-config-rows-key';
  ///生产任务单 次品记录列表 次品单删除时间限制（秒） int?
  static const MES_ORDER_CHECK_RECORD_LIST_DELETE_LIMIT_TIME_KEY = 'mes-order-check-record-list-delete-limit-time-key';
  ///生产任务单 次品记录列表 次品单据类型（次品记录 OR 材料不良记录） int
  static const MES_ORDER_CHECK_RECORD_LIST_CR_DOCUMENT_TYPE_INDEX_KEY = 'mes-order-check-record-list-cr-document-type-index-key';
  //endregion


  //region 生产派工单
  ///生产派工单 主页面 是否显示派工单状态选择过滤标签 bool
  static const MES_TASK_IS_SHOW_TASK_SIGN_FILTER_KEY = 'mes-task-is-show-task-sign-filter-key';
  ///生产派工单 主页面 派工单状态标签是否可以多选 bool
  static const MES_TASK_IS_TASK_SIGN_CHIP_MULTI_KEY = 'mes-task-is-task-sign-chip-multi-key';
  ///生产派工单 主页面 派工单的状态列表 选中的单据状态（可多选） int
  static const MES_TASK_SIGN_SELECTED_KEY = 'mes-task-sign-selected-key';
  ///生产派工单 主页面 是否显示车间选择器 bool
  static const MES_TASK_IS_SHOW_DEP_PICKER_KEY = 'mes-task-is-show-dep-picker-key';
  ///生产派工单 主页面 派工单车间筛选 车间IDs String
  static const MES_TASK_DEP_IDS_KEY = 'mes-task-dep-ids-key';
  ///生产派工单 主页面 是否显示产线选择器 bool
  static const MES_TASK_IS_SHOW_LINE_PICKER_KEY = 'mes-task-is-show-line-picker-key';
  ///生产派工单 主页面 派工单产线筛选 产线IDs String
  static const MES_TASK_LINE_IDS_KEY = 'mes-task-line-ids-key';
  ///生产派工单 主页面 是否显示单据日期选择器 bool
  static const MES_TASK_IS_SHOW_DATE_PICKER_KEY = 'mes-task-is-show-date-picker-key';
  ///生产派工单 主页面 日期查询类型 String
  static const MES_TASK_DATE_SEARCH_TYPE_INDEX_KEY = 'mes-task-date-search-type-index-key';
  ///生产派工单 主页面 日期选择器的初始值 String
  static const MES_TASK_DATE_PICKER_VALUE_MAP_KEY = 'mes-task-date-picker-value-map-key';
  ///生产派工单 主页面 是否显示搜索框 bool
  static const MES_TASK_IS_SHOW_SEARCH_INPUT_BOX_KEY = 'mes-task-is-show-search-input-box-key';
  ///生产派工单 主页面 搜索方式 int
  static const MES_TASK_SEARCH_TYPE_INDEX_KEY = 'mes-task-search-type-index-key';
  ///生产派工单 主页面 派工单列表页面显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_TASK_INFO_FORM_LIST_KEY = 'mes-task-info-form-list-key';
  ///生产派工单 主页面 派工单列表页面显示的按钮组列表 List<Map<String, dynamic>>
  static const MES_TASK_COMMAND_BAR_LIST_KEY = 'mes-task-command-bar-list-key';
  ///生产派工单 主页面 派工单列表的单页显示记录数 int
  static const MES_TASK_PAGE_CONFIG_ROWS_KEY = 'mes-task-page-config-rows-key';

  ///生产派工单 派工单详情Tab页 默认显示的选项卡 int
  static const MES_TASK_DETAIL_INITIAL_INDEX_KEY = 'mes-task-detail-initial-index-key';

  ///生产派工单 报工 序列号校验码 String
  static const MES_TASK_SUBMIT_ASSIGNMENT_SERIAL_NUMBER_CHECK_CODE_KEY = 'mes-task-submit-assignment-serial-number-check-code-key';
  ///生产派工单 报工 报工页面显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_TASK_SUBMIT_INFO_FORM_LIST_KEY = 'mes-task-submit-info-form-list-key';
  ///生产派工单 报工 报工提交按钮的显示 int
  static const MES_TASK_SUBMIT_BTN_INDEX_KEY = 'mes-task-submit-btn-index-key';
  ///生产派工单 报工 是否显示补打按钮 bool
  static const MES_TASK_SUBMIT_IS_SHOW_MAKE_UP_BTN_KEY = 'mes-task-submit-is-show-make-up-btn-key';
  ///生产派工单 报工 是否显示“自检确认”按钮 bool
  static const MES_TASK_SUBMIT_IS_SHOW_SELF_INSPECTION_BTN_KEY = 'mes-task-submit-is-show-self-inspection-btn-key';
  ///生产派工单 报工 是否显示“互检确认”按钮 bool
  static const MES_TASK_SUBMIT_IS_SHOW_MUTUAL_INSPECTION_BTN_KEY = 'mes-task-submit-is-show-mutual-inspection-btn-key';
  ///生产派工单 报工  报工记录提交成功后，是否返回到首页 bool
  static const MES_TASK_SUBMIT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY = 'mes-task-submit-is-get-back-after-submit-success-key';
  ///生产派工单 报工 是否显示报工方式切换按钮 bool
  static const MES_TASK_SUBMIT_IS_SHOW_TYPE_BTN_KEY = 'mes-task-submit-is-show-type-btn-key';
  ///生产派工单 报工 报工方式 String
  static const MES_TASK_SUBMIT_TYPE_KEY = 'mes-task-submit-type-key';
  ///生产派工单 报工 当报工方式是“按托报工”时，报工数据的计算方式 int
  static const MES_TASK_SUBMIT_CALC_RULE_FOR_PALLET_SUBMIT_TYPE_KEY = 'mes-task-submit-calc-rule-for-pallet-submit-type-key';
  ///生产派工单 报工 上一次选中的装箱容器ID String
  static const MES_TASK_SUBMIT_THE_LAST_CONTAINER_SELECTED_VALUE_KEY = 'mes-task-submit-the-last-container-selected-value-key';
  ///生产派工单 报工 上一次填写的皮重数据 double
  static const MES_TASK_SUBMIT_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY = 'mes-task-submit-the-last-num-pad-packing-weight-value-key';
  ///生产派工单 报工 上一次填写的单箱数量数据 double
  static const MES_TASK_SUBMIT_THE_LAST_SINGLE_BOX_QTY_VALUE_KEY = 'mes-task-submit-the-last-single-box-qty-value-key';
  ///生产派工单 报工 表单数据填写项的标题名称列表 String
  static const MES_TASK_SUBMIT_FORM_TITLE_MAP_KEY = 'mes-task-submit-form-title-map-key';
  ///生产派工单 报工 表单数据填写项的样式列表 String
  static const MES_TASK_SUBMIT_FORM_STYLE_MAP_KEY = 'mes-task-submit-form-style-map-key';
  ///生产派工单 报工 自动获取焦点的输入框字段名 String
  static const MES_TASK_SUBMIT_NUM_PAD_FOCUS_FIELD_KEY = 'mes-task-submit-num-pad-focus-field-key';
  ///生产派工单 报工 单列可显示的表单填写项的行数 int?
  static const MES_TASK_SUBMIT_FORM_ROW_MAX_COUNT_LIMIT_KEY = 'mes-task-submit-form-row-max-count-limit-key';
  ///生产派工单 报工 车间默认值获取方式 0: 单据车间 1: 登录账号所在车间 int
  static const MES_TASK_SUBMIT_DEP_GET_WAY_INDEX_KEY = 'mes-task-submit-dep-get-way-index-key';
  ///生产派工单 报工 产线数据的填报类型 0产线 OR 1加工中心 OR 2生产班组 int
  static const MES_TASK_SUBMIT_WC_DATA_REPORT_TYPE_KEY = 'mes-task-submit-wc-data-report-type-key';
  ///生产派工单 报工 人员是否可以通过 Adapter 选单 bool
  static const MES_TASK_SUBMIT_IS_PSN_HAS_ADAPTER_KEY = 'mes-task-submit-is-pan-has-adapter-key';
  ///生产派工单 报工 生产人员是否可以多选 bool
  static const MES_TASK_SUBMIT_IS_PSN_MULTI_KEY = 'mes-task-submit-is-psn-multi-key';
  ///生产派工单 报工 生产人员获取条件设置 int
  static const MES_TASK_SUBMIT_PSN_GET_WAY_INDEX_KEY = 'mes-task-submit-psn-get-way-index-key';
  ///生产派工单 报工 生产人员获取条件设置（车间固定值） String
  static const MES_TASK_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY = 'mes-task-submit-psn-get-way-dep-code-key';
  ///生产派工单 报工 生产人员获取条件设置（产线固定值） String
  static const MES_TASK_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY = 'mes-task-submit-psn-get-way-line-code-key';
  ///生产派工单 报工 设备是否可以通过 Adapter 选单 bool
  static const MES_TASK_SUBMIT_IS_DEVICE_HAS_ADAPTER_KEY = 'mes-task-submit-is-device-has-adapter-key';
  ///生产派工单 报工 设备的筛选条件 设备的车间id String
  static const MES_TASK_SUBMIT_DEVICE_DEP_ID_LIST_KEY = 'mes-task-submit-device-dep-id-list-key';
  ///生产派工单 报工 设备的筛选条件 设备的类别id String
  static const MES_TASK_SUBMIT_DEVICE_CLASS_ID_LIST_KEY = 'mes-task-submit-device-class-id-list-key';
  ///生产派工单 报工 是否通过选择装箱容器，自动填充皮重、单箱数量 bool
  static const MES_TASK_SUBMIT_IS_USE_PACKING_PICKER_KEY = 'mes-task-submit-is-use-packing-picker-key';
  ///生产派工单 报工 “整箱箱数”可以填写的上限 int
  static const MES_TASK_SUBMIT_NUM_MAX_COUNT_LIMIT_KEY = 'mes-task-submit-num-max-count-limit-key';
  ///生产派工单 报工 “单箱数量”可以填写的下限 int?
  static const MES_TASK_SUBMIT_SINGLE_BOX_QTY_MAX_COUNT_LIMIT_KEY = 'mes-task-submit-single-box-qty-max-count-limit-key';
  ///生产派工单 报工 是否显示“需要检验”按钮 bool
  static const MES_TASK_SUBMIT_IS_SHOW_INSPECT_FLAG_BTN_KEY = 'mes-task-submit-is-show-inspect-flag-btn-key';
  ///生产派工单 报工 “需要检验”按钮是否可以点击修改 bool
  static const MES_TASK_SUBMIT_IS_CAN_CLICK_INSPECT_FLAG_BTN_KEY = 'mes-task-submit-is-can-click-inspect-flag-btn-key';
  ///生产派工单 报工 “需要检验”按钮按钮的选中状态的默认值 bool?
  static const MES_TASK_SUBMIT_INSPECT_FLAG_DEFAULT_VALUE_KEY = 'mes-task-submit-inspect-flag-default-value-key';
  ///生产派工单 报工 当报工方式是“按序列号报工”时，是否显示“自动提交”按钮 bool
  static const MES_TASK_SUBMIT_IS_SHOW_AUTO_COMMIT_BTN_KEY = 'mes-task-submit-is-show-auto-commit-btn-key';
  ///生产派工单 报工 当报工方式是“按序列号报工”时，扫描序列号后，是否自动提交报工记录 bool
  static const MES_TASK_SUBMIT_AUTO_COMMIT_FOR_SERIAL_NUMBER_SUBMIT_TYPE_KEY = 'mes-task-submit-auto-commit-for-serial-number-submit-type-key';
  ///生产派工单 报工 是否保存上次报工时选中的员工 bool
  static const MES_TASK_SUBMIT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY = 'mes-task-submit-is-save-the-last-selected-psn-list-key';
  ///生产派工单 报工 上次报工时选中的员工列表 List<Map<String, dynamic>>
  static const MES_TASK_SUBMIT_THE_LAST_SELECTED_PSN_LIST_KEY = 'mes-task-submit-the-last-selected-psn-list-key';
  ///生产派工单 报工 是否保存上次报工时填写的皮重、单箱数量数据（或选择的装箱容器数据） bool
  static const MES_TASK_SUBMIT_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY = 'mes-task-submit-is-save-the-last-packing-weight-data-key';
  ///生产派工单 报工 “单箱数量”是否只能通过选择装箱容器来赋值，而不是手动输入 bool
  static const MES_TASK_SUBMIT_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY = 'mes-task-submit-is-single-box-qty-only-changed-by-container-key';
  ///生产派工单 报工 打印模板文件名称 String
  static const MES_TASK_SUBMIT_TEMPLATE_FILENAME_KEY = 'mes-task-submit-template-filename-key';
  ///生产派工单 报工 根据产品类别编码区分的打印模板名称列表 String
  static const MES_TASK_SUBMIT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY = 'mes-task-submit-inv-class-template-filename-map-key';
  ///生产派工单 报工 是否显示总重称重数据的 overlay bool
  static const MES_TASK_SUBMIT_IS_SHOW_WEIGHT_OVERLAY_KEY = 'mes-task-submit-is-show-weight-overlay-key';
  ///生产派工单 报工 显示总重称重数据 overlay 的位置 dx double
  static const MES_TASK_SUBMIT_WEIGHT_OVERLAY_DX_KEY = 'mes-task-submit-weight-overlay-dx-key';
  ///生产派工单 报工 显示总重称重数据 overlay 的位置 dy double
  static const MES_TASK_SUBMIT_WEIGHT_OVERLAY_DY_KEY = 'mes-task-submit-weight-overlay-dy-key';
  ///生产派工单 报工 是否保存上一次填写的报工总数 bool
  static const MES_TASK_SUBMIT_IS_SAVE_THE_LAST_QTY_DATA_KEY = 'mes-task-submit-is-save-the-last-qty-data-key';
  ///生产派工单 报工 上一次填写的报工总数 double
  static const MES_TASK_SUBMIT_THE_LAST_NUM_PAD_QTY_VALUE_KEY = 'mes-task-submit-the-last-num-pad-qty-value-key';

  ///生产派工单 报工列表 日期查询类型 String
  static const MES_TASK_SUBMIT_LIST_DATE_SEARCH_TYPE_INDEX_KEY = 'mes-task-submit-list-date-search-type-index-key';
  ///生产派工单 报工列表 日期选择器的初始值 String
  static const MES_TASK_SUBMIT_LIST_DATE_PICKER_VALUE_MAP_KEY = 'mes-task-submit-list-date-picker-value-map-key';
  ///生产派工单 报工列表 报工单列表页面显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_TASK_SUBMIT_LIST_INFO_FORM_LIST_KEY = 'mes-task-submit-list-info-form-list-key';
  ///生产派工单 报工列表 报工单列表页面显示的按钮组列表 List<Map<String, dynamic>>
  static const MES_TASK_SUBMIT_LIST_COMMAND_BAR_LIST_KEY = 'mes-task-submit-list-command-bar-list-key';
  ///生产派工单 报工列表 单页显示记录数 int
  static const MES_TASK_SUBMIT_LIST_PAGE_CONFIG_ROWS_KEY = 'mes-task-submit-list-page-config-rows-key';
  ///生产派工单 报工列表 超过指定时间范围不可删除（秒） int
  static const MES_TASK_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY = 'mes-task-submit-list-delete-limit-time-key';
  ///生产派工单 报工列表 是否显示搜索框 bool
  static const MES_TASK_SUBMIT_LIST_IS_SHOW_SEARCH_INPUT_BOX_KEY = 'mes-task-submit-list-is-show-search-in-put-key';
  ///生产派工单 报工列表 搜索方式 int
  static const MES_TASK_SUBMIT_LIST_SEARCH_TYPE_INDEX_KEY = 'mes-task-submit-list-search-type-index-key';

  ///生产派工单 报次品 报次品页面显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_TASK_CHECK_RECORD_INFO_FORM_LIST_KEY = 'mes-task-check-record-info-form-list-key';
  ///生产派工单 报次品 报次品提交按钮的显示 int
  static const MES_TASK_CHECK_RECORD_BTN_INDEX_KEY = 'mes-task-check-record-btn-index-key';
  ///生产派工单 报次品 是否显示补打按钮 bool
  static const MES_TASK_CHECK_RECORD_IS_SHOW_MAKE_UP_BTN_KEY = 'mes-task-check-record-is-show-make-up-btn-key';
  ///生产派工单 报次品 次品记录提交成功后，是否返回到首页 bool
  static const MES_TASK_CHECK_RECORD_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY = 'mes-task-check-record-is-get-back-after-check-record-success-key';
  ///生产派工单 报次品 是否显示报次品方式切换按钮 bool
  static const MES_TASK_CHECK_RECORD_IS_SHOW_TYPE_BTN_KEY = 'mes-task-check-record-is-show-type-btn-key';
  ///生产派工单 报次品 报次品方式 String
  static const MES_TASK_CHECK_RECORD_TYPE_KEY = 'mes-task-check-record-type-key';
  ///生产派工单 报次品 表单数据填写项的标题名称列表 String
  static const MES_TASK_CHECK_RECORD_FORM_TITLE_MAP_KEY = 'mes-task-check-record-form-title-map-key';
  ///生产派工单 报次品 表单数据填写项的样式列表 String
  static const MES_TASK_CHECK_RECORD_FORM_STYLE_MAP_KEY = 'mes-task-check-record-form-style-map-key';
  ///生产派工单 报次品 自动获取焦点的输入框字段名 String
  static const MES_TASK_CHECK_RECORD_NUM_PAD_FOCUS_FIELD_KEY = 'mes-task-check-record-num-pad-focus-field-key';
  ///生产派工单 报次品 单列可显示的表单填写项的行数 int?
  static const MES_TASK_CHECK_RECORD_FORM_ROW_MAX_COUNT_LIMIT_KEY = 'mes-task-check-record-form-row-max-count-limit-key';
  ///生产派工单 报次品 车间默认值获取方式 0: 单据车间 1: 登录账号所在车间 int
  static const MES_TASK_CHECK_RECORD_DEP_GET_WAY_INDEX_KEY = 'mes-task-check-record-dep-get-way-index-key';
  ///生产派工单 报次品 产线数据的填报类型 0产线 OR 1加工中心 OR 2生产班组 int
  static const MES_TASK_CHECK_RECORD_WC_DATA_REPORT_TYPE_KEY = 'mes-task-check-record-wc-data-report-type-key';
  ///生产派工单 报次品 人员是否可以通过 Adapter 选单 bool
  static const MES_TASK_CHECK_RECORD_IS_PSN_HAS_ADAPTER_KEY = 'mes-task-check-record-is-psn-has-adapter-key';
  ///生产派工单 报次品 生产人员是否可以多选 bool
  static const MES_TASK_CHECK_RECORD_IS_PSN_MULTI_KEY = 'mes-task-check-record-is-psn-multi-key';
  ///生产派工单 报次品 生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间  int
  static const MES_TASK_CHECK_RECORD_PSN_GET_WAY_INDEX_KEY = 'mes-task-check-record-psn-get-way-index-key';
  ///生产派工单 报次品 生产人员获取条件 车间固定值 String
  static const MES_TASK_CHECK_RECORD_PSN_GET_WAY_DEP_CODE_KEY = 'mes-task-check-record-psn-dep-code-key';
  ///生产派工单 报次品 生产人员获取条件设置（产线固定值） String
  static const MES_TASK_CHECK_RECORD_PSN_GET_WAY_LINE_CODE_KEY = 'mes-task-check-record-psn-get-way-line-code-key';
  ///生产派工单 报次品 设备是否可以通过 Adapter 选单 bool
  static const MES_TASK_CHECK_RECORD_IS_DEVICE_HAS_ADAPTER_KEY = 'mes-task-check-record-is-device-has-adapter-key';
  ///生产派工单 报次品 设备的筛选条件 设备的车间id List<String>
  static const MES_TASK_CHECK_RECORD_DEVICE_DEP_ID_LIST_KEY = 'mes-task-check-record-device-dep-id-list-key';
  ///生产派工单 报次品 设备的筛选条件 设备的类别id List<String>
  static const MES_TASK_CHECK_RECORD_DEVICE_CLASS_ID_LIST_KEY = 'mes-task-check-record-device-class-id-list-key';
  ///生产派工单 报次品 是否保存上次报工时选中的员工 bool
  static const MES_TASK_CHECK_RECORD_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY = 'mes-task-check-record-is-save-the-last-selected-psn-list-key';
  ///生产派工单 报次品 上次报工时选中的员工列表 List<Map<String, dynamic>>
  static const MES_TASK_CHECK_RECORD_THE_LAST_SELECTED_PSN_LIST_KEY = 'mes-task-check-record-the-last-selected-psn-list-key';
  ///生产派工单 报次品 打印模板文件名称 String
  static const MES_TASK_CHECK_RECORD_TEMPLATE_FILENAME_KEY = 'mes-task-check-record-template-filename-key';
  ///生产派工单 报次品 根据产品类别编码区分的打印模板名称列表 String
  static const MES_TASK_CHECK_RECORD_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY = 'mes-task-check-record-inv-class-template-filename-map-key';

  ///生产派工单 不良品上报 不良品上报页面显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_TASK_MATERIAL_REJECT_INFO_FORM_LIST_KEY = 'mes-task-material-reject-info-form-list-key';
  ///生产派工单 不良品上报 不良品上报提交按钮的显示 int
  static const MES_TASK_MATERIAL_REJECT_BTN_INDEX_KEY = 'mes-task-material-reject-btn-index-key';
  ///生产派工单 不良品上报 是否显示补打按钮 bool
  static const MES_TASK_MATERIAL_REJECT_IS_SHOW_MAKE_UP_BTN_KEY = 'mes-task-material-reject-is-show-make-up-btn-key';
  ///生产派工单 不良品上报 不良品记录提交成功后，是否返回到首页 bool
  static const MES_TASK_MATERIAL_REJECT_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY = 'mes-task-material-reject-is-get-back-after-commit-success-key';
  ///生产派工单 不良品上报 是否显示不良品上报方式切换按钮 bool
  static const MES_TASK_MATERIAL_REJECT_IS_SHOW_TYPE_BTN_KEY = 'mes-task-material-reject-is-show-type-btn-key';
  ///生产派工单 不良品上报 不良品上报方式 String
  static const MES_TASK_MATERIAL_REJECT_TYPE_KEY = 'mes-task-material-reject-type-key';
  ///生产派工单 不良品上报 表单数据填写项的标题名称列表 String
  static const MES_TASK_MATERIAL_REJECT_FORM_TITLE_MAP_KEY = 'mes-task-material-reject-form-title-map-key';
  ///生产派工单 不良品上报 表单数据填写项的样式列表 String
  static const MES_TASK_MATERIAL_REJECT_FORM_STYLE_MAP_KEY = 'mes-task-material-reject-form-style-map-key';
  ///生产派工单 不良品上报 自动获取焦点的输入框字段名 String
  static const MES_TASK_MATERIAL_REJECT_NUM_PAD_FOCUS_FIELD_KEY = 'mes-task-material-reject-num-pad-focus-field-key';
  ///生产派工单 不良品上报 单列可显示的表单填写项的行数 int?
  static const MES_TASK_MATERIAL_REJECT_FORM_ROW_MAX_COUNT_LIMIT_KEY = 'mes-task-material-reject-form-row-max-count-limit-key';
  ///生产派工单 不良品上报 车间默认值获取方式 0: 单据车间 1: 登录账号所在车间 int
  static const MES_TASK_MATERIAL_REJECT_DEP_GET_WAY_INDEX_KEY = 'mes-task-material-reject-dep-get-way-index-key';
  ///生产派工单 不良品上报 人员是否可以通过 Adapter 选单 bool
  static const MES_TASK_MATERIAL_REJECT_IS_PSN_HAS_ADAPTER_KEY = 'mes-task-material-reject-is-psn-has-adapter-key';
  ///生产派工单 不良品上报 生产人员是否可以多选 bool
  static const MES_TASK_MATERIAL_REJECT_IS_PSN_MULTI_KEY = 'mes-task-material-reject-is-psn-multi-key';
  ///生产派工单 不良品上报 生产人员获取条件的Index  0: 全部   1: 选中的车间  2: 固定车间  int
  static const MES_TASK_MATERIAL_REJECT_PSN_GET_WAY_INDEX_KEY = 'mes-task-material-reject-psn-get-way-index-key';
  ///生产派工单 不良品上报 生产人员获取条件 车间固定值 String
  static const MES_TASK_MATERIAL_REJECT_PSN_GET_WAY_DEP_CODE_KEY = 'mes-task-material-reject-psn-dep-code-key';
  ///生产派工单 不良品上报 生产人员获取条件设置（产线固定值） String
  static const MES_TASK_MATERIAL_REJECT_PSN_GET_WAY_LINE_CODE_KEY = 'mes-task-material-reject-psn-get-way-line-code-key';
  ///生产派工单 不良品上报 是否保存上次报工时选中的员工 bool
  static const MES_TASK_MATERIAL_REJECT_IS_SAVE_THE_LAST_SELECTED_PSN_LIST_KEY = 'mes-task-material-reject-is-save-the-last-selected-psn-list-key';
  ///生产派工单 不良品上报 上次报工时选中的员工列表 List<Map<String, dynamic>>
  static const MES_TASK_MATERIAL_REJECT_THE_LAST_SELECTED_PSN_LIST_KEY = 'mes-task-material-reject-the-last-selected-psn-list-key';
  ///生产派工单 不良品上报 打印模板文件名称 String
  static const MES_TASK_MATERIAL_REJECT_TEMPLATE_FILENAME_KEY = 'mes-task-material-reject-template-filename-key';
  ///生产派工单 不良品上报 根据产品类别编码区分的打印模板名称列表 String
  static const MES_TASK_MATERIAL_REJECT_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY = 'mes-task-material-reject-inv-class-template-filename-map-key';

  ///生产派工单 次品记录列表 日期查询类型 String
  static const MES_TASK_CHECK_RECORD_LIST_DATE_SEARCH_TYPE_INDEX_KEY = 'mes-task-check-record-list-date-search-type-index-key';
  ///生产派工单 次品记录列表 日期选择器的初始值 String
  static const MES_TASK_CHECK_RECORD_LIST_DATE_PICKER_VALUE_MAP_KEY = 'mes-task-check-record-list-date-picker-value-map-key';
  ///生产派工单 次品记录列表 次品单列表页面显示的数据字段列表 List<Map<String, dynamic>>
  static const MES_TASK_CHECK_RECORD_LIST_INFO_FORM_LIST_KEY = 'mes-task-check-record-list-info-form-list-key';
  ///生产派工单 次品记录列表 次品单列表页面显示的按钮组列表 List<Map<String, dynamic>>
  static const MES_TASK_CHECK_RECORD_LIST_COMMAND_BAR_LIST_KEY = 'mes-task-check-record-list-command-bar-list-key';
  ///生产派工单 次品记录列表 单页显示记录数 int
  static const MES_TASK_CHECK_RECORD_LIST_PAGE_CONFIG_ROWS_KEY = 'mes-task-check-record-list-page-config-rows-key';
  ///生产派工单 次品记录列表 次品单删除时间限制（秒） int?
  static const MES_TASK_CHECK_RECORD_LIST_DELETE_LIMIT_TIME_KEY = 'mes-task-check-record-list-delete-limit-time-key';
  ///生产派工单 次品记录列表 次品单据类型（次品记录 OR 材料不良记录） int
  static const MES_TASK_CHECK_RECORD_LIST_CR_DOCUMENT_TYPE_INDEX_KEY = 'mes-task-check-record-list-cr-document-type-index-key';
  //endregion


  //region 报工条码
  ///报工条码 主页面 条码列表页面显示的数据字段列表 List<Map<String, dynamic>>
  static const SUBMIT_BARCODE_INFO_FORM_LIST_KEY = 'submit-barcode-info-form-list-key';
  ///报工条码 搜索按钮列表选中的项 int
  static const SUBMIT_BARCODE_SEARCH_BTN_TYPE_INDEX_KEY = 'submit-barcode-search-btn-type-Index-key';
  //endregion


  //region 全场呼叫
  ///全场呼叫 主页面 是否显示状态选择过滤标签 bool
  static const ANDON_IS_SHOW_SIGN_FILTER_KEY = 'andon-is-show-sign-filter-key';
  ///全场呼叫 主页面 状态标签是否可以多选 bool
  static const ANDON_IS_SIGN_CHIP_MULTI_KEY = 'andon-is-sign-chip-multi-key';
  ///全场呼叫 主页面 状态列表 选中的单据状态（可多选） int
  static const ANDON_SIGN_SELECTED_KEY = 'andon-sign-selected-key';
  ///全场呼叫 主页面 是否显示车间选择器 bool
  static const ANDON_IS_SHOW_DEP_PICKER_KEY = 'andon-is-show-dep-picker-key';
  ///全场呼叫 主页面 任务单车间筛选 车间IDs String
  static const ANDON_DEP_IDS_KEY = 'andon-dep-ids-key';
  ///全场呼叫 主页面 是否显示单据日期选择器 bool
  static const ANDON_IS_SHOW_DATE_PICKER_KEY = 'andon-is-show-date-picker-key';
  ///全场呼叫 主页面 日期查询类型 String
  static const ANDON_DATE_SEARCH_TYPE_INDEX_KEY = 'andon-date-search-type-index-key';
  ///全场呼叫 主页面 日期选择器的初始值 String
  static const ANDON_DATE_PICKER_VALUE_MAP_KEY = 'andon-date-picker-value-map-key';
  ///全场呼叫 主页面 是否显示全场呼叫类型选择器 bool
  static const ANDON_IS_SHOW_ANDON_CLASS_PICKER_KEY = 'andon-is-show-andon-class-picker-key';
  ///全场呼叫 全场呼叫列表类别筛选 类别ID String
  static const ANDON_SERVICE_CLASS_ID_KEY = 'andon-service-class-id-key';
  ///全场呼叫 列表页面显示的按钮组列表 List<Map<String, dynamic>>
  static const ANDON_COMMAND_BAR_LIST_KEY = 'andon-command-bar-list-key';

  ///全场呼叫 主页面 全场呼叫列表的单页显示记录数 int
  static const ANDON_PAGE_CONFIG_ROWS_KEY = 'andon-page-config-rows-key';
  //endregion


  //region 拌料单

  ///拌料单 单据详情Tab页 默认显示的选项卡 int
  static const MO_MIXTURE_DETAIL_INITIAL_INDEX_KEY = 'mo-mixture-detail-initial-index-key';
  ///拌料单 报工 人员是否可以通过 Adapter 选单 bool
  static const MO_MIXTURE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY = 'mo-mixture-submit-is-pan-has-adapter-key';
  ///拌料单 报工 生产人员获取条件设置 int
  static const MO_MIXTURE_SUBMIT_PSN_GET_WAY_INDEX_KEY = 'mo-mixture-submit-psn-get-way-index-key';
  ///拌料单 报工 生产人员获取条件设置（车间固定值） String
  static const MO_MIXTURE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY = 'mo-mixture-submit-psn-get-way-dep-code-key';
  ///拌料单 报工 生产人员获取条件设置（产线固定值） String
  static const MO_MIXTURE_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY = 'mo-mixture-submit-psn-get-way-line-code-key';
  ///拌料单 报工 打印模板名称 String
  static const MO_MIXTURE_SUBMIT_TEMPLATE_FILENAME_KEY = 'mo-mixture-submit-template-filename-key';

  ///拌料单 报工列表 超过指定时间范围不可删除（秒） int
  static const MO_MIXTURE_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY = 'mo-mixture-submit-list-delete-limit-time-key';

  //endregion


  //region 粉料单

  ///粉料单 单据详情Tab页 默认显示的选项卡 int
  static const MO_POWDER_DETAIL_INITIAL_INDEX_KEY = 'mo-powder-detail-initial-index-key';
  ///粉料单 报工 人员是否可以通过 Adapter 选单 bool
  static const MO_POWDER_SUBMIT_IS_PSN_HAS_ADAPTER_KEY = 'mo-powder-submit-is-pan-has-adapter-key';
  ///粉料单 报工 生产人员获取条件设置 int
  static const MO_POWDER_SUBMIT_PSN_GET_WAY_INDEX_KEY = 'mo-powder-submit-psn-get-way-index-key';
  ///粉料单 报工 生产人员获取条件设置（车间固定值） String
  static const MO_POWDER_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY = 'mo-powder-submit-psn-get-way-dep-code-key';
  ///粉料单 报工 生产人员获取条件设置（产线固定值） String
  static const MO_POWDER_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY = 'mo-powder-submit-psn-get-way-line-code-key';
  ///粉料单 报工 打印模板名称 String
  static const MO_POWDER_SUBMIT_TEMPLATE_FILENAME_KEY = 'mo-powder-submit-template-filename-key';

  ///粉料单 报工列表 超过指定时间范围不可删除（秒） int
  static const MO_POWDER_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY = 'mo-powder-submit-list-delete-limit-time-key';

  //endregion


  //region 发料单

  ///发料单 单据详情Tab页 默认显示的选项卡 int
  static const MO_ISSUANCE_DETAIL_INITIAL_INDEX_KEY = 'mo-issuance-detail-initial-index-key';
  ///发料单 报工 人员是否可以通过 Adapter 选单 bool
  static const MO_ISSUANCE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY = 'mo-issuance-submit-is-pan-has-adapter-key';
  ///发料单 报工 生产人员获取条件设置 int
  static const MO_ISSUANCE_SUBMIT_PSN_GET_WAY_INDEX_KEY = 'mo-issuance-submit-psn-get-way-index-key';
  ///发料单 报工 生产人员获取条件设置（车间固定值） String
  static const MO_ISSUANCE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY = 'mo-issuance-submit-psn-get-way-dep-code-key';
  ///发料单 报工 生产人员获取条件设置（产线固定值） String
  static const MO_ISSUANCE_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY = 'mo-issuance-submit-psn-get-way-line-code-key';
  ///发料单 报工 打印模板名称 String
  static const MO_ISSUANCE_SUBMIT_TEMPLATE_FILENAME_KEY = 'mo-issuance-submit-template-filename-key';

  //endregion


  //region 模具档案

  ///模具档案 搜索按钮列表选中的项 int
  static const MOULD_SEARCH_BTN_TYPE_INDEX_KEY = 'mould-search-btn-type-Index-key';

  //endregion


  //region 质量巡检
  ///质量巡检 质量巡检单据的状态列表 选中的单据状态（单选） int
  static const QUALITY_INSPECTION_SIGN_SELECTED_KEY = 'quality-inspection-sign-selected-key';
  ///质量巡检 质量巡检单据的类型列表 选中的单据类型（单选） int
  static const QUALITY_INSPECTION_CATEGORY_SELECTED_KEY = 'quality-inspection-category-selected-key';
  ///质量巡检 前台显示的检验类型列表 int
  static const QUALITY_INSPECTION_SHOW_CATEGORY_LIST_KEY = 'quality-inspection-show-category-list-key';
  ///质量巡检 质量巡检单据的搜索条件（报检单 OR 检验单的筛选条件字段名对应的索引） int
  static const QUALITY_INSPECTION_SEARCH_TYPE_INDEX_KEY = 'quality-inspection-search-type-index-key';
  ///质量巡检 设备组条件 设备ID（可多选） String
  static const QUALITY_INSPECTION_DEVICES_KEY = 'quality-inspection-devices-key';
  ///质量巡检 车间条件 车间ID（可多选） String
  static const QUALITY_INSPECTION_DEP_KEY = 'quality-inspection-dep-key';
  ///质量巡检 派工单选择（新增自定义的检验单） 搜索按钮列表选中的项 int
  static const QUALITY_INSPECTION_MO_TASK_SEARCH_BTN_TYPE_INDEX_KEY = 'quality-inspection-mo-task-search-btn-type-index-key';
  ///质量巡检 派工单生成检验单的类型 firstCheckVoucher checkVoucher theLastCheckVoucher String
  static const QUALITY_INSPECTION_MO_TASK_CHECK_VOUCHER_TYPE_KEY = 'quality-inspection-mo-task-check-voucher-type-key';
  //endregion


  //region 生产产线
  ///生产产线 关联类型列表 选中的关联类型（单选） int
  static const BELT_LINE_OBJ_TYPE_SIGN_SELECTED_KEY = 'belt-line-obj-type-sign-selected-key';
  ///生产产线 关联对象类别列表 选中的关联对象类别（单选） int
  static const BELT_LINE_OBJ_CLASS_ID_SELECTED_KEY = 'belt-line-obj-class-id-selected-key';
  //endregion


  //region 生产班组
  ///生产班组 关联类型列表 选中的关联类型（单选） int
  static const TEAM_GROUP_OBJ_TYPE_SIGN_SELECTED_KEY = 'team-group-obj-type-sign-selected-key';
  ///生产班组 关联对象类别列表 选中的关联对象类别（单选） int
  static const TEAM_GROUP_OBJ_CLASS_ID_SELECTED_KEY = 'team-group-obj-class-id-selected-key';
  //endregion


  //region 加工中心
  ///加工中心 主页面 不显示的机器状态列表 List<int>
  static const WORK_CENTER_UN_VISIBLE_DEVICE_SIGN_LIST_KEY = 'work-center-un-visible-device-sign-list-key';

  ///加工中心 关联类型列表 选中的关联类型（单选） int
  static const WORK_CENTER_OBJ_TYPE_SIGN_SELECTED_KEY = 'work-center-obj-type-sign-selected-key';
  ///加工中心 关联对象类别列表 选中的关联对象类别（单选） int
  static const WORK_CENTER_OBJ_CLASS_ID_SELECTED_KEY = 'work-center-obj-class-id-selected-key';
  //endregion


  //region 库位看板
  ///库位看板 仓库名
  static const LOCATION_STOREHOUSE_NAME_KEY = 'location-storehouse-name';
  ///库位看板 仓库code
  static const LOCATION_STOREHOUSE_CODE_KEY = 'location-storehouse-code';
  ///库位看板 仓库id
  static const LOCATION_STOREHOUSE_ID_KEY = 'location-storehouse-id';
  //endregion


  //region 物料条码
  ///物料条码 主页面 是否显示搜索框 bool
  static const INV_BARCODE_IS_SHOW_SEARCH_INPUT_BOX_KEY = 'inv-barcode-is-show-search-in-put-key';
  ///物料条码 主页面 搜索方式 int
  static const INV_BARCODE_SEARCH_TYPE_INDEX_KEY = 'inv-barcode-search-type-index-key';
  ///物料条码 主页面 产品列表页面显示的数据字段列表 List<Map<String, dynamic>>
  static const INV_BARCODE_INFO_FORM_LIST_KEY = 'inv-barcode-info-form-list-key';
  ///物料条码 主页面 产品列表页面显示的按钮组列表 List<Map<String, dynamic>>
  static const INV_BARCODE_COMMAND_BAR_LIST_KEY = 'inv-barcode-command-bar-list-key';
  ///物料条码 主页面 产品列表的单页显示记录数 int
  static const INV_BARCODE_PAGE_CONFIG_ROWS_KEY = 'inv-barcode-page-config-rows-key';

  ///物料条码 详情Tab页 默认显示的选项卡 int
  static const INV_BARCODE_DETAIL_INITIAL_INDEX_KEY = 'inv-barcode-detail-initial-index-key';

  ///物料条码 提交页面 条码页面显示的数据字段列表 List<Map<String, dynamic>>
  static const INV_BARCODE_FORM_INFO_FORM_LIST_KEY = 'inv-barcode-form-info-form-list-key';
  ///物料条码 提交页面 提交按钮的显示 int
  static const INV_BARCODE_FORM_SAVE_BTN_INDEX_KEY = 'inv-barcode-form-save-btn-index-key';
  ///物料条码 提交页面 条码记录提交成功后，是否返回到首页 bool
  static const INV_BARCODE_FORM_IS_GET_BACK_AFTER_COMMIT_SUCCESS_KEY = 'inv-barcode-form-is-get-back-after-save-success-key';
  ///物料条码 提交页面 是否显示填报方式切换按钮 bool
  static const INV_BARCODE_FORM_IS_SHOW_TYPE_BTN_KEY = 'inv-barcode-form-is-show-type-btn-key';
  ///物料条码 提交页面 填报方式 String
  static const INV_BARCODE_FORM_TYPE_KEY = 'inv-barcode-form-type-key';
  ///物料条码 提交页面 当填报方式是“按托填报”时，填报数据的计算方式 int
  static const INV_BARCODE_FORM_CALC_RULE_FOR_PALLET_SAVE_TYPE_KEY = 'inv-barcode-form-calc-rule-for-pallet-save-type-key';
  ///物料条码 提交页面 上一次选中的装箱容器ID String
  static const INV_BARCODE_FORM_THE_LAST_CONTAINER_SELECTED_VALUE_KEY = 'inv-barcode-form-the-last-container-selected-value-key';
  ///物料条码 提交页面 上一次填写的皮重数据 double
  static const INV_BARCODE_FORM_THE_LAST_NUM_PAD_PACKING_WEIGHT_VALUE_KEY = 'inv-barcode-form-the-last-num-pad-packing-weight-value-key';
  ///物料条码 提交页面 上一次填写单箱数量的数据 double
  static const INV_BARCODE_FORM_THE_LAST_NUM_PAD_SINGLE_BOX_QTY_VALUE_KEY = 'inv-barcode-form-the-last-num-pad-single-box-qty-value-key';
  ///物料条码 提交页面 表单数据填写项的标题名称列表 String
  static const INV_BARCODE_FORM_FORM_TITLE_MAP_KEY = 'inv-barcode-form-form-title-map-key';
  ///物料条码 提交页面 表单数据填写项的样式列表 String
  static const INV_BARCODE_FORM_FORM_STYLE_MAP_KEY = 'inv-barcode-form-form-style-map-key';
  ///物料条码 提交页面 自动获取焦点的输入框字段名 String
  static const INV_BARCODE_FORM_NUM_PAD_FOCUS_FIELD_KEY = 'inv-barcode-form-num-pad-focus-field-key';
  ///物料条码 提交页面 单列可显示的表单填写项的行数 int?
  static const INV_BARCODE_FORM_FORM_ROW_MAX_COUNT_LIMIT_KEY = 'inv-barcode-form-form-row-max-count-limit-key';
  ///物料条码 提交页面 “整箱箱数”可以填写的上限 int?
  static const INV_BARCODE_FORM_NUM_MAX_COUNT_LIMIT_KEY = 'inv-barcode-form-num-max-count-limit-key';
  ///物料条码 提交页面 “单箱数量”可以填写的下限 int?
  static const INV_BARCODE_FORM_SINGLE_BOX_QTY_MAX_COUNT_LIMIT_KEY = 'inv-barcode-form-single-box-qty-max-count-limit-key';
  ///物料条码 提交页面 按重量填报时 产品称重的数据是否加到填报总数据上 bool
  static const INV_BARCODE_FORM_WEIGHT_IS_ADD_PIECE_WEIGHT_TO_TOTAL_KEY = 'inv-barcode-form-isaddtototal-key';
  ///物料条码 提交页面 按数量（多箱）提交时，是否显示称重消息传递过来的单箱重量、预计单箱数量
  static const INV_BARCODE_FORM_IS_SHOW_EXPECT_SINGLE_BOX_QTY_KEY = 'inv-barcode-form-is-show-expect-single-box-qty-key';
  ///物料条码 提交页面 是否保存上次填报时的填写的皮重数据或选择的装箱容器数据 bool
  static const INV_BARCODE_FORM_IS_SAVE_THE_LAST_PACKING_WEIGHT_DATA_KEY = 'inv-barcode-form-is-save-the-last-packing-weight-data-key';
  ///物料条码 提交页面 “单箱数量”是否只能通过选择装箱容器来赋值，而不是手动输入 bool
  static const INV_BARCODE_FORM_IS_SINGLE_BOX_QTY_ONLY_CHANGED_BY_CONTAINER_KEY = 'inv-barcode-form-is-single-box-qty-only-changed-by-container-key';
  ///物料条码 提交页面 条码打印 模板名称 String
  static const INV_BARCODE_FORM_TEMPLATE_FILENAME_KEY = 'inv-barcode-form-template-filename-key';
  ///物料条码 提交页面 条码打印 根据产品类别编码区分的打印模板名称列表 String
  static const INV_BARCODE_FORM_INV_CLASS_TEMPLATE_FILENAME_MAP_KEY = 'inv-barcode-form-inv-class-template-filename-map-key';
  ///物料条码 提交页面 是否通过选择装箱容器，自动填充皮重、单箱数量 bool
  static const INV_BARCODE_FORM_IS_USE_PACKING_PICKER_KEY = 'inv-barcode-form-use-packing-picker-key';

  ///生产派工单 次品记录列表 日期查询类型 String
  static const INV_BARCODE_LIST_DATE_SEARCH_TYPE_INDEX_KEY = 'inv-barcode-list-date-search-type-index-key';
  ///物料条码 条码列表 日期选择器的初始值 String
  static const INV_BARCODE_LIST_DATE_PICKER_VALUE_MAP_KEY = 'inv-barcode-list-date-picker-value-map-key';
  ///物料条码 条码列表 数据字段列表 List<Map<String, dynamic>>
  static const INV_BARCODE_LIST_INFO_FORM_LIST_KEY = 'inv-barcode-list-info-form-list-key';
  ///物料条码 条码列表 单页显示记录数 int
  static const INV_BARCODE_LIST_PAGE_CONFIG_ROWS_KEY = 'inv-barcode-list-page-config-rows-key';
  ///物料条码 条码列表 删除时间限制（秒） int?
  static const INV_BARCODE_LIST_DELETE_LIMIT_TIME_KEY = 'inv-barcode-list-delete-limit-time-key';
  ///物料条码 条码列表 搜索方式 int
  static const INV_BARCODE_LIST_SEARCH_TYPE_INDEX_KEY = 'inv-barcode-list-search-type-index-key';
  //endregion

}

class ShareKeyUtil {

  String getMoPowderSharedPreferencesKey(int progId, String mixtureKey){
    String key = '';
    switch (progId){
      case 651071:
        //region 拌料单
        key = mixtureKey;
        //endregion
        break;
      case 651076:
        //region 粉料单
        switch (mixtureKey){
          case SharedPreferencesKeys.MO_MIXTURE_DETAIL_INITIAL_INDEX_KEY:
            key = SharedPreferencesKeys.MO_POWDER_DETAIL_INITIAL_INDEX_KEY;
            break;
          case SharedPreferencesKeys.MO_MIXTURE_SUBMIT_IS_PSN_HAS_ADAPTER_KEY:
            key = SharedPreferencesKeys.MO_POWDER_SUBMIT_IS_PSN_HAS_ADAPTER_KEY;
            break;
          case SharedPreferencesKeys.MO_MIXTURE_SUBMIT_PSN_GET_WAY_INDEX_KEY:
            key = SharedPreferencesKeys.MO_POWDER_SUBMIT_PSN_GET_WAY_INDEX_KEY;
            break;
          case SharedPreferencesKeys.MO_MIXTURE_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY:
            key = SharedPreferencesKeys.MO_POWDER_SUBMIT_PSN_GET_WAY_DEP_CODE_KEY;
            break;
          case SharedPreferencesKeys.MO_MIXTURE_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY:
            key = SharedPreferencesKeys.MO_POWDER_SUBMIT_PSN_GET_WAY_LINE_CODE_KEY;
            break;
          case SharedPreferencesKeys.MO_MIXTURE_SUBMIT_TEMPLATE_FILENAME_KEY:
            key = SharedPreferencesKeys.MO_POWDER_SUBMIT_TEMPLATE_FILENAME_KEY;
            break;
          case SharedPreferencesKeys.MO_MIXTURE_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY:
            key = SharedPreferencesKeys.MO_POWDER_SUBMIT_LIST_DELETE_LIMIT_TIME_KEY;
            break;
        }
        //endregion
        break;
    }
    return key;
  }

  String getWorkCenterSharedPreferencesKey(int progId, String mixtureKey){
    String key = '';
    switch (progId){
      case 660003:
        //region 生产产线
        switch (mixtureKey){
          case SharedPreferencesKeys.WORK_CENTER_OBJ_TYPE_SIGN_SELECTED_KEY:
            key = SharedPreferencesKeys.BELT_LINE_OBJ_TYPE_SIGN_SELECTED_KEY;
            break;
          case SharedPreferencesKeys.WORK_CENTER_OBJ_CLASS_ID_SELECTED_KEY:
            key = SharedPreferencesKeys.BELT_LINE_OBJ_CLASS_ID_SELECTED_KEY;
            break;
        }
        //endregion
        break;
      case 660022:
        //region 加工中心
        key = mixtureKey;
        //endregion
        break;
      case 660021:
        //region 生产班组
        switch (mixtureKey){
          case SharedPreferencesKeys.WORK_CENTER_OBJ_TYPE_SIGN_SELECTED_KEY:
            key = SharedPreferencesKeys.TEAM_GROUP_OBJ_TYPE_SIGN_SELECTED_KEY;
            break;
          case SharedPreferencesKeys.WORK_CENTER_OBJ_CLASS_ID_SELECTED_KEY:
            key = SharedPreferencesKeys.TEAM_GROUP_OBJ_CLASS_ID_SELECTED_KEY;
            break;
        }
        //endregion
        break;
    }
    return key;
  }

}