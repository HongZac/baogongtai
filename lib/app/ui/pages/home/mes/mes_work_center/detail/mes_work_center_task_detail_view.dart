import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 加工中心（可选择派工单报工 OR 任务单报工） 派工单 详情路由页
class MesWorkCenterTaskDetailView extends StatelessWidget {
  const MesWorkCenterTaskDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.MES_WORK_CENTER_TASK_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}