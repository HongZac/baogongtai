import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产派工单 详情路由页
class MesTaskDetailView extends StatelessWidget  {
  const MesTaskDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.MES_TASK_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}
