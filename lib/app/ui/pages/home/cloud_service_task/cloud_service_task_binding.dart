import 'package:desktop/app/ui/pages/home/cloud_service_task/cloud_service_task_controller.dart';
import 'package:get/get.dart';


class CloudServiceTaskBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<CloudServiceTaskController>(CloudServiceTaskController());
  }
}