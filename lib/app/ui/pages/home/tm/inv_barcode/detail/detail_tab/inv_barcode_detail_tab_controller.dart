import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/tab_page_controller_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_tab/base_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/add_form/inv_barcode_add_form_controller.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/add_form/inv_barcode_add_form_page.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/list/inv_barcode_list_controller.dart';
import 'package:desktop/app/ui/pages/home/tm/inv_barcode/detail/list/inv_barcode_list_page.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///物料条码新增查看 详情Tab页面
class InvBarcodeDetailTabController extends BaseTabController {

  InventoryModel inventoryModel;
  String key;

  ///是否没有修改设置的权限
  final bool noPermission;
  final String permissionInfo;

  @override
  late final int initialIndex = ShareStorageUtil.instance?.read(SharedPreferencesKeys.INV_BARCODE_DETAIL_INITIAL_INDEX_KEY) ?? AppConfig.initialIndex;

  @override
  late final List<TabPageControllerModel> tabPageControllerList = [
    TabPageControllerModel( ///新增页
      put: (){
        Get.put<InvBarcodeAddFormController>(InvBarcodeAddFormController(
          inventoryModel: InventoryModel.fromJson(inventoryModel.toJson()),
          showAppBar: false,
        ));
      },
      delete: (){
        Get.delete<InvBarcodeAddFormController>(force: true);
      }
    ),
    TabPageControllerModel( ///条码列表页
        put: (){
          Get.put<InvBarcodeListController>(InvBarcodeListController(
            inventoryModel: InventoryModel.fromJson(inventoryModel.toJson()),
            showAppBar: false,
          ));
        },
        delete: (){
          Get.delete<InvBarcodeListController>(force: true);
        }
    ),
  ];

  @override
  final List<String> tabValueList = [
    '新增条码',
    '条码列表',
  ];

  @override
  final List<Widget> tabPageView = [
    InvBarcodeAddFormPage(),
    InvBarcodeListPage(),
  ];

  InvBarcodeDetailTabController({
    super.progId = -1,
    required this.inventoryModel,
    required this.key,
    this.noPermission = false,
    this.permissionInfo = '',
  });

  @override
  void settingOnTap() {
    Get.rootDelegate.toNamed(
        AppRoutes.INV_BARCODE_DETAIL_SETTING_PAGE,
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