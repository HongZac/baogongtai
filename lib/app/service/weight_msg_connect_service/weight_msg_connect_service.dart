import 'package:desktop/app/model/choice_chip_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_model.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_setting/weight_msg_connect_setting_controller.dart';
import 'package:desktop/app/service/weight_msg_connect_service/weight_msg_connect_setting/weight_msg_connect_setting_view.dart';
import 'package:desktop/app/ui/pages/home/setting/overall_setting_controller.dart';
import 'package:desktop/app/utils/dialog_utils.dart';
import 'package:desktop/app/utils/toast_notification.dart';
import 'package:get/get.dart';
import 'package:basement/utils.dart';
import 'package:desktop/app/utils/shared_preferences_keys.dart';


///称重消息接收服务 ShareStorageUtil.instance 初始化之后再 put
class WeightMsgConnectService extends GetxService{

  ///称重数据接收列表 (这里只初始化列表，在打开报工页面时才打开服务)
  final List<WeightMsgConnectModel> connectList = [];

  ///电子秤（称重重量）
  static const String dSEBWeight = 'device-submit-eBWeight';
  ///电子秤（报单重的称重重量）
  static const String dSEBWeightForWeightSubmitType = 'device-submit-eBWeight-for-weightSubmitType';
  ///电子秤（单箱皮重）
  static const String dSPackingWeight = 'device-submit-packingWeight';
  ///电子秤（单箱重量）
  static const String dSSingleBoxWeight = 'device-submit-singleBoxWeight';
  ///电子秤（尾箱重量）
  static const String dSLastBoxWeight = 'device-submit-lastBoxWeight';
  ///电子秤（报工总重）
  static const String dSWeight = 'device-submit-weight';
  ///扫码枪
  static const String scanGun = 'scan-gun';
  ///读卡器
  static const String cardReader = 'card-reader';

  @Deprecated('计划换个命名')
  late final List<ChoiceChipModel> weightMsgList = [
    ChoiceChipModel(keyName: dSEBWeight, title: '电子秤（称重重量）'),
    ChoiceChipModel(keyName: dSEBWeightForWeightSubmitType, title: '电子秤（报单重的称重重量）'),
    ChoiceChipModel(keyName: dSPackingWeight, title: '电子秤（单箱皮重）'),
    ChoiceChipModel(keyName: dSSingleBoxWeight, title: '电子秤（单箱重量）'),
    ChoiceChipModel(keyName: dSLastBoxWeight, title: '电子秤（尾箱重量）'),
    ChoiceChipModel(keyName: dSWeight, title: '电子秤（报工总重）'),
    ChoiceChipModel(keyName: scanGun, title: '扫码枪'),
    ChoiceChipModel(keyName: cardReader, title: '读卡器'),
  ];

  @override
  void onInit() {
    super.onInit();
    connectList.clear();
    var _list = ShareStorageUtil.instance?.read(SharedPreferencesKeys.CONNECTLIST_KEY) ?? [];
    if (_list.isNotEmpty){
      _list.forEach((element){
        WeightMsgConnectModel model = WeightMsgConnectModel.fromJson(element);
        connectList.add(model);
      });
    }
  }

  ///主机端口修改
  Future<void> setting(String key) async {
    WeightMsgConnectModel _model = connectList.firstWhere(
            (element) => element.key == key, orElse: () => WeightMsgConnectModel(key: key, host: '', port: 0, accuracy: 0, com: ''));
    var _dialogRes = await DialogUtils.showCustomDialog<WeightMsgConnectSettingController, bool>(
      Get.context!, title: '端口号设置：',
      initialHeight: 500,
      initialWidth: 900,
      barrierDismissible: false,
      content: WeightMsgConnectSettingView(),
      controller: WeightMsgConnectSettingController(weightMsgConnectModel: _model),
    );
    if (_dialogRes == null || !_dialogRes){
      return;
    }
    try {
      var ctl = Get.find<OverallSettingController>();
      ctl.update();
    } catch (e){}
    ToastNotification(Get.overlayContext!).success("修改成功！");
  }

  ///删除指定端口号
  Future<void> delete(String key) async{
    var _dialogRes = await DialogUtils.showConfirmationDialog(
      Get.context!, msg: '确认删除？',
      barrierDismissible: false,
    );
    if (_dialogRes == null || !_dialogRes){
      return;
    }
    connectList.removeWhere((element) => element.key == key);
    List<Map<String, dynamic>> _saveList = [];
    connectList.forEach((element) {
      _saveList.add(element.toJson());
    });
    ShareStorageUtil.instance?.write(SharedPreferencesKeys.CONNECTLIST_KEY, _saveList);
    try {
      var ctl = Get.find<OverallSettingController>();
      ctl.update();
    } catch (e){}
    ToastNotification(Get.overlayContext!).success("删除成功！");
  }

  String getFormatValue(
      String value, {
        bool isWeightMsgReverseOrder = false,
        bool isNum = true,
  }){
    ///new RegExp(r'[\s\r\n+\-a-zA-Z]')
    value = value.replaceAll(RegExp(r'[^0-9.]'), ''); ///移除非数字或小数点
    if (isWeightMsgReverseOrder){
      value = value.split('').reversed.join('');
    }
    if (isNum){
      int point = 0;
      List<String> list = value.split('.');
      if (list.length == 2){
        point = list[1].length;
      }
      //value = NumFormatUtil.qtyFormatConverter(value, decimal: point);
      value = num.tryParse(value)?.toStringAsFixed(point) ?? '';
    }
    return value;
  }

  ///判断指定两个值的差值是否在可接受误差范围内
  ///
  /// [True]：小于可接受误差值（在可接受误差范围内）；
  /// [False]：大于可接受误差值；
  ///
  /// [oldValue]：需要判断的旧值
  ///
  /// [value]：需要判断的新值
  ///
  /// [errorRange]：误差值
  bool isWithinAcceptableErrorRange({
    required double? oldValue,
    required double value,
    required double errorRange,
  }) {
    if (oldValue == null){
      return false;
    }
    bool boolValue = (oldValue - value).abs() < errorRange;
    if (boolValue){
      PrintUtil.printDebug('小于可接受误差值($errorRange)：old: $oldValue; new: $value');
    }
    return boolValue;
  }


}


