import 'package:basement/model.dart';
import 'package:desktop/app/model/tab_page_controller_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_tab/base_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/check_record_list/pmes_check_record_list_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/check_record_list/pmes_check_record_list_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/check_record/device_check_record_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/check_record/device_check_record_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/detail/device_detail_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/material_reject/device_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/material_reject/device_material_reject_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/production_record/production_record_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/production_record/production_record_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/shutdown_record/shutdown_record_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/shutdown_record/shutdown_record_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/submit/device_submit_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/device/detail_board/submit/device_submit_page.dart';
import 'package:desktop/app/ui/pages/home/pmes/submit_list/pmes_submit_list_controller.dart';
import 'package:desktop/app/ui/pages/home/pmes/submit_list/pmes_submit_list_page.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:basement/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'detail/device_detail_controller.dart';


///设备主页 详情Tab页面 TabBar+PageView实现详情页显示
class DeviceDetailBoardController extends BaseTabController {

  String deviceId;
  ///设备 ID
  String key;
  ///'deviceTask'
  String keyName;
  late final ModelWithGetxController<MoDeviceTaskModel> deviceTaskModelWithGetxController = Get.find<ModelWithGetxController<MoDeviceTaskModel>>(tag: 'PMesDevice-$deviceId');

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  @override
  final int initialIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.DEVICE_DETAIL_BOARD_INITIAL_INDEX_KEY) ?? AppConfig.initialIndex;

  @override
  late final List<TabPageControllerModel> tabPageControllerList = [
    TabPageControllerModel( ///详情页
      put: (){
        Get.put<DeviceDetailController>(DeviceDetailController(
          deviceId: deviceId,
          showAppBar: false,
        ));
      },
      delete: (){
        Get.delete<DeviceDetailController>(force: true);
      }
    ),
    TabPageControllerModel( ///报工页
      put: (){
        Get.put<DeviceSubmitController>(DeviceSubmitController(
          deviceId: deviceId,
          showAppBar: false,
        ));
      },
      delete: (){
        Get.delete<DeviceSubmitController>(force: true);
      }
    ),
    TabPageControllerModel( ///报工单列表页
      put: (){
        Get.put<PMesSubmitListController>(PMesSubmitListController(
          key: key,
          keyName: keyName,
          showAppBar: false,
        ));
      },
      delete: (){
        Get.delete<PMesSubmitListController>(force: true);
      }
    ),
    TabPageControllerModel( ///报次品页
      put: (){
        Get.put<DeviceCheckRecordController>(DeviceCheckRecordController(
          deviceId: deviceId,
          showAppBar: false,
        ));
      },
      delete: (){
        Get.delete<DeviceCheckRecordController>(force: true);
      }
    ),
    TabPageControllerModel( ///不良品上报页面
      put: (){
        Get.put<DeviceMaterialRejectController>(DeviceMaterialRejectController(
          deviceId: deviceId,
          showAppBar: false,
        ));
      },
      delete: (){
        Get.delete<DeviceMaterialRejectController>(force: true);
      }
    ),
    TabPageControllerModel( ///次品列表页
      put: (){
        Get.put<PMesCheckRecordListController>(PMesCheckRecordListController(
          key: key,
          keyName: keyName,
          showAppBar: false,
        ));
      },
      delete: (){
        Get.delete<PMesCheckRecordListController>(force: true);
      }
    ),
    TabPageControllerModel( ///生产记录列表页
      put: (){
        Get.put<ProductionRecordController>(ProductionRecordController(
          deviceId: deviceId,
        ));
      },
      delete: (){
        Get.delete<ProductionRecordController>(force: true);
      }
    ),
    TabPageControllerModel( ///停机记录列表页
        put: (){
          Get.put<ShutdownRecordController>(ShutdownRecordController(
            deviceId: deviceId,
          ));
        },
        delete: (){
          Get.delete<ShutdownRecordController>(force: true);
        }
    ),
  ];

  @override
  late final List<String> tabValueList = [
    '设备详情',
    '生产报工',
    '报工列表',
    '次品录入',
    '材料不良',
    '次品列表',
    '生产记录',
    '停机记录',
  ];

  @override
  final List<Widget> tabPageView = [
    DeviceDetailPage(),
    DeviceSubmitPage(),
    PMesSubmitListPage(),
    DeviceCheckRecordPage(),
    DeviceMaterialRejectPage(),
    PMesCheckRecordListPage(),
    ProductionRecordPage(),
    ShutdownRecordPage(),
  ];


  DeviceDetailBoardController({
    super.progId = -1,
    required this.deviceId,
    required this.key,
    required this.keyName,
    this.noPermission = false,
    this.permissionInfo = '',
  });

  @override
  Future<void> settingOnTap() async {
    Get.rootDelegate.toNamed(
      AppRoutes.PMES_REAL_TIME_MONITOR_DETAIL_SETTING_PAGE,
      parameters: {
        'noPermission': noPermission ? '1' : '0',
        'permissionInfo': permissionInfo,
      }
    );
  }

  @override
  void onClose() {
    super.onClose();
  }

}