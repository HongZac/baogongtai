import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';

///发料单 详情路由页
class MoIssuanceDetailView extends StatelessWidget {
  const MoIssuanceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.MO_ISSUANCE_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }
}