import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/nav2/router_outlet.dart';


///加工中心 详情路由页
class WorkCenterDetailView extends StatelessWidget {
  const WorkCenterDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.WORK_CENTER_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}