
import 'package:desktop/app/ui/pages/home/mes/mes_device_task/setting/mes_device_task_setting_controller.dart';
import 'package:get/get.dart';


///生产 设备对应生产派工单 - 参数设置
class MesDeviceTaskSettingBinding implements Bindings{
  @override
  void dependencies() {
    Get.put<MesDeviceTaskSettingController>(MesDeviceTaskSettingController());
  }

}