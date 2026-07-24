import 'package:basement/model.dart';
import 'package:basement/repository.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';


///公用服务类,主要存放常用数据
///此服务是在login登录之后才初始化,对应AppService是在login登录之前的公用服务
class DataService extends GetxService {

  ///注册公司名称
  String companyName = '宁波宏佳软件公司';

  String softwareName = '车间工作台';

  ///client.config中appSettings参数
  Map<String, dynamic> clientSettings = {};

  /// 自由项列表
  Map<String, UserDefEntity> userDefMap = {};

  ///AccInformation系统参数列表 该数据源来自 desktop 模块下的系统参数列表数据
  ///
  ///会有部分系统参数需要通过 FormRepository().getSystemAttribute() 来获取，这些数据在各自页面单独去获取
  Map<String, AccInformationEntity> accInformationMap = {};

  ///是否启用操作权限限制
  bool get isEnableOperatePrivilege => clientSettings['isEnableOperatePrivilege'] == 'true';


  @override
  void onInit() {
    super.onInit();
    _initService();
  }

  ///系统初始化工作
  Future<void> _initService() async {

    ///获取公司名称
    var res1 = await ClientRepository().getSystemName();
    if (res1.isSuccess){
      companyName = res1.data;
    }
    var res2 = await ClientRepository().getSystemName(key:'SystemName');
    if (res2.isSuccess){
      softwareName = res2.data;
    }
    String softName = ShareStorageUtil.personal?.read<String>(SharedPreferencesKeys.SOFTWARE_NAME_KEY) ?? '';
    if(softwareName != softName) {
      ShareStorageUtil.personal?.write(SharedPreferencesKeys.SOFTWARE_NAME_KEY, softwareName);
    }

    ///客户端设置参数列表
    ///如果需要考虑不同的语言状态，需要指定不同的name,默认读取的是client.config中的配置
    var result  = await ClientRepository().getSettings(configName: 'desktop');
    if(!result.isSuccess){
      ToastNotification(Get.overlayContext!).error('获取客户端配置文件中AppSettings参数失败！${result.message}');
      return;
    }
    clientSettings.addAll(result.data);


    ///获取自由项 Map类型
    await userDefInit();

    await accInformationInit();

  }

  ///获取自由项
  Future<void> userDefInit() async{
    userDefMap = {};
    var res = await UserDefRepository().getList('');
    if (res.isSuccess && res.data.isNotEmpty) {
      for (var element in res.data) {
        userDefMap[element.dicDbName ?? ''] = element;
      }
    }
  }

  Future<void> accInformationInit() async{
    accInformationMap = {};
    var res = await AccInformationRepository().getList('desktop');
    if (res.isSuccess && res.data.isNotEmpty){
      for (var element in res.data){
        accInformationMap[element.itemCode ?? ''] = element;
      }
    }
  }

}