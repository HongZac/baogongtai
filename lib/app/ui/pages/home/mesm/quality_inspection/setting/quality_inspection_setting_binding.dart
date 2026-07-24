
import 'package:desktop/app/ui/pages/home/mesm/quality_inspection/setting/quality_inspection_setting_controller.dart';
import 'package:get/get.dart';

///质量巡检首页 设置页面
class QualityInspectionSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<QualityInspectionSettingController>(QualityInspectionSettingController());
  }

}