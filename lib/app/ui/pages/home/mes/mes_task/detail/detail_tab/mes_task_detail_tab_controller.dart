import 'package:basement/model.dart';
import 'package:desktop/app/model/tab_page_controller_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_tab/base_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/check_record_list/mes_check_record_list_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/check_record_list/mes_check_record_list_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/detail/device_detail/mes_device_task_detail_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/detail/device_detail/mes_device_task_detail_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/check_record/mes_task_check_record_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/check_record/mes_task_check_record_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/material_reject/mes_task_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/material_reject/mes_task_material_reject_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/scan_code/mes_task_scan_code_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/scan_code/mes_task_scan_code_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/submit/mes_task_submit_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_task/detail/submit/mes_task_submit_page.dart';
import 'package:desktop/app/ui/pages/home/mes/submit_list/mes_submit_list_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/submit_list/mes_submit_list_page.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产派工单 详情Tab页面
class MesTaskDetailTabController extends BaseTabController{

  MoTaskModel taskModel;
  String key;
  String keyName;
  ///0：生产派工； 1：设备派工； 2：加工中心派工
  final int taskOpenType;

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  @override
  late final int initialIndex = (taskOpenType == 0
      ? ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_TASK_DETAIL_INITIAL_INDEX_KEY)
      : taskOpenType == 1
      ? ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_TASK_DETAIL_INITIAL_INDEX_KEY)
      : taskOpenType == 2
      ? ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_TASK_DETAIL_INITIAL_INDEX_KEY)
      : null)
      ?? AppConfig.initialIndex;

  @override
  late final List<TabPageControllerModel> tabPageControllerList = [
    if (taskOpenType == 1)
      TabPageControllerModel( ///详情页
          put: (){
            Get.put<MesDeviceTaskDetailController>(MesDeviceTaskDetailController(
              deviceId: key,
            ));
          },
          delete: (){
            Get.delete<MesDeviceTaskDetailController>(force: true);
          }
      ),

    TabPageControllerModel( ///报工页
        put: (){
          Get.put<MesTaskSubmitController>(MesTaskSubmitController(
            taskModel: MoTaskModel.fromJson(taskModel.toJson()),
            taskOpenType: taskOpenType,
            showAppBar: false,
            deviceId: taskOpenType == 1 ? key : '',
          ));
        },
        delete: (){
          Get.delete<MesTaskSubmitController>(force: true);
        }
    ),
    TabPageControllerModel( ///报工单列表页
        put: (){
          Get.put<MesSubmitListController>(MesSubmitListController(
            key: key,
            keyName: keyName,
            showAppBar: false,
          ));
        },
        delete: (){
          Get.delete<MesSubmitListController>(force: true);
        }
    ),
    TabPageControllerModel( ///报次品页
        put: (){
          Get.put<MesTaskCheckRecordController>(MesTaskCheckRecordController(
            taskModel: MoTaskModel.fromJson(taskModel.toJson()),
            taskOpenType: taskOpenType,
            showAppBar: false,
            deviceId: taskOpenType == 1 ? key : '',
          ));
        },
        delete: (){
          Get.delete<MesTaskCheckRecordController>(force: true);
        }
    ),
    TabPageControllerModel( ///不良品上报页面
        put: (){
          Get.put<MesTaskMaterialRejectController>(MesTaskMaterialRejectController(
            taskModel: MoTaskModel.fromJson(taskModel.toJson()),
            taskOpenType: taskOpenType,
            showAppBar: false,
            deviceId: taskOpenType == 1 ? key : '',
          ));
        },
        delete: (){
          Get.delete<MesTaskMaterialRejectController>(force: true);
        }
    ),
    TabPageControllerModel( ///次品列表页
        put: (){
          Get.put<MesCheckRecordListController>(MesCheckRecordListController(
            key: key,
            keyName: keyName,
            showAppBar: false,
          ));
        },
        delete: (){
          Get.delete<MesCheckRecordListController>(force: true);
        }
    ),
    TabPageControllerModel( ///报工扫码页
        put: (){
          Get.put<MesTaskScanCodeController>(MesTaskScanCodeController(
            taskModel: MoTaskModel.fromJson(taskModel.toJson()),
            taskOpenType: taskOpenType,
            showAppBar: false,
            deviceId: taskOpenType == 1 ? key : '',
          ));
        },
        delete: (){
          Get.delete<MesTaskScanCodeController>(force: true);
        }
    ),
  ];

  @override
  late final List<String> tabValueList = [
    if (taskOpenType == 1)
      '设备详情',
    '生产报工',
    '报工列表',
    '次品录入',
    '材料不良',
    '次品列表',
    '报工扫码'
  ];

  @override
  late final List<Widget> tabPageView = [
    if (taskOpenType == 1)
      MesDeviceTaskDetailPage(),
    MesTaskSubmitPage(),
    MesSubmitListPage(),
    MesTaskCheckRecordPage(),
    MesTaskMaterialRejectPage(),
    MesCheckRecordListPage(),
    MesTaskScanCodePage(),
  ];


  MesTaskDetailTabController({
    super.progId = -1,
    required this.taskModel,
    required this.key,
    required this.keyName,
    required this.taskOpenType,
    this.noPermission = false,
    this.permissionInfo = '',
  });

  @override
  Future<void> settingOnTap() async {
    if (taskOpenType == 0){
      Get.rootDelegate.toNamed(
        AppRoutes.MES_TASK_DETAIL_SETTING_PAGE,
        parameters: {
          'noPermission': noPermission ? '1' : '0',
          'permissionInfo': permissionInfo,
        }
      );
    }
    else if (taskOpenType == 1){
      Get.rootDelegate.toNamed(
        AppRoutes.MES_DEVICE_TASK_DETAIL_SETTING_PAGE,
        parameters: {
          'noPermission': noPermission ? '1' : '0',
          'permissionInfo': permissionInfo,
        }
      );
    }
    else if (taskOpenType == 2){
      Get.rootDelegate.toNamed(
        AppRoutes.MES_WORK_CENTER_TASK_DETAIL_SETTING_PAGE,
        parameters: {
          'noPermission': noPermission ? '1' : '0',
          'permissionInfo': permissionInfo,
        }
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

}