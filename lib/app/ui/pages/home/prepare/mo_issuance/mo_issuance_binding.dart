import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/mo_issuance_controller.dart';
import 'package:get/get.dart';

///发料单 主页面
class MoIssuanceBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MoIssuanceController>(MoIssuanceController());
  }

}