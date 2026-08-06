import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// 扫码枪全局状态管理服务
class ScanGunService extends GetxService {
  static ScanGunService get to => Get.find();

  /// 控制扫码框重新打开的全局状态
  /// 每次取反触发监听
  final RxBool needReopenScanGun = false.obs;

  /// 触发重新打开扫码框
  void triggerReopen() {
    needReopenScanGun.value = !needReopenScanGun.value;
    debugPrint('ScanGunService: 触发重新打开扫码框');
  }
}