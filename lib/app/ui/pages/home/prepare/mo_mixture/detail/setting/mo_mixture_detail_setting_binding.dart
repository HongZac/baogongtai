
import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/setting/mo_mixture_detail_setting_controller.dart';
import 'package:get/get.dart';

///拌料单 OR 粉料单 详情页 设置页面
class MoMixtureDetailSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MoMixtureDetailSettingController>(MoMixtureDetailSettingController(
      mainProgId: int.tryParse(Get.rootDelegate.parameters['mainProgId'].toString()) ?? -1,
    ));
  }

}