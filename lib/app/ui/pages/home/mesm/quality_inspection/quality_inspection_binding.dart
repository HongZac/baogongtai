import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/quality_inspection_controller.dart';
import 'package:get/get.dart';


///质量巡检首页
class QualityInspectionBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<QualityInspectionController>(QualityInspectionController());
  }

}