import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/detail/inspection_detail/inspection_form/quality_inspection_detail_form_controller.dart';
import 'package:get/get.dart';


///质量巡检 首巡末检检验单详情页（编辑 + 查看）
class QualityInspectionDetailFormBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<QualityInspectionDetailFormController>(QualityInspectionDetailFormController(
      moInspectId: Get.rootDelegate.parameters['moInspectId'] ?? '',
      moCheckId: Get.rootDelegate.parameters['moCheckId'] ?? '',
      taskId: Get.rootDelegate.parameters['taskId'] ?? '',
      taskToCheckVoucherCategory: int.tryParse(Get.rootDelegate.parameters['checkVoucherCategory'].toString()) ?? 2,
      openType: int.tryParse(Get.rootDelegate.parameters['openType'].toString()) ?? 0,
    ));
  }

}