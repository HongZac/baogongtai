import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/nav2/router_outlet.dart';


///机台报次品 路由页面
class DeviceCheckRecordView extends StatelessWidget  {
  const DeviceCheckRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.PMES_REAL_TIME_MONITOR_CHECK_RECORD_MAIN_PAGE,
        ),
      );
    });
  }

}
