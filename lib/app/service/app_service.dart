
import 'package:event_bus/event_bus.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

///公用服务类,
///此服务是在login登录前已经初始化,对应DataService是在login登录之后的公用服务
class AppService extends GetxService{

  late Future<void> init;

  final EventBus eventBus = EventBus();

  late final String versionCode;
  late final String versionName;


  @override
  void onInit() {
    super.onInit();
    init = _initFunc();
  }

  ///系统初始化工作
  Future<void> _initFunc() async {
    ///获取版本信息
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionCode = packageInfo.buildNumber.isEmpty ? '0' : packageInfo.buildNumber;
    versionName = packageInfo.version;
  }
}