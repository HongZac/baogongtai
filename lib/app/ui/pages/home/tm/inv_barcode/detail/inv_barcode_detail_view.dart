import 'package:desktop/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///物料条码新增查看 详情路由页
class InvBarcodeDetailView extends StatelessWidget {
  const InvBarcodeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(builder: (context,delegate,currentRoute) {
      return Scaffold(
        body: GetRouterOutlet(
          initialRoute: AppRoutes.INV_BARCODE_DETAIL_MAIN_PAGE,
        ),
      );
    });
  }

}
