import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产 加工中心（可选择派工单报工 OR 任务单报工） 任务单 详情路由页
class MesWorkCenterOrderDetailView extends StatelessWidget {
  const MesWorkCenterOrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.MES_WORK_CENTER_ORDER_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}