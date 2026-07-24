import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/detail/detail_tab/mo_issuance_detail_tab_controller.dart';
import 'package:get/get.dart';

///发料单 详情Tab页
class MoIssuanceDetailTabBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MoIssuanceDetailTabController>(MoIssuanceDetailTabController(
      issuanceModel: Get.rootDelegate.arguments(),
    ));
  }

}