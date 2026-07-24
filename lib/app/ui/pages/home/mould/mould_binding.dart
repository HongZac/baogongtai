import 'package:desktop/app/ui/pages/home/mould/mould_controller.dart';
import 'package:get/get.dart';

///模具查询 首页
class MouldBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MouldController>(MouldController());
  }

}