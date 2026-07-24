import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/nav2/router_outlet.dart';


///班组 详情路由页
class TeamGroupDetailView extends StatelessWidget {
  const TeamGroupDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.TEAM_GROUP_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}