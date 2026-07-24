import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///拌料单 详情路由页
class MoMixtureDetailView extends StatelessWidget {
  const MoMixtureDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.MO_MIXTURE_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}