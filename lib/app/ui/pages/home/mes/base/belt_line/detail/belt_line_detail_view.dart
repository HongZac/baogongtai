import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/nav2/router_outlet.dart';


///产线管理 详情路由页
class BeltLineDetailView extends StatelessWidget {
  const BeltLineDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.BELT_LINE_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}