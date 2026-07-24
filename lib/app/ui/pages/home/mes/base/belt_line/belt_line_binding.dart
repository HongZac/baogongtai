import 'package:desktop/app/ui/pages/home/mes/base/belt_line/belt_line_controller.dart';
import 'package:get/get.dart';

///产线管理 660003；加工中心 660022; 生产班组 660021 ; 生产工位 660025 ;
class BeltLineBinding implements Bindings {
  @override
  void dependencies() {
    String? tag = Get.rootDelegate.parameters['progId'];
    Get.put<BeltLineController>(BeltLineController(
      progId: int.tryParse(Get.rootDelegate.parameters['progId'].toString()) ?? -1
    ), tag: tag);
  }

}