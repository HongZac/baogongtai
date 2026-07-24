import 'package:get/get.dart';
import 'detail_board_controller.dart';

///设备主页  TabBar+PageView实现详情页显示
class DeviceDetailBoardBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<DeviceDetailBoardController>(DeviceDetailBoardController(
      deviceId: Get.rootDelegate.parameters['deviceId'] ?? '',
      key: Get.rootDelegate.parameters['key'] ?? '',
      keyName: Get.rootDelegate.parameters['keyName'] ?? '',
      noPermission: Get.rootDelegate.parameters['noPermission'] == '1',
      permissionInfo: Get.rootDelegate.parameters['permissionInfo'] ?? '',
    ));
  }
}
