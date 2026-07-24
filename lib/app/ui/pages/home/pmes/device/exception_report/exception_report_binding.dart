import 'package:get/get.dart';

import 'exception_report_controller.dart';

class ExceptionReportBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<ExceptionReportController>(ExceptionReportController(
      deviceId: Get.rootDelegate.parameters['deviceId'] ?? '',
    ));

  }

}