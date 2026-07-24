import 'package:desktop/app/ui/pages/empty_page/empty_controller.dart';
import 'package:get/get.dart';

class EmptyBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<EmptyController>(
        EmptyController(progId: Get.rootDelegate.parameters['progId'] ?? '', isShowBackButtonString: Get.rootDelegate.parameters['isShowBackButtonString'] ?? '0')
    );
  }

}