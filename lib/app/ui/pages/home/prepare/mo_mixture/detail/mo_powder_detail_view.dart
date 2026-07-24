import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///粉料单 详情路由页
class MoPowderDetailView extends StatelessWidget {
  const MoPowderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.MO_POWDER_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}