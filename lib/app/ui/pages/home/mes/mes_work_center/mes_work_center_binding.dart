import 'package:desktop/app/ui/pages/home/mes/mes_work_center/mes_work_center_controller.dart';
import 'package:get/get.dart';


///生产 加工中心（可选择派工单报工 OR 任务单报工）
class MesWorkCenterBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MesWorkCenterController>(MesWorkCenterController());
  }

}