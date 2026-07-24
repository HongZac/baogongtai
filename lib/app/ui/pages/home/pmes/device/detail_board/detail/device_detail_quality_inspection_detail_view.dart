import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///设备详情-质量巡检 检验单详情路由页
class DeviceDetailQualityInspectionDetailView extends StatelessWidget  {
  const DeviceDetailQualityInspectionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (BuildContext context, GetDelegate delegate, GetNavConfig? currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.PMES_REAL_TIME_MONITOR_DETAIL_IPQC_QUALITY_INSPECTION_MAIN_PAGE,
        ),
      );
    });
  }

}
