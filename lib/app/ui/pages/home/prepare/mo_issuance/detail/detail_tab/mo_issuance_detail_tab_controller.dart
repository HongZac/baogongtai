import 'package:basement/model.dart';
import 'package:desktop/app/model/tab_page_controller_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_tab/base_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/detail/edit/mo_issuance_edit_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/detail/edit/mo_issuance_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///发料单 详情Tab页
class MoIssuanceDetailTabController extends BaseTabController {

  MoIssuanceModel issuanceModel;

  @override
  final int initialIndex = 0;
  //ShareStorageUtil.instance?.read(SharedPreferencesKeys.MO_ISSUANCE_DETAIL_INITIAL_INDEX_KEY) ?? AppConfig.initialIndex;

  @override
  late final List<TabPageControllerModel> tabPageControllerList = [
    //region
    TabPageControllerModel( ///报工页
        put: (){
          Get.put<MoIssuanceEditController>(MoIssuanceEditController(
            issuanceModel: issuanceModel,
          ));
        },
        delete: (){
          Get.delete<MoIssuanceEditController>(force: true);
        }
    ),
    //endregion
  ];

  @override
  final List<String> tabValueList = [
    '发料打印',
  ];

  @override
  final List<Widget> tabPageView = [
    MoIssuanceEditPage(),
  ];


  MoIssuanceDetailTabController({
    super.progId = -1,
    required this.issuanceModel,
  });

  @override
  Future<void> settingOnTap() async {
    Get.rootDelegate.toNamed(AppRoutes.MO_ISSUANCE_DETAIL_SETTING_PAGE);
  }

}