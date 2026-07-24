import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///注塑 设备实时监测 详情路由页
class PMesDeviceDetailView extends StatelessWidget {
  const PMesDeviceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.PMES_REAL_TIME_MONITOR_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}
