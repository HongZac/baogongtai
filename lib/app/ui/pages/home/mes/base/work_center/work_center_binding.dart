import 'package:desktop/app/ui/pages/home/mes/base/work_center/work_center_controller.dart';
import 'package:get/get.dart';

///加工中心 660022
class WorkCenterBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<WorkCenterController>(WorkCenterController());
  }

}