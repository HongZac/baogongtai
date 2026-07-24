import 'package:get/get.dart';

import 'device_check_record_controller.dart';


///注塑 机台 报次品页面
class DeviceCheckRecordBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<DeviceCheckRecordController>(DeviceCheckRecordController(
      deviceId: Get.rootDelegate.parameters['deviceId'] ?? '',
    ));
  }
}