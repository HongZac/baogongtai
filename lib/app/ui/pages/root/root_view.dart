import 'package:context_menus/context_menus.dart';
import 'package:desktop/app/routes/app_routes.dart';
import 'package:desktop/app/utils/mine_context_menu_region_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import './root_controller.dart';

///根页面
class RootView extends GetView<RootController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RootController>(builder: (_) {
      return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (GetPlatform.isAndroid) {
              ///点击空白关闭软键盘
              FocusManager.instance.primaryFocus?.unfocus();

              ///全屏，关闭状态栏
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
            }
          },
          child: GetRouterOutlet.builder(builder: (BuildContext context, GetDelegate delegate, GetNavConfig? currentRoute) {
            return ContextMenuOverlay(
              cardBuilder: (BuildContext cardContext, children) {
                return MineContextMenuRegionUtil.cardBuilderWidget(cardContext, children);
              },
              buttonStyle: MineContextMenuRegionUtil.contextMenuButtonStyle(context),
              child: Scaffold(
                body: GetRouterOutlet(
                initialRoute: AppRoutes.LOGIN_PAGE,
                )
              ),
            );
          })
      );
    });
  }
}
