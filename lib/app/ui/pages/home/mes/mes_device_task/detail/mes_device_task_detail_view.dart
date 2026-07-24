import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 设备对应生产派工单 详情路由页
class MesDeviceTaskDetailView extends StatelessWidget {
  const MesDeviceTaskDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.MES_DEVICE_TASK_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}
