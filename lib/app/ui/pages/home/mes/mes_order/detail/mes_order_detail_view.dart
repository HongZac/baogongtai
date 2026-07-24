import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///生产任务单 详情路由页
class MesOrderDetailView extends StatelessWidget {
  const MesOrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.MES_ORDER_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}
