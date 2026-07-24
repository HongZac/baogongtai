import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/tab_page_controller_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_tab/base_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/check_record_list/mes_check_record_list_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/check_record_list/mes_check_record_list_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_order/detail/device_detail/mes_device_order_detail_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_device_order/detail/device_detail/mes_device_order_detail_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/check_record/mes_order_check_record_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/check_record/mes_order_check_record_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/material_reject/mes_order_material_reject_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/material_reject/mes_order_material_reject_page.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/submit/mes_order_submit_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/mes_order/detail/submit/mes_order_submit_page.dart';
import 'package:desktop/app/ui/pages/home/mes/submit_list/mes_submit_list_controller.dart';
import 'package:desktop/app/ui/pages/home/mes/submit_list/mes_submit_list_page.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产任务单 详情Tab页面
class MesOrderDetailTabController extends BaseTabController {

  MoOpOrderModel orderModel;
  String key;
  final String keyName;
  String invId;
  ///0：生产任务单； 1：设备任务单； 2：加工中心任务单
  final int orderOpenType;
  ///上一个页面选中的加工中心（加工中心任务单）
  final String workCenterId;

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  @override
  late final int initialIndex = (orderOpenType == 0
      ? ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_ORDER_DETAIL_INITIAL_INDEX_KEY)
      : orderOpenType == 1
      ? ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_DEVICE_ORDER_DETAIL_INITIAL_INDEX_KEY)
      : orderOpenType == 2
      ? ShareStorageUtil.instance?.read(SharedPreferencesKeys.MES_WORK_CENTER_ORDER_DETAIL_INITIAL_INDEX_KEY)
      : null)
      ?? AppConfig.initialIndex;

  @override
  late final List<TabPageControllerModel> tabPageControllerList = [
    ///详情页
    if (orderOpenType == 1)
      TabPageControllerModel( ///详情页
          put: (){
            Get.put<MesDeviceOrderDetailController>(MesDeviceOrderDetailController(
              deviceId: key,
            ));
          },
          delete: (){
            Get.delete<MesDeviceOrderDetailController>(force: true);
          }
      ),

    TabPageControllerModel( ///报工页
        put: (){
          Get.put<MesOrderSubmitController>(MesOrderSubmitController(
            orderModel: MoOpOrderModel.fromJson(orderModel.toJson()),
            orderOpenType: orderOpenType,
            workCenterId: workCenterId,
            showAppBar: false,
            deviceId: orderOpenType == 1 ? key : '',
          ));
        },
        delete: (){
          Get.delete<MesOrderSubmitController>(force: true);
        }
    ),
    TabPageControllerModel( ///报工单列表页
        put: (){
          Get.put<MesSubmitListController>(MesSubmitListController(
            key: key,
            keyName: keyName,
            invId: invId,
            showAppBar: false,
          ));
        },
        delete: (){
          Get.delete<MesSubmitListController>(force: true);
        }
    ),
    TabPageControllerModel( ///报次品页
        put: (){
          Get.put<MesOrderCheckRecordController>(MesOrderCheckRecordController(
            orderModel: MoOpOrderModel.fromJson(orderModel.toJson()),
            orderOpenType: orderOpenType,
            workCenterId: workCenterId,
            showAppBar: false,
            deviceId: orderOpenType == 1 ? key : '',
          ));
        },
        delete: (){
          Get.delete<MesOrderCheckRecordController>(force: true);
        }
    ),
    TabPageControllerModel( ///不良品上报页面
        put: (){
          Get.put<MesOrderMaterialRejectController>(MesOrderMaterialRejectController(
            orderModel: MoOpOrderModel.fromJson(orderModel.toJson()),
            orderOpenType: orderOpenType,
            showAppBar: false,
            deviceId: orderOpenType == 1 ? key : '',
          ));
        },
        delete: (){
          Get.delete<MesOrderMaterialRejectController>(force: true);
        }
    ),
    TabPageControllerModel( ///次品列表页
        put: (){
          Get.put<MesCheckRecordListController>(MesCheckRecordListController(
            key: key,
            keyName: keyName,
            invId: invId,
            showAppBar: false,
          ));
        },
        delete: (){
          Get.delete<MesCheckRecordListController>(force: true);
        }
    ),
  ];

  @override
  late final List<String> tabValueList = [
    if (orderOpenType == 1)
      '设备详情',
    '生产报工',
    '报工列表',
    '次品录入',
    '材料不良',
    '次品列表',
  ];

  @override
  late final List<Widget> tabPageView = [
    if (orderOpenType == 1)
      MesDeviceOrderDetailPage(),

    MesOrderSubmitPage(),
    MesSubmitListPage(),
    MesOrderCheckRecordPage(),
    MesOrderMaterialRejectPage(),
    MesCheckRecordListPage(),
  ];


  MesOrderDetailTabController({
    super.progId = -1,
    required this.orderModel,
    required this.key,
    required this.keyName,
    required this.invId,
    required this.orderOpenType,
    this.workCenterId = '',
    this.noPermission = false,
    this.permissionInfo = '',
  });


  @override
  Future<void> settingOnTap() async {
    if (orderOpenType == 0){
      Get.rootDelegate.toNamed(
        AppRoutes.MES_ORDER_DETAIL_SETTING_PAGE,
        parameters: {
          'noPermission': noPermission ? '1' : '0',
          'permissionInfo': permissionInfo,
        }
      );
    }
    else if (orderOpenType == 1){
      Get.rootDelegate.toNamed(
          AppRoutes.MES_DEVICE_ORDER_DETAIL_SETTING_PAGE,
          parameters: {
            'noPermission': noPermission ? '1' : '0',
            'permissionInfo': permissionInfo,
          }
      );
    }
    else if (orderOpenType == 2){
      Get.rootDelegate.toNamed(
        AppRoutes.MES_WORK_CENTER_ORDER_DETAIL_SETTING_PAGE,
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