import 'package:desktop/app/ui/pages/home/andon/andon_binding.dart';
import 'package:desktop/app/ui/pages/home/andon/andon_page.dart';
import 'package:desktop/app/ui/pages/home/andon/setting/andon_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/andon/setting/andon_setting_page.dart';
import 'package:desktop/app/ui/pages/home/cloud_service_task/cloud_service_task_binding.dart';
import 'package:desktop/app/ui/pages/home/cloud_service_task/cloud_service_task_page.dart';
import 'package:desktop/app/ui/pages/home/mes/base/belt_line/belt_line_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/base/belt_line/belt_line_page.dart';
import 'package:desktop/app/ui/pages/home/mes/base/belt_line/detail/belt_line_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mes/base/belt_line/detail/team_group_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mes/base/work_center/detail/work_center_detail_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/base/work_center/detail/work_center_detail_page.dart';
import 'package:desktop/app/ui/pages/home/mes/base/work_center/detail/work_center_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mes/base/work_center/work_center_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/base/work_center/work_center_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_order/detail/mes_device_order_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_order/mes_device_order_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_order/mes_device_order_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/detail/mes_device_task_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/mes_device_task_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/mes_device_task_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/setting/mes_device_task_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/setting/mes_device_task_setting_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/detail_tab/mes_order_detail_tab_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/detail_tab/mes_order_detail_tab_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/mes_order_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/setting/mes_order_detail_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/setting/mes_order_detail_setting_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/mes_order_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/mes_order_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/setting/mes_order_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/setting/mes_order_setting_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/detail_tab/mes_task_detail_tab_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/detail_tab/mes_task_detail_tab_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/mes_task_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/setting/mes_task_detail_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/setting/mes_task_detail_setting_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/mes_task_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/mes_task_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/setting/mes_task_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/setting/mes_task_setting_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/detail/mes_work_center_order_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/detail/mes_work_center_task_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/mes_work_center_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/mes_work_center_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/setting/mes_work_center_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/setting/mes_work_center_setting_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_work_center/work_center_allocate/page/work_center_allocate_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/final_inspection_detail/final_inspection_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/final_inspection_detail/final_inspection_form/final_inspection_detail_form_binding.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/final_inspection_detail/final_inspection_form/final_inspection_detail_form_page.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/inspection_detail/inspection_form/quality_inspection_detail_form_binding.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/inspection_detail/inspection_form/quality_inspection_detail_form_page.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/inspection_detail/quality_inspection_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/qm_inspection_detail/qm_inspection_detail_view.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/qm_inspection_detail/qm_inspection_form/qm_inspection_detail_form_binding.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/qm_inspection_detail/qm_inspection_form/qm_inspection_detail_form_page.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/quality_inspection_binding.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/quality_inspection_page.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/setting/quality_inspection_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/setting/quality_inspection_setting_page.dart';
import 'package:desktop/app/ui/pages/home/message/message_main_list/message_main_list_page.dart';
import 'package:desktop/app/ui/pages/home/message/message_main_list/message_main_list_view.dart';
import 'package:desktop/app/ui/pages/home/mould/mould_binding.dart';
import 'package:desktop/app/ui/pages/home/mould/mould_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/check_record_list/pmes_check_record_list_binding.dart';
import 'package:desktop/app/ui/pages/home/pmes/check_record_list/pmes_check_record_list_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/detail/device_detail_quality_inspection_detail_view.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/detail_board_binding.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/detail_board_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/detail_board_view.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/check_record/device_check_record_binding.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/check_record/device_check_record_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/check_record/device_check_record_view.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/setting/detail_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/setting/detail_setting_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/submit/device_submit_binding.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/submit/device_submit_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/submit/device_submit_view.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_andon/device_andon_binding.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_andon/device_andon_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_andon/device_andon_view.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_binding.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_setting/device_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/device_setting/device_setting_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/exception_report/exception_report_binding.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/exception_report/exception_report_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/exception_report/exception_report_view.dart';
import 'package:desktop/app/ui/pages/home/pmes/submit_list/pmes_submit_list_binding.dart';
import 'package:desktop/app/ui/pages/home/pmes/submit_list/pmes_submit_list_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/submit_list/pmes_submit_list_view.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/detail/detail_tab/mo_issuance_detail_tab_binding.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/detail/detail_tab/mo_issuance_detail_tab_page.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/detail/mo_issuance_detail_view.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/detail/setting/mo_issuance_detail_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/detail/setting/mo_issuance_detail_setting_page.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/mo_issuance_binding.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/mo_issuance_page.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/detail_tab/mo_mixture_detail_tab_binding.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/detail_tab/mo_mixture_detail_tab_page.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/mo_mixture_detail_view.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/mo_powder_detail_view.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/setting/mo_mixture_detail_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/setting/mo_mixture_detail_setting_page.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/mo_mixture_binding.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/mo_mixture_page.dart';
import 'package:desktop/app/ui/pages/home/setting/overall_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/setting/overall_setting_page.dart';
import 'package:desktop/app/ui/pages/home/message/message_binding.dart';
import 'package:desktop/app/ui/pages/home/message/message_page.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/detail_tab/inv_barcode_detail_tab_binding.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/detail_tab/inv_barcode_detail_tab_page.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/inv_barcode_detail_view.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/setting/inv_barcode_detail_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/setting/inv_barcode_detail_setting_page.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/inv_barcode_binding.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/inv_barcode_page.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/setting/inv_barcode_setting_binding.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/setting/inv_barcode_setting_page.dart';
import 'package:desktop/app/ui/pages/home/tm/submit_barcode/submit_barcode_binding.dart';
import 'package:desktop/app/ui/pages/home/tm/submit_barcode/submit_barcode_page.dart';
import 'package:desktop/app/ui/pages/login/login_view.dart';
import 'package:desktop/app/ui/pages/attach_view/attach_binding.dart';
import 'package:desktop/app/ui/pages/attach_view/attach_page.dart';
import 'package:get/get.dart';

