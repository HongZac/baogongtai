import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///质量巡检 终检检验单详情路由页
class FinalInspectionDetailView extends StatelessWidget  {
  const FinalInspectionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (BuildContext context, GetDelegate delegate, GetNavConfig? currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.IPQC_QUALITY_INSPECTION_FINAL_INSPECTION_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}
