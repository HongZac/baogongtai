
import 'package:desktop/app/ui/pages/home/mes/base/work_center/detail/work_center_detail_controller.dart';
import 'package:get/get.dart';


///加工中心 详情页面
class WorkCenterDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<WorkCenterDetailController>(WorkCenterDetailController(
      progId: int.tryParse(Get.rootDelegate.parameters['progId'].toString()) ?? -1,
      workCenterId: Get.rootDelegate.parameters['workCenterId'] ?? '',
    ));
  }

}