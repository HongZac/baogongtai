import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MesDeviceOrderDetailView extends StatelessWidget {
  const MesDeviceOrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.MES_DEVICE_ORDER_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }
}