import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/final_inspection_detail/final_inspection_form/final_inspection_detail_form_controller.dart';
import 'package:get/get.dart';

///质量巡检 终检检验单（生产完工检验单）详情页（编辑 + 查看）
class FinalInspectionDetailFormBinding implements Bindings {

  @override
  void dependencies() {
    Get.put<FinalInspectionDetailFormController>(FinalInspectionDetailFormController(
      moInspectId: Get.rootDelegate.parameters['moInspectId'] ?? '',
      moCheckId: Get.rootDelegate.parameters['moCheckId'] ?? '',
      taskId: Get.rootDelegate.parameters['taskId'] ?? '',
      taskToCheckVoucherCategory: int.tryParse(Get.rootDelegate.parameters['checkVoucherCategory'].toString()) ?? 2,
    ));
  }
}