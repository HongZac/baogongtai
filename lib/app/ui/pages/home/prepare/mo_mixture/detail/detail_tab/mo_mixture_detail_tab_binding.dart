import 'package:desktop/app/ui/pages/home/prepare/mo_mixture/detail/detail_tab/mo_mixture_detail_tab_controller.dart';
import 'package:get/get.dart';

///拌料单 OR 粉料单 详情Tab页
class MoMixtureDetailTabBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MoMixtureDetailTabController>(MoMixtureDetailTabController(
       mixtureModel: Get.rootDelegate.arguments(),
       moMixtureId: Get.rootDelegate.parameters['moMixtureId'] ?? '',
       mainProgId: int.tryParse(Get.rootDelegate.parameters['mainProgId'].toString()) ?? -1,
    ));
  }

}