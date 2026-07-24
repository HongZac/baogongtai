import 'package:basement/model.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/model/tab_page_controller_model.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/ui/pages/home/base/base_tab/base_tab_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/submit/mo_mixture_submit_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/submit/mo_mixture_submit_page.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/submit_list/mo_mixture_submit_list_controller.dart';
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/submit_list/mo_mixture_submit_list_page.dart';
import 'package:desktop/app/utils/app_config.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///拌料单 OR 粉料单 详情Tab页
class MoMixtureDetailTabController extends BaseTabController {

  ///主页面的 progId
  final mainProgId;
  late final String typeTitle = mainProgId == 651071 ? '拌料' : mainProgId == 651076 ? '粉料' : '';
  late final int submitProgId = mainProgId == 651071 ? 651073 : mainProgId == 651076 ? 651078 : -1;

  MoMixtureModel mixtureModel;
  String moMixtureId;

  @override
  late final int initialIndex = ShareStorageUtil.instance?.read(
    ShareKeyUtil().getMoPowderSharedPreferencesKey(
      mainProgId,
      SharedPreferencesKeys.MO_MIXTURE_DETAIL_INITIAL_INDEX_KEY
    )
  ) ?? AppConfig.initialIndex;

  @override
  late final List<TabPageControllerModel> tabPageControllerList = [
    //region
    TabPageControllerModel( ///报工页
        put: (){
          Get.put<MoMixtureSubmitController>(MoMixtureSubmitController(
            mixtureModel: mixtureModel,
            progId: submitProgId,
            mainProgId: mainProgId,
          ));
        },
        delete: (){
          Get.delete<MoMixtureSubmitController>(force: true);
        }
    ),
    TabPageControllerModel( ///报工单列表页
        put: (){
          Get.put<MoMixtureSubmitListController>(MoMixtureSubmitListController(
            moMixtureId: moMixtureId,
            progId: submitProgId,
            mainProgId: mainProgId,
          ));
        },
        delete: (){
          Get.delete<MoMixtureSubmitListController>(force: true);
        }
    ),
    //endregion
  ];

  @override
  late final List<String> tabValueList = [
    '$typeTitle报工',
    '报工列表',
  ];

  @override
  final List<Widget> tabPageView = [
    MoMixtureSubmitPage(),
    MoMixtureSubmitListPage(),
  ];


  MoMixtureDetailTabController({
    super.progId = -1,
    required this.mixtureModel,
    required this.moMixtureId,
    required this.mainProgId,
  });


  @override
  Future<void> settingOnTap() async {
    String route = '';
    switch (mainProgId){
      case 651071:
        route = AppRoutes.MO_MIXTURE_DETAIL_SETTING_PAGE;
        break;
      case 651076:
        route = AppRoutes.MO_POWDER_DETAIL_SETTING_PAGE;
        break;
    }
    Get.rootDelegate.toNamed(
      route,
      parameters: {
        'mainProgId': mainProgId.toString(),
      }
    );
  }

}