import 'package:desktop/app/ui/pages/home/home_view.dart';
import 'package:desktop/app/ui/pages/login/setting/login_setting_binding.dart';
import 'package:desktop/app/ui/pages/login/setting/login_setting_page.dart';
import 'package:desktop/app/ui/pages/root/root_binding.dart';
import 'package:desktop/app/ui/pages/root/root_view.dart';
import 'package:desktop/app/ui/pages/home/home_binding.dart';
import 'package:desktop/app/ui/pages/login/login_page/login_binding.dart';
import 'package:desktop/app/ui/pages/login/login_page/login_page.dart';
import 'package:desktop/app/ui/pages/empty_page/empty_binding.dart';
import 'package:desktop/app/ui/pages/empty_page/empty_page.dart';

import '../ui/pages/home/message/message_main_list/message_main_list_binding.dart';
import 'app_routes.dart';

class AppPages {

  AppPages._();

  static final pages = [
    GetPage(
        name: AppRoutes.ROOT,
        page: () => RootView(),
        binding: RootBinding(),
        participatesInRootNavigator: true,
        children: [
          GetPage(
            name: RoutePath.HOME,
            page: () => HomeView(),
            binding: HomeBinding(),
            children: [
              ///空页面
              GetPage(
                name: RoutePath.EMPTY,
                page: () => EmptyPage(),
                binding: EmptyBinding(),
              ),

              ///实时监测
              GetPage(
                name: RoutePath.PMES_REAL_TIME_MONITOR,
                page: () => DevicePage(),
                binding: DeviceBinding(),
                children: [
                  ///设置
                  GetPage(
                    name: RoutePath.SETTING,
                    page: ()=> DeviceSettingPage(),
                    binding: DeviceSettingBinding(),
                  ),
                  ///设备生产的技术指导书
                  GetPage(
                    name: RoutePath.ATTACH,
                    page: () => AttachPage(),
                    binding: AttachBinding(),
                  ),
                  ///设备详情 TabBar 路由
                  GetPage(
                    name: RoutePath.DETAIL,
                    page: () => PMesDeviceDetailView(),
                    children: [
                      ///设备详情 TabBar 主页面
                      GetPage(
                        name: RoutePath.MAIN,
                        page: () => DeviceDetailBoardPage(),
                        binding: DeviceDetailBoardBinding(),
                        children: [
                          ///设备详情 设置页面
                          GetPage(
                            name: RoutePath.SETTING,
                            page: () => DeviceDetailSettingPage(),
                            binding: DeviceDetailSettingBinding(),
                            parameters: const {
                              'type': 'tab',
                            }
                          ),
                          ///附件页面
                          GetPage(
                            name: RoutePath.ATTACH,
                            page: () => AttachPage(),
                            binding: AttachBinding(),
                          ),

                          ///检验单详情 路由
                          GetPage(
                              name: RoutePath.IPQC_QUALITY_INSPECTION,
                              page: () => DeviceDetailQualityInspectionDetailView(),
                              children: [
                                ///检验单详情 主页面
                                GetPage(
                                    name: RoutePath.MAIN,
                                    page: () => QualityInspectionDetailFormPage(),
                                    binding: QualityInspectionDetailFormBinding(),
                                    children: [
                                      ///检验单详情 设置页面
                                      GetPage(
                                          name: RoutePath.SETTING,
                                          page: () => EmptyPage(),
                                          binding: EmptyBinding(),
                                          parameters: const {
                                            'isShowBackButtonString': '1',
                                          }
                                      ),
                                      ///检验单附件页面
                                      GetPage(
                                        name: RoutePath.ATTACH,
                                        page: () => AttachPage(),
                                        binding: AttachBinding(),
                                      ),
                                    ]
                                ),
                              ]
                          ),
                        ]
                      ),
                    ]
                  ),
                  ///报工页面 路由
                  GetPage(
                    name: RoutePath.SUBMIT,
                    page: () => DeviceSubmitView(),
                    children: [
                      ///报工页面 主页面
                      GetPage(
                        name: RoutePath.MAIN,
                        page: () => DeviceSubmitPage(),
                        binding: DeviceSubmitBinding(),
                        children: [
                          ///报工页面 设置页面
                          GetPage(
                              name: RoutePath.SETTING,
                              page: () => DeviceDetailSettingPage(),
                              binding: DeviceDetailSettingBinding(),
                              parameters: const {
                                'type': 'submit',
                              }
                          ),
                        ]
                      ),
                    ]
                  ),
                  ///报工列表页面
                  GetPage(
                    name: RoutePath.SUBMIT_LIST,
                    page: () => PMesSubmitListView(initialRoute: AppRoutes.PMES_REAL_TIME_MONITOR_SUBMIT_LIST_MAIN_PAGE,),
                    children: [
                      GetPage(
                        name: RoutePath.MAIN,
                        page: () => PMesSubmitListPage(),
                        binding: PMesSubmitListBinding(),
                        children: [
                          ///附件页面
                          GetPage(
                            name: RoutePath.ATTACH,
                            page: () => AttachPage(),
                            binding: AttachBinding(),
                          ),
                        ]
                      )
                    ]
                  ),
                  ///报次品页面 路由
                  GetPage(
                      name: RoutePath.CHECK_RECORD,
                      page: () => DeviceCheckRecordView(),
                      children: [
                        ///报次品页面 主页面
                        GetPage(
                            name: RoutePath.MAIN,
                            page: () => DeviceCheckRecordPage(),
                            binding: DeviceCheckRecordBinding(),
                            children: [
                              ///报次品页面 设置页面
                              GetPage(
                                  name: RoutePath.SETTING,
                                  page: () => DeviceDetailSettingPage(),
                                  binding: DeviceDetailSettingBinding(),
                                  parameters: const {
                                    'type': 'checkRecord',
                                  }
                              ),
                            ]
                        )
                      ]
                  ),
                  ///次品列表页面
                  GetPage(
                      name: RoutePath.CHECK_RECORD_LIST,
                      page: () => PMesCheckRecordListPage(),
                      binding: PMesCheckRecordListBinding()
                  ),

                  ///异常报告
                  GetPage(
                      name: RoutePath.EXCEPTION,
                      page: () => ExceptionReportView(),
                      children: [
                        GetPage(
                          name: RoutePath.MAIN,
                            page: () => ExceptionReportPage(),
                            binding: ExceptionReportBinding()
                        )
                      ]
                  ),
                  ///全场呼叫
                  GetPage(
                      name: RoutePath.DEVICE_ANDON,
                      page: () => DeviceAndonView(),
                      children: [
                        GetPage(
                            name: RoutePath.MAIN,
                            page: () => DeviceAndonPage(),
                            binding: DeviceAndonBinding()
                        )
                      ]
                  ),
                ]
              ),

              ///生产 设备对应生产派工单
              GetPage(
                  name: RoutePath.MES_DEVICE_TASK,
                  page: () => MesDeviceTaskPage(),
                  binding: MesDeviceTaskBinding(),
                  children: [
                    ///设置
                    GetPage(
                      name: RoutePath.SETTING,
                      page: () => MesDeviceTaskSettingPage(),
                      binding: MesDeviceTaskSettingBinding(),
                    ),
                    ///附件、图片查看
                    GetPage(
                      name: RoutePath.ATTACH,
                      page: () => AttachPage(),
                      binding: AttachBinding(),
                    ),
                    GetPage(
                        name: RoutePath.DETAIL,
                        page: () => MesDeviceTaskDetailView(),
                        children: [
                          GetPage(
                              name: RoutePath.MAIN,
                              page: () => MesTaskDetailTabPage(),
                              binding: MesTaskDetailTabBinding(),
                              children: [
                                ///派工单详情 设置页面
                                GetPage(
                                    name: RoutePath.SETTING,
                                    page: () => MesTaskDetailSettingPage(),
                                    binding: MesTaskDetailSettingBinding(),
                                    parameters: const {
                                      'type': 'tab',
                                      'taskOpenType': '1',
                                    }
                                ),
                                ///派工单详情 派工单的附件页面
                                GetPage(
                                  name: RoutePath.ATTACH,
                                  page: () => AttachPage(),
                                  binding: AttachBinding(),
                                ),
                              ]
                          )
                        ]
                    ),
                  ]
              ),

              ///生产 设备对应生产任务单
              GetPage(
                  name: RoutePath.MES_DEVICE_ORDER,
                  page: () => MesDeviceOrderPage(),
                  binding: MesDeviceOrderBinding(),
                  children: [
                    ///设置
                    //GetPage(
                    //  name: RoutePath.SETTING,
                    //  page: () => MesDeviceOrderSettingPage(),
                    //  binding: MesDeviceOrderSettingBinding(),
                    //),
                    ///附件、图片查看
                    GetPage(
                      name: RoutePath.ATTACH,
                      page: () => AttachPage(),
                      binding: AttachBinding(),
                    ),
                    GetPage(
                        name: RoutePath.DETAIL,
                        page: () => MesDeviceOrderDetailView(),
                        children: [
                          GetPage(
                              name: RoutePath.MAIN,
                              page: () => MesOrderDetailTabPage(),
                              binding: MesOrderDetailTabBinding(),
                              children: [
                                ///任务单详情 设置页面
                                GetPage(
                                    name: RoutePath.SETTING,
                                    page: () => MesOrderDetailSettingPage(),
                                    binding: MesOrderDetailSettingBinding(),
                                    parameters: const {
                                      'type': 'tab',
                                      'orderOpenType': '1',
                                    }
                                ),
                                ///任务单详情 任务单的附件页面
                                GetPage(
                                  name: RoutePath.ATTACH,
                                  page: () => AttachPage(),
                                  binding: AttachBinding(),
                                ),
                              ]
                          )
                        ]
                    ),
                  ]
              ),

              ///加工中心报工
              GetPage(
                name: RoutePath.MES_WORK_CENTER_SUBMIT,
                page: () => MesWorkCenterPage(),
                binding: MesWorkCenterBinding(),
                children: [
                  ///设置
                  GetPage(
                    name: RoutePath.SETTING,
                    page: () => MesWorkCenterSettingPage(),
                    binding: MesWorkCenterSettingBinding(),
                  ),
                  ///附件、图片查看
                  GetPage(
                    name: RoutePath.ATTACH,
                    page: () => AttachPage(),
                    binding: AttachBinding(),
                  ),
                  ///加工中心分配
                  GetPage(
                      name: RoutePath.ALLOCATE_DETAIL,
                      page: () => WorkCenterAllocateDetailView(),
                      children: [
                        GetPage(
                          name: RoutePath.MAIN,
                          page: () => WorkCenterDetailPage(),
                          binding: WorkCenterDetailBinding(),
                        )
                      ]
                  ),
                  ///任务单详情
                  GetPage(
                    name: RoutePath.ORDER_DETAIL,
                    page: () => MesWorkCenterOrderDetailView(),
                    children: [
                      GetPage(
                        name: RoutePath.MAIN,
                        page: () => MesOrderDetailTabPage(),
                        binding: MesOrderDetailTabBinding(),
                        children: [
                          ///任务单详情 设置页面
                          GetPage(
                              name: RoutePath.SETTING,
                              page: () => MesOrderDetailSettingPage(),
                              binding: MesOrderDetailSettingBinding(),
                              parameters: const {
                                'type': 'tab',
                                'orderOpenType': '2',
                              }
                          ),
                          ///任务单详情 派工单的附件页面
                          GetPage(
                            name: RoutePath.ATTACH,
                            page: () => AttachPage(),
                            binding: AttachBinding(),
                          ),
                        ]
                      )
                    ]
                  ),
                  ///派工单详情
                  GetPage(
                      name: RoutePath.TASK_DETAIL,
                      page: () => MesWorkCenterTaskDetailView(),
                      children: [
                        GetPage(
                            name: RoutePath.MAIN,
                            page: () => MesTaskDetailTabPage(),
                            binding: MesTaskDetailTabBinding(),
                            children: [
                              ///派工单详情 设置页面
                              GetPage(
                                  name: RoutePath.SETTING,
                                  page: () => MesTaskDetailSettingPage(),
                                  binding: MesTaskDetailSettingBinding(),
                                  parameters: const {
                                    'type': 'tab',
                                    'taskOpenType': '2',
                                  }
                              ),
                              ///派工单详情 派工单的附件页面
                              GetPage(
                                name: RoutePath.ATTACH,
                                page: () => AttachPage(),
                                binding: AttachBinding(),
                              ),
                            ]
                        )
                      ]
                  )
                ]
              ),

              ///任务单报工
              GetPage(
                name: RoutePath.MES_ORDER,
                page: () => MesOrderPage(),
                binding: MesOrderBinding(),
                children: [
                  ///设置
                  GetPage(
                    name: RoutePath.SETTING,
                    page: () => MesOrderSettingPage(),
                    binding: MesOrderSettingBinding(),
                  ),
                  ///附件、图片查看
                  GetPage(
                    name: RoutePath.ATTACH,
                    page: () => AttachPage(),
                    binding: AttachBinding(),
                  ),
                  GetPage(
                      name: RoutePath.DETAIL,
                      page: () => MesOrderDetailView(),
                      children: [
                        GetPage(
                            name: RoutePath.MAIN,
                            page: () => MesOrderDetailTabPage(),
                            binding: MesOrderDetailTabBinding(),
                            children: [
                              ///任务单详情 设置页面
                              GetPage(
                                  name: RoutePath.SETTING,
                                  page: () => MesOrderDetailSettingPage(),
                                  binding: MesOrderDetailSettingBinding(),
                                  parameters: const {
                                    'type': 'tab',
                                  }
                              ),
                              ///任务单详情 派工单的附件页面
                              GetPage(
                                name: RoutePath.ATTACH,
                                page: () => AttachPage(),
                                binding: AttachBinding(),
                              ),
                            ]
                        )
                      ]
                  ),
                ]
              ),

              ///派工单报工
              GetPage(
                name: RoutePath.MES_TASK,
                page: () => MesTaskPage(),
                binding: MesTaskBinding(),
                children: [
                  ///设置
                  GetPage(
                    name: RoutePath.SETTING,
                    page: () => MesTaskSettingPage(),
                    binding: MesTaskSettingBinding(),
                  ),
                  ///附件、图片查看
                  GetPage(
                    name: RoutePath.ATTACH,
                    page: () => AttachPage(),
                    binding: AttachBinding(),
                  ),
                  GetPage(
                    name: RoutePath.DETAIL,
                    page: () => MesTaskDetailView(),
                    children: [
                      GetPage(
                        name: RoutePath.MAIN,
                        page: () => MesTaskDetailTabPage(),
                        binding: MesTaskDetailTabBinding(),
                        children: [
                          ///派工单详情 设置页面
                          GetPage(
                              name: RoutePath.SETTING,
                              page: () => MesTaskDetailSettingPage(),
                              binding: MesTaskDetailSettingBinding(),
                              parameters: const {
                                'type': 'tab',
                                'taskOpenType': '0',
                              }
                          ),
                          ///派工单详情 派工单的附件页面
                          GetPage(
                              name: RoutePath.ATTACH,
                              page: () => AttachPage(),
                              binding: AttachBinding(),
                          ),
                        ]
                      )
                    ]
                  ),
                ]
              ),

              ///安灯系统
              GetPage(
                title:'全场呼叫',
                name: RoutePath.ANDON,
                page: () => AndonPage(),
                binding: AndonBinding(),
                children: [
                  ///设置
                  GetPage(
                    name: RoutePath.SETTING,
                    page: () => AndonSettingPage(),
                    binding: AndonSettingBinding(),
                  ),
                  ///附件、图片查看
                  GetPage(
                    name: RoutePath.ATTACH,
                    page: () => AttachPage(),
                    binding: AttachBinding(),
                  ),
                ]
              ),

              ///系统消息
              GetPage(
                title: '系统消息',
                name: RoutePath.MESSAGE,
                page: () => MessagePage(),
                binding: MessageBinding(),
                children: [
                  GetPage(
                    name: RoutePath.DETAIL,
                    page: () => MessageMainListView(),
                    children: [
                      GetPage(
                        name: RoutePath.MAIN,
                        page: () => MessageMainListPage(),
                        binding: MessageMainListBinding(),
                      ),
                    ]
                  )
                ]
              ),

              ///报工条码
              GetPage(
                title: '报工条码',
                name: RoutePath.SUBMIT_BARCODE,
                page: () => SubmitBarcodePage(),
                binding: SubmitBarcodeBinding(),
              ),

              ///拌料单报工 651071
              GetPage(
                name: RoutePath.MO_MIXTURE,
                page: () => MoMixturePage(customTag: '651071',),
                binding: MoMixtureBinding(),
                parameters: {
                  'progId': '651071'
                },
                children: [
                  GetPage(
                    name: RoutePath.DETAIL,
                    page: () => MoMixtureDetailView(),
                    children: [
                      GetPage(
                        name: RoutePath.MAIN,
                        page: () => MoMixtureDetailTabPage(),
                        binding: MoMixtureDetailTabBinding(),
                        children: [
                          ///拌料单详情 设置页面
                          GetPage(
                            name: RoutePath.SETTING,
                            page: () => MoMixtureDetailSettingPage(),
                            binding: MoMixtureDetailSettingBinding(),
                          ),
                        ]
                      )
                    ]
                  ),
                ]
              ),

              ///粉料单报工 651076
              GetPage(
                  name: RoutePath.MO_POWDER,
                  page: () => MoMixturePage(customTag: '651076'),
                  binding: MoMixtureBinding(),
                  parameters: {
                    'progId': '651076'
                  },
                  children: [
                    GetPage(
                        name: RoutePath.DETAIL,
                        page: () => MoPowderDetailView(),
                        children: [
                          GetPage(
                              name: RoutePath.MAIN,
                              page: () => MoMixtureDetailTabPage(),
                              binding: MoMixtureDetailTabBinding(),
                              children: [
                                ///拌料单详情 设置页面
                                GetPage(
                                  name: RoutePath.SETTING,
                                  page: () => MoMixtureDetailSettingPage(),
                                  binding: MoMixtureDetailSettingBinding(),
                                ),
                              ]
                          )
                        ]
                    ),
                  ]
              ),

              ///发料单打印
              GetPage(
                name: RoutePath.MO_ISSUANCE,
                page: () => MoIssuancePage(),
                binding: MoIssuanceBinding(),
                children: [
                  GetPage(
                    name: RoutePath.DETAIL,
                    page: () => MoIssuanceDetailView(),
                    children: [
                      GetPage(
                        name: RoutePath.MAIN,
                        page: () => MoIssuanceDetailTabPage(),
                        binding: MoIssuanceDetailTabBinding(),
                        children: [
                          ///拌料单详情 设置页面
                          GetPage(
                            name: RoutePath.SETTING,
                            page: () => MoIssuanceDetailSettingPage(),
                            binding: MoIssuanceDetailSettingBinding(),
                          ),
                        ]
                      )
                    ],
                  ),
                ]
              ),

              ///模具档案查询
              GetPage(
                title: '模具档案',
                name: RoutePath.MOULD,
                page: () => MouldPage(),
                binding: MouldBinding(),
                children: [
                  ///模具附件查看
                  GetPage(
                    name: RoutePath.ATTACH,
                    page: () => AttachPage(),
                    binding: AttachBinding(),
                  ),
                ]
              ),

              ///质量巡检首页
              GetPage(
                  name: RoutePath.IPQC_QUALITY_INSPECTION,
                  page: () => QualityInspectionPage(),
                  binding: QualityInspectionBinding(),
                  children: [
                    ///报检单的附件页面
                    GetPage(
                      name: RoutePath.ATTACH,
                      page: () => AttachPage(),
                      binding: AttachBinding(),
                    ),

                    ///设置
                    GetPage(
                      name: RoutePath.SETTING,
                      page: () => QualityInspectionSettingPage(),
                      binding: QualityInspectionSettingBinding(),
                    ),

                    ///检验单详情 路由
                    GetPage(
                        name: RoutePath.DETAIL,
                        page: () => QualityInspectionDetailView(),
                        children: [
                          ///检验单详情 主页面
                          GetPage(
                              name: RoutePath.MAIN,
                              page: () => QualityInspectionDetailFormPage(),
                              binding: QualityInspectionDetailFormBinding(),
                              children: [
                                ///检验单详情 设置页面
                                GetPage(
                                    name: RoutePath.SETTING,
                                    page: () => EmptyPage(),
                                    binding: EmptyBinding(),
                                    parameters: const {
                                      'isShowBackButtonString': '1',
                                    }
                                ),
                                ///检验单附件页面
                                GetPage(
                                  name: RoutePath.ATTACH,
                                  page: () => AttachPage(),
                                  binding: AttachBinding(),
                                ),
                              ]
                          ),
                        ]
                    ),

                    ///终检检验单详情 路由
                    GetPage(
                        name: RoutePath.FINAL_INSPECTION_DETAIL,
                        page: () => FinalInspectionDetailView(),
                        children: [
                          ///终检验单详情 主页面
                          GetPage(
                              name: RoutePath.MAIN,
                              page: () => FinalInspectionDetailFormPage(),
                              binding: FinalInspectionDetailFormBinding(),
                              children: [
                                ///检验单详情 设置页面
                                GetPage(
                                    name: RoutePath.SETTING,
                                    page: () => EmptyPage(),
                                    binding: EmptyBinding(),
                                    parameters: const {
                                      'isShowBackButtonString': '1',
                                    }
                                ),
                                ///检验单附件页面
                                GetPage(
                                  name: RoutePath.ATTACH,
                                  page: () => AttachPage(),
                                  binding: AttachBinding(),
                                ),
                              ]
                          ),
                        ]
                    ),

                    ///来料检验单详情 路由
                    GetPage(
                        name: RoutePath.QM_INSPECTION_DETAIL,
                        page: () => QMInspectionDetailView(),
                        children: [
                          ///来料检验单详情 主页面
                          GetPage(
                              name: RoutePath.MAIN,
                              page: () => QMInspectionDetailFormPage(),
                              binding: QMInspectionDetailFormBinding(),
                              children: [
                                ///检验单详情 设置页面
                                GetPage(
                                    name: RoutePath.SETTING,
                                    page: () => EmptyPage(),
                                    binding: EmptyBinding(),
                                    parameters: const {
                                      'isShowBackButtonString': '1',
                                    }
                                ),
                                ///检验单附件页面
                                GetPage(
                                  name: RoutePath.ATTACH,
                                  page: () => AttachPage(),
                                  binding: AttachBinding(),
                                ),
                              ]
                          ),
                        ]
                    ),

                  ]
              ),

              ///产线
              GetPage(
                title: '生产产线',
                name: RoutePath.BELT_LINE,
                page: () => BeltLinePage(customTag: '660003'),
                binding: BeltLineBinding(),
                parameters: {
                  'progId': '660003'
                },
                children: [
                  GetPage(
                      name: RoutePath.DETAIL,
                      page: () => BeltLineDetailView(),
                      children: [
                        GetPage(
                          name: RoutePath.MAIN,
                          page: () => WorkCenterDetailPage(),
                          binding: WorkCenterDetailBinding(),
                        )
                      ]
                  ),
                ],
              ),

              ///班组
              GetPage(
                title: '生产班组',
                name: RoutePath.TEAM_GROUP,
                page: () => BeltLinePage(customTag: '660021'),
                binding: BeltLineBinding(),
                parameters: {
                  'progId': '660021'
                },
                children: [
                  GetPage(
                      name: RoutePath.DETAIL,
                      page: () => TeamGroupDetailView(),
                      children: [
                        GetPage(
                          name: RoutePath.MAIN,
                          page: () => WorkCenterDetailPage(),
                          binding: WorkCenterDetailBinding(),
                        )
                      ]
                  ),
                ],
              ),

              ///加工中心
              GetPage(
                title: '加工中心',
                name: RoutePath.WORK_CENTER,
                page: () => WorkCenterPage(),
                binding: WorkCenterBinding(),
                children: [
                  GetPage(
                    name: RoutePath.DETAIL,
                    page: () => WorkCenterDetailView(),
                    children: [
                      GetPage(
                        name: RoutePath.MAIN,
                        page: () => WorkCenterDetailPage(),
                        binding: WorkCenterDetailBinding(),
                      )
                    ]
                  ),
                ],
              ),

              ///物料条码 新增 查看
              GetPage(
                  name: RoutePath.INV_BARCODE,
                  page: () => InvBarcodePage(),
                  binding: InvBarcodeBinding(),
                  children: [
                    ///设置
                    GetPage(
                      name: RoutePath.SETTING,
                      page: () => InvBarcodeSettingPage(),
                      binding: InvBarcodeSettingBinding(),
                    ),
                    ///附件、图片查看
                    GetPage(
                      name: RoutePath.ATTACH,
                      page: () => AttachPage(),
                      binding: AttachBinding(),
                    ),
                    ///详情
                    GetPage(
                        name: RoutePath.DETAIL,
                        page: () => InvBarcodeDetailView(),
                        children: [
                          GetPage(
                              name: RoutePath.MAIN,
                              page: () => InvBarcodeDetailTabPage(),
                              binding: InvBarcodeDetailTabBinding(),
                              children: [
                                ///任务单详情 设置页面
                                GetPage(
                                    name: RoutePath.SETTING,
                                    page: () => InvBarcodeDetailSettingPage(),
                                    binding: InvBarcodeDetailSettingBinding(),
                                    parameters: const {
                                      'type': 'tab',
                                    }
                                ),
                                ///任务单详情 派工单的附件页面
                                GetPage(
                                  name: RoutePath.ATTACH,
                                  page: () => AttachPage(),
                                  binding: AttachBinding(),
                                ),
                              ]
                          )
                        ]
                    ),
                  ]
              ),

              ///远程云消息
              GetPage(
                name: RoutePath.CLOUD_SERVICE_TASK,
                page: () => CloudServiceTaskPage(),
                binding: CloudServiceTaskBinding(),
              ),
              
              ///全局设置
              GetPage(
                title:'全局设置',
                name: RoutePath.SETTING,
                page: () => OverallSettingPage(),
                binding: OverallSettingBinding(),
              ),
            ],
          ),

          ///登录 路由页
          GetPage(
            name: RoutePath.LOGIN,
            page: () => LoginView(),
            children: [
              ///登录主页面
              GetPage(
                name: RoutePath.MAIN,
                page: ()=> LoginPage(),
                binding: LoginPageBinding(),
                children: [
                  ///登录设置页面
                  GetPage(
                    name: RoutePath.SETTING,
                    page: ()=> LoginSettingPage(),
                    binding: LoginSettingBinding(),
                  ),
                ]
              ),
            ]
          ),
        ]
    ),
  ];
}
