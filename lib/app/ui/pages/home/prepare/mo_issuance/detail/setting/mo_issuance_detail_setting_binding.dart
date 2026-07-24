import 'package:desktop/app/ui/pages/home/prepare/mo_issuance/detail/setting/mo_issuance_detail_setting_controller.dart';
import 'package:get/get.dart';

///发料单 详情页 设置页面
class MoIssuanceDetailSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MoIssuanceDetailSettingController>(MoIssuanceDetailSettingController());
  }

}