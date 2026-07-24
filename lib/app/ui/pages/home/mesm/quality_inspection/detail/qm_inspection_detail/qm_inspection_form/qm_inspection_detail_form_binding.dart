import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/qm_inspection_detail/qm_inspection_form/qm_inspection_detail_form_controller.dart';
import 'package:get/get.dart';

///质量巡检 来料检验单详情页（编辑 + 查看）
class QMInspectionDetailFormBinding implements Bindings {

  @override
  void dependencies() {
    Get.put<QMInspectionDetailFormController>(QMInspectionDetailFormController(
      inspectMxID: Get.rootDelegate.parameters['inspectMxID'] ?? '',
      moCheckId: Get.rootDelegate.parameters['moCheckId'] ?? '',
      taskId: Get.rootDelegate.parameters['taskId'] ?? '',
      taskToCheckVoucherCategory: int.tryParse(Get.rootDelegate.parameters['checkVoucherCategory'].toString()) ?? 2,
    ));
  }
}