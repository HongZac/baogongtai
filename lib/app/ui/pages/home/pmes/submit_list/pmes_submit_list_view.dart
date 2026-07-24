import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/nav2/router_outlet.dart';


///机台报工单列表 路由页面
class PMesSubmitListView extends StatelessWidget  {
  const PMesSubmitListView({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: initialRoute,
        ),
      );
    });
  }

}
