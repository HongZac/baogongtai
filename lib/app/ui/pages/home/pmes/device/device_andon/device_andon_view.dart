import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/nav2/router_outlet.dart';


///工作流程-全场呼叫页面 路由页面
class DeviceAndonView extends StatelessWidget  {
  const DeviceAndonView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.DEVICE_ANDON_MAIN_PAGE,
        ),
      );
    });
  }

}
