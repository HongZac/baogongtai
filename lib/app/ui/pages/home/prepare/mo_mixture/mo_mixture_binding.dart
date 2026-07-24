import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/mo_mixture_controller.dart';
import 'package:get/get.dart';

///拌料单 651071 OR 粉料单 651076 主页面
class MoMixtureBinding implements Bindings {
  @override
  void dependencies() {
    String? tag = Get.rootDelegate.parameters['progId'];
    Get.put<MoMixtureController>(MoMixtureController(
      progId: int.tryParse(Get.rootDelegate.parameters['progId'].toString()) ?? -1
    ), tag: tag);
  }

}